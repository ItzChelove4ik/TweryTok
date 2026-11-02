#import "TikTokHeaders.h"
#import "TWSeriesManager.h"
#import "TWLikeColorManager.h"
#import <objc/runtime.h>

NSArray *jailbreakPaths;

static __weak id sCurrentActiveCell = nil;
static __weak AWEPlayVideoPlayerController *sCurrentActivePlayerController = nil;
static __weak TTVideoEngine *sCurrentActiveVideoEngine = nil;

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
    NSLog(@"[TweryTok] AppDelegate didFinishLaunching reached");
    [[TWSeriesManager shared] start];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"flex_enebaled"]) {
        [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"TweryTokFirstRun"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"TweryTokFirstRun" forKey:@"TweryTokFirstRun"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hide_ads"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_button"];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"remove_elements_button"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"show_porgress_bar"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"save_profile"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_profile_information"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_cover_image"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"follow_status_badge"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"download_cover_image"]) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_cover_image"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"follow_status_badge"]) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"follow_status_badge"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"TweryTokV2ButtonsMigrated"]) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"TweryTokV2ButtonsMigrated"];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"remove_elements_button"];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"download_button"]) {
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_button"];
        }
    }
    [BHIManager cleanCache];
    return true;
}

static BOOL isAuthenticationShowed = FALSE;
- (void)applicationDidBecomeActive:(id)arg1 {
    %orig;
    [[TWSeriesManager shared] checkAndCatchUp];
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
    if ([self.itemModel.identifier isEqualToString:@"twerytok_settings"]) {
        UIViewController *top = topMostController();
        ViewController *vc = [[ViewController alloc] init];
        UINavigationController *TweryTokSettings = [[UINavigationController alloc] initWithRootViewController:vc];
        if (@available(iOS 13.0, *)) {
            if (top.view.window.traitCollection.userInterfaceStyle) {
                TweryTokSettings.overrideUserInterfaceStyle = top.view.window.traitCollection.userInterfaceStyle;
            }
        }
        [top presentViewController:TweryTokSettings animated:true completion:nil];
    } else {
        return %orig;
    }
}
%end

%hook AWESettingsNormalSectionViewModel
%property (nonatomic, strong) TTKSettingsBaseCellPlugin *twerytokCell;

- (NSString *)sectionHeaderTitle {
    if ([self.sectionIdentifier isEqualToString:@"twerytok_mod_section"]) {
        BOOL tr = [BHIManager isTurkish];
        return tr ? @"TikTok Mod Ayarları" : @"TikTok Mod Settings";
    }
    return %orig;
}

- (NSArray *)modelsArray {
    if ([self.sectionIdentifier isEqualToString:@"twerytok_mod_section"]) {
        if (!self.twerytokCell) {
            TTKSettingsBaseCellPlugin *TweryTokSettingsPluginCell = [[%c(TTKSettingsBaseCellPlugin) alloc] initWithPluginContext:self.context];

            AWESettingItemModel *TweryTokSettingsItemModel = [[%c(AWESettingItemModel) alloc] initWithIdentifier:@"twerytok_settings"];
            BOOL tr = [BHIManager isTurkish];
            NSString *title = tr ? @"TweryTok Ayarları" : @"TweryTok Settings";
            [TweryTokSettingsItemModel setTitle:title];
            [TweryTokSettingsItemModel setDetail:title];
            [TweryTokSettingsItemModel setIconImage:[UIImage systemImageNamed:@"gear"]];
            [TweryTokSettingsItemModel setType:99];

            [TweryTokSettingsPluginCell setItemModel:TweryTokSettingsItemModel];
            self.twerytokCell = TweryTokSettingsPluginCell;
        }
        return @[self.twerytokCell];
    }
    return %orig;
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
        [self addTweryTokMenuButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    sCurrentActiveCell = self;
    self.elementsHidden = false;
    if ([BHIManager downloadButton]) {
        [self addTweryTokMenuButton];
    }
}
- (void)layoutSubviews {
    %orig;
    if ([BHIManager downloadButton]) {
        [self addTweryTokMenuButton];
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
%new - (void)showTweryTokDownloadActionSheet {
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
            [self toggleTweryTokHideElements];
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
%new - (void)toggleTweryTokHideElements {
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
%new - (void)setupTweryTokMenu:(UIButton *)sender {
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
            [self toggleTweryTokHideElements];
            [self setupTweryTokMenu:sender];
        }];
        [menuActions addObject:cleanAction];
    }

    if (NO) {
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
        [self setupTweryTokMenu:sender];
    }
    [self showTweryTokDownloadActionSheet];
}
%new - (void)addTweryTokMenuButton {
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

    [self setupTweryTokMenu:menuButton];
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
        [self addTweryTokMenuButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    sCurrentActiveCell = self;
    self.elementsHidden = false;
    if ([BHIManager downloadButton]) {
        [self addTweryTokMenuButton];
    }
}
- (void)layoutSubviews {
    %orig;
    if ([BHIManager downloadButton]) {
        [self addTweryTokMenuButton];
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
%new - (void)showTweryTokDownloadActionSheet {
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
            [self toggleTweryTokHideElements];
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
%new - (void)toggleTweryTokHideElements {
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
%new - (void)setupTweryTokMenu:(UIButton *)sender {
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
            [self toggleTweryTokHideElements];
            [self setupTweryTokMenu:sender];
        }];
        [menuActions addObject:cleanAction];
    }

    if (NO) {
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
        [self setupTweryTokMenu:sender];
    }
    [self showTweryTokDownloadActionSheet];
}
%new - (void)addTweryTokMenuButton {
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

    [self setupTweryTokMenu:menuButton];
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

// Labs: A/B experiment overrides (Settings -> Labs -> A/B Experiment Explorer; key: ab_overrides).
// These are the Libra/ClientAB read accessors verified in MusicallyCore 46.5.0 ObjC metadata.
// The Labs editor preserves original value types, so returning the boxed override is type-safe.
// NOTE: do NOT hook ABTestMonitor*/exposure paths (tracking) — overrides stay local-only.




// ============================================================================
// ФИЧА 2: смена цвета лайков (TWLikeColorManager)
// ============================================================================

%hook UIImage
// ФИЧА 2 (TweryTok): перекраска лайк-иконок.
// АНТИ-РЕКУРСИЯ: tintedImageForName: зовёт [UIImage imageNamed:], т.е. этот же хук.
// Страж в TWLikeColorManager глушит вложенный вызов; здесь дополнительно НЕ трогаем
// запросы, пришедшие изнутри перекраски (isLikeAssetName для них вернёт то же имя,
// но tinted будет nil — вернётся оригинал).
+ (UIImage *)imageNamed:(NSString *)name {
    // быстрый выход: фича выключена — нулевой оверхед, оригинальное поведение
    if (![TWLikeColorManager active]) return %orig;
    if (name && [TWLikeColorManager isLikeAssetName:name]) {
        UIImage *tinted = [TWLikeColorManager tintedImageForName:name];
        if (tinted) return tinted;
    }
    return %orig;
}
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle compatibleWithTraitCollection:(id)trait {
    if (![TWLikeColorManager active]) return %orig;
    if (name && [TWLikeColorManager isLikeAssetName:name]) {
        UIImage *tinted = [TWLikeColorManager tintedImageForName:name];
        if (tinted) return tinted;
    }
    return %orig;
}
%end

// Частицы даблтап-анимации: TikTok использует CAEmitterCell с красным цветом.
// Хукаем только установку «лайкового» (красно-розового) цвета — чужие эмиттеры не трогаем.
%hook CAEmitterCell
- (void)setColor:(CGColorRef)color {
    if ([TWLikeColorManager active] && color) {
        UIColor *orig = [UIColor colorWithCGColor:color];
        CGFloat r = 0, g = 0, b = 0, a = 0;
        // getRed:...: возвращает NO для не-RGB (grayscale) цветов — тогда не трогаем
        if (![orig getRed:&r green:&g blue:&b alpha:&a]) {
            %orig;
            return;
        }
        // «лайковый» цвет: красный/розовый доминирует (r > 0.6, g и b малы)
        BOOL isLikeColor = (r > 0.6f && g < 0.4f && b < 0.5f);
        if (isLikeColor) {
            %orig([[BHIManager likeColor] CGColor]);
            return;
        }
    }
    %orig;
}
%end

%ctor {
    // Диагностика: подтверждение загрузки dylib (видно в Console.app на устройстве)
    NSLog(@"[TweryTok] dylib loaded (build %@), hooks initializing...", @"3.1");
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


