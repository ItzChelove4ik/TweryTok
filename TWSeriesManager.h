#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//
// TWSeriesManager — движок «Автопродление серии» (фича 1, TweryTok).
//
// Архитектура (всё defensive — классы TikTok IM-стека не подтверждены дампом):
//  1. Список чатов: рантайм-резолв класса-провайдера по списку кандидатов,
//     чтение массива бесед KVC-путями, streak-детект по цепочке селекторов-кандидатов.
//  2. Отправка: рантайм-резолв sender-класса, вызов селекторов-кандидатов.
//  3. Расписание: NSTimer в foreground + catch-up при didBecomeActive.
//  4. Анти-спам: 1 отправка/чат/сутки (NSUserDefaults), джиттер ±3 мин, задержки 2-8 с между чатами.
//
@interface TWSeriesManager : NSObject

+ (instancetype)shared;

// Вызывается из AppDelegate didFinishLaunching + applicationDidBecomeActive
- (void)start;
- (void)stop;

// Catch-up: если время X уже прошло сегодня и не всё отправлено — отправить сейчас
- (void)checkAndCatchUp;

// Диагностика: логирует найденные IM-классы/селекторы в Console (для research)
- (void)logStreakDiagnostics;

// Ручная отправка (для теста из настроек)
- (void)sendNow;

// Статистика для UI настроек: сколько чатов попадёт в следующую отправку
- (NSInteger)eligibleConversationCount;
- (nullable NSDate *)nextFireDate;

@end

NS_ASSUME_NONNULL_END
