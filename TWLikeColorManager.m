#import "TWLikeColorManager.h"
#import "BHIManager.h"

// ============================================================================
// TWLikeColorManager — реализация.
//
// КРИТИЧНО ДИЗАЙН-РЕШЕНИЕ (conservative): НЕ глобальный свиззл imageNamed:.
// Глобальный свиззл UIImage imageNamed: затронул бы ВСЕ иконки приложения и
// сломал тему/кэш TikTok. Вместо этого:
//   1. Хук imageNamed: в Tweak.x проверяет isLikeAssetName: (белый список
//      паттернов лайк-ассетов) и только тогда подменяет картинку.
//   2. Перекраска — с template-рендерингом и tintColor, оригинальная форма
//      (маска) сохраняется.
//   3. CAEmitterCell.color (системный селектор, 100% стабилен) перекрашивает
//      частицы даблтап-анимации — только если включен кастомный цвет и
//      исходный цвет "лайковый" (красно-розовая гамма) — защита от чужих эмиттеров.
// ============================================================================

static NSString * const kTWLikeLog = @"[TweryTok/LikeColor] ";

@implementation TWLikeColorManager

+ (instancetype)shared {
    static TWLikeColorManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWLikeColorManager alloc] init];
    });
    return instance;
}

+ (BOOL)active {
    return [BHIManager likeColorEnabled] && [BHIManager likeColor] != nil;
}

// Белый список лайк-ассетов. Паттерны подобраны по конвенциям TikTok
// (icon_*_like, aweme_like, digg — «digg» это внутреннее имя лайка TikTok).
// Если ничего не совпало — НЕ трогаем: остальной UI остаётся оригинальным.
+ (BOOL)isLikeAssetName:(NSString *)name {
    if (name.length < 4) return NO;
    NSString *n = name.lowercaseString;
    NSArray<NSString *> *patterns = @[
        @"like", @"digg", @"heart", @"praise",
    ];
    // Только иконки, не бэкграунды/панели: отсекаем широкие контейнеры
    NSArray<NSString *> *negative = @[
        @"likelist", @"likedlist", @"like_list", @"dislike_list", @"likelist",
        @"heartbeats", @"heartsound",
    ];
    for (NSString *bad in negative) {
        if ([n containsString:bad]) return NO;
    }
    for (NSString *p in patterns) {
        if ([n containsString:p]) return YES;
    }
    return NO;
}

+ (UIImage *)tintedImageForName:(NSString *)name {
    if (![self active]) return nil;
    // РЕКУРСИОННЫЙ СТРАЖ: [UIImage imageNamed:] ниже — это хукнутый метод, который
    // снова вызовет tintedImageForName: для того же имени. Без стража — бесконечная
    // рекурсия и stack overflow (краш приложения). Это был баг краша на запуске.
    static BOOL sInTint = NO;
    if (sInTint) return nil;  // вложенный вызов — не перекрашиваем, выходим
    sInTint = YES;
    UIImage *original = nil;
    @try {
        original = [UIImage imageNamed:name];
    } @finally {
        sInTint = NO;
    }
    if (!original) return nil;

    // template-рендеринг: маска формы + заливка цветом
    UIImage *template = [original imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(original.size, NO, original.scale);
    [[BHIManager likeColor] setFill];
    [template drawInRect:CGRectMake(0, 0, original.size.width, original.size.height)];
    UIImage *tinted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tinted;
}

@end
