//
//  TWSeriesHeaders.h
//  TweryTok — декларации классов TikTok IM-стека для фичи Auto Streak.
//
//  ВАЖНО (research-статус, шаг 3B):
//  Ни один из этих классов НЕ подтверждён дампом декриптованного бинарника
//  (в TikTokHeaders.h TweakiTok IM-стек отсутствует; публичных дампов
//  MusicallyCore с IM-классами найдено не было — все "streak" -тулы на GitHub
//  работают через web/Selenium и IM-API не трогают).
//  Сигнатуры реконструированы по конвенциям именования AWE*/TT* и по
//  единственному подтверждённому в TweakiTok IM-классу:
//    AWEIMMessageDataController — p_markReadSyncToServerWithMessage: (подтверждено, 46.5.0)
//    TIMInputStatusManager      — sendInputStatusWithConversationID:inputStatus: (подтверждено, 46.5.0)
//  ВСЕ вызовы в TWSeriesManager защищены: NSClassFromString + respondsToSelector
//  + @try/@catch. Если класса нет — тихий no-op, приложение не падает.
//
//  Для подтверждения сигнатур на устройстве: frida/tw_research.js в этом репо.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Conversations (НЕ ПОДТВЕРЖДЕНО)

// Модель беседы в списке чатов. Ожидается в списке результатов inbox-запроса.
@interface AWEIMConversationInfo : NSObject
@property (nonatomic, copy, readonly) NSString *conversationId;        // ID беседы (НЕ ПОДТВЕРЖДЕНО)
@property (nonatomic, copy, readonly) NSString *conversationShortId;   // (НЕ ПОДТВЕРЖДЕНО)
@property (nonatomic, assign, readonly) BOOL isInbox;                  // виден в списке (НЕ ПОДТВЕРЖДЕНО)
// Streak-механика: TikTok хранит факт активной серии по-разному в разных версиях.
// Кандидаты (все НЕ ПОДТВЕРЖДЕНО, поиск через respondsToSelector в рантайме):
//   - streakInfo / streak / flameInfo / streakActive / isStreak
//   - bizData (словарь) с ключами streak_* / flame_*
@property (nonatomic, copy, readonly) NSDictionary *bizData;           // универсальный словарь (НЕ ПОДТВЕРЖДЕНО)
@end

// Класс-клиент списка бесед. Кандидаты имени: AWEIMConversationListService /
// AWEIMConversationManager / IMKitConversationStore — резолвим все по очереди.
#pragma mark - Sticker / Emoticon (НЕ ПОДТВЕРЖДЕНО)

// Модель стикера.
@interface AWEIMEmoticonInfo : NSObject
@property (nonatomic, copy, readonly) NSString *emoticonId;   // (НЕ ПОДТВЕРЖДЕНО)
@property (nonatomic, copy, readonly) NSString *imageURL;     // (НЕ ПОДТВЕРЖДЕНО)
@end

#pragma mark - Отправка сообщения (НЕ ПОДТВЕРЖДЕНО)

// Класс-отправитель. Кандидаты: AWEIMMessageSendService / IMKitSendMessage /
// AWEIMSendService — резолвим по очереди, дергаем селекторы-кандидаты:
//   sendMessageWithConversationId:content:
//   sendStickerWithConversationId:stickerId:
//   sendEmoticonWithConversationId:emoticonId:
