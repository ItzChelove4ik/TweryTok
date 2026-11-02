//
//  ViewController.m — настройки TweryTok (шаг 3: зачищено + 2 новые секции).
//  Секции: 0 Feed, 1 Profile, 2 Confirm, 3 Region, 4 Auto Streak (NEW), 5 Like Color (NEW), 6 Developer
//

#import "ViewController.h"
#import "CountryTable.h"
#import "../BHIManager.h"
#import "../TWSeriesManager.h"

@interface ViewController ()
@property (nonatomic, strong) UITableView *staticTable;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.title = [BHIManager isTurkish] ? @"TweryTok Ayarları" : @"TweryTok Settings";

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithDefaultBackground];
        appearance.backgroundColor = [UIColor systemBackgroundColor];
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor labelColor]
        };
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.compactAppearance = appearance;
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[BHIManager isTurkish] ? @"Kapat" : @"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettings)];

    self.staticTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.staticTable.translatesAutoresizingMaskIntoConstraints = NO;
    self.staticTable.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:self.staticTable];
    [NSLayoutConstraint activateConstraints:@[
        [self.staticTable.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.staticTable.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.staticTable.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.staticTable.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    self.staticTable.dataSource = self;
    self.staticTable.delegate = self;
    self.staticTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)dismissSettings {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    BOOL tr = [BHIManager isTurkish];
    switch (section) {
        case 0: return tr ? @"Akış (Feed)" : @"Feed";
        case 1: return tr ? @"Profil" : @"Profile";
        case 2: return tr ? @"Onay Pencereleri" : @"Confirm";
        case 3: return tr ? @"Bölge (Region)" : @"Region";
        case 4: return tr ? @"Seri Otomatik Uzatma (Streak)" : @"Auto Streak";
        case 5: return tr ? @"Beğeni Rengi" : @"Like Color";
        case 6: return tr ? @"Geliştirici" : @"Developer";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 13;   // Feed (удалены story/live-record switches)
        case 1: return 5;    // Profile
        case 2: return 4;    // Confirm
        case 3: return 4;    // Region
        case 4: return 6;    // Auto Streak: toggle, time, timezone, sticker, excluded, status
        case 5: return 3;    // Like Color: toggle, color, reset
        case 6: return 2;    // Developer: repo link, diagnostics
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL tr = [BHIManager isTurkish];

    if (indexPath.section == 0) { // Feed
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Reklamları Gizle" : @"Hide Ads"
                                                Detail:tr ? @"Akıştaki tüm reklamları kaldırır" : @"Remove all ads in the feed"
                                                   Key:@"hide_ads"];
            case 1:
                return [self createSwitchCellWithTitle:tr ? @"TweryTok Menü Butonu" : @"TweryTok Menu Button"
                                                Detail:tr ? @"Videoya indirme menüsü butonu ekler" : @"Add the download menu button to videos"
                                                   Key:@"download_button"];
            case 2:
                return [self createSwitchCellWithTitle:tr ? @"Paylaşım Menüsü" : @"Share Sheet"
                                                Detail:tr ? @"İndirilenler için paylaşım sayfası açar" : @"Open share sheet for downloads"
                                                   Key:@"share_sheet"];
            case 3:
                return [self createSwitchCellWithTitle:tr ? @"Filigranı Kaldır" : @"Remove Watermark"
                                                Detail:tr ? @"İndirilen videolardan filigranı kaldırır" : @"Remove watermark from downloads"
                                                   Key:@"remove_watermark"];
            case 4:
                return [self createSwitchCellWithTitle:tr ? @"Ekranı Temizleme Butonu" : @"Clear Screen Button"
                                                Detail:tr ? @"Arayüz öğelerini gizleme butonu ekler" : @"Add clear-screen option"
                                                   Key:@"remove_elements_button"];
            case 5:
                return [self createSwitchCellWithTitle:tr ? @"Döngüyü Durdur" : @"Stop Playback"
                                                Detail:tr ? @"Videoların döngüde oynatılmasını kapatır" : @"Stop looping playback"
                                                   Key:@"stop_play"];
            case 6:
                return [self createSwitchCellWithTitle:tr ? @"İlerleme Çubuğunu Göster" : @"Show Progress Bar"
                                                Detail:tr ? @"Tüm videolarda kaydırılabilir ilerleme çubuğu gösterir" : @"Show draggable progress bar"
                                                   Key:@"show_porgress_bar"];
            case 7:
                return [self createSwitchCellWithTitle:tr ? @"Kullanıcı Adlarını Göster" : @"Show Usernames"
                                                Detail:tr ? @"Takma ad yerine kullanıcı adını gösterir" : @"Show @usernames instead of nicknames"
                                                   Key:@"show_username"];
            case 8:
                return [self createSwitchCellWithTitle:tr ? @"Hassas İçerik Filtresini Kapat" : @"Disable Sensitive Content"
                                                Detail:tr ? @"Hassas içerik maskesini kaldırır" : @"Remove sensitive content mask"
                                                   Key:@"disable_unsensitive"];
            case 9:
                return [self createSwitchCellWithTitle:tr ? @"Uyarıları Kapat" : @"Disable Warnings"
                                                Detail:tr ? @"Video uyarı etiketlerini gizler" : @"Hide video warning labels"
                                                   Key:@"disable_warnings"];
            case 10:
                return [self createSwitchCellWithTitle:tr ? @"Canlı Yayınları Gizle" : @"Disable Live Streaming"
                                                Detail:tr ? @"Akışta canlı yayın bölümlerini gizler" : @"Hide live sections in the feed"
                                                   Key:@"disable_live"];
            case 11:
                return [self createSwitchCellWithTitle:tr ? @"Önerileri Atla" : @"Skip Recommendations"
                                                Detail:tr ? @"Öneri kartlarını otomatik atlar" : @"Auto-skip recommendation cards"
                                                   Key:@"skip_recommnedations"];
            case 12:
                return [self createSwitchCellWithTitle:tr ? @"Kapak Resmini İndir" : @"Download Cover Image"
                                                Detail:tr ? @"İndirme menüsüne kapak resmi seçeneği ekler" : @"Add cover image option in download menu"
                                                   Key:@"download_cover_image"];
            default: break;
        }
    } else if (indexPath.section == 1) { // Profile
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Takip Durumu Rozeti" : @"Follow Status Badge"
                                                Detail:tr ? @"Profilde takip durumu rozeti gösterir" : @"Show follow status badge on profiles"
                                                   Key:@"follow_status_badge"];
            case 1:
                return [self createSwitchCellWithTitle:tr ? @"Video Sayısı" : @"Video Count"
                                                Detail:tr ? @"Profilde video sayısını gösterir" : @"Show video count on profiles"
                                                   Key:@"video_count"];
            case 2:
                return [self createSwitchCellWithTitle:tr ? @"Profil Fotoğrafını Kaydet" : @"Save Profile Photo"
                                                Detail:tr ? @"Uzun basışla profil fotoğrafını kaydeder" : @"Long-press to save profile photo"
                                                   Key:@"save_profile"];
            case 3:
                return [self createSwitchCellWithTitle:tr ? @"Profil Bilgilerini Kopyala" : @"Copy Profile Information"
                                                Detail:tr ? @"Uzun basışla profil bilgilerini kopyalar" : @"Long-press to copy profile info"
                                                   Key:@"copy_profile_information"];
            case 4:
                return [self createSwitchCellWithTitle:tr ? @"Video Meta Verileri" : @"Video Metadata"
                                                Detail:tr ? @"Profil gridinde beğeni sayısı ve tarih gösterir" : @"Show like count & date in profile grid"
                                                   Key:@"video_like_count"];
            default: break;
        }
    } else if (indexPath.section == 2) { // Confirm
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Beğeni Onayı" : @"Like Confirmation"
                                                Detail:tr ? @"Beğenmeden önce onay ister" : @"Confirm before liking"
                                                   Key:@"like_confirm"];
            case 1:
                return [self createSwitchCellWithTitle:tr ? @"Yorum Beğenme Onayı" : @"Like Comment Confirmation"
                                                Detail:tr ? @"Yorumu beğenmeden önce onay ister" : @"Confirm before liking a comment"
                                                   Key:@"like_comment_confirm"];
            case 2:
                return [self createSwitchCellWithTitle:tr ? @"Yorum Beğenmeme Onayı" : @"Dislike Comment Confirmation"
                                                Detail:tr ? @"Yorumu beğenmemeden önce onay ister" : @"Confirm before disliking a comment"
                                                   Key:@"dislike_comment_confirm"];
            case 3:
                return [self createSwitchCellWithTitle:tr ? @"Takip Onayı" : @"Follow Confirmation"
                                                Detail:tr ? @"Birini takip etmeden önce onay ister" : @"Confirm before following a user"
                                                   Key:@"follow_confirm"];
            default: break;
        }
    } else if (indexPath.section == 3) { // Region
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Bölge Değiştirmeyi Aç" : @"Enable Region Changing"
                                                Detail:tr ? @"Bölge değiştirme işlevini aktif eder" : @"Enable region changing"
                                                   Key:@"en_region"];
            case 1: {
                UITableViewCell *regions = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                regions.textLabel.text = tr ? @"Bölgeler" : @"Regions";
                NSDictionary *selectedRegion = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"region"];
                if (selectedRegion) {
                    NSString *areaName = tr ? (selectedRegion[@"area_tr"] ?: selectedRegion[@"area"]) : selectedRegion[@"area"];
                    regions.detailTextLabel.text = areaName ?: (tr ? @"Seçilmedi" : @"None");
                } else {
                    regions.detailTextLabel.text = tr ? @"Seçilmedi" : @"None";
                }
                return regions;
            }
            case 2:
                return [self createSwitchCellWithTitle:tr ? @"Bölge Değiştirme Girişini Göster" : @"Show Region Change Option"
                                                Detail:tr ? @"TikTok resmi bölge değiştirme girişini gösterir" : @"Surface official region change entry"
                                                   Key:@"show_region_change_option"];
            case 3: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Bölgeyi Değiştir (Resmi)" : @"Change Region (Official)";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.detailTextLabel.text = tr ? @"TikTok resmi bölge değiştirme sayfasını açar" : @"Open official region change page";
                cell.imageView.image = [UIImage systemImageNamed:@"arrow.up.right.square"];
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
                return cell;
            }
            default: break;
        }
    } else if (indexPath.section == 4) { // ============ AUTO STREAK (NEW) ============
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Seri Otomatik Uzatma" : @"Auto Streak"
                                                Detail:tr ? @"Sohbetlerdeki aktif serilere (🔥) her gün otomatik sticker gönderir" : @"Automatically send a sticker daily to chats with an active streak (🔥)"
                                                   Key:@"twery_streak_enabled"];
            case 1: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Gönderim Saati" : @"Send Time";
                NSInteger h = [BHIManager streakSendHour];
                NSInteger m = [BHIManager streakSendMinute];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)h, (long)m];
                cell.imageView.image = [UIImage systemImageNamed:@"clock"];
                return cell;
            }
            case 2: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Saat Dilimi" : @"Time Zone";
                cell.detailTextLabel.text = [BHIManager streakTimeZoneIdentifier];
                cell.imageView.image = [UIImage systemImageNamed:@"globe"];
                return cell;
            }
            case 3: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Sticker" : @"Sticker";
                cell.detailTextLabel.text = tr ? @"🔥 Varsayılan" : @"🔥 Default";
                cell.imageView.image = [UIImage systemImageNamed:@"flame"];
                return cell;
            }
            case 4: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Hariç Tutulan Sohbetler" : @"Excluded Chats";
                NSArray *excl = [BHIManager streakExcludedConversations];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(excl.count)];
                cell.imageView.image = [UIImage systemImageNamed:@"person.2.slash"];
                return cell;
            }
            case 5: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Durum" : @"Status";
                NSDate *next = [[TWSeriesManager shared] nextFireDate];
                if (next) {
                    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                    fmt.dateStyle = NSDateFormatterShortStyle;
                    fmt.timeStyle = NSDateFormatterShortStyle;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", tr ? @"Sonraki gönderim" : @"Next send", [fmt stringFromDate:next]];
                } else {
                    cell.detailTextLabel.text = tr ? @"Devre dışı" : @"Disabled";
                }
                cell.imageView.image = [UIImage systemImageNamed:@"timer"];
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
                return cell;
            }
            default: break;
        }
    } else if (indexPath.section == 5) { // ============ LIKE COLOR (NEW) ============
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Beğeni Rengi" : @"Like Color"
                                                Detail:tr ? @"Beğeni butonunu ve kalp animasyonunu renklendirir" : @"Recolor the like button and heart animation"
                                                   Key:@"twery_like_color_enabled"];
            case 1: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Renk" : @"Color";
                NSString *hex = [BHIManager likeColorHex];
                if (hex.length > 0) {
                    cell.detailTextLabel.text = [@"#" stringByAppendingString:hex];
                    UIView *swatch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
                    swatch.layer.cornerRadius = 6;
                    swatch.backgroundColor = [BHIManager likeColor] ?: [UIColor systemRedColor];
                    cell.accessoryView = swatch;
                } else {
                    cell.detailTextLabel.text = tr ? @"Varsayılan (kırmızı)" : @"Default (red)";
                }
                cell.imageView.image = [UIImage systemImageNamed:@"paintpalette"];
                return cell;
            }
            case 2: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Rengi Sıfırla" : @"Reset Color";
                cell.textLabel.textColor = [UIColor systemRedColor];
                cell.imageView.image = [UIImage systemImageNamed:@"arrow.counterclockwise"];
                return cell;
            }
            default: break;
        }
    } else if (indexPath.section == 6) { // Developer
        switch (indexPath.row) {
            case 0: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"TweryTok";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.detailTextLabel.text = tr ? @"Açık Kaynak Kod & Güncellemeler (ItzChelove4ik)" : @"Source Code & Updates (ItzChelove4ik)";
                cell.imageView.image = [UIImage systemImageNamed:@"link"];
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
                return cell;
            }
            case 1: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Streak Tanılama (Log)" : @"Streak Diagnostics (Log)";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.imageView.image = [UIImage systemImageNamed:@"stethoscope"];
                return cell;
            }
            default: break;
        }
    }
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 3 && indexPath.row == 1) {
        CountryTable *countryTable = [[CountryTable alloc] init];
        [self presentModalNavWithRoot:countryTable];
    }
    else if (indexPath.section == 3 && indexPath.row == 3) {
        NSString *target = @"https://www.tiktok.com/tpp/inapp/pns_product_poseidon/change-region-selector.html";
        NSMutableCharacterSet *allowed = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [allowed addCharactersInString:@"-._~"];
        NSString *encoded = [target stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSString *route = [NSString stringWithFormat:@"aweme://webview/?hide_nav_bar=1&use_spark=1&show_loading=1&url=%@", encoded];
        NSURL *url = [NSURL URLWithString:route];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    else if (indexPath.section == 4 && indexPath.row == 1) {
        [self presentStreakTimePicker];
    }
    else if (indexPath.section == 4 && indexPath.row == 2) {
        [self presentStreakTimeZonePicker];
    }
    else if (indexPath.section == 4 && indexPath.row == 5) {
        // статус — просто обновить таблицу
        [self.staticTable reloadData];
    }
    else if (indexPath.section == 5 && indexPath.row == 1) {
        [self presentLikeColorPicker];
    }
    else if (indexPath.section == 5 && indexPath.row == 2) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"twery_like_color_hex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.staticTable reloadData];
    }
    else if (indexPath.section == 6 && indexPath.row == 0) {
        NSURL *url = [NSURL URLWithString:@"https://github.com/ItzChelove4ik/TweryTok"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    else if (indexPath.section == 6 && indexPath.row == 1) {
        [[TWSeriesManager shared] logStreakDiagnostics];
        [self showToast:([BHIManager isTurkish] ? @"Konsola yazıldı (Console.app)" : @"Logged to console (Console.app)")];
    }
}

#pragma mark - Pickers (Auto Streak)

- (void)presentStreakTimePicker {
    BOOL tr = [BHIManager isTurkish];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:tr ? @"Gönderim Saati" : @"Send Time"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger h = 6; h <= 20; h += 2) {
        NSString *title = [NSString stringWithFormat:@"%02ld:00", (long)h];
        [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            [[NSUserDefaults standardUserDefaults] setInteger:h forKey:@"twery_streak_hour"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"twery_streak_minute"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[TWSeriesManager shared] start];
            [self.staticTable reloadData];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:tr ? @"İptal" : @"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentAdaptiveAlert:alert];
}

- (void)presentStreakTimeZonePicker {
    BOOL tr = [BHIManager isTurkish];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:tr ? @"Saat Dilimi" : @"Time Zone"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray<NSString *> *zones = @[@"Europe/Moscow", @"Europe/Kyiv", @"Europe/Istanbul", @"Europe/London",
                                    @"Europe/Berlin", @"Asia/Almaty", @"Asia/Tbilisi", @"America/New_York"];
    for (NSString *z in zones) {
        [alert addAction:[UIAlertAction actionWithTitle:z style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            [[NSUserDefaults standardUserDefaults] setObject:z forKey:@"twery_streak_timezone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.staticTable reloadData];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:tr ? @"İptal" : @"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentAdaptiveAlert:alert];
}

#pragma mark - Pickers (Like Color)

- (void)presentLikeColorPicker {
    BOOL tr = [BHIManager isTurkish];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:tr ? @"Beğeni Rengi" : @"Like Color"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSDictionary<NSString *, NSString *> *presets = @{
        @"❤️ Kırmızı (varsayılan)": @"FE2C55",   // TikTok red
        @"🩷 Pembe": @"FF3B8D",
        @"💙 Mavi": @"00C2FF",
        @"💚 Yeşil": @"34C759",
        @"💜 Mor": @"AF52DE",
        @"🧡 Turuncu": @"FF9500",
        @"💛 Sarı": @"FFCC00",
        @"🤍 Beyaz": @"FFFFFF",
    };
    for (NSString *name in presets) {
        [alert addAction:[UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            [[NSUserDefaults standardUserDefaults] setObject:presets[name] forKey:@"twery_like_color_hex"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.staticTable reloadData];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:tr ? @"İptal" : @"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentAdaptiveAlert:alert];
}

- (void)presentAdaptiveAlert:(UIAlertController *)alert {
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showToast:(NSString *)message {
    UILabel *label = [[UILabel alloc] init];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 8;
    label.clipsToBounds = YES;
    label.frame = CGRectMake(20, self.view.bounds.size.height - 100, self.view.bounds.size.width - 40, 36);
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [self.view addSubview:label];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    });
}

#pragma mark - Хелперы

- (void)presentModalNavWithRoot:(UIViewController *)rootVC {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle style = self.navigationController.overrideUserInterfaceStyle ?: self.overrideUserInterfaceStyle;
        if (style != UIUserInterfaceStyleUnspecified) {
            navController.overrideUserInterfaceStyle = style;
            rootVC.overrideUserInterfaceStyle = style;
        }
    }
    [self presentViewController:navController animated:YES completion:nil];
}

- (UITableViewCell *)createSwitchCellWithTitle:(NSString *)title Detail:(NSString*)detail Key:(NSString*)key {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    UISwitch *switchView = [[UISwitch alloc] init];
    [cell.contentView addSubview:switchView];
    cell.accessoryView = switchView;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:key] != nil) {
        switchView.on = [defaults boolForKey:key];
    } else if ([key isEqualToString:@"hide_ads"] || [key isEqualToString:@"download_button"] || [key isEqualToString:@"remove_watermark"] || [key isEqualToString:@"download_cover_image"] || [key isEqualToString:@"follow_status_badge"] || [key isEqualToString:@"show_porgress_bar"]) {
        switchView.on = YES;
    } else {
        switchView.on = NO;
    }
    switchView.accessibilityLabel = key;
    [switchView addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];

    cell.textLabel.text = title;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}

- (void)switchToggled:(UISwitch *)sender {
    NSString *key = sender.accessibilityLabel;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:sender.isOn forKey:key];
    [defaults synchronize];
    // Стрик-тумблер: перезапустить движок сразу
    if ([key isEqualToString:@"twery_streak_enabled"]) {
        if (sender.isOn) {
            [[TWSeriesManager shared] start];
        } else {
            [[TWSeriesManager shared] stop];
        }
        [self.staticTable reloadData];
    }
}

@end
