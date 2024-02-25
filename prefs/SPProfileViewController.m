// SPProfileViewController.m

#import "SPProfileViewController.h"
#import "Preferences.h"
#import <rootless.h>

@implementation SPProfileViewController

- (id)initWithProperties:(NSDictionary *)properties {
	self = [super init];
	if (self) {
		self.properties = properties;

		self.title = @"Profiles";

		if (@available(iOS 13, *)) {
			self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
		} else {
			self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
		}

		self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		[self.view addSubview:self.tableView];

		NSString *path = ROOT_PATH_NS(@"/Library/Spectrum");
		NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
		NSMutableArray *plistFiles = [[NSMutableArray alloc] init];

		[files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *filename = (NSString *)obj;
			NSString *extension = [[filename pathExtension] lowercaseString];
			if ([extension isEqualToString:@"plist"]) {
				NSDictionary *contents = [[NSDictionary alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:filename]];
				if (contents[@"name"] && ![contents[@"name"] isEqualToString:@"Default"]) [plistFiles addObject:contents[@"name"]];
			}
		}];

		self.profiles = plistFiles;

		CFStringRef ref = CFPreferencesCopyAppValue((CFStringRef)self.properties[@"key"], (CFStringRef)self.properties[@"defaults"]);

		NSInteger index = [plistFiles indexOfObject:(__bridge NSString *)ref];

		if (index != NSNotFound) self.selected = index + 1;
		else self.selected = 0;
	}
	return self;
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
	
	NSString *title = @"";
	if (indexPath.row == 0)
		title = @"Default";
	else
		title = self.profiles[indexPath.row - 1];

	cell.textLabel.text = title;

	if (indexPath.row == self.selected)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	self.selected = indexPath.row;

	for (int i = 0; i < [tableView numberOfRowsInSection:0]; i++) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/%@.plist"), self.properties[@"defaults"]]];

	[settings setObject:cell.textLabel.text forKey:self.properties[@"key"]];

	[settings writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@.plist", ROOT_PATH_NS(@"/var/mobile/Library/Preferences"), self.properties[@"defaults"]]] error:nil];
	CFPreferencesAppSynchronize((CFStringRef)self.properties[@"defaults"]);
	CFPreferencesSetAppValue((CFStringRef)self.properties[@"key"], (CFStringRef)cell.textLabel.text, (CFStringRef)self.properties[@"defaults"]);

	[[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.spectrum.profilechange" object:self];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)self.properties[@"PostNotification"], nil, nil, true);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.profiles.count + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

@end
