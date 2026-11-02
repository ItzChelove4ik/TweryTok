#import "BHIManager.h"
#import "TikTokHeaders.h"

@implementation BHIManager
+ (instancetype)sharedManager {
    static BHIManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[BHIManager alloc] init];
    });
    return shared;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        Class toastCls = NSClassFromString(@"AWEToast");
        if (error == nil) {
            NSLog(@"[TweryTok] Photo saved to Camera Roll successfully.");
            if ([toastCls respondsToSelector:@selector(showSuccess:)]) {
                [toastCls showSuccess:[BHIManager isTurkish] ? @"Fotoğraf Kaydedildi" : @"Photo Saved"];
            }
        } else {
            NSLog(@"[TweryTok] Error saving photo to Camera Roll: %@", error);
            if ([toastCls respondsToSelector:@selector(showError:)]) {
                [toastCls showError:[BHIManager isTurkish] ? @"Fotoğraf Kaydedilemedi" : @"Failed to Save Photo"];
            }
        }
    });
}
+ (BOOL)hideAds {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"hide_ads"] == nil) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_ads"];
}
+ (BOOL)downloadCoverImage {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"download_cover_image"] == nil) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"download_cover_image"];
}
+ (BOOL)downloadButton {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"download_button"] == nil) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"download_button"];
}
+ (BOOL)shareSheet {
     return [[NSUserDefaults standardUserDefaults] boolForKey:@"share_sheet"];
}
+ (BOOL)removeWatermark {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"remove_watermark"] == nil) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_watermark"];
}
+ (BOOL)hideElementButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_elements_button"];
}
+ (BOOL)uploadRegion {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"upload_region"];
}
+ (BOOL)autoPlay {
    return NO;
}
+ (BOOL)stopPlay {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"stop_play"];
}
+ (BOOL)progressBar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"show_porgress_bar"];
}
+ (BOOL)showUsername {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"show_username"];
}
+ (BOOL)disablePullToRefresh {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"pull_to_refresh"];
}
+ (BOOL)disableUnsensitive {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_unsensitive"];
}
+ (BOOL)disableWarnings {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_warnings"];
}
+ (BOOL)disableLive {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_live"];
}
+ (BOOL)skipRecommendations {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"skip_recommnedations"];
}
+ (BOOL)likeConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"like_confirm"];
}
+ (BOOL)likeCommentConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"like_comment_confirm"];
}
+ (BOOL)dislikeCommentConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dislike_comment_confirm"];
}
+ (BOOL)followConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"follow_confirm"];
}
+ (BOOL)followStatusBadge {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"follow_status_badge"] == nil) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"follow_status_badge"];
}
+ (BOOL)profileSave {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"save_profile"];
}
+ (BOOL)profileCopy {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_profile_information"];
}
+ (BOOL)profileVideoCount {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"uploaded_videos"];
}
+ (BOOL)regionChangingEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_region"];
}
+ (BOOL)videoLikeCount {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_like_count"];
}
+ (BOOL)videoUploadDate {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_upload_date"];
}
+ (NSDictionary *)selectedRegion {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"region"];
}
+ (BOOL)fakeChangesEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_fake"];
}
+ (BOOL)fakeVerified {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"fake_verify"];
}
+ (BOOL)disableScreenshotDetection {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_screenshot_detection"];
}
+ (void)cleanCache {
    NSArray <NSURL *> *DocumentFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in DocumentFiles) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"png"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"jpeg"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp3"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"m4a"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
    }
    
    NSArray <NSURL *> *TempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSTemporaryDirectory()] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in TempFiles) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"mov"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"tmp"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"png"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"jpeg"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp3"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"m4a"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file hasDirectoryPath]) {
            if ([BHIManager isEmpty:file]) {
                [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
            }
        }
    }
}
+ (BOOL)isEmpty:(NSURL *)url {
    NSArray *FolderFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    if (FolderFiles.count == 0) {
        return true;
    } else {
        return false;
    }
}
+ (void)showSaveVC:(id)item {
    UIActivityViewController *acVC = [[UIActivityViewController alloc] initWithActivityItems:item applicationActivities:nil];
    if (is_iPad()) {
        acVC.popoverPresentationController.sourceView = topMostController().view;
        acVC.popoverPresentationController.sourceRect = CGRectMake(topMostController().view.bounds.size.width / 2.0, topMostController().view.bounds.size.height / 2.0, 1.0, 1.0);
    }
    [topMostController() presentViewController:acVC animated:true completion:nil];
}
+ (void)saveMedia:(id)newFilePath fileExtension:(id)fileextension {
    NSArray *imageExtensions = @[@"png", @"jpg", @"jpeg", @"gif", @"tiff", @"bmp", @"heif", @"heic", @"svg", @"webp"];
    NSArray *videoExtensions = @[@"mp4", @"mov", @"avi", @"mkv", @"wmv", @"flv", @"webm"];
    NSString *ext = [fileextension lowercaseString];

    NSURL *fileURL = nil;
    NSString *filePath = nil;
    if ([newFilePath isKindOfClass:[NSURL class]]) {
        fileURL = (NSURL *)newFilePath;
        filePath = [fileURL path];
    } else if ([newFilePath isKindOfClass:[NSString class]]) {
        filePath = (NSString *)newFilePath;
        fileURL = [NSURL fileURLWithPath:filePath];
    }

    if (!fileURL && !filePath) {
        NSLog(@"[TweryTok] saveMedia: invalid path");
        return;
    }

    void (^showResultToast)(BOOL, BOOL) = ^(BOOL success, BOOL isVideo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            Class toastCls = NSClassFromString(@"AWEToast");
            if (success) {
                NSString *msg = isVideo ? 
                    ([BHIManager isTurkish] ? @"Video Kaydedildi" : @"Video Saved") :
                    ([BHIManager isTurkish] ? @"Fotoğraf Kaydedildi" : @"Photo Saved");
                if ([toastCls respondsToSelector:@selector(showSuccess:)]) {
                    [toastCls showSuccess:msg];
                }
            } else {
                NSString *msg = isVideo ?
                    ([BHIManager isTurkish] ? @"Video Kaydedilemedi" : @"Failed to Save Video") :
                    ([BHIManager isTurkish] ? @"Fotoğraf Kaydedilemedi" : @"Failed to Save Photo");
                if ([toastCls respondsToSelector:@selector(showError:)]) {
                    [toastCls showError:msg];
                }
            }
        });
    };

    if ([imageExtensions containsObject:ext]) {
        NSData *data = nil;
        if (filePath) {
            data = [NSData dataWithContentsOfFile:filePath];
        }
        if (!data && fileURL) {
            data = [NSData dataWithContentsOfURL:fileURL];
        }

        UIImage *image = nil;
        if (data && data.length > 0) {
            image = [UIImage imageWithData:data];
        }
        if (!image && filePath) {
            image = [UIImage imageWithContentsOfFile:filePath];
        }

        NSData *jpegData = image ? UIImageJPEGRepresentation(image, 1.0) : data;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    if (jpegData && jpegData.length > 0) {
                        PHAssetCreationRequest *req = [PHAssetCreationRequest creationRequestForAsset];
                        [req addResourceWithType:PHAssetResourceTypePhoto data:jpegData options:nil];
                    } else if (fileURL) {
                        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                        [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto fileURL:fileURL options:options];
                    }
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    showResultToast(success, NO);
                }];
            } else {
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                    });
                    showResultToast(YES, NO);
                } else {
                    showResultToast(NO, NO);
                }
            }
        }];
        return;
    }

    if ([videoExtensions containsObject:ext] && fileURL) {
        // Ensure the file on disk has an mp4 extension so PhotoKit doesn't reject it
        NSString *currentExt = [fileURL.pathExtension lowercaseString];
        if (![videoExtensions containsObject:currentExt]) {
            NSString *newPath = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
            [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newPath error:nil];
            filePath = newPath;
            fileURL = [NSURL fileURLWithPath:newPath];
        }

        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                    options.shouldMoveFile = NO;
                    [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypeVideo fileURL:fileURL options:options];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        showResultToast(YES, YES);
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath)) {
                                UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
                                showResultToast(YES, YES);
                            } else {
                                showResultToast(NO, YES);
                            }
                        });
                    }
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
                        showResultToast(YES, YES);
                    } else {
                        showResultToast(NO, YES);
                    }
                });
            }
        }];
        return;
    }
}

+ (NSString *)getDownloadingPersent:(float)per {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    NSNumber *number = [NSNumber numberWithFloat:per];
    return [numberFormatter stringFromNumber:number];
}
+ (BOOL)isTurkish {
    NSString *appLang = [[NSUserDefaults standardUserDefaults] stringForKey:@"current_i18n_language"];
    if (appLang && [appLang hasPrefix:@"tr"]) {
        return YES;
    }
    NSString *appLang2 = [[NSUserDefaults standardUserDefaults] stringForKey:@"app_language"];
    if (appLang2 && [appLang2 hasPrefix:@"tr"]) {
        return YES;
    }
    NSArray *languages = [NSLocale preferredLanguages];
    if (languages.count > 0 && [[languages firstObject] hasPrefix:@"tr"]) {
        return YES;
    }
    return NO;
}

+ (NSString *)localizedString:(NSString *)en tr:(NSString *)tr {
    return [self isTurkish] ? tr : en;
}

+ (BOOL)showRegionChangeOption {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"show_region_change_option"];
}

#pragma mark - Auto Streak (TweryTok)

+ (BOOL)streakAutoSendEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"twery_streak_enabled"];
}
+ (NSInteger)streakSendHour {
    NSInteger h = [[NSUserDefaults standardUserDefaults] integerForKey:@"twery_streak_hour"];
    return (h >= 0 && h <= 23) ? h : 12;  // default 12:00
}
+ (NSInteger)streakSendMinute {
    NSInteger m = [[NSUserDefaults standardUserDefaults] integerForKey:@"twery_streak_minute"];
    return (m >= 0 && m <= 59) ? m : 0;
}
+ (NSString *)streakTimeZoneIdentifier {
    NSString *tz = [[NSUserDefaults standardUserDefaults] stringForKey:@"twery_streak_timezone"];
    if (tz.length == 0) return @"Europe/Moscow";
    // валидация
    NSArray<NSString *> *known = [NSTimeZone performSelector:@selector(knownTimeZoneNames)];
    if (![known containsObject:tz]) return @"Europe/Moscow";
    return tz;
}
+ (NSString *)streakStickerID {
    NSString *sid = [[NSUserDefaults standardUserDefaults] stringForKey:@"twery_streak_sticker_id"];
    return sid.length > 0 ? sid : @"1";  // "1" — placeholder, fire sticker TBD on-device
}
+ (NSArray<NSString *> *)streakExcludedConversations {
    return [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"twery_streak_excluded"];
}
+ (NSDictionary *)streakLastSentDates {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"twery_streak_last_sent"];
}
+ (void)setStreakLastSentDate:(NSString *)convId {
    NSMutableDictionary *d = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"twery_streak_last_sent"] mutableCopy] ?: [NSMutableDictionary new];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    fmt.timeZone = [NSTimeZone timeZoneWithName:[self streakTimeZoneIdentifier]];
    d[convId] = [fmt stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:@"twery_streak_last_sent"];
}

#pragma mark - Like Color (TweryTok)

+ (BOOL)likeColorEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"twery_like_color_enabled"];
}
+ (NSString *)likeColorHex {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"twery_like_color_hex"];
}
+ (UIColor *)likeColor {
    NSString *hex = [self likeColorHex];
    if (hex.length < 6) return nil;
    // #RRGGBB
    NSRange r = [hex rangeOfString:@"#" options:NSBackwardsSearch];
    if (r.location != NSNotFound) hex = [hex substringFromIndex:r.location + 1];
    if (hex.length != 6) return nil;
    unsigned rgb = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&rgb];
    return [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8) & 0xFF) / 255.0
                            blue:(rgb & 0xFF) / 255.0
                           alpha:1.0];
}

@end