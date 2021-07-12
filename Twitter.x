
#import "Tweak.h"

%group Twitter

%hook TAEStandardColorPalette

- (UIColor *)primaryColor {
	return useTint ? tint : %orig;
}

- (UIColor *)brandLogoColor { // launch screen background
	return useTint ? tint : %orig;
}

- (UIColor *)navigationBarLogoColor {
	return useTint ? tint : %orig;
}

- (UIColor *)notificationBadgeColor {
	return useTint ? tint : %orig;
}

- (UIColor *)verifiedColor {
	return useTint ? tint : %orig;
}

- (UIColor *)backgroundColor {
	return staticColor(@"light", @"secondarySystemBackgroundColor") ?: %orig;
}

- (UIColor *)appBackgroundColor {
	return staticColor(@"light", @"systemGroupedBackgroundColor") ?: %orig;
}

- (UIColor *)_dividerColor {
	return staticColor(@"light", @"separatorColor") ?: %orig;
}

- (UIColor *)highlightBackgroundColor {
	return staticColor(@"light", @"tableViewCellSelectionColor") ?: %orig;
}

// - (UIColor *)itemDarkBackgroundColor // launch screen logo color
// - (UIColor *)integralTweetActionColor // tweet button glyphs color
// - (UIColor *)dmBubbleIncomingColor 
// - (UIColor *)tabBarItemColor
// - (UIColor *)cellAccessoryColor

%end

%hook TAEDarkColorPalette

- (UIColor *)primaryColor {
	return useTint ? tint : %orig;
}

- (UIColor *)brandLogoColor {
	return useTint ? tint : %orig;
}

- (UIColor *)navigationBarLogoColor {
	return useTint ? tint : %orig;
}

- (UIColor *)notificationBadgeColor {
	return useTint ? tint : %orig;
}

- (UIColor *)verifiedColor {
	return useTint ? tint : %orig;
}

- (UIColor *)backgroundColor {
	return staticColor(@"dark", @"secondarySystemBackgroundColor") ?: %orig;
}

- (UIColor *)appBackgroundColor {
	return staticColor(@"dark", @"systemGroupedBackgroundColor") ?: %orig;
}

- (UIColor *)_dividerColor {
	return staticColor(@"dark", @"separatorColor") ?: %orig;
}

- (UIColor *)highlightBackgroundColor {
	return staticColor(@"dark", @"tableViewCellSelectionColor") ?: %orig;
}

%end

%hook TAEDarkerColorPalette

- (UIColor *)primaryColor {
	return useTint ? tint : %orig;
}

- (UIColor *)brandLogoColor {
	return useTint ? tint : %orig;
}

- (UIColor *)navigationBarLogoColor {
	return useTint ? tint : %orig;
}

- (UIColor *)notificationBadgeColor {
	return useTint ? tint : %orig;
}

- (UIColor *)verifiedColor {
	return useTint ? tint : %orig;
}

- (UIColor *)backgroundColor {
	return staticColor(@"dark", @"secondarySystemBackgroundColor") ?: %orig;
}

- (UIColor *)appBackgroundColor {
	return staticColor(@"dark", @"systemGroupedBackgroundColor") ?: %orig;
}

- (UIColor *)_dividerColor {
	return staticColor(@"dark", @"separatorColor") ?: %orig;
}

- (UIColor *)highlightBackgroundColor {
	return staticColor(@"dark", @"tableViewCellSelectionColor") ?: %orig;
}

%end

%hook TUISearchTextView

// there might be a twitter color key for this but idk it
- (id)_backgroundImageWithDynamicFillColor:(UIColor *)color {
	return %orig(dynamicColorWithOptions(color, @"systemGroupedBackgroundColor"));
}

%end

%end

%ctor {
	BOOL isTwitter = [[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.atebits.Tweetie2"];

	if (getPrefBool(@"enabled") && isTwitter) {
		%init(Twitter)
	}
}
