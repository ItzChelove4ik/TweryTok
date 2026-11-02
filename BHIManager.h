#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BHIManager: NSObject
+ (instancetype)sharedManager;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
+ (BOOL)hideAds;
+ (BOOL)downloadButton;
+ (BOOL)downloadCoverImage;
+ (BOOL)shareSheet;
+ (BOOL)removeWatermark;
+ (BOOL)hideElementButton;
+ (BOOL)uploadRegion;
+ (BOOL)autoPlay;
+ (BOOL)stopPlay;
+ (BOOL)progressBar;
+ (BOOL)showUsername;
+ (BOOL)disablePullToRefresh;
+ (BOOL)disableUnsensitive;
+ (BOOL)disableWarnings;
+ (BOOL)disableLive;
+ (BOOL)skipRecommendations;
+ (BOOL)likeConfirmation;
+ (BOOL)likeCommentConfirmation;
+ (BOOL)dislikeCommentConfirmation;
+ (BOOL)followConfirmation;
+ (BOOL)followStatusBadge;
+ (BOOL)profileSave;
+ (BOOL)profileCopy;
+ (BOOL)profileVideoCount;
+ (BOOL)videoLikeCount;
+ (BOOL)videoUploadDate;
+ (BOOL)regionChangingEnabled;
+ (NSDictionary *)selectedRegion;
+ (BOOL)fakeChangesEnabled;
+ (BOOL)fakeVerified;
+ (BOOL)disableScreenshotDetection;
+ (void)showSaveVC:(id)item;
+ (void)cleanCache;
+ (BOOL)isEmpty:(NSURL *)url;
+ (NSString *)getDownloadingPersent:(float)per;
+ (void)saveMedia:(id)item fileExtension:(id)fileExtension;
+ (BOOL)isTurkish;
+ (NSString *)localizedString:(NSString *)en tr:(NSString *)tr;

+ (BOOL)showRegionChangeOption;

#pragma mark - Auto Streak (TweryTok)
+ (BOOL)streakAutoSendEnabled;
+ (NSInteger)streakSendHour;
+ (NSInteger)streakSendMinute;
+ (NSString *)streakTimeZoneIdentifier;   // default Europe/Moscow
+ (NSString *)streakStickerID;            // default: TikTok default sticker id
+ (NSArray<NSString *> *)streakExcludedConversations;
+ (NSDictionary *)streakLastSentDates;    // conversationId -> ISO date string (day)
+ (void)setStreakLastSentDate:(NSString *)convId;

#pragma mark - Like Color (TweryTok)
+ (BOOL)likeColorEnabled;
+ (NSString *)likeColorHex;               // nil = reset to default
+ (UIColor *)likeColor;
@end
