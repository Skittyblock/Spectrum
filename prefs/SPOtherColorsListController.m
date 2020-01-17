// SPOtherColorsListController.m

#include "SPOtherColorsListController.h"
#import "Preferences.h"

@implementation SPOtherColorsListController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.view.tintColor = kTintColor;
	[UIApplication sharedApplication].keyWindow.tintColor = kTintColor;
	[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = kTintColor;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[UIApplication sharedApplication].keyWindow.tintColor = nil;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"OtherColors" target:self];
	}

	return _specifiers;
}

@end
