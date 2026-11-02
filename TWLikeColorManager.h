#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//
// TWLikeColorManager — перекраска лайк-иконок и анимации (фича 2, TweryTok).
//
// Исследованные цели (по TikTokHeaders.h / известным конвенциям TikTok):
//  - AWEPlayInteractionLikeElement (ПОДТВЕРЖДЕНО в TikTokHeaders.h:48, селектор buttonClicked)
//    — кнопка лайка в фиде. Само сердце-изображение грузится через [UIImage imageNamed:]
//    с ассетами вида "icon_like_*" / "aweme_like_*" (НЕ ПОДТВЕРЖДЕНО — точные имена ассетов
//    зависят от версии; ловим списком паттернов).
//  - CAEmitterCell (системный класс, ПОДТВЕРЖДЕНО существованием): анимация сердечек
//    при даблтапе у TikTok — эмиттер с красными частицами. Хукаем установку color.
//  - CALayer backgroundColor для оверлея большого сердца при даблтапе (системный).
//
@interface TWLikeColorManager : NSObject

+ (instancetype)shared;

// Должен ли быть применён кастомный цвет
+ (BOOL)active;
// Перекрашенное изображение (кэш по systemImageNamed+color)
+ (nullable UIImage *)tintedImageForName:(NSString *)name;

// Подходящее ли это имя ассета для перекраски (только лайк-ассеты!)
+ (BOOL)isLikeAssetName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
