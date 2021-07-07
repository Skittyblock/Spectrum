// SPOtherColorsListController.m

#include "SPOtherColorsListController.h"
#import "Preferences.h"

@implementation SPOtherColorsListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"OtherColors" target:self];
	}

	return _specifiers;
}

@end
