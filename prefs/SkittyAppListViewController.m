// Skitty App List - Custom AppList Alternative
// By Skitty

#import "SkittyAppListViewController.h"

CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

SkittyAppListViewController *controller;

static void setAppList(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  if ([(__bridge NSDictionary *)userInfo count] < 2) { // people must have at least two apps, right?
    return;
  }
  NSLog(@"[SPEC] setAppList: %@", userInfo);
  [controller recieveAppList:(__bridge NSDictionary *)userInfo];
}

static void post() {
  NSLog(@"[SPEC] post");
  CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.skitty.spectrum.getapps"), nil, nil, true);
}

@implementation SkittyAppListViewController

- (NSArray *)specifiers {
  return nil;
}

- (id)init {
  self = [super init];
  if (self) {
    // Supported Apps
    //self.supportedApps = @[@"com.apple.AppStore", @"com.apple.mobilecal", @"com.apple.MobileAddressBook", @"com.apple.mobilemail", @"com.apple.Maps", @"com.apple.MobileSMS", @"com.apple.Music", @"com.apple.mobileslideshow", @"com.apple.mobilephone", @"com.apple.news", @"com.apple.podcasts", @"com.apple.Preferences", @"is.workflow.my.app"];
    
    self.title = @"Enabled Apps";

    CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, setAppList, CFSTR("xyz.skitty.spectrum.setapps"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);

    NSString *prefPath = @"/var/mobile/Library/Preferences/xyz.skitty.spectrum.apps.plist";
    NSArray *apps;
    if ([[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
      NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefPath];
      apps = [prefs objectForKey:@"Apps"];
    } else {
      apps = @[];
    }
    self.preferencesAppList = apps;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    //self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"Search";

    //self.tableView.tableHeaderView = self.searchController.searchBar;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO; // unfortunatly, this is required.

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    [self getAppList];

    // This is probably a terrible way to do it.
    controller = self;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

// Preferences

- (void)updatePreferencesAppList {
  NSString *prefPath = @"/var/mobile/Library/Preferences/xyz.skitty.spectrum.apps.plist";
  NSDictionary *preferencesDict = @{ @"Apps": self.preferencesAppList };
  [preferencesDict writeToFile:prefPath atomically:YES];
}

- (void)updateSwitch:(UISwitch *)appSwitch {
  NSString *tag = [NSString stringWithFormat:@"%ld", (long)appSwitch.tag];
  NSInteger section = [[tag substringToIndex:1] intValue] - 1;
  NSInteger row = [[tag substringFromIndex:1] intValue];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  BOOL on = [(UISwitch *)cell.accessoryView isOn];
  //setOn:animated:

  NSString *bundleIdentifier;
  /*if (indexPath.section == 0) {
    bundleIdentifier = self.supportedIdentifiers[indexPath.row];
  } else if (indexPath.section == 1) {
    bundleIdentifier = self.unsupportedIdentifiers[indexPath.row];
  }*/
  bundleIdentifier = self.identifiers[indexPath.row];

  NSMutableArray *list = [self.preferencesAppList mutableCopy];
  if (on) {
    [list addObject:bundleIdentifier];
  } else {
    [list removeObject:bundleIdentifier];
  }

  self.preferencesAppList = list;
  [self updatePreferencesAppList];
}

// App List

- (void)getAppList {
  NSLog(@"[SPEC] getAppList");

  if (self.appList.count == 0) {
    self.appList = @{@"Loading!": @"Loading..."};
  }
  
  post();
}

- (void)recieveAppList:(NSDictionary *)appList {
  if ([appList count] < 2) {
    return;
  }
  self.fullAppList = appList;
  [self updateAppList:appList];
}

- (void)updateAppList:(NSDictionary *)appList {
  NSArray *ids = [appList keysSortedByValueUsingComparator:^(NSString *obj1, NSString *obj2) {
    return [obj1 compare:obj2];
  }];

  /*NSMutableArray *supportedIds = [[NSMutableArray alloc] init];
  NSMutableArray *unsupportedIds = [ids mutableCopy];
  for (int i = 0; i < self.supportedApps.count; i++) {
    if ([appList objectForKey:self.supportedApps[i]]) {
      [supportedIds addObject:self.supportedApps[i]];
      [unsupportedIds removeObject:self.supportedApps[i]];
    }
  }

  self.supportedIdentifiers = supportedIds;
  self.unsupportedIdentifiers = unsupportedIds;*/
  self.identifiers = ids;
  self.appList = appList;

  [self.tableView reloadData];
}

// Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SkittyAppCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:3 reuseIdentifier:@"SkittyAppCell"];
  }
  
  UISwitch *appSwitch = [[UISwitch alloc] init];
  appSwitch.tag = [[NSString stringWithFormat:@"%ld%ld", (long)indexPath.section + 1, (long)indexPath.row] intValue];
  [appSwitch addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventPrimaryActionTriggered];
  [cell setAccessoryView:appSwitch];
  
  cell.detailTextLabel.textColor = [UIColor grayColor];
  
  //if (indexPath.section == 0) {
    if ([self.preferencesAppList containsObject:self.identifiers[indexPath.row]]) {
      [appSwitch setOn:YES animated:NO];
    }
    cell.textLabel.text = [self.fullAppList objectForKey:self.identifiers[indexPath.row]];
    //cell.detailTextLabel.text = self.identifiers[indexPath.row];
    cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:self.identifiers[indexPath.row] format:0 scale:[UIScreen mainScreen].scale];
  /*} else if (indexPath.section == 1) {
    if ([self.preferencesAppList containsObject:self.unsupportedIdentifiers[indexPath.row]]) {
      [appSwitch setOn:YES animated:NO];
    }
    cell.textLabel.text = [self.fullAppList objectForKey:self.unsupportedIdentifiers[indexPath.row]];
    //cell.detailTextLabel.text = self.unsupportedIdentifiers[indexPath.row];
    cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:self.unsupportedIdentifiers[indexPath.row] format:0 scale:[UIScreen mainScreen].scale];
  }*/
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  /*if (section == 0) {
    return self.supportedIdentifiers.count;
  } else if (section == 1) {
    return self.unsupportedIdentifiers.count;
  }*/
  return self.identifiers.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  /*if (section == 0) {
    return @"Supported Apps";
  } else if (section == 1) {
    return @"Unsupported Apps";
  }*/
  return nil;
}

// Search Bar

- (void)searchWithText:(NSString *)text {
  NSLog(@"[SPEC] searchWithText: %@", text);
  //text = @"Cal";
  NSDictionary *newAppList;
  if (text.length == 0) {
    newAppList = self.fullAppList;
  } else {
    NSMutableDictionary *mutableList = [[NSMutableDictionary alloc] init];
    NSArray *ids = [self.fullAppList keysSortedByValueUsingComparator:^(NSString *obj1, NSString *obj2) {
      return [obj1 compare:obj2];
    }];
    NSArray<NSString *> *names = [[self.fullAppList allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (int i = 0; i < names.count; i++) {
      if ([names[i].lowercaseString rangeOfString:text.lowercaseString].location != NSNotFound) {
        [mutableList setObject:names[i] forKey:ids[i]];
      }
    }
    newAppList = [mutableList copy];
  }
  NSLog(@"[SPEC] search list: %@", newAppList);
  [self updateAppList:newAppList];
}
/*
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
  NSLog(@"[SPEC] updateSearchResultsForSearchController");
}
*/
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
  //NSLog(@"[SPEC] textDidChange: %@", text);
  [self searchWithText:text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  //NSLog(@"[SPEC] searchBarTextDidBeginEditing");
  [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
  //NSLog(@"[SPEC] searchBarTextDidEndEditing: %@", searchBar.text);
  [self searchWithText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
  [searchBar setShowsCancelButton:NO animated:YES];
  [self searchWithText:nil];
}

@end
