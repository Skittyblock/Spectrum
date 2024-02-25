// SPProfileCell.m

#import "SPProfileCell.h"
#import "SPProfileViewController.h"
#import <rootless.h>

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
	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/%@.plist"), self.specifier.properties[@"defaults"]]];

	NSString *title = [[settings objectForKey:self.specifier.properties[@"key"]] stringValue] ?: @"Default";

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
