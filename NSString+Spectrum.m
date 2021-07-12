// NSString+Spectrum.m

#import "NSString+Spectrum.h"

@implementation NSString (Spectrum)

- (NSString *)capitalizeFirstLetter {
	NSMutableString *copy = self.mutableCopy;
	[copy replaceCharactersInRange:NSMakeRange(0, 1) withString:[[self substringToIndex:1] capitalizedString]];
	return copy;
}

@end
