#import "TikTokHeaders.h"
#import <objc/runtime.h>

NSArray *jailbreakPaths;

static __weak id sCurrentActiveCell = nil;
static __weak AWEPlayVideoPlayerController *sCurrentActivePlayerController = nil;
static __weak TTVideoEngine *sCurrentActiveVideoEngine = nil;
static __weak AWEAwemeModel *sCurrentShareAweme = nil;
static __weak TTKStoryDetailTableViewCell *sCurrentActiveStoryCell = nil;

@implementation BHTMenuButton
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:NO];
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect touchBounds = CGRectInset(self.bounds, -12, -12);
    return CGRectContainsPoint(touchBounds, point);
}
- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction previewForHighlightingMenuWithConfiguration:(UIContextMenuConfiguration *)configuration {
    UIPreviewParameters *params = [[UIPreviewParameters alloc] init];
    params.backgroundColor = [UIColor clearColor];
    params.shadowPath = [UIBezierPath bezierPath];
    params.visiblePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    return [[UITargetedPreview alloc] initWithView:self parameters:params];
}
- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction previewForDismissingMenuWithConfiguration:(UIContextMenuConfiguration *)configuration {
    UIPreviewParameters *params = [[UIPreviewParameters alloc] init];
    params.backgroundColor = [UIColor clearColor];
    params.shadowPath = [UIBezierPath bezierPath];
    params.visiblePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    return [[UITargetedPreview alloc] initWithView:self parameters:params];
}
@end



%hook TTKFeedInteractionContainerElement
- (void)hideAllElements:(BOOL)hide exceptArray:(id)array {
    %orig;
    if (sCurrentActiveCell) {
        @try {
            if ([sCurrentActiveCell respondsToSelector:@selector(setElementsHidden:)]) {
                ((AWEFeedViewTemplateCell *)sCurrentActiveCell).elementsHidden = hide;
            }
        } @catch (__unused NSException *e) {}
        UIView *btn = [((UIView *)sCurrentActiveCell) viewWithTag:997];
        if (btn) {
            btn.hidden = hide;
            btn.alpha = hide ? 0.0 : 1.0;
        }
    }
}
%end




static void showConfirmation(void (^okHandler)(void)) {
  NSString *title = [BHIManager localizedString:@"TweryTok, Hi" tr:@"TweryTok, Selam"];
  NSString *desc = [BHIManager localizedString:@"Are you sure?" tr:@"Emin misiniz?"];
  NSString *yes = [BHIManager localizedString:@"Yes" tr:@"Evet"];
  NSString *no = [BHIManager localizedString:@"No" tr:@"Hayır"];
  [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:yes cancelButtonTitle:no actionBlock:^{
    okHandler();
  } cancelBlock:nil];
}

static BOOL sIsConfirmingLike = NO;

static void showLikeConfirmation(void (^okHandler)(void)) {
  NSString *title = [BHIManager localizedString:@"TweryTok, Hi" tr:@"TweryTok, Selam"];
  NSString *desc = [BHIManager localizedString:@"Do you want to like this video?" tr:@"Bu videoyu beğenmek istiyor musunuz?"];
  NSString *yes = [BHIManager localizedString:@"Yes" tr:@"Evet"];
  NSString *no = [BHIManager localizedString:@"No" tr:@"Hayır"];
  sIsConfirmingLike = YES;
  [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:yes cancelButtonTitle:no actionBlock:^{
    if (okHandler) {
      okHandler();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      sIsConfirmingLike = NO;
    });
  } cancelBlock:^{
    sIsConfirmingLike = NO;
  }];
}

%hook AppDelegate
- (_Bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"flex_enebaled"]) {
        [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BHTikTokFirstRun"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"BHTikTokFirstRun" forKey:@"BHTikTokFirstRun"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hide_ads"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_button"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_story"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"live_record_button"];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"remove_elements_button"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"show_porgress_bar"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"save_profile"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_profile_information"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_cover_image"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"follow_status_badge"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"extended_bio"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"extendedComment"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"download_cover_image"]) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_cover_image"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"follow_status_badge"]) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"follow_status_badge"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BHTikTokV2ButtonsMigrated"]) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"BHTikTokV2ButtonsMigrated"];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"download_story"]) {
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_story"];
        }
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"remove_elements_button"];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"download_button"]) {
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_button"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_story"];
        }
    }
    // Labs: re-apply A/B overrides through TikTok's own debug-override mock layer
    // (AWEABTestManager debugOverride_* API, verified present in MusicallyCore 46.5.0).
    // The %hook backstops below cover readers that bypass the mock layer.
    NSDictionary *abOverrides = [BHIManager abOverrides];
    if (abOverrides.count > 0) {
        [%c(AWEABTestManager) debugOverride_EnabledMock:YES];
        for (NSString *abKey in abOverrides) {
            [%c(AWEABTestManager) debugOverride_SetMockValue:abOverrides[abKey] forKey:abKey];
        }
    }
    [BHIManager cleanCache];
    return true;
}

static BOOL isAuthenticationShowed = FALSE;
- (void)applicationDidBecomeActive:(id)arg1 { // old app lock TODO: add face-id
  %orig;

  if ([BHIManager appLock] && !isAuthenticationShowed) {
    UIViewController *rootController = [[self window] rootViewController];
    SecurityViewController *securityViewController = [SecurityViewController new];
    securityViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootController presentViewController:securityViewController animated:YES completion:nil];
    isAuthenticationShowed = TRUE;
  }
}

- (void)applicationWillEnterForeground:(id)arg1 {
  %orig;
  isAuthenticationShowed = FALSE;
}
%end

%hook TTKMediaSpeedControlService
- (void)setPlaybackRate:(CGFloat)arg1 {
    NSNumber *speed = [BHIManager selectedSpeed];
    if (![BHIManager speedEnabled] || [speed isEqualToNumber:@1]) {
        return %orig;
    }
    if ([BHIManager speedEnabled]) {
        if ([BHIManager selectedSpeed]) {
            return %orig([speed floatValue]);
        }
    } else {
        return %orig;
    }
}
%end

%hook AWEUserWorkCollectionViewCell
- (void)configWithModel:(id)arg1 isMine:(BOOL)arg2 { // Video like count & upload date lables
    %orig;
    if ([BHIManager videoLikeCount] || [BHIManager videoUploadDate]) {
        for (int i = 0; i < [[self.contentView subviews] count]; i ++) {
            UIView *j = [[self.contentView subviews] objectAtIndex:i];
            if (j.tag == 1001) {
                [j removeFromSuperview];
            } 
            else if (j.tag == 1002) {
                [j removeFromSuperview];
            }
        }

        AWEAwemeModel *model = [self model];
        AWEAwemeStatisticsModel *statistics = [model statistics];
        NSNumber *createTime = [model createTime];
        NSNumber *likeCount = [statistics diggCount];
        NSString *likeCountFormatted = [self formattedNumber:[likeCount integerValue]];
        NSString *formattedDate = [self formattedDateStringFromTimestamp:[createTime doubleValue]];

        UILabel *likeCountLabel = [UILabel new];
        likeCountLabel.text = likeCountFormatted;
        likeCountLabel.textColor = [UIColor whiteColor];
        likeCountLabel.font = [UIFont boldSystemFontOfSize:13.0];
        likeCountLabel.tag = 1001;
        [likeCountLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        
        UIImageView *heartImage = [UIImageView new];
        heartImage.image = [UIImage systemImageNamed:@"heart"];
        heartImage.tintColor = [UIColor whiteColor];
        [heartImage setTranslatesAutoresizingMaskIntoConstraints:false];

        UILabel *uploadDateLabel = [UILabel new];
        uploadDateLabel.text = formattedDate;
        uploadDateLabel.textColor = [UIColor whiteColor];
        uploadDateLabel.font = [UIFont boldSystemFontOfSize:13.0];
        uploadDateLabel.tag = 1002;
        [uploadDateLabel setTranslatesAutoresizingMaskIntoConstraints:false];

        UIImageView *clockImage = [UIImageView new];
        clockImage.image = [UIImage systemImageNamed:@"clock"];
        clockImage.tintColor = [UIColor whiteColor];
        [clockImage setTranslatesAutoresizingMaskIntoConstraints:false];
        

        for (int i = 0; i < [[self.contentView subviews] count]; i ++) {
            UIView *j = [[self.contentView subviews] objectAtIndex:i];
            if (j.tag == 1001) {
                [j removeFromSuperview];
            } 
            else if (j.tag == 1002) {
                [j removeFromSuperview];
            }
        }
        if ([BHIManager videoLikeCount]) {
        [self.contentView addSubview:heartImage];
        [NSLayoutConstraint activateConstraints:@[
                [heartImage.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:110],
                [heartImage.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:4],
                [heartImage.widthAnchor constraintEqualToConstant:16],
                [heartImage.heightAnchor constraintEqualToConstant:16],
            ]];
        [self.contentView addSubview:likeCountLabel];
        [NSLayoutConstraint activateConstraints:@[
                [likeCountLabel.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:109],
                [likeCountLabel.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:23],
                [likeCountLabel.widthAnchor constraintEqualToConstant:200],
                [likeCountLabel.heightAnchor constraintEqualToConstant:16],
            ]];
        }
        if ([BHIManager videoUploadDate]) {
        [self.contentView addSubview:clockImage];
        [NSLayoutConstraint activateConstraints:@[
                [clockImage.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:128],
                [clockImage.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:4],
                [clockImage.widthAnchor constraintEqualToConstant:16],
                [clockImage.heightAnchor constraintEqualToConstant:16],
            ]];
        [self.contentView addSubview:uploadDateLabel];
        [NSLayoutConstraint activateConstraints:@[
                [uploadDateLabel.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:127],
                [uploadDateLabel.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:23],
                [uploadDateLabel.widthAnchor constraintEqualToConstant:200],
                [uploadDateLabel.heightAnchor constraintEqualToConstant:16],
            ]];
        }
    }
}
%new - (NSString *)formattedNumber:(NSInteger)number {

    if (number >= 1000000) {
        return [NSString stringWithFormat:@"%.1fm", number / 1000000.0];
    } else if (number >= 1000) {
        return [NSString stringWithFormat:@"%.1fk", number / 1000.0];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)number];
    }

}
%new - (NSString *)formattedDateStringFromTimestamp:(NSTimeInterval)timestamp {

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yy"; 
    return [dateFormatter stringFromDate:date];

}
%end

%hook TTKProfileRootView
- (void)layoutSubviews { // Video count & follow status badge
    %orig;
    if ([BHIManager profileVideoCount]){
        TTKProfileOtherViewController *rootVC = [self yy_viewController];
        AWEUserModel *user = [rootVC user];
        NSNumber *userVideoCount = [user visibleVideosCount];
        if (userVideoCount){
            UILabel *userVideoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,2,100,20.5)];
            userVideoCountLabel.text = [NSString stringWithFormat:@"Video Count: %@", userVideoCount];
            userVideoCountLabel.font = [UIFont systemFontOfSize:9.0];
            [self addSubview:userVideoCountLabel];
        }
    }
    if ([BHIManager followStatusBadge]) {
        [self bht_updateFollowStatusBadge];
    } else {
        [self bht_removeFollowStatusBadge];
    }
}

%new - (void)bht_removeFollowStatusBadge {
    UIView *badge = [self viewWithTag:99823];
    if (badge) [badge removeFromSuperview];
}

%new - (void)bht_updateFollowStatusBadge {
    id rootVC = [self yy_viewController];
    if (!rootVC) return;

    // Detect if this is user's own profile - must ONLY show on other users' profiles:
    UIViewController *curr = (UIViewController *)rootVC;
    BOOL isOtherVC = NO;
    while (curr) {
        if ([curr isKindOfClass:NSClassFromString(@"TTKProfileOtherViewController")]) {
            isOtherVC = YES;
            break;
        }
        curr = curr.parentViewController;
    }
    if (!isOtherVC) {
        [self bht_removeFollowStatusBadge];
        return;
    }

    AWEUserModel *user = nil;
    if ([rootVC respondsToSelector:@selector(user)]) {
        user = [rootVC user];
    }
    if (!user && [rootVC respondsToSelector:@selector(childViewControllers)]) {
        for (UIViewController *child in [rootVC childViewControllers]) {
            if ([child respondsToSelector:@selector(user)]) {
                user = [child performSelector:@selector(user)];
                if (user) break;
            }
        }
    }
    if (!user && [rootVC respondsToSelector:@selector(parentViewController)]) {
        UIViewController *parent = [rootVC parentViewController];
        if (parent && [parent respondsToSelector:@selector(user)]) {
            user = [parent performSelector:@selector(user)];
        }
    }

    if (!user) {
        // Data might still be loading from network; retry after a short delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self bht_updateFollowStatusBadge];
        });
        return;
    }

    if ([user respondsToSelector:@selector(isMe)] && [user isMe]) {
        [self bht_removeFollowStatusBadge];
        return;
    }
    if ([user respondsToSelector:@selector(isCurrentLoginUser)] && [user isCurrentLoginUser]) {
        [self bht_removeFollowStatusBadge];
        return;
    }

    BOOL followsYou = NO;
    if ([user respondsToSelector:@selector(followerStatus)]) {
        if ([user followerStatus] == 1) {
            followsYou = YES;
        }
    }
    if (!followsYou && [user respondsToSelector:@selector(followStatus)]) {
        if ([user followStatus] == 2) {
            followsYou = YES;
        }
    }

    NSString *handle = nil;
    if ([user respondsToSelector:@selector(uniqueID)] && [user uniqueID].length > 0) {
        handle = [user uniqueID];
    } else if ([user respondsToSelector:@selector(shortID)] && [user shortID].length > 0) {
        handle = [user shortID];
    } else if (user.socialName.length > 0) {
        handle = user.socialName;
    }
    if ([handle hasPrefix:@"@"]) {
        handle = [handle substringFromIndex:1];
    }

    UIView *usernameView = [self bht_findUsernameLabelWithHandle:handle];
    if (!usernameView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self bht_updateFollowStatusBadge];
        });
        return;
    }

    UILabel *badge = (UILabel *)[self viewWithTag:99823];
    if (!badge) {
        badge = [[UILabel alloc] init];
        badge.tag = 99823;
        badge.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];
        badge.textAlignment = NSTextAlignmentCenter;
        badge.layer.cornerRadius = 4.0;
        badge.layer.masksToBounds = YES;
        [self addSubview:badge];
    }

    BOOL tr = [BHIManager isTurkish];
    if (followsYou) {
        badge.text = tr ? @" Sizi takip ediyor " : @" Follows you ";
        badge.textColor = [UIColor colorWithRed:0.20 green:0.78 blue:0.35 alpha:1.0];
        badge.backgroundColor = [UIColor colorWithRed:0.20 green:0.78 blue:0.35 alpha:0.18];
    } else {
        badge.text = tr ? @" Sizi takip etmiyor " : @" Doesn't follow you ";
        badge.textColor = [UIColor colorWithRed:0.95 green:0.30 blue:0.30 alpha:1.0];
        badge.backgroundColor = [UIColor colorWithRed:0.95 green:0.30 blue:0.30 alpha:0.15];
    }

    [badge sizeToFit];
    CGFloat bw = badge.bounds.size.width + 10.0;
    CGFloat bh = 18.0;

    CGRect userRectInSelf = [self convertRect:usernameView.bounds fromView:usernameView];
    CGFloat textW = 0;
    NSString *uText = nil;
    UIFont *uFont = nil;
    if ([usernameView isKindOfClass:[UILabel class]]) {
        UILabel *ul = (UILabel *)usernameView;
        uText = ul.text ?: ul.attributedText.string;
        uFont = ul.font;
    }
    if (!uFont) uFont = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
    if (uText.length > 0) {
        CGSize ts = [uText sizeWithAttributes:@{NSFontAttributeName: uFont}];
        textW = ts.width;
    }
    if (textW <= 0) {
        textW = [usernameView sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    }
    CGFloat actualW = MAX(MAX(userRectInSelf.size.width, textW), [usernameView sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width);
    CGFloat bx = userRectInSelf.origin.x + actualW + 8.0;
    CGFloat by = userRectInSelf.origin.y + (userRectInSelf.size.height - bh) / 2.0;

    if (self.bounds.size.width > 0 && bx + bw > self.bounds.size.width - 10.0) {
        bx = self.bounds.size.width - bw - 10.0;
    }

    badge.frame = CGRectMake(bx, by, bw, bh);
    [self bringSubviewToFront:badge];
}

%new - (UIView *)bht_findUsernameLabelWithHandle:(NSString *)handle {
    if ([handle hasPrefix:@"@"]) {
        handle = [handle substringFromIndex:1];
    }
    NSString *handleWithAt = handle.length > 0 ? [NSString stringWithFormat:@"@%@", handle] : nil;

    NSMutableArray *queue = [NSMutableArray arrayWithObject:self];
    UIView *fallbackAtLabel = nil;

    while (queue.count > 0) {
        UIView *v = queue.firstObject;
        [queue removeObjectAtIndex:0];

        // The username handle is strictly in the top profile header (Y <= 260pt).
        // Any view below 260pt is follower counts, action buttons, or bio text!
        CGRect converted = [self convertRect:v.bounds fromView:v];
        if (converted.origin.y > 260.0) continue;

        // Skip bio / description views explicitly (TikTok uses TTTAttributedLabel for bio)
        NSString *clsName = NSStringFromClass([v class]);
        if ([clsName containsString:@"Bio"] || 
            [clsName containsString:@"Signature"] || 
            [clsName containsString:@"Description"] ||
            [clsName containsString:@"Work"] ||
            [v isKindOfClass:NSClassFromString(@"TTTAttributedLabel")]) {
            continue;
        }

        NSString *txt = nil;
        if ([v isKindOfClass:[UILabel class]]) {
            UILabel *ul = (UILabel *)v;
            // Username handles are always single-line labels
            if (ul.numberOfLines > 1) continue;
            txt = ul.text;
            if (!txt && ul.attributedText) {
                txt = ul.attributedText.string;
            }
        } else if ([v respondsToSelector:@selector(attributedText)]) {
            id att = [v valueForKey:@"attributedText"];
            if ([att isKindOfClass:[NSAttributedString class]]) {
                txt = [(NSAttributedString *)att string];
            }
        }
        if (!txt && [v respondsToSelector:@selector(text)]) {
            id t = [v valueForKey:@"text"];
            if ([t isKindOfClass:[NSString class]]) txt = t;
        }

        if (txt.length > 0) {
            // Bios contain newlines; username handles NEVER have newlines
            if ([txt containsString:@"\n"] || [txt containsString:@"\r"]) {
                continue;
            }

            NSString *trimmed = [txt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // 1. Exact match with @handle (e.g. @cgsunar)
            if (handleWithAt && [trimmed isEqualToString:handleWithAt]) {
                return v;
            }
            // 2. Exact match with handle without @ (e.g. cgsunar)
            if (handle.length > 0 && [trimmed isEqualToString:handle]) {
                return v;
            }
            // 3. Starts with @handle and has no spaces/colons
            if (handleWithAt && [trimmed hasPrefix:handleWithAt] && ![trimmed containsString:@" "] && ![trimmed containsString:@":"]) {
                return v;
            }

            // 4. Fallback: single-line handle starting with @ in the top header
            if (!fallbackAtLabel && [trimmed hasPrefix:@"@"] && 
                ![trimmed containsString:@" "] && 
                ![trimmed containsString:@":"] && 
                trimmed.length >= 2 && trimmed.length <= 32 &&
                converted.origin.y > 40.0 && converted.origin.y <= 260.0) {
                fallbackAtLabel = v;
            }
        }

        for (UIView *sub in v.subviews) {
            [queue addObject:sub];
        }
    }
    return fallbackAtLabel;
}

// copy profile information (46.5.0: TIKTOKProfileHeaderView was removed by TikTok,
// so the long-press gesture now lives on the profile root view)
- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if ([BHIManager profileCopy]) {
        [self addHandleLongPress];
    }
    return self;
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        id rootVC = [self yy_viewController];
        if (![rootVC respondsToSelector:@selector(user)]) { return; }
        AWEUserModel *user = [rootVC user];
        if (!user) { return; }
        NSString *profileInfo = [NSString stringWithFormat:([BHIManager isTurkish] ? @"Takma Ad: %@\nKullanıcı Adı: @%@\nTakipçi: %@\nTakip Edilen: %@\nBiyografi: %@" : @"Nickname: %@\nUsername: @%@\nFollowers: %@\nFollowing: %@\nBio: %@"), user.nickname ?: @"", user.socialName ?: @"", [user followerCount] ?: @0, [user followingCount] ?: @0, user.signature ?: @""];
        NSString *title = [BHIManager localizedString:@"Copy profile information" tr:@"Profil bilgilerini kopyala"];
        NSString *desc = [BHIManager localizedString:@"Do you want to copy profile information to clipboard?" tr:@"Profil bilgilerini panoya kopyalamak istiyor musunuz?"];
        NSString *yes = [BHIManager localizedString:@"Yes" tr:@"Evet"];
        NSString *no = [BHIManager localizedString:@"No" tr:@"Hayır"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:yes cancelButtonTitle:no actionBlock:^{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = profileInfo;
        } cancelBlock:nil];
    }
}
%end

%hook TTKProfileOtherViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if ([BHIManager followStatusBadge]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TTKProfileRootView *rootView = (TTKProfileRootView *)[self bht_findProfileRootView];
            if (rootView && [rootView respondsToSelector:@selector(bht_updateFollowStatusBadge)]) {
                [rootView bht_updateFollowStatusBadge];
            }
        });
    }
}
- (void)p_refreshHeaderViewAfterFetchUser:(id)arg1 shouldRefreshTabView:(BOOL)arg2 {
    %orig;
    if ([BHIManager followStatusBadge]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TTKProfileRootView *rootView = (TTKProfileRootView *)[self bht_findProfileRootView];
            if (rootView && [rootView respondsToSelector:@selector(bht_updateFollowStatusBadge)]) {
                [rootView bht_updateFollowStatusBadge];
            }
        });
    }
}
- (void)p_refreshUserData:(id)arg1 {
    %orig;
    if ([BHIManager followStatusBadge]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TTKProfileRootView *rootView = (TTKProfileRootView *)[self bht_findProfileRootView];
            if (rootView && [rootView respondsToSelector:@selector(bht_updateFollowStatusBadge)]) {
                [rootView bht_updateFollowStatusBadge];
            }
        });
    }
}
%new - (UIView *)bht_findProfileRootView {
    NSMutableArray *q = [NSMutableArray arrayWithObject:self.view];
    while (q.count > 0) {
        UIView *v = q.firstObject;
        [q removeObjectAtIndex:0];
        if ([v isKindOfClass:NSClassFromString(@"TTKProfileRootView")]) {
            return v;
        }
        for (UIView *sub in v.subviews) {
            [q addObject:sub];
        }
    }
    return nil;
}
%end


%hook BDImageView
- (void)layoutSubviews { // Profile save
    %orig;
    if ([BHIManager profileSave]) {
        [self addHandleLongPress];
    }
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSString *title = [BHIManager localizedString:@"Save profile image" tr:@"Profil resmini kaydet"];
        NSString *desc = [BHIManager localizedString:@"Do you want to save this image" tr:@"Bu resmi kaydetmek istiyor musunuz?"];
        NSString *yes = [BHIManager localizedString:@"Yes" tr:@"Evet"];
        NSString *no = [BHIManager localizedString:@"No" tr:@"Hayır"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:yes cancelButtonTitle:no actionBlock:^{
            UIImageWriteToSavedPhotosAlbum([self bd_baseImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
  } cancelBlock:nil];
    }
}
%new - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"Error saving image: %@", error.localizedDescription);
    } else {
        NSLog(@"Image successfully saved to Photos app");
    }
}
%end

%hook AWEUserNameLabel // fake verification
- (void)layoutSubviews {
    %orig;
    if ([BHIManager fakeVerified]) {
        [self addVerifiedIcon:YES];
    }
}
- (void)addVerifiedIcon:(BOOL)arg1 {
    if ([BHIManager fakeVerified]) {
        %orig(YES);
    } else {
        %orig(arg1);
    }
}
%end

%hook TTTAttributedLabel // copy profile decription
- (void)layoutSubviews {
    %orig;
    if ([BHIManager profileCopy]){
        [self addHandleLongPress];
    }
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSString *profileDescription = [self text];
        NSString *title = [BHIManager localizedString:@"Copy bio" tr:@"Biyografiyi kopyala"];
        NSString *desc = [BHIManager localizedString:@"Do you want to copy this text to clipboard" tr:@"Bu metni panoya kopyalamak istiyor musunuz?"];
        NSString *yes = [BHIManager localizedString:@"Yes" tr:@"Evet"];
        NSString *no = [BHIManager localizedString:@"No" tr:@"Hayır"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:yes cancelButtonTitle:no actionBlock:^{
             if (profileDescription) {
                 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                 pasteboard.string = profileDescription;
             }
  } cancelBlock:nil];
    }
}
%end

%hook TTKSettingsViewModel
- (NSArray *)sectionViewModelsArray {
    NSArray *sections = %orig;
    if (!sections || sections.count == 0) return sections;

    for (id sec in sections) {
        if ([sec respondsToSelector:@selector(sectionIdentifier)] && 
            [[sec sectionIdentifier] isEqualToString:@"twerytok_mod_section"]) {
            return sections;
        }
    }

    // Locate the "Aktivite" / "Activity" section to place TweryTok right above it (under "Ayarlar ve gizlilik")
    AWESettingsNormalSectionViewModel *activitySec = nil;
    NSUInteger targetIndex = NSNotFound;
    for (NSUInteger i = 0; i < sections.count; i++) {
        id sec = sections[i];
        NSString *title = [sec respondsToSelector:@selector(sectionHeaderTitle)] ? [sec sectionHeaderTitle] : nil;
        NSString *ident = [sec respondsToSelector:@selector(sectionIdentifier)] ? [sec sectionIdentifier] : nil;
        if ((title && ([title localizedCaseInsensitiveContainsString:@"Aktivit"] || [title localizedCaseInsensitiveContainsString:@"Activit"])) ||
            (ident && [ident localizedCaseInsensitiveContainsString:@"activ"])) {
            activitySec = (AWESettingsNormalSectionViewModel *)sec;
            targetIndex = i;
            break;
        }
    }
    if (targetIndex == NSNotFound) {
        // Fallback: place before the first section that has a visible header title
        for (NSUInteger i = 0; i < sections.count; i++) {
            id sec = sections[i];
            NSString *title = [sec respondsToSelector:@selector(sectionHeaderTitle)] ? [sec sectionHeaderTitle] : nil;
            if (title && title.length > 0) {
                activitySec = (AWESettingsNormalSectionViewModel *)sec;
                targetIndex = i;
                break;
            }
        }
    }
    if (targetIndex == NSNotFound) {
        targetIndex = sections.count > 1 ? 1 : 0;
    }

    id context = nil;
    if (activitySec && [activitySec respondsToSelector:@selector(context)]) {
        context = activitySec.context;
    } else {
        id firstSec = sections.firstObject;
        if ([firstSec respondsToSelector:@selector(context)]) {
            context = [firstSec context];
        }
    }

    Class secClass = activitySec ? [activitySec class] : %c(AWESettingsNormalSectionViewModel);
    AWESettingsNormalSectionViewModel *modSection = [[secClass alloc] init];
    if ([modSection respondsToSelector:@selector(setSectionIdentifier:)]) {
        modSection.sectionIdentifier = @"twerytok_mod_section";
    }
    BOOL tr = [BHIManager isTurkish];
    if ([modSection respondsToSelector:@selector(setSectionHeaderTitle:)]) {
        modSection.sectionHeaderTitle = tr ? @"TikTok Mod Ayarları" : @"TikTok Mod Settings";
    }
    if (context && [modSection respondsToSelector:@selector(setContext:)]) {
        modSection.context = context;
    }

    NSMutableArray *newSections = [sections mutableCopy];
    [newSections insertObject:modSection atIndex:targetIndex];
    return [newSections copy];
}
%end

%hook TTKSettingsBaseCellPlugin
- (void)didSelectItemAtIndex:(NSInteger)index {
    if ([self.itemModel.identifier isEqualToString:@"bhtiktok_settings"]) {
        UIViewController *top = topMostController();
        ViewController *vc = [[ViewController alloc] init];
        UINavigationController *BHTikTokSettings = [[UINavigationController alloc] initWithRootViewController:vc];
        if (@available(iOS 13.0, *)) {
            if (top.view.window.traitCollection.userInterfaceStyle) {
                BHTikTokSettings.overrideUserInterfaceStyle = top.view.window.traitCollection.userInterfaceStyle;
            }
        }
        [top presentViewController:BHTikTokSettings animated:true completion:nil];
    } else {
        return %orig;
    }
}
%end

%hook AWESettingsNormalSectionViewModel
%property (nonatomic, strong) TTKSettingsBaseCellPlugin *bhtiktokCell;

- (NSString *)sectionHeaderTitle {
    if ([self.sectionIdentifier isEqualToString:@"twerytok_mod_section"]) {
        BOOL tr = [BHIManager isTurkish];
        return tr ? @"TikTok Mod Ayarları" : @"TikTok Mod Settings";
    }
    return %orig;
}

- (NSArray *)modelsArray {
    if ([self.sectionIdentifier isEqualToString:@"twerytok_mod_section"]) {
        if (!self.bhtiktokCell) {
            TTKSettingsBaseCellPlugin *BHTikTokSettingsPluginCell = [[%c(TTKSettingsBaseCellPlugin) alloc] initWithPluginContext:self.context];

            AWESettingItemModel *BHTikTokSettingsItemModel = [[%c(AWESettingItemModel) alloc] initWithIdentifier:@"bhtiktok_settings"];
            BOOL tr = [BHIManager isTurkish];
            NSString *title = tr ? @"TweryTok Ayarları" : @"TweryTok Settings";
            [BHTikTokSettingsItemModel setTitle:title];
            [BHTikTokSettingsItemModel setDetail:title];
            [BHTikTokSettingsItemModel setIconImage:[UIImage systemImageNamed:@"gear"]];
            [BHTikTokSettingsItemModel setType:99];

            [BHTikTokSettingsPluginCell setItemModel:BHTikTokSettingsItemModel];
            self.bhtiktokCell = BHTikTokSettingsPluginCell;
        }
        return @[self.bhtiktokCell];
    }
    return %orig;
}
%end

%hook SparkViewController // alwaysOpenSafari
- (void)viewWillAppear:(BOOL)animated {
    if (![BHIManager alwaysOpenSafari]) {
        return %orig;
    }
    
    // NSURL *url = self.originURL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.originURL resolvingAgainstBaseURL:NO];
    NSString *searchParameter = @"url";
    NSString *searchValue = nil;
    
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if ([queryItem.name isEqualToString:searchParameter]) {
            searchValue = queryItem.value;
            break;
        }
    }
    
    // In-app browser is used for two-factor authentication with security key,
    // login will not complete successfully if it's redirected to Safari
    // if ([urlStr containsString:@"twitter.com/account/"] || [urlStr containsString:@"twitter.com/i/flow/"]) {
    //     return %orig;
    // }

    if (searchValue) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:searchValue] options:@{} completionHandler:nil];
        [self didTapCloseButton];
    } else {
        return %orig;
    }
}
%end

%hook CTCarrier // changes country 
- (NSString *)mobileCountryCode {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"mcc"];
        }
        return %orig;
    }
    return %orig;
}

- (void)setIsoCountryCode:(NSString *)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}

- (NSString *)isoCountryCode {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}

- (NSString *)mobileNetworkCode {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"mnc"];
        }
        return %orig;
    }
    return %orig;
}
%end
%hook TTKStoreRegionService
- (id)storeRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (id)getStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (void)setStoreRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig([selectedRegion[@"code"] lowercaseString]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end
%hook TIKTOKRegionManager
+ (NSString *)systemRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
+ (id)region {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
+ (id)mccmnc {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [NSString stringWithFormat:@"%@%@", selectedRegion[@"mcc"], selectedRegion[@"mnc"]];
        }
        return %orig;
    }
    return %orig;
}
+ (id)storeRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
+ (id)currentRegionV2 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
+ (id)localRegion {
        if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}

%end

// 46.5.0: belt-and-braces coverage for the newer store-region managers found in the 46.5.0
// binary. Same spoofing pattern as the other region hooks; any selector a class does not
// actually implement simply fails to hook (harmless no-op).
%hook TTKStoreRegionManager
- (id)storeRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (void)setStoreRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig([selectedRegion[@"code"] lowercaseString]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (id)getStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (id)getStoreRegionUpperCase {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (id)appStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setAppStoreRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (id)appSettingStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (id)userStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (id)ttStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (id)individualAccountStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setIndividualAccountStoreRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end

%hook TTRegionManager
- (id)region {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (id)systemRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (id)localRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (id)currentAppRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setCurrentAppRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (id)storeRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (void)setStoreRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig([selectedRegion[@"code"] lowercaseString]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (id)getStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (id)appStoreRegion {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setAppStoreRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end

// 46.5.0: surface TikTok's hidden official account-region-change entry (PNSChangeRegion SDK).
// Hook targets verified by walking the ObjC metadata of MusicallyCore (46.5.0): the gates are
// ObjC properties on these exact classes. (Earlier attempts hooked TTK* manager names, which are
// pure Swift classes invisible to objc_getClass — those hooks were silent no-ops.)
// The server still validates the actual migration (IP/eligibility/cooldown); this only reveals the UI.
%hook PNSChangeRegionSettingsModel
- (BOOL)isChangeRegionEnabled {
    if ([BHIManager showRegionChangeOption]) {
        return YES;
    }
    return %orig;
}
%end

%hook PNSChangeRegionSettingsModelV2
- (BOOL)isChangeRegionEnabled {
    if ([BHIManager showRegionChangeOption]) {
        return YES;
    }
    return %orig;
}
%end

%hook PNSChangeRegionCountryModelV2
- (BOOL)hasEntranceShowInfo {
    if ([BHIManager showRegionChangeOption]) {
        return YES;
    }
    return %orig;
}
- (NSInteger)entranceShowType {
    if ([BHIManager showRegionChangeOption]) {
        NSInteger orig = %orig;
        return orig == 0 ? 1 : orig;
    }
    return %orig;
}
%end

// 46.5.0: TTKPassportAppStoreRegionModel was removed by TikTok (replaced by PNSAppStoreRegion*
// network response DTOs, which are not consulted for region). Region spoofing remains covered by
// the CTCarrier / TTKStoreRegionService / TIKTOKRegionManager / ATSRegionCacheManager /
// TTKStoreRegionModel / TTInstallIDManager / BDInstallGlobalConfig hooks in this file.

%hook ATSRegionCacheManager
- (id)getRegion {
 if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (id)storeRegionFromCache {
 if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (id)storeRegionFromTTNetNotification:(id)arg1 {
 if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (void)setRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig([selectedRegion[@"code"] lowercaseString]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (id)region {
 if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
%end

%hook TTKStoreRegionModel
- (id)storeRegion {
 if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setStoreRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end

%hook TTInstallIDManager
- (id)currentAppRegion {
 if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setCurrentAppRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end

%hook BDInstallGlobalConfig
- (id)currentAppRegion {
 if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setCurrentAppRegion:(id)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end

%hook ACCCreationPublishAction
- (BOOL)is_open_hd {
    if ([BHIManager uploadHD]) {
        return 1;
    }
    return %orig;
}
- (void)setIs_open_hd:(BOOL)arg1 {
    if ([BHIManager uploadHD]) {
        %orig(1);
    }
    else {
        return %orig;
    }
}
- (BOOL)is_have_hd {
    if ([BHIManager uploadHD]) {
        return 1;
    }
    return %orig;
}
- (void)setIs_have_hd:(BOOL)arg1 {
    if ([BHIManager uploadHD]) {
        %orig(1);
    }
    else {
        return %orig;
    }
}

%end

%hook TTKCommentPanelViewController
- (void)viewDidLoad {
    %orig;
    if ([BHIManager transparentCommnet]){
        UIView *commnetView = [self view];
        [commnetView setAlpha:0.90];
    }
}
%end

%hook AWEAwemeModel // no ads, show porgress bar
- (id)initWithDictionary:(id)arg1 error:(id *)arg2 {
    id orig = %orig;
    return [BHIManager hideAds] && self.isAds ? nil : orig;
}
- (id)init {
    id orig = %orig;
    return [BHIManager hideAds] && self.isAds ? nil : orig;
}

- (BOOL)progressBarDraggable {
    return [BHIManager progressBar] || %orig;
}
- (BOOL)progressBarVisible {
    return [BHIManager progressBar] || %orig;
}
- (BOOL)canDragProgressBar {
    return [BHIManager progressBar] || %orig;
}
- (BOOL)showProgressBar {
    return [BHIManager progressBar] || %orig;
}
- (void)live_callInitWithDictyCategoryMethod:(id)arg1 {
    if (![BHIManager disableLive]) {
        %orig;
    }
}
+ (id)liveStreamURLJSONTransformer {
    if ([BHIManager disableLive]) {
        return nil;
    }
    return %orig;
}
+ (id)relatedLiveJSONTransformer {
    if ([BHIManager disableLive]) {
        return nil;
    }
    return %orig;
}
+ (id)rawModelFromLiveRoomModel:(id)arg1 {
    if ([BHIManager disableLive]) {
        return nil;
    }
    return %orig;
}
+ (id)aweLiveRoom_subModelPropertyKey {
    if ([BHIManager disableLive]) {
        return nil;
    }
    return %orig;
}
%end

%hook AWEPlayInteractionWarningElementView
- (id)warningImage {
    if ([BHIManager disableWarnings]) {
        return nil;
    }
    return %orig;
}
- (id)warningLabel {
    if ([BHIManager disableWarnings]) {
        return nil;
    }
    return %orig;
}
%end

%hook TUXLabel
- (void)setText:(NSString*)arg1 {
    if ([BHIManager showUsername]) {
        if ([[[self superview] superview] isKindOfClass:%c(AWEPlayInteractionAuthorUserNameButton)]){
            AWEFeedCellViewController *rootVC = [[[self superview] superview] yy_viewController];
            AWEAwemeModel *model = rootVC.model;
            AWEUserModel *authorModel = model.author;
            NSString *nickname = authorModel.nickname;
            NSString *username = authorModel.socialName;
            %orig(username);
        }else {
            %orig;
        }
    }else {
        %orig;
    }
}
%end

%hook AWENewFeedTableViewController
- (BOOL)disablePullToRefreshGestureRecognizer {
    if ([BHIManager disablePullToRefresh]){
        return 1;
    }
    return %orig;
}

%end


%hook TTVideoEngine
- (void)play {
    sCurrentActiveVideoEngine = self;
    %orig;
    if ([BHIManager progressBar]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *top = topMostController();
            if (top && [NSStringFromClass([top class]) containsString:@"Story"]) {
                if ([top respondsToSelector:@selector(bht_layoutStoryProgressBar)]) {
                    [top performSelector:@selector(bht_layoutStoryProgressBar)];
                }
            }
        });
    }
}
%end

%hook AWEVideoControlModel
- (BOOL)canDragProgressBar {
    return [BHIManager progressBar] || %orig;
}
- (BOOL)showProgressBar {
    return [BHIManager progressBar] || %orig;
}
%end
%hook AWEPlayVideoPlayerController // auto play next video and stop looping video
- (void)play {
    sCurrentActivePlayerController = self;
    %orig;
}
- (void)updatePlayerIfNeeded {
    sCurrentActivePlayerController = self;
    %orig;
}
- (void)playerWillLoopPlaying:(id)arg1 {
    if ([BHIManager autoPlay]) {
        if ([self.container.parentViewController isKindOfClass:%c(AWENewFeedTableViewController)]) {
            [((AWENewFeedTableViewController *)self.container.parentViewController) scrollToNextVideo];
            return;
        }
    }
    %orig;
}
- (BOOL)loop {
    if ([BHIManager stopPlay]) {
        return 0;
    }
    return %orig; 
}
- (void)setLoop:(BOOL)arg1 {
    if ([BHIManager stopPlay]) {
        %orig(0);
    }else {
        %orig;
    }
}
%end

%hook AWEMaskInfoModel // Disable Unsensitive Content
- (BOOL)showMask {
    if ([BHIManager disableUnsensitive]) {
        return 0;
    }
    return %orig;
}
- (void)setShowMask:(BOOL)arg1 {
    if ([BHIManager disableUnsensitive]) {
        %orig(0);
    }
    else {
        %orig;
    }
}
%end

%hook NSNotificationCenter // bypass screenshot detection (feature #4)
// TikTok registers its screenshot handlers (live/chat detection, "share this screenshot"
// popup) via UIApplicationUserDidTakeScreenshotNotification. Blocking the registration
// means those handlers never fire: no detection toasts, no share popup, app-wide.
- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object {
    if ([BHIManager disableScreenshotDetection] && [name isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"]) {
        return;
    }
    %orig;
}
- (id)addObserverForName:(id)name object:(id)object queue:(id)queue usingBlock:(id)block {
    if ([BHIManager disableScreenshotDetection] && [name isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"]) {
        return nil;
    }
    return %orig;
}
%end

%hook AWEIMMessageReadComponent // ghost mode: read receipts (feature #2)
// stops the "mark as read" sync to TikTok's servers; messages still appear read locally
- (void)p_markReadSyncToServerWithMessage:(id)arg1 {
    if ([BHIManager ghostReadReceipts]) {
        return;
    }
    %orig;
}
%end

%hook AWEIMMessageDataController // ghost mode: read receipts (belt-and-braces, same selector)
- (void)p_markReadSyncToServerWithMessage:(id)arg1 {
    if ([BHIManager ghostReadReceipts]) {
        return;
    }
    %orig;
}
%end

%hook TIMInputStatusManager // ghost mode: typing indicators (feature #2)
// blocks the input-status ("typing...") signal at the IM SDK layer
- (void)sendInputStatusWithConversationID:(id)arg1 inputStatus:(long long)arg2 {
    if ([BHIManager ghostTyping]) {
        return;
    }
    %orig;
}
%end

%hook AWEAwemeACLItem // remove default watermark
- (void)setWatermarkType:(NSUInteger)arg1 {
    if ([BHIManager removeWatermark]){
        %orig(1);
    }
    else { 
        %orig;
    }
    
}
- (NSUInteger)watermarkType {
    if ([BHIManager removeWatermark]){
        return 1;
    }
    return %orig;
}
%end

%hook UIButton // follow confirmation broken 
- (void)_onTouchUpInside {
    if ([BHIManager followConfirmation] && [self.currentTitle isEqualToString:@"Follow"]) {
        showConfirmation(^(void) {
            %orig;
        });
    } else {
        %orig;
    }
}
%end
%hook AWEPlayInteractionUserAvatarElement
- (void)onFollowViewClicked:(id)sender {
    if ([BHIManager followConfirmation]) {
        showConfirmation(^(void) {
            %orig;
        });
    } else {
        return %orig;
    }
}
%end

%hook TTKProfileBaseComponentModel // Fake Followers, Fake Following and FakeVerified.

- (NSDictionary *)bizData {
	if ([BHIManager fakeChangesEnabled]) {
		NSDictionary *originalData = %orig;
		NSMutableDictionary *modifiedData = [originalData mutableCopy];
		
		NSNumber *fakeFollowingCount = [self numberFromUserDefaultsForKey:@"following_count"];
		NSNumber *fakeFollowersCount = [self numberFromUserDefaultsForKey:@"follower_count"];
		
		if ([self.componentID isEqualToString:@"relation_info_follower"]) {
			modifiedData[@"follower_count"] = fakeFollowersCount ?: @0; 
		} else if ([self.componentID isEqualToString:@"relation_info_following"]) {
			modifiedData[@"following_count"] = fakeFollowingCount ?: @0; 
			modifiedData[@"formatted_number"] = [self formattedStringFromNumber:fakeFollowingCount ?: @0];
		} 
		return [modifiedData copy];
	}
	return %orig;
}

- (NSArray *)components {
	if ([BHIManager fakeVerified]) {
		NSArray *originalComponents = %orig;
		if ([self.componentID isEqualToString:@"user_account_base_info"]) {
			BOOL hasVerify = NO;
			for (TTKProfileBaseComponentModel *comp in originalComponents) {
				if ([comp.componentID isEqualToString:@"user_account_verify"] || [comp.name isEqualToString:@"user_account_verify"]) {
					hasVerify = YES;
					break;
				}
			}
			if (!hasVerify) {
				NSMutableArray *modifiedComponents = [originalComponents mutableCopy];
				TTKProfileBaseComponentModel *fakeVerify = [%c(TTKProfileBaseComponentModel) new];
				fakeVerify.componentID = @"user_account_verify";
				fakeVerify.name = @"user_account_verify";
				[modifiedComponents addObject:fakeVerify];
				return [modifiedComponents copy];
			}
		}
	}
	return %orig;
}

%new - (NSNumber *)numberFromUserDefaultsForKey:(NSString *)key {
    NSString *stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    return (stringValue.length > 0) ? @([stringValue doubleValue]) : @0; 
}

%new - (NSString *)formattedStringFromNumber:(NSNumber *)number {
    if (!number) return @"0"; 

    double value = [number doubleValue];
    if (value == 0) return @"0"; 

    NSString *formattedString;
    if (value >= 1e9) {
        formattedString = [NSString stringWithFormat:@"%.1fB", value / 1e9];
    } else if (value >= 1e6) {
        formattedString = [NSString stringWithFormat:@"%.1fM", value / 1e6];
    } else if (value >= 1e3) {
        formattedString = [NSString stringWithFormat:@"%.1fk", value / 1e3];
    } else {
        formattedString = [NSString stringWithFormat:@"%.0f", value];
    }

    return formattedString;
}

%end

%hook AWEPlayInteractionLikeElement
- (void)buttonClicked {
    if ([BHIManager likeConfirmation]) {
        id model = nil;
        @try {
            if ([self respondsToSelector:@selector(model)]) {
                model = [self valueForKey:@"model"];
            } else if ([self respondsToSelector:@selector(awemeModel)]) {
                model = [self valueForKey:@"awemeModel"];
            } else if ([self respondsToSelector:@selector(context)]) {
                id ctx = [self valueForKey:@"context"];
                if ([ctx respondsToSelector:@selector(model)]) {
                    model = [ctx valueForKey:@"model"];
                } else if ([ctx respondsToSelector:@selector(awemeModel)]) {
                    model = [ctx valueForKey:@"awemeModel"];
                }
            }
        } @catch (__unused NSException *e) {}

        BOOL isLiked = NO;
        if (model) {
            @try {
                if ([model respondsToSelector:@selector(userDigged)]) {
                    isLiked = [[model valueForKey:@"userDigged"] boolValue];
                } else if ([model respondsToSelector:@selector(isUserDigged)]) {
                    isLiked = [[model valueForKey:@"isUserDigged"] boolValue];
                }
            } @catch (__unused NSException *e) {}
        }

        if (!isLiked && !sIsConfirmingLike) {
            showLikeConfirmation(^{
                %orig;
            });
            return;
        }
    }
    %orig;
}
%end

%hook AWEFeedVideoButton // like feed confirmation fallback
- (void)_onTouchUpInside {
    if ([BHIManager likeConfirmation]) {
        showLikeConfirmation(^{
            %orig;
        });
    } else {
        %orig;
    }
}
%end
%hook AWECommentPanelCell // like/dislike comment confirmation
- (void)onLikeAction:(id)arg1 {
    if ([BHIManager likeCommentConfirmation]) {
        showConfirmation(^(void) {
            %orig;
        });
    } else {
        return %orig;
    }
}
- (void)onDislikeAction:(id)arg1 {
    if ([BHIManager dislikeCommentConfirmation]) {
        showConfirmation(^(void) {
            %orig;
        });
    } else {
        return %orig;
    }
}
%end

%hook AWEUserModel // follower, following Count fake and fake verification
- (BOOL)isVerify {
    if ([BHIManager fakeVerified]) {
        return YES;
    }
    return %orig;
}
- (NSString *)customVerify {
    if ([BHIManager fakeVerified]) {
        NSString *orig = %orig;
        if (orig.length > 0) return orig;
        return @"Verified";
    }
    return %orig;
}
- (NSNumber *)followerCount {
    if ([BHIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"follower_count"];
        if (!(fakeCountString.length == 0)) {
            NSInteger fakeCount = [fakeCountString integerValue];
            return [NSNumber numberWithInt:fakeCount];
        }

        return %orig;
    }

    return %orig;
}
- (NSNumber *)followingCount {
    if ([BHIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"following_count"];
        if (!(fakeCountString.length == 0)) {
            NSInteger fakeCount = [fakeCountString integerValue];
            return [NSNumber numberWithInt:fakeCount];
        }

        return %orig;
    }

    return %orig;
}
%end

%hook AWETextInputController
- (NSUInteger)maxLength {
    if ([BHIManager extendedComment]) {
        return 500;
    }

    return %orig;
}
%end
%hook AWEPlayVideoPlayerController
- (void)containerDidFullyDisplayWithReason:(NSInteger)arg1 {
    if ([[[self container] parentViewController] isKindOfClass:%c(AWENewFeedTableViewController)] && [BHIManager skipRecommendations]) {
        AWENewFeedTableViewController *rootVC = [[self container] parentViewController];
        AWEAwemeModel *currentModel = [rootVC currentAweme];
        if ([currentModel isUserRecommendBigCard]) {
            [rootVC scrollToNextVideo];
        }
    }else {
        %orig;
    }
}
%end
%hook AWEProfileEditTextViewController
- (NSInteger)maxTextLength {
    if ([BHIManager extendedBio]) {
        return 222;
    }

    return %orig;
}
%end
%hook AWEPlayInteractionAuthorView
%new - (NSString *)emojiForCountryCode:(NSString *)countryCode {
    // Convert the country code to uppercase
    NSString *uppercaseCountryCode = [countryCode uppercaseString];
    
    // Ensure the country code has exactly two characters
    if (uppercaseCountryCode.length != 2) {
        return nil;
    }
    
    // Convert the country code to the regional indicator symbols
    uint32_t firstLetter = [uppercaseCountryCode characterAtIndex:0] + 0x1F1E6 - 'A';
    uint32_t secondLetter = [uppercaseCountryCode characterAtIndex:1] + 0x1F1E6 - 'A';
    
    // Create the emoji using the regional indicator symbols
    NSString *flagEmoji = [[NSString alloc] initWithBytes:&firstLetter length:4 encoding:NSUTF32LittleEndianStringEncoding];
    flagEmoji = [flagEmoji stringByAppendingString:[[NSString alloc] initWithBytes:&secondLetter length:4 encoding:NSUTF32LittleEndianStringEncoding]];
    
    return flagEmoji;
}

- (void)layoutSubviews {
    %orig;
    if ([BHIManager uploadRegion]){
        for (int i = 0; i < [[self subviews] count]; i ++){
            id j = [[self subviews] objectAtIndex:i];
            if ([j isKindOfClass:%c(UIStackView)]){
                CGRect frame = [j frame];
                frame.origin.x = 39.5; 
                [j setFrame:frame];
            }else {
                [[self viewWithTag:666] removeFromSuperview];
            }
        }
        [[self viewWithTag:666] removeFromSuperview];
        AWEFeedCellViewController* rootVC = self.yy_viewController;
        AWEAwemeModel *model = rootVC.model;
        NSString *countryID = model.region;
        UILabel *uploadLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,2,39.5,20.5)];
        NSString *countryEmoji = [self emojiForCountryCode:countryID];
        uploadLabel.text = [NSString stringWithFormat:@"%@ •",countryEmoji];
        uploadLabel.tag = 666;
        [uploadLabel setTextColor: [UIColor whiteColor]];
        [uploadLabel sizeToFit];
        [self addSubview:uploadLabel];
    }
}
%end
// 46.5.0: TIKTOKProfileHeaderView was removed by TikTok (profile header is now built by the
// TTKProfileHeaderAdaptor / TTKProfileHeaderViewComponent family). The copy profile
// information feature moved to the TTKProfileRootView hook near the top of this file.

%hook AWELiveFeedEntranceView
- (void)switchStateWithTapped:(BOOL)arg1 {
    if (![BHIManager liveActionEnabled] || [BHIManager selectedLiveAction] == 0) {
        %orig;
    } else if ([BHIManager liveActionEnabled] && [[BHIManager selectedLiveAction] intValue] == 1) {
        UIViewController *top = topMostController();
        ViewController *vc = [[ViewController alloc] init];
        UINavigationController *BHTikTokSettings = [[UINavigationController alloc] initWithRootViewController:vc];
        if (@available(iOS 13.0, *)) {
            if (top.view.window.traitCollection.userInterfaceStyle) {
                BHTikTokSettings.overrideUserInterfaceStyle = top.view.window.traitCollection.userInterfaceStyle;
            }
        }
        [top presentViewController:BHTikTokSettings animated:true completion:nil];
    } 
    else {
        %orig;
    }

}
%end

static NSURL *getDownloadURLForPhoto(AWEPhotoAlbumPhoto *photo) {
    if (!photo) return nil;
    AWEURLModel *urlModel = nil;
    @try {
        if ([photo respondsToSelector:@selector(originPhotoURL)]) {
            urlModel = [photo originPhotoURL];
        }
        if (!urlModel && [photo respondsToSelector:@selector(watermarkPhotoURL)]) {
            urlModel = [photo valueForKey:@"watermarkPhotoURL"];
        }
        if (!urlModel && [photo respondsToSelector:@selector(downloadPhotoURL)]) {
            urlModel = [photo valueForKey:@"downloadPhotoURL"];
        }
        if (!urlModel && [photo respondsToSelector:@selector(displayPhotoURL)]) {
            urlModel = [photo valueForKey:@"displayPhotoURL"];
        }
        if (!urlModel && [photo respondsToSelector:@selector(photoURL)]) {
            urlModel = [photo valueForKey:@"photoURL"];
        }
    } @catch (__unused NSException *e) {}

    if (urlModel) {
        NSURL *u = [urlModel bestURLtoDownload];
        if (u) return u;
        if ([urlModel respondsToSelector:@selector(recommendUrl)] && [urlModel recommendUrl]) {
            return [urlModel recommendUrl];
        }
        if (urlModel.originURLList.count > 0) {
            return [NSURL URLWithString:urlModel.originURLList.firstObject];
        }
        if (urlModel.urlList.count > 0) {
            return [NSURL URLWithString:urlModel.urlList.firstObject];
        }
    }
    return nil;
}

static NSString *getDownloadFormatForPhoto(AWEPhotoAlbumPhoto *photo) {
    if (!photo) return @"jpeg";
    AWEURLModel *urlModel = nil;
    @try {
        if ([photo respondsToSelector:@selector(originPhotoURL)]) {
            urlModel = [photo originPhotoURL];
        }
    } @catch (__unused NSException *e) {}
    if (urlModel) {
        NSString *fmt = [urlModel bestURLtoDownloadFormat];
        NSArray *imageExts = @[@"png", @"jpg", @"jpeg", @"gif", @"tiff", @"bmp", @"heif", @"heic", @"webp"];
        if (fmt && [imageExts containsObject:[fmt lowercaseString]]) {
            return fmt;
        }
    }
    return @"jpeg";
}

%hook AWEFeedViewTemplateCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
%property (nonatomic, retain) UIProgressView *progressView;
- (void)configWithModel:(id)model {
    %orig;
    sCurrentActiveCell = self;
    self.elementsHidden = false;
    if ([BHIManager downloadButton]) {
        [self addBHTikTokMenuButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    sCurrentActiveCell = self;
    self.elementsHidden = false;
    if ([BHIManager downloadButton]) {
        [self addBHTikTokMenuButton];
    }
}
- (void)layoutSubviews {
    %orig;
    if ([BHIManager downloadButton]) {
        [self addBHTikTokMenuButton];
    } else {
        UIView *mirror = [self viewWithTag:996];
        if (mirror) [mirror removeFromSuperview];
        UIView *btn = [self viewWithTag:997];
        if (btn) [btn removeFromSuperview];
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *btn = [self viewWithTag:997];
    if (btn && !btn.hidden && btn.alpha > 0.05 && btn.userInteractionEnabled) {
        CGPoint pInBtn = [self convertPoint:point toView:btn];
        if ([btn pointInside:pInBtn withEvent:event]) {
            return btn;
        }
    }
    return %orig;
}
%new - (void)showBHTikTokDownloadActionSheet {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if (!rootVC) {
        UIResponder *r = self;
        while (r) {
            if ([r isKindOfClass:%c(AWEAwemeBaseViewController)]) {
                rootVC = (AWEAwemeBaseViewController *)r;
                break;
            }
            r = [r nextResponder];
        }
    }
    if (!rootVC) return;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[BHIManager isTurkish] ? @"TweryTok Menüsü" : @"TweryTok Menu" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if ([BHIManager hideElementButton]) {
        NSString *cleanTitle = self.elementsHidden ? ([BHIManager isTurkish] ? @"Ekranı Göster" : @"Show Elements") : ([BHIManager isTurkish] ? @"Ekranı Temizle" : @"Clean Screen");
        [alert addAction:[UIAlertAction actionWithTitle:cleanTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self toggleBHTikTokHideElements];
        }]];
    }

    if ([rootVC isKindOfClass:%c(AWEFeedCellViewController)]) {
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Video" tr:@"Videoyu İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadVideo:rootVC];
        }]];
        if ([BHIManager downloadCoverImage]) {
            [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Cover Image" tr:@"Kapak Resmini İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self downloadCoverImage:rootVC];
            }]];
        }

        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Music" tr:@"Müziği İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Video link" tr:@"Video Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyVideo:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Music link" tr:@"Müzik Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Decription" tr:@"Açıklamayı Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyDecription:rootVC];
        }]];
    } else if ([rootVC isKindOfClass:%c(TTKPhotoAlbumDetailCellController)] || [rootVC isKindOfClass:%c(TTKPhotoAlbumFeedCellController)]) {
        NSArray *photos = rootVC.model.photoAlbum.photos;
        unsigned long photosCount = [photos count];
        for (int i = 0; i < photosCount; i++) {
            NSString *title = [BHIManager isTurkish] ? [NSString stringWithFormat:@"%d. Fotoğrafı İndir", i+1] : [NSString stringWithFormat:@"Download Photo %d", i+1];
            [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [(id)self downloadPhotos:(id)rootVC photoIndex:i];
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download All Photos" tr:@"Tüm Fotoğrafları İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [(id)self downloadPhotos:(id)rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Music" tr:@"Müziği İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Video link" tr:@"Video Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyVideo:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Music link" tr:@"Müzik Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Decription" tr:@"Açıklamayı Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyDecription:rootVC];
        }]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Video" tr:@"Videoyu İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadVideo:rootVC];
        }]];
        if ([BHIManager downloadCoverImage]) {
            [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Cover Image" tr:@"Kapak Resmini İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self downloadCoverImage:rootVC];
            }]];
        }

        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Music" tr:@"Müziği İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Video link" tr:@"Video Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyVideo:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Music link" tr:@"Müzik Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Decription" tr:@"Açıklamayı Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyDecription:rootVC];
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Cancel" tr:@"İptal"] style:UIAlertActionStyleCancel handler:nil]];

    UIViewController *top = topMostController();
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = top.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(top.view.bounds.size.width / 2.0, top.view.bounds.size.height / 2.0, 1.0, 1.0);
    }
    [top presentViewController:alert animated:YES completion:nil];
}
%new - (void)toggleBHTikTokHideElements {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC.interactionController isKindOfClass:%c(TTKFeedInteractionLegacyMainContainerElement)]) {
        TTKFeedInteractionLegacyMainContainerElement *interactionController = rootVC.interactionController;
        UIView *btn = [self viewWithTag:997];
        if (self.elementsHidden) {
            self.elementsHidden = false;
            [interactionController hideAllElements:false exceptArray:nil];
            if (btn) {
                btn.hidden = NO;
                btn.alpha = 1.0;
            }
        } else {
            self.elementsHidden = true;
            [interactionController hideAllElements:true exceptArray:nil];
            if (btn) {
                btn.hidden = YES;
                btn.alpha = 0.0;
            }
        }
    }
}
%new - (UIView *)bhtFindAvatarView:(UIView *)parent {
    if (!parent) return nil;
    if ([parent isKindOfClass:%c(AWEPlayInteractionUserAvatarView)]) {
        return parent;
    }
    for (UIView *sub in parent.subviews) {
        UIView *found = [self bhtFindAvatarView:sub];
        if (found) return found;
    }
    return nil;
}
%new - (void)setupBHTikTokMenu:(UIButton *)sender {
    if (!sender) return;
    BOOL tr = [BHIManager isTurkish];
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if (!rootVC) {
        UIResponder *r = self;
        while (r) {
            if ([r isKindOfClass:%c(AWEAwemeBaseViewController)]) {
                rootVC = (AWEAwemeBaseViewController *)r;
                break;
            }
            r = [r nextResponder];
        }
    }
    if (!rootVC) return;

    NSMutableArray *menuActions = [NSMutableArray array];

    if ([BHIManager hideElementButton]) {
        NSString *cleanTitle = self.elementsHidden ? (tr ? @"Ekranı Göster" : @"Show Elements") : (tr ? @"Ekranı Temizle" : @"Clean Screen");
        UIImage *cleanIcon = [UIImage systemImageNamed:self.elementsHidden ? @"eye" : @"eye.slash"];
        UIAction *cleanAction = [UIAction actionWithTitle:cleanTitle image:cleanIcon identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self toggleBHTikTokHideElements];
            [self setupBHTikTokMenu:sender];
        }];
        [menuActions addObject:cleanAction];
    }

    if ([rootVC isKindOfClass:%c(TTKPhotoAlbumDetailCellController)] || [rootVC isKindOfClass:%c(TTKPhotoAlbumFeedCellController)]) {
        NSArray *photos = rootVC.model.photoAlbum.photos;
        unsigned long photosCount = [photos count];
        for (int i = 0; i < photosCount; i++) {
            NSString *title = tr ? [NSString stringWithFormat:@"%d. Fotoğrafı İndir", i+1] : [NSString stringWithFormat:@"Download Photo %d", i+1];
            UIAction *pAction = [UIAction actionWithTitle:title image:[UIImage systemImageNamed:@"photo"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                [(id)self downloadPhotos:(id)rootVC photoIndex:i];
            }];
            [menuActions addObject:pAction];
        }
        UIAction *allPhotosAction = [UIAction actionWithTitle:tr ? @"Tüm Fotoğrafları İndir" : @"Download All Photos" image:[UIImage systemImageNamed:@"photo.on.rectangle"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [(id)self downloadPhotos:(id)rootVC];
        }];
        [menuActions addObject:allPhotosAction];
    } else {
        UIAction *dlVideoAction = [UIAction actionWithTitle:tr ? @"Videoyu İndir" : @"Download Video" image:[UIImage systemImageNamed:@"film"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self downloadVideo:rootVC];
        }];
        [menuActions addObject:dlVideoAction];
        if ([BHIManager downloadCoverImage]) {
            UIAction *dlCoverAction = [UIAction actionWithTitle:tr ? @"Kapak Resmini İndir" : @"Download Cover Image" image:[UIImage systemImageNamed:@"photo"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                [self downloadCoverImage:rootVC];
            }];
            [menuActions addObject:dlCoverAction];
        }
    }

    UIAction *dlMusicAction = [UIAction actionWithTitle:tr ? @"Müziği İndir" : @"Download Music" image:[UIImage systemImageNamed:@"music.note"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self downloadMusic:rootVC];
    }];
    [menuActions addObject:dlMusicAction];

    UIAction *copyVideoAction = [UIAction actionWithTitle:tr ? @"Video Bağlantısını Kopyala" : @"Copy Video link" image:[UIImage systemImageNamed:@"link"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self copyVideo:rootVC];
    }];
    UIAction *copyMusicAction = [UIAction actionWithTitle:tr ? @"Müzik Bağlantısını Kopyala" : @"Copy Music link" image:[UIImage systemImageNamed:@"link"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self copyMusic:rootVC];
    }];
    UIAction *copyDescAction = [UIAction actionWithTitle:tr ? @"Açıklamayı Kopyala" : @"Copy Description" image:[UIImage systemImageNamed:@"note.text"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self copyDecription:rootVC];
    }];

    UIMenu *copyMenu = [UIMenu menuWithTitle:tr ? @"Kopyalama Seçenekleri" : @"Copy Menu" image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil options:0 children:@[copyVideoAction, copyMusicAction, copyDescAction]];
    [menuActions addObject:copyMenu];

    UIMenu *mainMenu = [UIMenu menuWithTitle:tr ? @"TweryTok Menüsü" : @"TweryTok Menu" children:menuActions];
    [sender setMenu:mainMenu];
    sender.showsMenuAsPrimaryAction = YES;
}
%new - (void)bhtMenuButtonHandler:(UIButton *)sender {
    if (@available(iOS 14.0, *)) {
        [self setupBHTikTokMenu:sender];
    }
    [self showBHTikTokDownloadActionSheet];
}
%new - (void)addBHTikTokMenuButton {
    UIView *oldMirror = [self viewWithTag:996];
    if (oldMirror) [oldMirror removeFromSuperview];

    if (![BHIManager downloadButton]) {
        UIView *old = [self viewWithTag:997];
        if (old) [old removeFromSuperview];
        return;
    }

    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:25 weight:UIImageSymbolWeightRegular];
    UIImage *icon = [UIImage systemImageNamed:@"ellipsis.circle" withConfiguration:config];
    if (!icon) icon = [UIImage systemImageNamed:@"ellipsis.circle"];

    BHTMenuButton *menuButton = (BHTMenuButton *)[self viewWithTag:997];
    if (!menuButton) {
        menuButton = [BHTMenuButton buttonWithType:UIButtonTypeCustom];
        menuButton.tag = 997;
        menuButton.tintColor = [UIColor whiteColor];
        menuButton.adjustsImageWhenHighlighted = NO;

        [menuButton setImage:icon forState:UIControlStateNormal];

        menuButton.layer.shadowColor = [UIColor blackColor].CGColor;
        menuButton.layer.shadowOffset = CGSizeMake(0, 1);
        menuButton.layer.shadowOpacity = 0.6f;
        menuButton.layer.shadowRadius = 2.0f;

        [menuButton addTarget:self action:@selector(bhtMenuButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [menuButton setImage:icon forState:UIControlStateNormal];
    }

    UIView *avatarView = [self bhtFindAvatarView:self];
    CGFloat btnW = 40.0;
    CGFloat btnH = 40.0;

    if (avatarView && (avatarView.window || avatarView.bounds.size.width > 0)) {
        CGRect avatarRect = [avatarView convertRect:avatarView.bounds toView:self];
        CGFloat btnX = CGRectGetMidX(avatarRect) - (btnW / 2.0);
        CGFloat btnY = avatarRect.origin.y - btnH + 6.0;
        menuButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    } else {
        CGFloat screenW = self.bounds.size.width > 0 ? self.bounds.size.width : [UIScreen mainScreen].bounds.size.width;
        CGFloat screenH = self.bounds.size.height > 0 ? self.bounds.size.height : [UIScreen mainScreen].bounds.size.height;
        CGFloat btnX = screenW - btnW - 14.0;
        CGFloat btnY = (screenH * 0.44) - btnH + 16.0;
        menuButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }

    if (menuButton.superview != self) {
        [menuButton removeFromSuperview];
        [self addSubview:menuButton];
    }
    [self bringSubviewToFront:menuButton];

    [self setupBHTikTokMenu:menuButton];
    menuButton.hidden = self.elementsHidden;
    menuButton.alpha = self.elementsHidden ? 0.0 : 1.0;
}
%new - (void)downloadHDVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://tikwm.com/video/media/hdplay/%@.mp4", as]];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadCoverImage:(AWEAwemeBaseViewController *)rootVC {
    AWEAwemeModel *model = rootVC.model;
    AWEURLModel *coverURLModel = model.video.originCover ?: (model.video.coverURL ?: model.video.dynamicCover);
    NSURL *downloadableURL = [coverURLModel bestURLtoDownload];
    if (!downloadableURL && coverURLModel.originURLList.count > 0) {
        downloadableURL = [NSURL URLWithString:coverURLModel.originURLList.firstObject];
    }
    if (!downloadableURL && coverURLModel.urlList.count > 0) {
        downloadableURL = [NSURL URLWithString:coverURLModel.urlList.firstObject];
    }

    if (!downloadableURL) {
        NSString *title = [BHIManager isTurkish] ? @"TweryTok, Selam" : @"TweryTok, Hi";
        NSString *desc = [BHIManager isTurkish] ? @"Kapak resmi bağlantısı bulunamadı." : @"Could not obtain cover image download URL.";
        NSString *ok = [BHIManager isTurkish] ? @"Tamam" : @"OK";
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
        return;
    }

    self.fileextension = [coverURLModel bestURLtoDownloadFormat] ?: @"jpeg";
    if ([self.fileextension isEqualToString:@"mp4"] || [self.fileextension isEqualToString:@"mp3"]) {
        self.fileextension = @"jpeg";
    }

    BHDownload *dwManager = [[BHDownload alloc] init];
    [dwManager downloadFileWithURL:downloadableURL];
    [dwManager setDelegate:self];
    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
    [self.hud showInView:topMostController().view];
}
%new - (void)downloadVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC photoIndex:(unsigned long)index {
    NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
    if (index >= photos.count) return;
    AWEPhotoAlbumPhoto *currentPhoto = [photos objectAtIndex:index];

    NSURL *downloadableURL = getDownloadURLForPhoto(currentPhoto);
    self.fileextension = getDownloadFormatForPhoto(currentPhoto);
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC {
    NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
    unsigned long photosCount = [photos count];
    NSMutableArray *downloadableURLs = [NSMutableArray array];
    for (int i = 0; i < photosCount; i++) {
        AWEPhotoAlbumPhoto *currentPhoto = [photos objectAtIndex:i];
        NSURL *url = getDownloadURLForPhoto(currentPhoto);
        if (url) {
            [downloadableURLs addObject:url];
        }
    }
    self.fileextension = getDownloadFormatForPhoto(photos.firstObject);
    if (downloadableURLs.count > 0) {
        BHMultipleDownload *dwManager = [[BHMultipleDownload alloc] init];
        [dwManager downloadFiles:downloadableURLs];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
    self.fileextension = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)copyMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
    } else {
        NSString *title = [BHIManager localizedString:@"TweryTok, Hi" tr:@"TweryTok, Selam"];
        NSString *desc = [BHIManager localizedString:@"Could not copy music link." tr:@"Müzik bağlantısı kopyalanamadı."];
        NSString *ok = [BHIManager localizedString:@"OK" tr:@"Tamam"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)copyVideo:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
    } else {
        NSString *title = [BHIManager localizedString:@"TweryTok, Hi" tr:@"TweryTok, Selam"];
        NSString *desc = [BHIManager localizedString:@"Could not copy video link." tr:@"Video bağlantısı kopyalanamadı."];
        NSString *ok = [BHIManager localizedString:@"OK" tr:@"Tamam"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)copyDecription:(AWEAwemeBaseViewController *)rootVC {
    NSString *video_description = nil;
    @try {
        video_description = [rootVC.model valueForKey:@"desc"];
    } @catch (__unused NSException *exception) {}
    if (video_description.length == 0) {
        video_description = rootVC.model.music_songName;
    }
    if (video_description.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
    } else {
        NSString *title = [BHIManager localizedString:@"TweryTok, Hi" tr:@"TweryTok, Selam"];
        NSString *desc = [BHIManager localizedString:@"Could not copy description." tr:@"Açıklama kopyalanamadı."];
        NSString *ok = [BHIManager localizedString:@"OK" tr:@"Tamam"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)downloaderProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    [self.hud dismiss];
    if ([BHIManager shareSheet]) {
        [BHIManager showSaveVC:downloadedFilePaths];
    }
    else {
        for (NSURL *url in downloadedFilePaths) {
            NSData *d = [NSData dataWithContentsOfURL:url];
            UIImage *img = d ? [UIImage imageWithData:d] : nil;
            if (img) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
                });
            }
        }
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    for (NSURL *url in downloadedFilePaths) {
                        NSData *data = [NSData dataWithContentsOfURL:url];
                        UIImage *img = data ? [UIImage imageWithData:data] : nil;
                        NSData *jpegData = img ? UIImageJPEGRepresentation(img, 1.0) : data;
                        if (jpegData && jpegData.length > 0) {
                            PHAssetCreationRequest *req = [PHAssetCreationRequest creationRequestForAsset];
                            [req addResourceWithType:PHAssetResourceTypePhoto data:jpegData options:nil];
                        } else {
                            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto fileURL:url options:options];
                        }
                    }
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        Class toastCls = NSClassFromString(@"AWEToast");
                        if ([toastCls respondsToSelector:@selector(showSuccess:)]) {
                            [toastCls showSuccess:[BHIManager isTurkish] ? @"Tüm Fotoğraflar Kaydedildi" : @"All Photos Saved"];
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Class toastCls = NSClassFromString(@"AWEToast");
                    if ([toastCls respondsToSelector:@selector(showSuccess:)]) {
                        [toastCls showSuccess:[BHIManager isTurkish] ? @"Tüm Fotoğraflar Kaydedildi" : @"All Photos Saved"];
                    }
                });
            }
        }];
    }
}
%new - (void)downloaderDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
    self.hud.tapOutsideBlock = ^(JGProgressHUD * _Nonnull HUD) {
        self.hud.textLabel.text = [BHIManager localizedString:@"Backgrounding ✌️" tr:@"Arka plana alındı ✌️"];
        [self.hud dismissAfterDelay:0.4];
    };
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    [self.hud dismiss];
    NSArray *audioExtensions = @[@"mp3", @"aac", @"wav", @"m4a", @"ogg", @"flac", @"aiff", @"wma"];
    if ([BHIManager shareSheet] || [audioExtensions containsObject:self.fileextension]) {
        [BHIManager showSaveVC:@[filePath]];
    }
    else {
        [BHIManager saveMedia:filePath fileExtension:self.fileextension ?: @"jpeg"];
    }
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end
%hook AWEAwemeDetailTableViewCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) UIProgressView *progressView;
%property (nonatomic, retain) NSString *fileextension;
- (void)configWithModel:(id)model {
    %orig;
    sCurrentActiveCell = self;
    self.elementsHidden = false;
    if ([BHIManager downloadButton]) {
        [self addBHTikTokMenuButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    sCurrentActiveCell = self;
    self.elementsHidden = false;
    if ([BHIManager downloadButton]) {
        [self addBHTikTokMenuButton];
    }
}
- (void)layoutSubviews {
    %orig;
    if ([BHIManager downloadButton]) {
        [self addBHTikTokMenuButton];
    } else {
        UIView *mirror = [self viewWithTag:996];
        if (mirror) [mirror removeFromSuperview];
        UIView *btn = [self viewWithTag:997];
        if (btn) [btn removeFromSuperview];
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *btn = [self viewWithTag:997];
    if (btn && !btn.hidden && btn.alpha > 0.05 && btn.userInteractionEnabled) {
        CGPoint pInBtn = [self convertPoint:point toView:btn];
        if ([btn pointInside:pInBtn withEvent:event]) {
            return btn;
        }
    }
    return %orig;
}
%new - (void)showBHTikTokDownloadActionSheet {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if (!rootVC) {
        UIResponder *r = self;
        while (r) {
            if ([r isKindOfClass:%c(AWEAwemeBaseViewController)]) {
                rootVC = (AWEAwemeBaseViewController *)r;
                break;
            }
            r = [r nextResponder];
        }
    }
    if (!rootVC) return;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[BHIManager isTurkish] ? @"TweryTok Menüsü" : @"TweryTok Menu" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if ([BHIManager hideElementButton]) {
        NSString *cleanTitle = self.elementsHidden ? ([BHIManager isTurkish] ? @"Ekranı Göster" : @"Show Elements") : ([BHIManager isTurkish] ? @"Ekranı Temizle" : @"Clean Screen");
        [alert addAction:[UIAlertAction actionWithTitle:cleanTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self toggleBHTikTokHideElements];
        }]];
    }

    if ([rootVC isKindOfClass:%c(AWEFeedCellViewController)]) {
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Video" tr:@"Videoyu İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadVideo:rootVC];
        }]];
        if ([BHIManager downloadCoverImage]) {
            [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Cover Image" tr:@"Kapak Resmini İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self downloadCoverImage:rootVC];
            }]];
        }

        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Music" tr:@"Müziği İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Video link" tr:@"Video Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyVideo:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Music link" tr:@"Müzik Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Decription" tr:@"Açıklamayı Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyDecription:rootVC];
        }]];
    } else if ([rootVC isKindOfClass:%c(TTKPhotoAlbumDetailCellController)] || [rootVC isKindOfClass:%c(TTKPhotoAlbumFeedCellController)]) {
        NSArray *photos = rootVC.model.photoAlbum.photos;
        unsigned long photosCount = [photos count];
        for (int i = 0; i < photosCount; i++) {
            NSString *title = [BHIManager isTurkish] ? [NSString stringWithFormat:@"%d. Fotoğrafı İndir", i+1] : [NSString stringWithFormat:@"Download Photo %d", i+1];
            [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [(id)self downloadPhotos:(id)rootVC photoIndex:i];
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download All Photos" tr:@"Tüm Fotoğrafları İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [(id)self downloadPhotos:(id)rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Music" tr:@"Müziği İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Video link" tr:@"Video Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyVideo:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Music link" tr:@"Müzik Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Decription" tr:@"Açıklamayı Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyDecription:rootVC];
        }]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Video" tr:@"Videoyu İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadVideo:rootVC];
        }]];
        if ([BHIManager downloadCoverImage]) {
            [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Cover Image" tr:@"Kapak Resmini İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self downloadCoverImage:rootVC];
            }]];
        }

        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Download Music" tr:@"Müziği İndir"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Video link" tr:@"Video Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyVideo:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Music link" tr:@"Müzik Bağlantısını Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyMusic:rootVC];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Copy Decription" tr:@"Açıklamayı Kopyala"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self copyDecription:rootVC];
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:[BHIManager localizedString:@"Cancel" tr:@"İptal"] style:UIAlertActionStyleCancel handler:nil]];

    UIViewController *top = topMostController();
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = top.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(top.view.bounds.size.width / 2.0, top.view.bounds.size.height / 2.0, 1.0, 1.0);
    }
    [top presentViewController:alert animated:YES completion:nil];
}
%new - (void)toggleBHTikTokHideElements {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC.interactionController isKindOfClass:%c(TTKFeedInteractionLegacyMainContainerElement)]) {
        TTKFeedInteractionLegacyMainContainerElement *interactionController = rootVC.interactionController;
        UIView *btn = [self viewWithTag:997];
        if (self.elementsHidden) {
            self.elementsHidden = false;
            [interactionController hideAllElements:false exceptArray:nil];
            if (btn) {
                btn.hidden = NO;
                btn.alpha = 1.0;
            }
        } else {
            self.elementsHidden = true;
            [interactionController hideAllElements:true exceptArray:nil];
            if (btn) {
                btn.hidden = YES;
                btn.alpha = 0.0;
            }
        }
    }
}
%new - (UIView *)bhtFindAvatarView:(UIView *)parent {
    if (!parent) return nil;
    if ([parent isKindOfClass:%c(AWEPlayInteractionUserAvatarView)]) {
        return parent;
    }
    for (UIView *sub in parent.subviews) {
        UIView *found = [self bhtFindAvatarView:sub];
        if (found) return found;
    }
    return nil;
}
%new - (void)setupBHTikTokMenu:(UIButton *)sender {
    if (!sender) return;
    BOOL tr = [BHIManager isTurkish];
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if (!rootVC) {
        UIResponder *r = self;
        while (r) {
            if ([r isKindOfClass:%c(AWEAwemeBaseViewController)]) {
                rootVC = (AWEAwemeBaseViewController *)r;
                break;
            }
            r = [r nextResponder];
        }
    }
    if (!rootVC) return;

    NSMutableArray *menuActions = [NSMutableArray array];

    if ([BHIManager hideElementButton]) {
        NSString *cleanTitle = self.elementsHidden ? (tr ? @"Ekranı Göster" : @"Show Elements") : (tr ? @"Ekranı Temizle" : @"Clean Screen");
        UIImage *cleanIcon = [UIImage systemImageNamed:self.elementsHidden ? @"eye" : @"eye.slash"];
        UIAction *cleanAction = [UIAction actionWithTitle:cleanTitle image:cleanIcon identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self toggleBHTikTokHideElements];
            [self setupBHTikTokMenu:sender];
        }];
        [menuActions addObject:cleanAction];
    }

    if ([rootVC isKindOfClass:%c(TTKPhotoAlbumDetailCellController)] || [rootVC isKindOfClass:%c(TTKPhotoAlbumFeedCellController)]) {
        NSArray *photos = rootVC.model.photoAlbum.photos;
        unsigned long photosCount = [photos count];
        for (int i = 0; i < photosCount; i++) {
            NSString *title = tr ? [NSString stringWithFormat:@"%d. Fotoğrafı İndir", i+1] : [NSString stringWithFormat:@"Download Photo %d", i+1];
            UIAction *pAction = [UIAction actionWithTitle:title image:[UIImage systemImageNamed:@"photo"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                [(id)self downloadPhotos:(id)rootVC photoIndex:i];
            }];
            [menuActions addObject:pAction];
        }
        UIAction *allPhotosAction = [UIAction actionWithTitle:tr ? @"Tüm Fotoğrafları İndir" : @"Download All Photos" image:[UIImage systemImageNamed:@"photo.on.rectangle"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [(id)self downloadPhotos:(id)rootVC];
        }];
        [menuActions addObject:allPhotosAction];
    } else {
        UIAction *dlVideoAction = [UIAction actionWithTitle:tr ? @"Videoyu İndir" : @"Download Video" image:[UIImage systemImageNamed:@"film"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self downloadVideo:rootVC];
        }];
        [menuActions addObject:dlVideoAction];
        if ([BHIManager downloadCoverImage]) {
            UIAction *dlCoverAction = [UIAction actionWithTitle:tr ? @"Kapak Resmini İndir" : @"Download Cover Image" image:[UIImage systemImageNamed:@"photo"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                [self downloadCoverImage:rootVC];
            }];
            [menuActions addObject:dlCoverAction];
        }
    }

    UIAction *dlMusicAction = [UIAction actionWithTitle:tr ? @"Müziği İndir" : @"Download Music" image:[UIImage systemImageNamed:@"music.note"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self downloadMusic:rootVC];
    }];
    [menuActions addObject:dlMusicAction];

    UIAction *copyVideoAction = [UIAction actionWithTitle:tr ? @"Video Bağlantısını Kopyala" : @"Copy Video link" image:[UIImage systemImageNamed:@"link"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self copyVideo:rootVC];
    }];
    UIAction *copyMusicAction = [UIAction actionWithTitle:tr ? @"Müzik Bağlantısını Kopyala" : @"Copy Music link" image:[UIImage systemImageNamed:@"link"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self copyMusic:rootVC];
    }];
    UIAction *copyDescAction = [UIAction actionWithTitle:tr ? @"Açıklamayı Kopyala" : @"Copy Description" image:[UIImage systemImageNamed:@"note.text"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self copyDecription:rootVC];
    }];

    UIMenu *copyMenu = [UIMenu menuWithTitle:tr ? @"Kopyalama Seçenekleri" : @"Copy Menu" image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil options:0 children:@[copyVideoAction, copyMusicAction, copyDescAction]];
    [menuActions addObject:copyMenu];

    UIMenu *mainMenu = [UIMenu menuWithTitle:tr ? @"TweryTok Menüsü" : @"TweryTok Menu" children:menuActions];
    [sender setMenu:mainMenu];
    sender.showsMenuAsPrimaryAction = YES;
}
%new - (void)bhtMenuButtonHandler:(UIButton *)sender {
    if (@available(iOS 14.0, *)) {
        [self setupBHTikTokMenu:sender];
    }
    [self showBHTikTokDownloadActionSheet];
}
%new - (void)addBHTikTokMenuButton {
    UIView *oldMirror = [self viewWithTag:996];
    if (oldMirror) [oldMirror removeFromSuperview];

    if (![BHIManager downloadButton]) {
        UIView *old = [self viewWithTag:997];
        if (old) [old removeFromSuperview];
        return;
    }

    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:25 weight:UIImageSymbolWeightRegular];
    UIImage *icon = [UIImage systemImageNamed:@"ellipsis.circle" withConfiguration:config];
    if (!icon) icon = [UIImage systemImageNamed:@"ellipsis.circle"];

    BHTMenuButton *menuButton = (BHTMenuButton *)[self viewWithTag:997];
    if (!menuButton) {
        menuButton = [BHTMenuButton buttonWithType:UIButtonTypeCustom];
        menuButton.tag = 997;
        menuButton.tintColor = [UIColor whiteColor];
        menuButton.adjustsImageWhenHighlighted = NO;

        [menuButton setImage:icon forState:UIControlStateNormal];

        menuButton.layer.shadowColor = [UIColor blackColor].CGColor;
        menuButton.layer.shadowOffset = CGSizeMake(0, 1);
        menuButton.layer.shadowOpacity = 0.6f;
        menuButton.layer.shadowRadius = 2.0f;

        [menuButton addTarget:self action:@selector(bhtMenuButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [menuButton setImage:icon forState:UIControlStateNormal];
    }

    UIView *avatarView = [self bhtFindAvatarView:self];
    CGFloat btnW = 40.0;
    CGFloat btnH = 40.0;

    if (avatarView && (avatarView.window || avatarView.bounds.size.width > 0)) {
        CGRect avatarRect = [avatarView convertRect:avatarView.bounds toView:self];
        CGFloat btnX = CGRectGetMidX(avatarRect) - (btnW / 2.0);
        CGFloat btnY = avatarRect.origin.y - btnH + 6.0;
        menuButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    } else {
        CGFloat screenW = self.bounds.size.width > 0 ? self.bounds.size.width : [UIScreen mainScreen].bounds.size.width;
        CGFloat screenH = self.bounds.size.height > 0 ? self.bounds.size.height : [UIScreen mainScreen].bounds.size.height;
        CGFloat btnX = screenW - btnW - 14.0;
        CGFloat btnY = (screenH * 0.44) - btnH + 16.0;
        menuButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }

    if (menuButton.superview != self) {
        [menuButton removeFromSuperview];
        [self addSubview:menuButton];
    }
    [self bringSubviewToFront:menuButton];

    [self setupBHTikTokMenu:menuButton];
    menuButton.hidden = self.elementsHidden;
    menuButton.alpha = self.elementsHidden ? 0.0 : 1.0;
}
%new - (void)downloadHDVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://tikwm.com/video/media/hdplay/%@.mp4", as]];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadCoverImage:(AWEAwemeBaseViewController *)rootVC {
    AWEAwemeModel *model = rootVC.model;
    AWEURLModel *coverURLModel = model.video.originCover ?: (model.video.coverURL ?: model.video.dynamicCover);
    NSURL *downloadableURL = [coverURLModel bestURLtoDownload];
    if (!downloadableURL && coverURLModel.originURLList.count > 0) {
        downloadableURL = [NSURL URLWithString:coverURLModel.originURLList.firstObject];
    }
    if (!downloadableURL && coverURLModel.urlList.count > 0) {
        downloadableURL = [NSURL URLWithString:coverURLModel.urlList.firstObject];
    }

    if (!downloadableURL) {
        NSString *title = [BHIManager isTurkish] ? @"TweryTok, Selam" : @"TweryTok, Hi";
        NSString *desc = [BHIManager isTurkish] ? @"Kapak resmi bağlantısı bulunamadı." : @"Could not obtain cover image download URL.";
        NSString *ok = [BHIManager isTurkish] ? @"Tamam" : @"OK";
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
        return;
    }

    self.fileextension = [coverURLModel bestURLtoDownloadFormat] ?: @"jpeg";
    if ([self.fileextension isEqualToString:@"mp4"] || [self.fileextension isEqualToString:@"mp3"]) {
        self.fileextension = @"jpeg";
    }

    BHDownload *dwManager = [[BHDownload alloc] init];
    [dwManager downloadFileWithURL:downloadableURL];
    [dwManager setDelegate:self];
    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
    [self.hud showInView:topMostController().view];
}
%new - (void)downloadVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC photoIndex:(unsigned long)index {
    NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
    if (index >= photos.count) return;
    AWEPhotoAlbumPhoto *currentPhoto = [photos objectAtIndex:index];

    NSURL *downloadableURL = getDownloadURLForPhoto(currentPhoto);
    self.fileextension = getDownloadFormatForPhoto(currentPhoto);
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC {
    NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
    unsigned long photosCount = [photos count];
    NSMutableArray *downloadableURLs = [NSMutableArray array];
    for (int i = 0; i < photosCount; i++) {
        AWEPhotoAlbumPhoto *currentPhoto = [photos objectAtIndex:i];
        NSURL *url = getDownloadURLForPhoto(currentPhoto);
        if (url) {
            [downloadableURLs addObject:url];
        }
    }
    self.fileextension = getDownloadFormatForPhoto(photos.firstObject);
    if (downloadableURLs.count > 0) {
        BHMultipleDownload *dwManager = [[BHMultipleDownload alloc] init];
        [dwManager downloadFiles:downloadableURLs];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
    self.fileextension = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)copyMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
    } else {
        NSString *title = [BHIManager localizedString:@"TweryTok, Hi" tr:@"TweryTok, Selam"];
        NSString *desc = [BHIManager localizedString:@"Could not copy music link." tr:@"Müzik bağlantısı kopyalanamadı."];
        NSString *ok = [BHIManager localizedString:@"OK" tr:@"Tamam"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)copyVideo:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
    } else {
        NSString *title = [BHIManager localizedString:@"TweryTok, Hi" tr:@"TweryTok, Selam"];
        NSString *desc = [BHIManager localizedString:@"Could not copy video link." tr:@"Video bağlantısı kopyalanamadı."];
        NSString *ok = [BHIManager localizedString:@"OK" tr:@"Tamam"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)copyDecription:(AWEAwemeBaseViewController *)rootVC {
    NSString *video_description = nil;
    @try {
        video_description = [rootVC.model valueForKey:@"desc"];
    } @catch (__unused NSException *exception) {}
    if (video_description.length == 0) {
        video_description = rootVC.model.music_songName;
    }
    if (video_description.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
    } else {
        NSString *title = [BHIManager localizedString:@"TweryTok, Hi" tr:@"TweryTok, Selam"];
        NSString *desc = [BHIManager localizedString:@"Could not copy description." tr:@"Açıklama kopyalanamadı."];
        NSString *ok = [BHIManager localizedString:@"OK" tr:@"Tamam"];
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)downloaderProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    [self.hud dismiss];
    if ([BHIManager shareSheet]) {
        [BHIManager showSaveVC:downloadedFilePaths];
    }
    else {
        for (NSURL *url in downloadedFilePaths) {
            NSData *d = [NSData dataWithContentsOfURL:url];
            UIImage *img = d ? [UIImage imageWithData:d] : nil;
            if (img) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
                });
            }
        }
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    for (NSURL *url in downloadedFilePaths) {
                        NSData *data = [NSData dataWithContentsOfURL:url];
                        UIImage *img = data ? [UIImage imageWithData:data] : nil;
                        NSData *jpegData = img ? UIImageJPEGRepresentation(img, 1.0) : data;
                        if (jpegData && jpegData.length > 0) {
                            PHAssetCreationRequest *req = [PHAssetCreationRequest creationRequestForAsset];
                            [req addResourceWithType:PHAssetResourceTypePhoto data:jpegData options:nil];
                        } else {
                            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto fileURL:url options:options];
                        }
                    }
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        Class toastCls = NSClassFromString(@"AWEToast");
                        if ([toastCls respondsToSelector:@selector(showSuccess:)]) {
                            [toastCls showSuccess:[BHIManager isTurkish] ? @"Tüm Fotoğraflar Kaydedildi" : @"All Photos Saved"];
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    Class toastCls = NSClassFromString(@"AWEToast");
                    if ([toastCls respondsToSelector:@selector(showSuccess:)]) {
                        [toastCls showSuccess:[BHIManager isTurkish] ? @"Tüm Fotoğraflar Kaydedildi" : @"All Photos Saved"];
                    }
                });
            }
        }];
    }
}
%new - (void)downloaderDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
    self.hud.tapOutsideBlock = ^(JGProgressHUD * _Nonnull HUD) {
        self.hud.textLabel.text = [BHIManager localizedString:@"Backgrounding ✌️" tr:@"Arka plana alındı ✌️"];
        [self.hud dismissAfterDelay:0.4];
    };
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    [self.hud dismiss];
    NSArray *audioExtensions = @[@"mp3", @"aac", @"wav", @"m4a", @"ogg", @"flac", @"aiff", @"wma"];
    if ([BHIManager shareSheet] || [audioExtensions containsObject:self.fileextension]) {
        [BHIManager showSaveVC:@[filePath]];
    }
    else {
        [BHIManager saveMedia:filePath fileExtension:self.fileextension ?: @"jpeg"];
    }
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end

@interface BHTStoryDownloader : NSObject <BHDownloadDelegate, BHMultipleDownloadDelegate>
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, strong) NSString *fileextension;
+ (instancetype)shared;
- (void)downloadStoryModel:(AWEAwemeModel *)rawModel;
@end

@implementation BHTStoryDownloader
+ (instancetype)shared {
    static BHTStoryDownloader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BHTStoryDownloader alloc] init];
    });
    return instance;
}

- (void)downloadStoryModel:(AWEAwemeModel *)rawModel {
    if (!rawModel && sCurrentActiveStoryCell) {
        rawModel = [sCurrentActiveStoryCell bht_storyModel];
    }
    if (!rawModel) {
        NSString *title = [BHIManager isTurkish] ? @"TweryTok, Selam" : @"TweryTok, Hi";
        NSString *desc = [BHIManager isTurkish] ? @"Hikaye medyası bulunamadı." : @"Could not find story media.";
        NSString *ok = [BHIManager isTurkish] ? @"Tamam" : @"OK";
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
        return;
    }

    AWEAwemeModel *model = rawModel.currentPlayingStory ?: rawModel;

    // Check multiple photos first
    if (model.photoAlbum.photos.count > 1) {
        NSMutableArray *urls = [NSMutableArray array];
        for (AWEPhotoAlbumPhoto *p in model.photoAlbum.photos) {
            NSURL *u = getDownloadURLForPhoto(p);
            if (u) [urls addObject:u];
        }
        if (urls.count > 0) {
            self.fileextension = getDownloadFormatForPhoto(model.photoAlbum.photos.firstObject);
            BHMultipleDownload *dwManager = [[BHMultipleDownload alloc] init];
            [dwManager downloadFiles:urls];
            [dwManager setDelegate:self];
            self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
            [self.hud showInView:topMostController().view];
            return;
        }
    }

    NSURL *downloadURL = nil;
    NSString *format = nil;

    // 1. Single photo in photo album
    if (model.photoAlbum.photos.count > 0) {
        AWEPhotoAlbumPhoto *firstPhoto = model.photoAlbum.photos.firstObject;
        downloadURL = getDownloadURLForPhoto(firstPhoto);
        format = getDownloadFormatForPhoto(firstPhoto);
    }

    // 2. Video story
    if (!downloadURL && model.video.playURL) {
        downloadURL = [model.video.playURL bestURLtoDownload];
        if (!downloadURL && model.video.playURL.originURLList.count > 0) {
            downloadURL = [NSURL URLWithString:model.video.playURL.originURLList.firstObject];
        }
        format = [model.video.playURL bestURLtoDownloadFormat] ?: @"mp4";
    }

    // 3. Fallback originCover for photo story
    if (!downloadURL && model.video.originCover) {
        downloadURL = [model.video.originCover bestURLtoDownload];
        if (!downloadURL && model.video.originCover.originURLList.count > 0) {
            downloadURL = [NSURL URLWithString:model.video.originCover.originURLList.firstObject];
        }
        format = [model.video.originCover bestURLtoDownloadFormat] ?: @"jpeg";
    }

    if (!downloadURL) {
        NSString *title = [BHIManager isTurkish] ? @"TweryTok, Selam" : @"TweryTok, Hi";
        NSString *desc = [BHIManager isTurkish] ? @"Hikaye indirme bağlantısı alınamadı." : @"Could not obtain story download URL.";
        NSString *ok = [BHIManager isTurkish] ? @"Tamam" : @"OK";
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
        return;
    }

    self.fileextension = format;
    BHDownload *dwManager = [[BHDownload alloc] init];
    [dwManager downloadFileWithURL:downloadURL];
    [dwManager setDelegate:self];

    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    self.hud.textLabel.text = [BHIManager localizedString:@"Downloading" tr:@"İndiriliyor"];
    [self.hud showInView:topMostController().view];
}

- (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
    __weak typeof(self) weakSelf = self;
    self.hud.tapOutsideBlock = ^(JGProgressHUD * _Nonnull HUD) {
        weakSelf.hud.textLabel.text = [BHIManager localizedString:@"Backgrounding ✌️" tr:@"Arka plana alındı ✌️"];
        [weakSelf.hud dismissAfterDelay:0.4];
    };
}

- (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:docPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [NSUUID UUID].UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
    [self.hud dismiss];

    NSArray *audioExtensions = @[@"mp3", @"aac", @"wav", @"m4a", @"ogg", @"flac", @"aiff", @"wma"];
    if ([BHIManager shareSheet] || [audioExtensions containsObject:self.fileextension]) {
        [BHIManager showSaveVC:@[newFilePath]];
    } else {
        [BHIManager saveMedia:newFilePath fileExtension:self.fileextension];
        [%c(AWEToast) showSuccess:[BHIManager isTurkish] ? @"Hikaye Kaydedildi" : @"Story Saved"];
    }
}

- (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
        NSString *title = [BHIManager isTurkish] ? @"Hata" : @"Error";
        NSString *desc = [BHIManager isTurkish] ? @"Hikaye indirilemedi." : @"Failed to download story.";
        NSString *ok = [BHIManager isTurkish] ? @"Tamam" : @"OK";
        [%c(AWEUIAlertView) showAlertWithTitle:title description:desc image:nil actionButtonTitle:ok cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}

- (void)downloaderProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}

- (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    for (NSURL *filePath in downloadedFilePaths) {
        NSURL *newFilePath = [[NSURL fileURLWithPath:docPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [NSUUID UUID].UUIDString, self.fileextension]];
        [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
        [BHIManager saveMedia:newFilePath fileExtension:self.fileextension];
    }
    [self.hud dismiss];
    [%c(AWEToast) showSuccess:[BHIManager isTurkish] ? @"Hikaye Fotoğrafları Kaydedildi" : @"Story Photos Saved"];
}

- (void)downloaderDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
@end

static AWEShareItem *createStoryDownloadItem(id templateItem, AWEAwemeModel *aweme) {
    AWEShareItem *dlItem = nil;
    Class dlChannelClass = %c(AWEDownloadShareChannel);
    if (dlChannelClass) {
        @try {
            AWEDownloadShareChannel *channel = [[dlChannelClass alloc] init];
            NSUInteger st = 1;
            if (templateItem && [templateItem respondsToSelector:NSSelectorFromString(@"style")]) {
                @try {
                    st = [[templateItem valueForKey:@"style"] unsignedIntegerValue];
                } @catch (__unused NSException *e) {}
            }
            dlItem = [channel makeItemWithStyle:st inView:nil];
        } @catch (__unused NSException *e) {}
    }
    if (!dlItem) {
        Class itemClass = %c(AWEShareItem);
        if (itemClass) {
            @try {
                dlItem = [[itemClass alloc] initWithType:@"bht_story_download"];
            } @catch (__unused NSException *e) {}
        }
    }
    if (!dlItem) return nil;

    [dlItem setTitle:[BHIManager isTurkish] ? @"İndir" : @"Download"];
    UIImage *img = [UIImage systemImageNamed:@"arrow.down.to.line.compact"] ?: [UIImage systemImageNamed:@"arrow.down"];
    if (img) {
        [dlItem setImage:img];
    }
    if (templateItem) {
        @try {
            if ([templateItem respondsToSelector:NSSelectorFromString(@"shareCategory")]) {
                [dlItem setShareCategory:[[templateItem valueForKey:@"shareCategory"] unsignedIntegerValue]];
            }
            if ([templateItem respondsToSelector:NSSelectorFromString(@"style")]) {
                [dlItem setStyle:[[templateItem valueForKey:@"style"] unsignedIntegerValue]];
            }
            if ([templateItem respondsToSelector:NSSelectorFromString(@"iconColorName")]) {
                [dlItem setIconColorName:[templateItem valueForKey:@"iconColorName"]];
            }
            if ([templateItem respondsToSelector:NSSelectorFromString(@"titleColorName")]) {
                [dlItem setTitleColorName:[templateItem valueForKey:@"titleColorName"]];
            }
            if ([templateItem respondsToSelector:NSSelectorFromString(@"iconBackgroundColorName")]) {
                [dlItem setIconBackgroundColorName:[templateItem valueForKey:@"iconBackgroundColorName"]];
            }
        } @catch (__unused NSException *e) {}
    }
    [dlItem setEnabled:YES];

    __weak AWEAwemeModel *weakAweme = aweme;
    [dlItem registerHandler:^(id item) {
        UIViewController *top = topMostController();
        [top dismissViewControllerAnimated:YES completion:^{
            AWEAwemeModel *m = weakAweme ?: sCurrentShareAweme;
            [[BHTStoryDownloader shared] downloadStoryModel:m];
        }];
    } forEvents:1];

    return dlItem;
}



@implementation BHTStoryProgressBar
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;

        _trackBgView = [[UIView alloc] init];
        _trackBgView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
        _trackBgView.layer.cornerRadius = 2.0;
        _trackBgView.layer.masksToBounds = YES;
        _trackBgView.userInteractionEnabled = NO;
        [self addSubview:_trackBgView];

        _trackFillView = [[UIView alloc] init];
        _trackFillView.backgroundColor = [UIColor whiteColor];
        _trackFillView.layer.cornerRadius = 2.0;
        _trackFillView.layer.masksToBounds = YES;
        _trackFillView.userInteractionEnabled = NO;
        [self addSubview:_trackFillView];

        _thumbView = [[UIView alloc] init];
        _thumbView.backgroundColor = [UIColor whiteColor];
        _thumbView.layer.cornerRadius = 6.0;
        _thumbView.layer.shadowColor = [UIColor blackColor].CGColor;
        _thumbView.layer.shadowOpacity = 0.5;
        _thumbView.layer.shadowRadius = 2.0;
        _thumbView.layer.shadowOffset = CGSizeMake(0, 1);
        _thumbView.userInteractionEnabled = NO;
        [self addSubview:_thumbView];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat trackH = 4.0;
    CGFloat trackY = (h - trackH) / 2.0;

    _trackBgView.frame = CGRectMake(0, trackY, w, trackH);
    CGFloat fillW = w * _progress;
    if (fillW < 0) fillW = 0;
    if (fillW > w) fillW = w;
    _trackFillView.frame = CGRectMake(0, trackY, fillW, trackH);

    CGFloat thumbD = _isDragging ? 16.0 : 12.0;
    _thumbView.layer.cornerRadius = thumbD / 2.0;
    CGFloat thumbX = fillW - (thumbD / 2.0);
    if (thumbX < 0) thumbX = 0;
    if (thumbX > w - thumbD) thumbX = w - thumbD;
    CGFloat thumbY = (h - thumbD) / 2.0;
    _thumbView.frame = CGRectMake(thumbX, thumbY, thumbD, thumbD);
}

- (void)updateProgress:(CGFloat)p {
    if (p < 0.0) p = 0.0;
    if (p > 1.0) p = 1.0;
    _progress = p;
    [self setNeedsLayout];
}

- (void)seekToPercent:(CGFloat)percent {
    if (sCurrentActivePlayerController && [sCurrentActivePlayerController respondsToSelector:@selector(totalDuration)]) {
        double total = [sCurrentActivePlayerController totalDuration];
        if (total > 0) {
            double targetTime = total * percent;
            if ([sCurrentActivePlayerController respondsToSelector:@selector(seekToTime:completion:)]) {
                [sCurrentActivePlayerController seekToTime:targetTime completion:nil];
                return;
            } else if ([sCurrentActivePlayerController respondsToSelector:@selector(setPlayerSeekTime:completion:)]) {
                [sCurrentActivePlayerController setPlayerSeekTime:targetTime completion:nil];
                return;
            }
        }
    }
    if (sCurrentActivePlayerController && [sCurrentActivePlayerController respondsToSelector:@selector(seekToPercent:completeBlock:)]) {
        [sCurrentActivePlayerController seekToPercent:percent completeBlock:nil];
        return;
    }
    if (sCurrentActiveVideoEngine && [sCurrentActiveVideoEngine respondsToSelector:@selector(duration)]) {
        double dur = [sCurrentActiveVideoEngine duration];
        if (dur > 0) {
            double targetTime = dur * percent;
            if ([sCurrentActiveVideoEngine respondsToSelector:@selector(setCurrentPlaybackTime:complete:)]) {
                [sCurrentActiveVideoEngine setCurrentPlaybackTime:targetTime complete:nil];
            } else if ([sCurrentActiveVideoEngine respondsToSelector:@selector(setCurrentPlaybackTime:)]) {
                [sCurrentActiveVideoEngine setCurrentPlaybackTime:targetTime];
            }
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    CGPoint pt = [sender locationInView:self];
    CGFloat w = self.bounds.size.width;
    if (w <= 0) return;
    CGFloat p = pt.x / w;
    [self updateProgress:p];
    [self seekToPercent:p];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint pt = [sender locationInView:self];
    CGFloat w = self.bounds.size.width;
    if (w <= 0) return;
    CGFloat p = pt.x / w;
    if (p < 0.0) p = 0.0;
    if (p > 1.0) p = 1.0;

    if (sender.state == UIGestureRecognizerStateBegan) {
        _isDragging = YES;
        [self updateProgress:p];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        [self updateProgress:p];
        [self seekToPercent:p];
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        _isDragging = NO;
        [self updateProgress:p];
        [self seekToPercent:p];
    }
}

- (void)startTimer {
    [self stopTimer];
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf tick];
    }];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)tick {
    if (_isDragging) return;
    if (!self.window || self.hidden || self.alpha <= 0.01) return;

    double curr = 0;
    double total = 0;
    if (sCurrentActivePlayerController && [sCurrentActivePlayerController respondsToSelector:@selector(currentPlaybackTime)]) {
        curr = [sCurrentActivePlayerController currentPlaybackTime];
    } else if (sCurrentActiveVideoEngine && [sCurrentActiveVideoEngine respondsToSelector:@selector(currentPlaybackTime)]) {
        curr = [sCurrentActiveVideoEngine currentPlaybackTime];
    }

    if (sCurrentActivePlayerController && [sCurrentActivePlayerController respondsToSelector:@selector(totalDuration)]) {
        total = [sCurrentActivePlayerController totalDuration];
    } else if (sCurrentActiveVideoEngine && [sCurrentActiveVideoEngine respondsToSelector:@selector(duration)]) {
        total = [sCurrentActiveVideoEngine duration];
    }

    if (total > 0.1) {
        [self updateProgress:(CGFloat)(curr / total)];
    }
}

- (void)dealloc {
    [self stopTimer];
}
@end

static void bht_layoutProgressBarInView(UIView *parentView) {
    if (!parentView) return;

    // Ensure only ONE progress bar ever exists across the window
    UIWindow *win = parentView.window ?: [UIApplication sharedApplication].keyWindow;
    if (win) {
        NSMutableArray *queue = [NSMutableArray arrayWithObject:win];
        while (queue.count > 0) {
            UIView *cur = queue.firstObject;
            [queue removeObjectAtIndex:0];
            if (cur.tag == 99871 && cur.superview != parentView) {
                [(BHTStoryProgressBar *)cur stopTimer];
                [cur removeFromSuperview];
            }
            for (UIView *sub in cur.subviews) {
                [queue addObject:sub];
            }
        }
    }

    BHTStoryProgressBar *bar = (BHTStoryProgressBar *)[parentView viewWithTag:99871];
    if (![BHIManager progressBar]) {
        if (bar) {
            [bar stopTimer];
            [bar removeFromSuperview];
        }
        return;
    }
    if (!bar) {
        bar = [[BHTStoryProgressBar alloc] initWithFrame:CGRectZero];
        bar.tag = 99871;
        [parentView addSubview:bar];
    }
    CGFloat screenW = parentView.bounds.size.width;
    CGFloat screenH = parentView.bounds.size.height;
    if (screenW <= 0 || screenH <= 0) return;

    CGFloat margin = 16.0;
    CGFloat barH = 26.0;
    CGFloat bottomOffset = 90.0;
    if (@available(iOS 11.0, *)) {
        if (parentView.safeAreaInsets.bottom > 0) {
            bottomOffset = parentView.safeAreaInsets.bottom + 58.0;
        }
    }
    CGFloat barY = screenH - bottomOffset - barH;
    bar.frame = CGRectMake(margin, barY, screenW - (margin * 2.0), barH);
    [parentView bringSubviewToFront:bar];
    [bar startTimer];
}

%hook TTKStory2FeedViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    bht_layoutProgressBarInView(self.view);
}
- (void)viewDidLayoutSubviews {
    %orig;
    bht_layoutProgressBarInView(self.view);
}
- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    BHTStoryProgressBar *bar = [self.view viewWithTag:99871];
    if (bar) [bar stopTimer];
}
%new - (void)bht_layoutStoryProgressBar {
    bht_layoutProgressBarInView(self.view);
}
%end

%hook TTKShareConfiguration
- (id)initWithShareContext:(id)context {
    id res = %orig;
    @try {
        if ([context respondsToSelector:NSSelectorFromString(@"aweme")]) {
            sCurrentShareAweme = [context valueForKey:@"aweme"];
        } else if ([context respondsToSelector:@selector(model)]) {
            sCurrentShareAweme = (id)[context model];
        }
    } @catch (__unused NSException *e) {}
    return res;
}
%end

%hook AWEAwemeModel
- (BOOL)preventDownload {
    if ([BHIManager downloadStory] && self.isStory) {
        return NO;
    }
    return %orig;
}
- (BOOL)allowDownload {
    if ([BHIManager downloadStory] && self.isStory) {
        return YES;
    }
    return %orig;
}
- (BOOL)allowDownloadPhoto {
    if ([BHIManager downloadStory] && self.isStory) {
        return YES;
    }
    return %orig;
}
- (BOOL)allowDownloadWithoutWatermark {
    if ([BHIManager downloadStory] && self.isStory) {
        return YES;
    }
    return %orig;
}
%end

%hook AWEDownloadShareChannel
- (BOOL)prepareWithContext:(id)context {
    if ([BHIManager downloadStory]) {
        return YES;
    }
    return %orig;
}
- (BOOL)isShareItemEnabled {
    if ([BHIManager downloadStory]) {
        return YES;
    }
    return %orig;
}
- (void)shareWithCompletion:(id)completion {
    if ([BHIManager downloadStory]) {
        AWEAwemeModel *m = sCurrentShareAweme;
        if (!m && [self.context respondsToSelector:NSSelectorFromString(@"aweme")]) {
            m = [self.context valueForKey:@"aweme"];
        }
        if (m && (m.isStory || sCurrentActiveStoryCell)) {
            UIViewController *top = topMostController();
            [top dismissViewControllerAnimated:YES completion:^{
                [[BHTStoryDownloader shared] downloadStoryModel:m];
            }];
            if (completion) {
                ((void (^)(BOOL, NSError *))completion)(YES, nil);
            }
            return;
        }
    }
    %orig;
}
%end

%hook TTKNSharePanelViewModel
- (NSArray *)groupedActionItems {
    NSArray *orig = %orig;
    if (![BHIManager downloadStory]) return orig;
    if (!orig || orig.count == 0) return orig;

    BOOL isStory = NO;
    AWEAwemeModel *storyModel = sCurrentShareAweme;
    if (storyModel && storyModel.isStory) isStory = YES;
    if (!isStory && sCurrentActiveStoryCell) {
        isStory = YES;
        if (!storyModel) storyModel = [sCurrentActiveStoryCell bht_storyModel];
    }
    UIViewController *top = topMostController();
    if (!isStory && ([top isKindOfClass:%c(TTKStory2FeedViewController)] || [top.presentingViewController isKindOfClass:%c(TTKStory2FeedViewController)])) {
        isStory = YES;
    }
    if (!isStory) return orig;

    id firstSec = orig.firstObject;
    if ([firstSec isKindOfClass:[NSArray class]]) {
        NSArray *firstSection = (NSArray *)firstSec;
        if (firstSection.count > 0) {
            for (id it in firstSection) {
                if ([it respondsToSelector:@selector(title)] && ([[it title] isEqualToString:@"İndir"] || [[it title] isEqualToString:@"Download"])) {
                    return orig;
                }
            }
            id templateItem = firstSection.firstObject;
            AWEShareItem *dlItem = createStoryDownloadItem(templateItem, storyModel);
            if (dlItem) {
                NSMutableArray *newFirstSection = [NSMutableArray arrayWithObject:dlItem];
                [newFirstSection addObjectsFromArray:firstSection];
                NSMutableArray *newGroups = [orig mutableCopy];
                newGroups[0] = newFirstSection;
                return newGroups;
            }
        }
    }
    return orig;
}

- (NSArray *)actionRowItems {
    NSArray *orig = %orig;
    if (![BHIManager downloadStory]) return orig;
    if (!orig || orig.count == 0) return orig;

    BOOL isStory = NO;
    AWEAwemeModel *storyModel = sCurrentShareAweme;
    if (storyModel && storyModel.isStory) isStory = YES;
    if (!isStory && sCurrentActiveStoryCell) {
        isStory = YES;
        if (!storyModel) storyModel = [sCurrentActiveStoryCell bht_storyModel];
    }
    UIViewController *top = topMostController();
    if (!isStory && ([top isKindOfClass:%c(TTKStory2FeedViewController)] || [top.presentingViewController isKindOfClass:%c(TTKStory2FeedViewController)])) {
        isStory = YES;
    }
    if (!isStory) return orig;

    for (id it in orig) {
        if ([it respondsToSelector:@selector(title)] && ([[it title] isEqualToString:@"İndir"] || [[it title] isEqualToString:@"Download"])) {
            return orig;
        }
    }

    id templateItem = orig.firstObject;
    AWEShareItem *dlItem = createStoryDownloadItem(templateItem, storyModel);
    if (dlItem) {
        NSMutableArray *newItems = [NSMutableArray arrayWithObject:dlItem];
        [newItems addObjectsFromArray:orig];
        return newItems;
    }
    return orig;
}

- (NSArray *)secondRowItems {
    NSArray *orig = %orig;
    if (![BHIManager downloadStory]) return orig;
    if (!orig || orig.count == 0) return orig;

    BOOL isStory = NO;
    AWEAwemeModel *storyModel = sCurrentShareAweme;
    if (storyModel && storyModel.isStory) isStory = YES;
    if (!isStory && sCurrentActiveStoryCell) {
        isStory = YES;
        if (!storyModel) storyModel = [sCurrentActiveStoryCell bht_storyModel];
    }
    UIViewController *top = topMostController();
    if (!isStory && ([top isKindOfClass:%c(TTKStory2FeedViewController)] || [top.presentingViewController isKindOfClass:%c(TTKStory2FeedViewController)])) {
        isStory = YES;
    }
    if (!isStory) return orig;

    for (id it in orig) {
        if ([it respondsToSelector:@selector(title)] && ([[it title] isEqualToString:@"İndir"] || [[it title] isEqualToString:@"Download"])) {
            return orig;
        }
    }

    id templateItem = orig.firstObject;
    AWEShareItem *dlItem = createStoryDownloadItem(templateItem, storyModel);
    if (dlItem) {
        NSMutableArray *newItems = [NSMutableArray arrayWithObject:dlItem];
        [newItems addObjectsFromArray:orig];
        return newItems;
    }
    return orig;
}
%end

%hook AWEURLModel
%new - (NSString *)bestURLtoDownloadFormat {
    NSString *bestURLFormat = nil;
    NSArray *list = self.originURLList.count > 0 ? self.originURLList : self.urlList;
    for (NSString *url in list) {
        NSString *lower = [url lowercaseString];
        if ([lower containsString:@"video_mp4"] || [lower containsString:@".mp4"]) {
            bestURLFormat = @"mp4";
            break;
        } else if ([lower containsString:@"jpeg"] || [lower containsString:@"jpg"]) {
            bestURLFormat = @"jpeg";
            break;
        } else if ([lower containsString:@"png"]) {
            bestURLFormat = @"png";
            break;
        } else if ([lower containsString:@"heic"] || [lower containsString:@"heif"]) {
            bestURLFormat = @"heic";
            break;
        } else if ([lower containsString:@"webp"]) {
            bestURLFormat = @"webp";
            break;
        } else if ([lower containsString:@".mp3"] || [lower containsString:@"audio_mp3"]) {
            bestURLFormat = @"mp3";
            break;
        } else if ([lower containsString:@".m4a"] || [lower containsString:@"audio_m4a"]) {
            bestURLFormat = @"m4a";
            break;
        }
    }
    if (bestURLFormat == nil) {
        bestURLFormat = @"mp4";
    }

    return bestURLFormat;
}
%new - (NSURL *)bestURLtoDownload {
    NSURL *bestURL = nil;
    NSArray *list = self.originURLList.count > 0 ? self.originURLList : self.urlList;
    for (NSString *url in list) {
        NSString *lower = [url lowercaseString];
        if ([lower containsString:@"video_mp4"] || [lower containsString:@"jpeg"] || [lower containsString:@"jpg"] || [lower containsString:@"png"] || [lower containsString:@"webp"] || [lower containsString:@".mp3"]) {
            bestURL = [NSURL URLWithString:url];
            break;
        }
    }

    if (bestURL == nil && list.count > 0) {
        bestURL = [NSURL URLWithString:[list firstObject]];
    }

    return bestURL;
}
%end

%hook NSFileManager
-(BOOL)fileExistsAtPath:(id)arg1 {
	for (NSString *file in jailbreakPaths) {
		if ([arg1 isEqualToString:file]) {
			return NO;
		}
	}
	return %orig;
}
-(BOOL)fileExistsAtPath:(id)arg1 isDirectory:(BOOL*)arg2 {
	for (NSString *file in jailbreakPaths) {
		if ([arg1 isEqualToString:file]) {
			return NO;
		}
	}
	return %orig;
}
%end
%hook BDADeviceHelper
+(bool)isJailBroken {
	return NO;
}
%end

%hook UIDevice
+(bool)btd_isJailBroken {
	return NO;
}
%end

%hook TTInstallUtil
+(bool)isJailBroken {
	return NO;
}
%end

%hook AppsFlyerUtils
+(bool)isJailbrokenWithSkipAdvancedJailbreakValidation:(bool)arg2 {
	return NO;
}
%end

%hook PIPOIAPStoreManager
-(bool)_pipo_isJailBrokenDeviceWithProductID:(id)arg2 orderID:(id)arg3 {
	return NO;
}
%end

%hook IESLiveDeviceInfo
+(bool)isJailBroken {
	return NO;
}
%end

%hook PIPOStoreKitHelper
-(bool)isJailBroken {
	return NO;
}
%end

%hook BDInstallNetworkUtility
+(bool)isJailBroken {
	return NO;
}
%end

%hook TTAdSplashDeviceHelper
+(bool)isJailBroken {
	return NO;
}
%end

%hook GULAppEnvironmentUtil
+(bool)isFromAppStore {
	return YES;
}
+(bool)isAppStoreReceiptSandbox {
	return NO;
}
+(bool)isAppExtension {
	return YES;
}
%end

%hook FBSDKAppEventsUtility
+(bool)isDebugBuild {
	return NO;
}
%end

%hook AWEAPMManager
+(id)signInfo {
	return @"AppStore";
}
%end

%hook NSBundle
-(id)pathForResource:(id)arg1 ofType:(id)arg2 {
	if ([arg2 isEqualToString:@"mobileprovision"]) {
		return nil;
	}
	return %orig;
}
%end
%hook AWESecurity
- (void)resetCollectMode {
	return;
}
%end
%hook MSManagerOV
- (id)setMode {
	return (id (^)(id)) ^{
	};
}
%end
%hook MSConfigOV
- (id)setMode {
	return (id (^)(id)) ^{
	};
}
%end

// Custom offline videos limit (Settings -> Offline Videos -> Videos Limit; key: offline_videos_limit,
// 0/absent = stock behavior). AWEOfflineVideoConfigUtils is the single config authority for the
// offline-videos feature: shouldDownloadCount feeds the download flow, getFinalCountWithCount:
// clamps a requested count to the stock tier cap, isAtMaxDownloadCount stops refills at the cap.
%hook AWEOfflineVideoConfigUtils
+ (NSInteger)shouldDownloadCount {
    NSNumber *custom = [BHIManager offlineVideosLimit];
    if (custom != nil && [custom integerValue] > 0) {
        return [custom integerValue];
    }
    return %orig;
}
+ (NSInteger)defaultShouldDownloadCount {
    NSNumber *custom = [BHIManager offlineVideosLimit];
    if (custom != nil && [custom integerValue] > 0) {
        return [custom integerValue];
    }
    return %orig;
}
+ (int)getFinalCountWithCount:(int)count {
    // only ever raise the stock clamp, never shrink it or alter sentinel values
    int stock = %orig;
    NSNumber *custom = [BHIManager offlineVideosLimit];
    if (custom != nil && [custom integerValue] > 0 && count > stock) {
        return count;
    }
    return stock;
}
+ (BOOL)isAtMaxDownloadCount {
    NSNumber *custom = [BHIManager offlineVideosLimit];
    if (custom != nil && [custom integerValue] > 0) {
        return NO; // don't stop refilling at the stock cap
    }
    return %orig;
}
%end

// Labs: A/B experiment overrides (Settings -> Labs -> A/B Experiment Explorer; key: ab_overrides).
// These are the Libra/ClientAB read accessors verified in MusicallyCore 46.5.0 ObjC metadata.
// The Labs editor preserves original value types, so returning the boxed override is type-safe.
// NOTE: do NOT hook ABTestMonitor*/exposure paths (tracking) — overrides stay local-only.
%hook AWEABTestManager
- (id)getStableValueWithKey:(id)key {
    id override = [BHIManager abOverrides][key];
    if (override) {
        return override;
    }
    return %orig;
}
- (id)getUidABTestValue:(id)key stable:(BOOL)stable defaultValue:(id)defaultValue {
    id override = [BHIManager abOverrides][key];
    if (override) {
        return override;
    }
    return %orig;
}
%end

%hook TTKClientABTestService
- (id)clientABValueFor:(id)key {
    id override = [BHIManager abOverrides][key];
    if (override) {
        return override;
    }
    return %orig;
}
%end



%ctor {
    jailbreakPaths = @[
        @"/Applications/Cydia.app", @"/Applications/blackra1n.app",
        @"/Applications/FakeCarrier.app", @"/Applications/Icy.app",
        @"/Applications/IntelliScreen.app", @"/Applications/MxTube.app",
        @"/Applications/RockApp.app", @"/Applications/SBSettings.app", @"/Applications/WinterBoard.app",
        @"/.cydia_no_stash", @"/.installed_unc0ver", @"/.bootstrapped_electra",
        @"/usr/libexec/cydia/firmware.sh", @"/usr/libexec/ssh-keysign", @"/usr/libexec/sftp-server",
        @"/usr/bin/ssh", @"/usr/bin/sshd", @"/usr/sbin/sshd",
        @"/var/lib/cydia", @"/var/lib/dpkg/info/mobilesubstrate.md5sums",
        @"/var/log/apt", @"/usr/share/jailbreak/injectme.plist", @"/usr/sbin/frida-server",
        @"/Library/MobileSubstrate/CydiaSubstrate.dylib", @"/Library/TweakInject",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib", @"Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist", @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        @"/System/Library/LaunchDaemons/com.ikey.bbot.plist", @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist", @"/System/Library/CoreServices/SystemVersion.plist",
        @"/private/var/mobile/Library/SBSettings/Themes", @"/private/var/lib/cydia",
        @"/private/var/tmp/cydia.log", @"/private/var/log/syslog",
        @"/private/var/cache/apt/", @"/private/var/lib/apt",
        @"/private/var/Users/", @"/private/var/stash",
        @"/usr/lib/libjailbreak.dylib", @"/usr/lib/libz.dylib",
        @"/usr/lib/system/introspectionNSZombieEnabled",
        @"/usr/lib/dyld",
        @"/jb/amfid_payload.dylib", @"/jb/libjailbreak.dylib",
        @"/jb/jailbreakd.plist", @"/jb/offsets.plist",
        @"/jb/lzma",
        @"/hmd_tmp_file",
        @"/etc/ssh/sshd_config", @"/etc/apt/undecimus/undecimus.list",
        @"/etc/apt/sources.list.d/sileo.sources", @"/etc/apt/sources.list.d/electra.list",
        @"/etc/apt", @"/etc/ssl/certs", @"/etc/ssl/cert.pem",
        @"/bin/sh", @"/bin/bash",
    ];
    %init;
}

static inline BOOL isTikTokLiveAudienceRoomVC(UIViewController *vc) {
    if (!vc) return NO;
    NSString *cls = NSStringFromClass([vc class]);
    return [cls isEqualToString:@"IESLiveMTAudienceViewController"] ||
           [cls isEqualToString:@"IESLiveAudienceViewController"] ||
           [cls isEqualToString:@"TTKLiveAudienceContainerViewController"] ||
           [cls isEqualToString:@"IESLiveRoomSlideViewController"];
}

%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if ([BHIManager liveRecordButton] && isTikTokLiveAudienceRoomVC(self)) {
        [[BHTLiveRecorder shared] attachToViewController:self];
    }
}
- (void)viewDidLayoutSubviews {
    %orig;
    if ([BHIManager liveRecordButton] && [BHTLiveRecorder shared].currentLiveVC == self) {
        [[BHTLiveRecorder shared] updateButtonFrameForViewController:self];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    if ([BHTLiveRecorder shared].currentLiveVC == self) {
        [[BHTLiveRecorder shared] detachFromViewController:self];
    }
}
%end
