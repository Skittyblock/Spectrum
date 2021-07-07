// SPFillColorsListController.m

#include "SPFillColorsListController.h"
#import "Preferences.h"

@implementation SPFillColorsListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"FillColors" target:self];
	}

	return _specifiers;
}

@end
