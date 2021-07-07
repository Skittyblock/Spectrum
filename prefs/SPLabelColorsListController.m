// SPLabelColorsListController.m

#include "SPLabelColorsListController.h"
#import "Preferences.h"

@implementation SPLabelColorsListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"LabelColors" target:self];
	}

	return _specifiers;
}

@end
