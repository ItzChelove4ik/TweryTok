#import "LiveActions.h"
#import "../BHIManager.h"

@interface LiveActions () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *liveFuncValues;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *liveFuncTitles;

@end

@implementation LiveActions

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = [BHIManager isTurkish] ? @"Canlı Buton Eylemleri" : @"Live Button Actions";
    self.liveFuncTitles = [BHIManager isTurkish] ? @[@"Varsayılan", @"TweryTok Ayarları", @"Oynatma Hızı"] : @[@"Default", @"TweryTok Settings", @"Playback Speed"];
    self.liveFuncValues = @[@0, @1, @2];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[BHIManager isTurkish] ? @"Kapat" : @"Done"
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(dismissActions)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    [self setupNavBarAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavBarAppearance];
    [self.tableView reloadData];
}

- (void)setupNavBarAppearance {
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

- (void)dismissActions {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.liveFuncValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LiveActionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.liveFuncTitles[indexPath.row];
    cell.backgroundColor = [UIColor systemBackgroundColor];
    cell.textLabel.textColor = [UIColor labelColor];
    
    NSNumber *currentAction = [BHIManager selectedLiveAction];
    if (currentAction && [currentAction isEqual:self.liveFuncValues[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *selectedLiveOption = self.liveFuncTitles[indexPath.row];
    NSNumber *selectedValue = self.liveFuncValues[indexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:selectedValue forKey:@"live_action"];
    [defaults synchronize];
    
    [self.tableView reloadData];
    
    BOOL tr = [BHIManager isTurkish];
    NSString *title = tr ? @"Canlı Eylem Seçildi" : @"Live Option Selected";
    NSString *msg = tr ? [NSString stringWithFormat:@"Seçilen eylem: %@", selectedLiveOption]
                       : [NSString stringWithFormat:@"You selected: %@", selectedLiveOption];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:tr ? @"Tamam" : @"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification"
                                                        object:nil
                                                      userInfo:@{@"selected action": selectedLiveOption}];
}

@end
