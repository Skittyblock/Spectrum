// SPHeader.m

#include "SPHeader.h"

@implementation SPHeader

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

	if (self) {
		NSArray *subtitles = [NSArray arrayWithObjects:@"Customize system tints!", @"By Skitty", @"Free and Open-Source!", nil];

		self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, [[UIApplication sharedApplication] keyWindow].frame.size.width, 60)];
		self.title.numberOfLines = 1;
		self.title.font = [UIFont systemFontOfSize:50];
		self.title.text = @"Spectrum";
		self.title.textColor = kTintColor;
		self.title.textAlignment = NSTextAlignmentCenter;
		[self addSubview:self.title];

		self.subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, [[UIApplication sharedApplication] keyWindow].frame.size.width, 30)];
		self.subtitle.numberOfLines = 1;
		self.subtitle.font = [UIFont systemFontOfSize:20];
		self.subtitle.text = [subtitles objectAtIndex:arc4random_uniform([subtitles count])];
		self.subtitle.textColor = [UIColor grayColor];
		self.subtitle.textAlignment = NSTextAlignmentCenter;
		[self addSubview:self.subtitle];
	}

	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
	CGFloat prefHeight = 150.0;
	return prefHeight;
}

@end
