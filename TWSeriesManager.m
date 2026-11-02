#import "TWSeriesManager.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#import <objc/runtime.h>
#import "BHIManager.h"
#import "TWSeriesHeaders.h"

// ============================================================================
// TWSeriesManager — реализация. ВЕСЬ TikTok-код defensive (research-статус:
// классы IM-стека не подтверждены — см. TWSeriesHeaders.h и frida/tw_research.js).
// ============================================================================

static NSTimer *twStreakTimer = nil;

// Кандидаты класса-провайдера списка бесед (по порядку приоритета)
static NSArray<NSString *> *twConversationProviderCandidates() {
    return @[
        @"AWEIMConversationListService",
        @"AWEIMConversationManager",
        @"AWEIMConversationService",
        @"AWEIMDataService",
        @"AWEIMEngine",
        @"IMKitConversationStore",
    ];
}

// Кандидаты класса-отправителя сообщений
static NSArray<NSString *> *twMessageSenderCandidates() {
    return @[
        @"AWEIMMessageSendService",
        @"IMKitSendMessage",
        @"AWEIMSendService",
        @"AWEIMMessageService",
        @"AWEIMMessageDataController",
    ];
}

// Селекторы-кандидаты «получить список бесед» (инстанс-методы без аргументов)
static NSArray<NSString *> *twConversationListSelectors() {
    return @[
        @"allConversations",
        @"conversationList",
        @"conversations",
        @"inboxConversationList",
        @"getConversationList",
        @"fetchAllConversations",
    ];
}

// Селекторы-кандидаты «есть ли у беседы активная серия»
static NSArray<NSString *> *twStreakCheckSelectors() {
    return @[
        @"isStreakActive",
        @"streakActive",
        @"hasStreak",
        @"hasFlame",
        @"streakInfo",
        @"flameInfo",
    ];
}

static NSString * const kTWStreakLog = @"[TweryTok/Streak] ";

@implementation TWSeriesManager

+ (instancetype)shared {
    static TWSeriesManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWSeriesManager alloc] init];
    });
    return instance;
}

#pragma mark - Расписание

- (void)start {
    [self stop];
    if (![BHIManager streakAutoSendEnabled]) return;

    [self checkAndCatchUp];
    [self scheduleNextTimer];
}

- (void)stop {
    if (twStreakTimer) {
        [twStreakTimer invalidate];
        twStreakTimer = nil;
    }
}

- (void)scheduleNextTimer {
    [self stop];
    NSDate *fire = [self nextFireDate];
    if (!fire) return;
    NSTimeInterval interval = [fire timeIntervalSinceNow];
    if (interval < 0) interval = 1.0;
    if (interval > 86400.0) interval = 86400.0;
    twStreakTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                     target:self
                                                   selector:@selector(timerFired:)
                                                   userInfo:nil
                                                    repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:twStreakTimer forMode:NSRunLoopCommonModes];
    NSLog(@"%@scheduled next send at %@ (%.0f sec)", kTWStreakLog, fire, interval);
}

- (void)timerFired:(NSTimer *)t {
    [self sendNow];
    [self scheduleNextTimer];
}

// Следующий момент срабатывания: сегодня HH:MM (TZ) если ещё не прошло и не всё отправлено,
// иначе завтра. С джиттером ±180 сек.
- (NSDate *)nextFireDate {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];

    NSDateComponents *today = [cal componentsInTimeZone:[NSTimeZone timeZoneWithName:[BHIManager streakTimeZoneIdentifier]] fromDate:now];
    today.hour = [BHIManager streakSendHour];
    today.minute = [BHIManager streakSendMinute];
    today.second = 0;
    NSDate *todayFire = [cal dateFromComponents:today];

    BOOL alreadySentToday = [self lastRunDay] != nil;
    if (todayFire && [todayFire timeIntervalSinceNow] > 0) {
        return [self addJitter:todayFire];
    }
    if (alreadySentToday) {
        // сегодня уже отработали (или время уже прошло до запуска и catch-up сделал дело) — завтра
        NSDate *tomorrow = [todayFire dateByAddingTimeInterval:86400];
        return [self addJitter:tomorrow];
    }
    return [self addJitter:todayFire];
}

- (NSDate *)addJitter:(NSDate *)date {
    // ±180 сек — чтобы отправка не была роботически точной
    NSInteger jitter = (arc4random_uniform(361) - 180); // -180...+180
    return [date dateByAddingTimeInterval:jitter];
}

// Дата последнего полного прогона (день), nil если сегодня прогонов не было
- (NSString *)lastRunDay {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"twery_streak_last_run_day"];
}

- (void)setLastRunDay {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    fmt.timeZone = [NSTimeZone timeZoneWithName:[BHIManager streakTimeZoneIdentifier]];
    [[NSUserDefaults standardUserDefaults] setObject:[fmt stringFromDate:[NSDate date]] forKey:@"twery_streak_last_run_day"];
}

#pragma mark - Catch-up

- (void)checkAndCatchUp {
    if (![BHIManager streakAutoSendEnabled]) return;

    // Прошло ли время X сегодня?
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComp = [cal componentsInTimeZone:[NSTimeZone timeZoneWithName:[BHIManager streakTimeZoneIdentifier]] fromDate:now];
    NSInteger minutesNow = nowComp.hour * 60 + nowComp.minute;
    NSInteger minutesTarget = [BHIManager streakSendHour] * 60 + [BHIManager streakSendMinute];

    if (minutesNow >= minutesTarget && [self lastRunDay] == nil) {
        NSLog(@"%@catch-up: time passed, sending now", kTWStreakLog);
        [self sendNow];
    }
}

#pragma mark - Список бесед (defensive runtime)

// Возвращает NSArray<id> моделей бесед (или nil — если классы не найдены)
- (NSArray *)fetchConversations {
    for (NSString *className in twConversationProviderCandidates()) {
        Class cls = NSClassFromString(className);
        if (!cls) continue;

        id instance = [cls respondsToSelector:@selector(sharedInstance)] ? [cls performSelector:@selector(sharedInstance)]
                       : [cls respondsToSelector:@selector(sharedManager)] ? [cls performSelector:@selector(sharedManager)]
                       : [cls respondsToSelector:@selector(defaultInstance)] ? [cls performSelector:@selector(defaultInstance)]
                       : nil;
        if (!instance) continue;

        for (NSString *sel in twConversationListSelectors()) {
            if ([instance respondsToSelector:NSSelectorFromString(sel)]) {
                @try {
                    id result = [instance performSelector:NSSelectorFromString(sel)];
                    if ([result isKindOfClass:[NSArray class]] && [(NSArray *)result count] > 0) {
                        NSLog(@"%@provider: %@ instance via %@ -> %@ (%lu items)",
                              kTWStreakLog, className, instance ? @"shared" : @"?", sel, (unsigned long)[(NSArray *)result count]);
                        return result;
                    }
                } @catch (NSException *e) {
                    NSLog(@"%@selector %@ on %@ threw: %@", kTWStreakLog, sel, className, e);
                }
            }
        }
    }
    NSLog(@"%@no conversation provider resolved (classes not found in this TikTok version)", kTWStreakLog);
    return nil;
}

// Проверка: активна ли серия у беседы. Defensive: перебор селекторов-кандидатов.
- (BOOL)conversationHasStreak:(id)conversation {
    // 1. Прямые селекторы
    for (NSString *sel in twStreakCheckSelectors()) {
        if ([conversation respondsToSelector:NSSelectorFromString(sel)]) {
            @try {
                id v = [conversation performSelector:NSSelectorFromString(sel)];
                if ([v isKindOfClass:[NSNumber class]] && [(NSNumber *)v boolValue]) return YES;
                if (v != nil && ![v isKindOfClass:[NSNull class]]) return YES; // streakInfo/flameInfo объект
            } @catch (__unused NSException *e) {}
        }
    }
    // 2. KVC-поля
    for (NSString *key in @[@"streakInfo", @"streak", @"flameInfo", @"flame", @"streakActive"]) {
        @try {
            id v = [conversation valueForKey:key];
            if ([v isKindOfClass:[NSNumber class]] && [(NSNumber *)v boolValue]) return YES;
            if ([v isKindOfClass:[NSDictionary class]] && [(NSDictionary *)v count] > 0) return YES;
            if (v && ![v isKindOfClass:[NSNull class]]) return YES;
        } @catch (__unused NSException *e) {}
    }
    // 3. bizData-словарь с ключами streak_*
    @try {
        id biz = [conversation respondsToSelector:@selector(bizData)] ? [conversation performSelector:@selector(bizData)] : nil;
        if ([biz isKindOfClass:[NSDictionary class]]) {
            for (NSString *k in [(NSDictionary *)biz allKeys]) {
                if ([k.lowercaseString containsString:@"streak"] || [k.lowercaseString containsString:@"flame"]) {
                    return YES;
                }
            }
        }
    } @catch (__unused NSException *e) {}
    return NO;
}

// ID беседы (defensive)
- (NSString *)conversationIdOf:(id)conversation {
    for (NSString *key in @[@"conversationId", @"conversationID", @"conversationShortId", @"convId", @"shortId", @"infoId"]) {
        @try {
            id v = [conversation valueForKey:key];
            if ([v isKindOfClass:[NSString class]] && [(NSString *)v length] > 0) return v;
        } @catch (__unused NSException *e) {}
    }
    return nil;
}

#pragma mark - Отправка (defensive runtime)

- (BOOL)sendStickerToConversationId:(NSString *)convId {
    NSString *stickerId = [BHIManager streakStickerID];
    for (NSString *className in twMessageSenderCandidates()) {
        Class cls = NSClassFromString(className);
        if (!cls) continue;
        id instance = [cls respondsToSelector:@selector(sharedInstance)] ? [cls performSelector:@selector(sharedInstance)]
                       : [cls respondsToSelector:@selector(sharedManager)] ? [cls performSelector:@selector(sharedManager)]
                       : nil;
        if (!instance) continue;

        // Кандидаты селекторов отправки стикера (2 арг: convId, stickerId)
        NSArray<NSString *> *stickerSelectors = @[
            @"sendStickerWithConversationId:stickerId:",
            @"sendEmoticonWithConversationId:emoticonId:",
            @"sendSticker:toConversation:",
            @"sendStickerMessage:conversationId:",
            // fallback — текст-сообщение со стикером-эмодзи 🔥 (если стикер-API нет, текст с эмодзи тоже продлевает серию)
            @"sendMessageWithConversationId:content:",
            @"sendTextMessage:toConversationId:",
        ];
        for (NSString *sel in stickerSelectors) {
            SEL s = NSSelectorFromString(sel);
            if ([instance respondsToSelector:s]) {
                @try {
                    // 2-аргументный вызов через NSInvocation
                    NSMethodSignature *sig = [instance methodSignatureForSelector:s];
                    if (sig.numberOfArguments == 3 || sig.numberOfArguments == 4) {
                        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
                        [inv setTarget:instance];
                        [inv setSelector:s];
                        id arg1 = convId;
                        id arg2 = stickerId;
                        [inv setArgument:&arg1 atIndex:2];
                        [inv setArgument:&arg2 atIndex:3];
                        [inv invoke];
                        NSLog(@"%@sent via %@ %@ -> %@", kTWStreakLog, className, sel, convId);
                        return YES;
                    }
                } @catch (NSException *e) {
                    NSLog(@"%@send attempt %@ %@ threw: %@", kTWStreakLog, className, sel, e);
                }
            }
        }
    }
    NSLog(@"%@no message sender resolved for conversation %@", kTWStreakLog, convId);
    return NO;
}

#pragma mark - Прогон

- (void)sendNow {
    if (![BHIManager streakAutoSendEnabled]) return;

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSArray *conversations = [self fetchConversations];
        if (!conversations) {
            NSLog(@"%@sendNow: no conversations available (IM classes unresolved)", kTWStreakLog);
            return;
        }

        NSArray<NSString *> *excluded = [BHIManager streakExcludedConversations] ?: @[];
        NSDictionary *lastSent = [BHIManager streakLastSentDates];
        NSDateFormatter *dayFmt = [[NSDateFormatter alloc] init];
        dayFmt.dateFormat = @"yyyy-MM-dd";
        dayFmt.timeZone = [NSTimeZone timeZoneWithName:[BHIManager streakTimeZoneIdentifier]];
        NSString *todayStr = [dayFmt stringFromDate:[NSDate date]];

        NSMutableArray<NSString *> *targets = [NSMutableArray array];
        for (id conv in conversations) {
            NSString *convId = [self conversationIdOf:conv];
            if (!convId) continue;
            if ([excluded containsObject:convId]) continue;
            if ([lastSent[convId] isEqualToString:todayStr]) continue; // уже отправляли сегодня
            if (![self conversationHasStreak:conv]) continue;
            [targets addObject:convId];
        }

        NSLog(@"%@sendNow: %lu eligible conversations (of %lu total, %lu excluded)",
              kTWStreakLog, (unsigned long)targets.count, (unsigned long)conversations.count, (unsigned long)excluded.count);

        // Случайные задержки 2-8 сек между чатами (анти-спам паттерн)
        for (NSUInteger i = 0; i < targets.count; i++) {
            NSString *convId = targets[i];
            NSUInteger delay = 2 + arc4random_uniform(7); // 2...8
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BOOL ok = [self sendStickerToConversationId:convId];
                if (ok) {
                    [BHIManager setStreakLastSentDate:convId];
                }
            });
        }

        [self setLastRunDay];
    });
}

#pragma mark - Статистика и диагностика

- (NSInteger)eligibleConversationCount {
    NSArray *conversations = [self fetchConversations];
    if (!conversations) return 0;
    NSArray<NSString *> *excluded = [BHIManager streakExcludedConversations] ?: @[];
    NSDictionary *lastSent = [BHIManager streakLastSentDates];
    NSDateFormatter *dayFmt = [[NSDateFormatter alloc] init];
    dayFmt.dateFormat = @"yyyy-MM-dd";
    dayFmt.timeZone = [NSTimeZone timeZoneWithName:[BHIManager streakTimeZoneIdentifier]];
    NSString *todayStr = [dayFmt stringFromDate:[NSDate date]];

    NSInteger count = 0;
    for (id conv in conversations) {
        NSString *convId = [self conversationIdOf:conv];
        if (!convId || [excluded containsObject:convId]) continue;
        if ([lastSent[convId] isEqualToString:todayStr]) continue;
        if (![self conversationHasStreak:conv]) continue;
        count++;
    }
    return count;
}

- (void)logStreakDiagnostics {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSLog(@"%@=== DIAGNOSTICS ===", kTWStreakLog);
        NSLog(@"%@provider candidates found:", kTWStreakLog);
        for (NSString *cn in twConversationProviderCandidates()) {
            Class c = NSClassFromString(cn);
            NSLog(@"%@  %@ -> %@", kTWStreakLog, cn, c ? @"EXISTS" : @"not found");
        }
        NSLog(@"%@sender candidates found:", kTWStreakLog);
        for (NSString *cn in twMessageSenderCandidates()) {
            Class c = NSClassFromString(cn);
            NSLog(@"%@  %@ -> %@", kTWStreakLog, cn, c ? @"EXISTS" : @"not found");
        }
        // Сканируем runtime на любые IM/streak классы
        int found = 0;
        // objc_getClassList скан
        unsigned int classCount = 0;
        Class *classes = objc_copyClassList(&classCount);
        if (classes) {
            for (unsigned int i = 0; i < classCount; i++) {
                NSString *name = NSStringFromClass(classes[i]);
                if ([name containsString:@"Streak"] || [name containsString:@"Flame"]) {
                    NSLog(@"%@  RUNTIME: %@", kTWStreakLog, name);
                    found++;
                }
            }
            free(classes);
        }
        NSLog(@"%@=== END (%d streak-named classes) ===", kTWStreakLog, found);
    });
}

@end

#pragma clang diagnostic pop
