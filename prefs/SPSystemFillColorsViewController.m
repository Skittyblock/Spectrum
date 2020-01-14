// SPSystemFillColorsViewController.m

#include "SPSystemFillColorsViewController.h"

@implementation SPSystemFillColorsViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
	self.view.tintColor = kTintColor;
	keyWindow.tintColor = kTintColor;
	[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = kTintColor;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
	keyWindow.tintColor = nil;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"FillColors" target:self];
	}

	return _specifiers;
}

@end
