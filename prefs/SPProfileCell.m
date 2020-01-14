// SPProfileCell.m

#import "SPProfileCell.h"
#import "SPProfileViewController.h"

@implementation SPProfileCell

- (id)target {
	return self;
}

- (id)cellTarget {
	return self;
}

- (SEL)action {
	return @selector(openModePage);
}

- (SEL)cellAction {
	return @selector(openModePage);
}

- (void)openModePage {
	// do it
	UINavigationController *navController = [self _viewControllerForAncestor].navigationController;
	SPProfileViewController *controller = [[SPProfileViewController alloc] initWithProperties:self.specifier.properties];
	[navController pushViewController:controller animated:YES];
}

- (void)updateProfile {
	NSString *path = @"/Library/Application Support/Spectrum/Profiles";
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
	NSMutableArray *plistFiles = [[NSMutableArray alloc] init];

	[files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *filename = (NSString *)obj;
		NSString *extension = [[filename pathExtension] lowercaseString];
		if ([extension isEqualToString:@"plist"]) {
			NSDictionary *contents = [[NSDictionary alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:filename]];
			if (contents[@"name"])
				[plistFiles addObject:contents[@"name"]];
		}
	}];

	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.specifier.properties[@"defaults"]]];

	int index = [[settings objectForKey:self.specifier.properties[@"key"]] intValue];

	NSString *title = @"";
	
	if (index >= plistFiles.count)
		title = @"Custom";
	else
		title = plistFiles[index];

	self.detailTextLabel.text = title;
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];

	//self.detailTextLabel.textColor = [UIColor grayColor];
	[self updateProfile];

	[self.specifier setTarget:self];
	[self.specifier setButtonAction:@selector(openModePage)];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:@"xyz.skitty.spectrum.profilechange" object:nil];
}

@end
