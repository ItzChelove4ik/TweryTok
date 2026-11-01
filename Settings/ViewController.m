//
//  ViewController.m
//  StaticTableView
//
//  Created by raul on 08/10/2024.
//

#import "ViewController.h"
#import "CountryTable.h"
#import "LiveActions.h"
#import "PlaybackSpeed.h"
#import "OfflineVideosLimit.h"
#import "LabsViewController.h"
#import "../BHIManager.h"

@interface ViewController ()
@property (nonatomic, strong) UITableView *staticTable;
@property (nonatomic, assign) BOOL isAdditionalCellVisible;
@property (nonatomic, assign) UIImage *devImage;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(regionSelected:)
                                                 name:@"RegionSelectedNotification"
                                               object:nil];
}

- (void)dismissSettings {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.staticTable reloadData];
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
}

- (void)regionSelected:(NSNotification *)notification {
    [self.staticTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 11;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    BOOL tr = [BHIManager isTurkish];
    switch (section) {
        case 0:
            return tr ? @"Akış (Feed)" : @"Feed";
        case 1:
            return tr ? @"Profil" : @"Profile";
        case 2:
            return tr ? @"Onay Pencereleri" : @"Confirm";
        case 3:
            return tr ? @"Diğer" : @"Other";
        case 4:
            return tr ? @"Bölge (Region)" : @"Region";
        case 5:
            return tr ? @"Canlı Yayın Butonu İşlevi" : @"Live Button Function";
        case 6:
            return tr ? @"Oynatma Hızı" : @"Playback Speed";
        case 7:
            return tr ? @"Geliştirici" : @"Developer";
        case 8:
            return tr ? @"Gizlilik" : @"Privacy";
        case 9:
            return tr ? @"Çevrimdışı Videolar" : @"Offline Videos";
        case 10:
            return tr ? @"Deneysel (Labs)" : @"Labs";
        default:
            break;
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 17;
        case 1: return 5;
        case 2: return 4;
        case 3: return 11;
        case 4: return 4;
        case 5: return 2;
        case 6: return 2;
        case 7: return 1;
        case 8: return 2;
        case 9: return 1;
        case 10: return 1;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL tr = [BHIManager isTurkish];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Reklamları Gizle" : @"Hide Ads"
                                                Detail:tr ? @"Uygulamadaki tüm reklamları gizler" : @"Hide all ads from the app"
                                                   Key:@"hide_ads"];
            case 1:
                return [self createSwitchCellWithTitle:tr ? @"TweryTok Menü Butonu" : @"TweryTok Menu Button"
                                                Detail:tr ? @"Sağ tarafa (profil resminin üstüne) indirme ve ekranı temizleme butonunu ekler" : @"Add download and clear screen menu button on the right side (above avatar)"
                                                   Key:@"download_button"];
            case 2:
                return [self createSwitchCellWithTitle:tr ? @"Paylaşım Menüsü" : @"Share Sheet"
                                                Detail:tr ? @"İndirilenleri doğrudan iOS paylaşım ekranında açar" : @"Enable sharing options in share sheet"
                                                   Key:@"share_sheet"];
            case 3:
                return [self createSwitchCellWithTitle:tr ? @"Filigranı Kaldır" : @"Remove Watermark"
                                                Detail:tr ? @"Videolardaki TikTok filigranını kaldırır" : @"Remove the TikTok watermark from videos"
                                                   Key:@"remove_watermark"];
            case 4:
                return [self createSwitchCellWithTitle:tr ? @"Ekranı Temizleme Butonu" : @"Clear Screen Button"
                                                Detail:tr ? @"TweryTok menüsüne ekranı temizleme seçeneğini ekler" : @"Enable clear screen option in TweryTok menu"
                                                   Key:@"remove_elements_button"];
            case 5:
                return [self createSwitchCellWithTitle:tr ? @"Döngüyü Durdur" : @"Stop Playback"
                                                Detail:tr ? @"Video bittiğinde otomatik duraklatır" : @"Stop video playback automatically"
                                                   Key:@"stop_play"];
            case 6:
                return [self createSwitchCellWithTitle:tr ? @"İlerleme Çubuğunu Göster" : @"Show Progress Bar"
                                                Detail:tr ? @"Video oynatılırken sarma çubuğunu zorla gösterir" : @"Display progress bar on video playback"
                                                   Key:@"show_porgress_bar"];
            case 7:
                return [self createSwitchCellWithTitle:tr ? @"Şeffaf Yorumlar" : @"Transparent Comments"
                                                Detail:tr ? @"Yorum panelinin arka planını yarı saydam yapar" : @"Make comments transparent"
                                                   Key:@"transparent_commnet"];
            case 8:
                return [self createSwitchCellWithTitle:tr ? @"Kullanıcı Adlarını Göster" : @"Show Usernames"
                                                Detail:tr ? @"Görünen ad yerine @kullanıcıadı gösterir" : @"Display usernames on videos"
                                                   Key:@"show_username"];
            case 9:
                return [self createSwitchCellWithTitle:tr ? @"Hassas İçerik Filtresini Kapat" : @"Disable Sensitive Content"
                                                Detail:tr ? @"Hassas içerik sansürünü ve uyarısını kaldırır" : @"Disable sensitive content filter"
                                                   Key:@"disable_unsensitive"];
            case 10:
                return [self createSwitchCellWithTitle:tr ? @"Uyarıları Kapat" : @"Disable Warnings"
                                                Detail:tr ? @"COVID, güvenlik vb. uyarı kartlarını gizler" : @"Disable TikTok warnings"
                                                   Key:@"disable_warnings"];
            case 11:
                return [self createSwitchCellWithTitle:tr ? @"Canlı Yayınları Gizle" : @"Disable Live Streaming"
                                                Detail:tr ? @"Akışta çıkan canlı yayınları devre dışı bırakır" : @"Disable live video streaming"
                                                   Key:@"disable_live"];
            case 12:
                return [self createSwitchCellWithTitle:tr ? @"Önerileri Atla" : @"Skip Recommendations"
                                                Detail:tr ? @"TikTok'un önerdiği videoları otomatik atlar" : @"Skip recommended videos"
                                                   Key:@"skip_recommnedations"];
            case 13:
                return [self createSwitchCellWithTitle:tr ? @"Yükleme Bölgesi Bayrağı" : @"Upload Region"
                                                Detail:tr ? @"Kullanıcı adının yanına yüklendiği ülkenin bayrağını ekler" : @"Show Upload Region Flag Next to Username"
                                                   Key:@"upload_region"];
            case 14:
                return [self createSwitchCellWithTitle:tr ? @"Hikaye İndirme Butonu" : @"Story Download Button"
                                                Detail:tr ? @"Hikaye paylaşım menüsüne (Bildir butonunun yanına) İndir butonunu ekler" : @"Add download button to the story share menu (next to Report)"
                                                   Key:@"download_story"];
            case 15:
                return [self createSwitchCellWithTitle:tr ? @"Canlı Yayın Kaydet Butonu" : @"Live Record Button"
                                                Detail:tr ? @"Canlı yayınlarda sağ üst kısma ekran kaydetme butonunu ekler" : @"Add screen record button to the top right in live streams"
                                                   Key:@"live_record_button"];
            case 16:
                return [self createSwitchCellWithTitle:tr ? @"Kapak Resmini İndir" : @"Download Cover Image"
                                                Detail:tr ? @"İndirme menüsüne videonun kapak resmini kaydetme seçeneğini ekler" : @"Add option to save video cover image in download menu"
                                                   Key:@"download_cover_image"];
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Profil Resmini Kaydet" : @"Profile Save"
                                                Detail:tr ? @"Profil resmine uzun basarak galeriye kaydeder" : @"Save profile details to clipboard"
                                                   Key:@"save_profile"];
            case 1:
                return [self createSwitchCellWithTitle:tr ? @"Profil Bilgilerini Kopyala" : @"Profile Copy"
                                                Detail:tr ? @"Profile uzun basarak bilgileri panoya kopyalar" : @"Copy profile information"
                                                   Key:@"copy_profile_information"];
            case 2:
                return [self createSwitchCellWithTitle:tr ? @"Video Beğeni Sayısı" : @"Video Like Count"
                                                Detail:tr ? @"Profil ızgarasında video beğeni sayılarını gösterir" : @"Show the number of likes on videos"
                                                   Key:@"video_like_count"];
            case 3:
                return [self createSwitchCellWithTitle:tr ? @"Video Yüklenme Tarihi" : @"Video Upload Date"
                                                Detail:tr ? @"Profil ızgarasında videonun yüklenme tarihini gösterir" : @"Show the date videos were uploaded"
                                                   Key:@"video_upload_date"];
            case 4:
                return [self createSwitchCellWithTitle:tr ? @"Takip Durumu Göstergesi" : @"Follow Status Indicator"
                                                Detail:tr ? @"Kullanıcı adının yanında sizi takip edip etmediğini gösterir" : @"Show whether user follows you next to their username"
                                                   Key:@"follow_status_badge"];
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Beğeni Onayı" : @"Like Confirmation"
                                                Detail:tr ? @"Videoyu beğenmeden önce onay ister" : @"Confirm before liking a video"
                                                   Key:@"like_confirm"];
            case 1:
                return [self createSwitchCellWithTitle:tr ? @"Yorum Beğeni Onayı" : @"Like Comment Confirmation"
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
            default:
                break;
        }
    } else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Daima Safari'de Aç" : @"Always Open Safari"
                                                Detail:tr ? @"Bağlantıları doğrudan sistem Safari tarayıcısında açar" : @"Always open links in Safari"
                                                   Key:@"openInBrowser"];
            case 1:
                return [self createSwitchCellWithTitle:tr ? @"Sahte Verileri Aç" : @"Enable Fake Changes"
                                                Detail:tr ? @"Özel sahte profil verilerini etkinleştirir" : @"Enable fake profile changes"
                                                   Key:@"en_fake"];
            case 2: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                
                UILabel *followerLabel = [[UILabel alloc] init];
                followerLabel.text = tr ? @"Takipçi:" : @"Follower:";
                followerLabel.font = [UIFont systemFontOfSize:16];
                followerLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:followerLabel];
                
                UITextField *textField = [[UITextField alloc] init];
                textField.placeholder = tr ? @"Takipçi sayısı girin" : @"Enter follower count";
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.delegate = self;
                textField.tag = 2;
                textField.returnKeyType = UIReturnKeyDone;
                textField.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:textField];
                
                [NSLayoutConstraint activateConstraints:@[
                    [followerLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
                    [followerLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                    [followerLabel.widthAnchor constraintEqualToConstant:100],
                    
                    [textField.leadingAnchor constraintEqualToAnchor:followerLabel.trailingAnchor constant:10],
                    [textField.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15],
                    [textField.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                    [textField.heightAnchor constraintEqualToConstant:30]
                ]];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *savedText = [defaults stringForKey:@"follower_count"];
                if (savedText) {
                    textField.text = savedText;
                }
                
                return cell;
            }
            case 3: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                
                UILabel *followingLabel = [[UILabel alloc] init];
                followingLabel.text = tr ? @"Takip Edilen:" : @"Following:";
                followingLabel.font = [UIFont systemFontOfSize:16];
                followingLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:followingLabel];
                
                UITextField *textField = [[UITextField alloc] init];
                textField.placeholder = tr ? @"Takip edilen sayısı girin" : @"Enter following count";
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.delegate = self;
                textField.tag = 1;
                textField.returnKeyType = UIReturnKeyDone;
                textField.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:textField];
                
                [NSLayoutConstraint activateConstraints:@[
                    [followingLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
                    [followingLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                    [followingLabel.widthAnchor constraintEqualToConstant:100],
                    
                    [textField.leadingAnchor constraintEqualToAnchor:followingLabel.trailingAnchor constant:10],
                    [textField.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15],
                    [textField.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                    [textField.heightAnchor constraintEqualToConstant:30]
                ]];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *savedText = [defaults stringForKey:@"following_count"];
                if (savedText) {
                    textField.text = savedText;
                }
                
                return cell;
            }
            case 4:
                return [self createSwitchCellWithTitle:tr ? @"Sahte Mavi Tik" : @"Fake Verified"
                                                Detail:tr ? @"Profilinizde doğrulanmış onay rozeti gösterir" : @"Make your account appear verified"
                                                   Key:@"fake_verify"];
            case 5:
                return [self createSwitchCellWithTitle:tr ? @"Genişletilmiş Biyo" : @"Extended Bio"
                                                Detail:tr ? @"Profil biyografisindeki karakter sınırını kaldırır" : @"Extend bio section of your profile"
                                                   Key:@"extended_bio"];
            case 6:
                return [self createSwitchCellWithTitle:tr ? @"Genişletilmiş Yorumlar" : @"Extended Comments"
                                                Detail:tr ? @"Yorum yazma alanındaki karakter sınırını kaldırır" : @"Extend the length of your comments"
                                                   Key:@"extendedComment"];
            case 7:
                return [self createSwitchCellWithTitle:tr ? @"HD Video Yükleme" : @"Upload HD"
                                                Detail:tr ? @"Videoları doğrudan HD kalitede yükler" : @"Upload videos in HD quality"
                                                   Key:@"upload_hd"];
            case 8:
                return [self createSwitchCellWithTitle:tr ? @"Uygulama Kilidi" : @"App Lock"
                                                Detail:tr ? @"Uygulamayı Face ID / Parola ile kilitler" : @"Lock the app with a passcode"
                                                   Key:@"padlock"];
            case 9:
                return [self createSwitchCellWithTitle:tr ? @"FLEX'i Etkinleştir" : @"Enable Flex"
                                                Detail:tr ? @"Geliştirici konsolunu açar (Sadece geliştiriciler için)" : @"Developers Only, DON'T touch it if you don't know what you are doing."
                                                   Key:@"flex_enebaled"];
            case 10:
                return [self createSwitchCellWithTitle:tr ? @"Ekran Görüntüsü Korumasını Engelle" : @"Bypass Screenshot Detection"
                                                Detail:tr ? @"Ekran görüntüsü alındığında bildirim ve paylaşım penceresini engeller" : @"Take screenshots freely; suppress screenshot notifications and the share popup"
                                                   Key:@"disable_screenshot_detection"];
            default:
                break;
        }
    } else if (indexPath.section == 4) {
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Bölge Değiştirmeyi Aç" : @"Enable Region Changing"
                                                Detail:tr ? @"Özel bölge/konum değiştirme işlevini aktif eder" : @"Enable region changing functionality"
                                                   Key:@"en_region"];
            case 1: {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                UITableViewCell *regions = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                regions.textLabel.text = tr ? @"Bölgeler" : @"Regions";
                NSDictionary *selectedRegion = [defaults dictionaryForKey:@"region"];
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
                                                Detail:tr ? @"TikTok resmi hesap bölgesi değiştirme girişini ayarlarda gösterir" : @"Surface TikTok's official account region change entry in settings"
                                                   Key:@"show_region_change_option"];
            case 3: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Bölgeyi Değiştir (Resmi)" : @"Change Region (Official)";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.detailTextLabel.text = tr ? @"TikTok resmi bölge değiştirme sayfasını açar" : @"Open TikTok official region change page directly";
                cell.imageView.image = [UIImage systemImageNamed:@"arrow.up.right.square"];
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
                return cell;
            }
            default:
                break;
        }
    } else if (indexPath.section == 5) {
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Canlı Buton Eylemi" : @"Live Button Action"
                                                Detail:tr ? @"Sol üstteki butonun varsayılan işlevini değiştirir" : @"Change The Default Live Button Action"
                                                   Key:@"en_livefunc"];
            case 1: {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                UITableViewCell *liveAction = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                liveAction.textLabel.text = tr ? @"Eylemler" : @"Actions";
                NSString *selectedLiveAction = [defaults valueForKey:@"live_action"];
                NSArray *liveFuncTitles = tr ? @[@"Varsayılan", @"TweryTok Ayarları", @"Oynatma Hızı"] : @[@"Default", @"TweryTok Settings", @"Playback Speed"];
                if (selectedLiveAction != nil) {
                    liveAction.detailTextLabel.text = [NSString stringWithFormat:@"%@", [liveFuncTitles objectAtIndex:[selectedLiveAction integerValue]]];
                }
                
                return liveAction;
            }
            default:
                break;
        }
    } else if (indexPath.section == 6) {
        switch (indexPath.row) {
            case 0: {
                return [self createSwitchCellWithTitle:tr ? @"Kalıcı Oynatma Hızı" : @"Playback Speed"
                                                Detail:tr ? @"Sabit video oynatma hızını aktif eder" : @"Enable Presistent Playback Speed."
                                                   Key:@"playback_en"];
            }
            case 1: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Hızlar" : @"Speeds";
                
                NSNumber *selectedSpeed = [BHIManager selectedSpeed];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ x", selectedSpeed];
                return cell;
            }
        }
    }
    else if (indexPath.section == 7) {
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
            default:
                break;
        }
    }
    else if (indexPath.section == 8) {
        switch (indexPath.row) {
            case 0:
                return [self createSwitchCellWithTitle:tr ? @"Hayalet Modu: Okundu Bilgisi" : @"Ghost Mode: Read Receipts"
                                                Detail:tr ? @"DM mesajlarını görüldü bildirimi gitmeden okur" : @"Read DMs without sending seen receipts"
                                                   Key:@"ghost_read_receipts"];
            case 1:
                return [self createSwitchCellWithTitle:tr ? @"Hayalet Modu: Yazıyor Bilgisi" : @"Ghost Mode: Typing"
                                                Detail:tr ? @"DM'lerde yazarken yazıyor bildirimini engeller" : @"Type without sending typing indicators"
                                                   Key:@"ghost_typing"];
            default:
                break;
        }
    }
    else if (indexPath.section == 9) {
        switch (indexPath.row) {
            case 0: {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"Video Limiti" : @"Videos Limit";
                NSNumber *limit = [defaults objectForKey:@"offline_videos_limit"];
                if (limit != nil && [limit integerValue] > 0) {
                    cell.detailTextLabel.text = tr ? [NSString stringWithFormat:@"%@ video", limit] : [NSString stringWithFormat:@"%@ videos", limit];
                } else {
                    cell.detailTextLabel.text = tr ? @"Varsayılan" : @"Default";
                }
                return cell;
            }
            default:
                break;
        }
    }
    else if (indexPath.section == 10) {
        switch (indexPath.row) {
            case 0: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = tr ? @"A/B Deney Gezgini" : @"A/B Experiment Explorer";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.detailTextLabel.text = tr ? @"TikTok dahili A/B bayraklarını görüntüleyin ve değiştirin" : @"View & override TikTok's internal A/B flags";
                cell.imageView.image = [UIImage systemImageNamed:@"flask"];
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
                return cell;
            }
            default:
                break;
        }
    }
    return [UITableViewCell new];
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected row at index: %ld", (long)indexPath.section);
    if (indexPath.section == 4 && indexPath.row == 1){
        CountryTable *countryTable = [[CountryTable alloc] init];
        [self presentModalNavWithRoot:countryTable];
    }
    else if (indexPath.section == 4 && indexPath.row == 3){
        NSString *target = @"https://www.tiktok.com/tpp/inapp/pns_product_poseidon/change-region-selector.html";
        NSMutableCharacterSet *allowed = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [allowed addCharactersInString:@"-._~"];
        NSString *encoded = [target stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSString *route = [NSString stringWithFormat:@"aweme://webview/?hide_nav_bar=1&use_spark=1&show_loading=1&url=%@", encoded];
        NSURL *url = [NSURL URLWithString:route];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    else if (indexPath.section == 5 && indexPath.row == 1){
        LiveActions *liveActions = [[LiveActions alloc] init];
        [self presentModalNavWithRoot:liveActions];
    } else if (indexPath.section == 6 && indexPath.row == 1) {
        PlaybackSpeed *playbackSpeed = [[PlaybackSpeed alloc] init];
        [self presentModalNavWithRoot:playbackSpeed];
    }
    else if (indexPath.section == 7 && indexPath.row == 0){
        NSURL *url = [NSURL URLWithString:@"https://github.com/ItzChelove4ik/TweryTok"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    else if (indexPath.section == 9 && indexPath.row == 0){
        OfflineVideosLimit *offlineLimit = [[OfflineVideosLimit alloc] init];
        [self presentModalNavWithRoot:offlineLimit];
    }
    else if (indexPath.section == 10 && indexPath.row == 0){
        LabsViewController *labs = [[LabsViewController alloc] init];
        [self presentModalNavWithRoot:labs];
    }
}

- (UITableViewCell *)createSwitchCellWithTitle:(NSString *)title Detail:(NSString*)detail Key:(NSString*)key {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    [cell.contentView addSubview:switchView];
    cell.accessoryView = switchView;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:key] != nil) {
        switchView.on = [defaults boolForKey:key];
    } else if ([key isEqualToString:@"hide_ads"] || [key isEqualToString:@"download_button"] || [key isEqualToString:@"download_story"] || [key isEqualToString:@"live_record_button"] || [key isEqualToString:@"remove_watermark"] || [key isEqualToString:@"upload_hd"] || [key isEqualToString:@"download_cover_image"] || [key isEqualToString:@"follow_status_badge"] || [key isEqualToString:@"show_porgress_bar"]) {
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
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:textField.text forKey:@"following_count"];
        [defaults synchronize];
    } else if (textField.tag == 2){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:textField.text forKey:@"follower_count"];
        [defaults synchronize];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
