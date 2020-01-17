// Spectrum, by Skitty (and Even)
// Customize system colors!

#import "Tweak.h"

static NSMutableDictionary *settings;
static NSArray *systemIdentifiers;
static bool global = YES;
//static bool useIconColor = NO;
static bool enabled;

static bool isDefault;
static NSDictionary *currentProfile;

static bool customTintColor;
static bool customDarkColors;
static bool customLightColors;

static UIColor *tint;
static UIColor *highlight;

// Dark Colors
static UIColor *darkGroupTableViewBackgroundColor;
static UIColor *darkSeparatorColor;
static UIColor *darkSystemBackgroundColor;
static UIColor *darkSystemGroupedBackgroundColor;
static UIColor *darkTableCellGroupedBackgroundColor;
static UIColor *darkSecondarySystemBackgroundColor;
static UIColor *darkSecondarySystemGroupedBackgroundColor;
static UIColor *darkTertiarySystemBackgroundColor;
static UIColor *darkTertiarySystemGroupedBackgroundColor;

static UIColor *darkLabelColor;
static UIColor *darkPlaceholderLabelColor;
static UIColor *darkSecondaryLabelColor;
static UIColor *darkTertiaryLabelColor;

// Light Colors
static UIColor *lightGroupTableViewBackgroundColor;
static UIColor *lightSeparatorColor;
static UIColor *lightSystemBackgroundColor;
static UIColor *lightSystemGroupedBackgroundColor;
static UIColor *lightTableCellGroupedBackgroundColor;
static UIColor *lightSecondarySystemBackgroundColor;
static UIColor *lightSecondarySystemGroupedBackgroundColor;
static UIColor *lightTertiarySystemBackgroundColor;
static UIColor *lightTertiarySystemGroupedBackgroundColor;

static UIColor *lightLabelColor;
static UIColor *lightPlaceholderLabelColor;
static UIColor *lightSecondaryLabelColor;
static UIColor *lightTertiaryLabelColor;
//static UIColor *iconTint;

UIColor *appTintColorFromWindow(UIWindow *window) {
	if (!window || !window.tintColor) {
		UIView *view = [[UIView alloc] init];
		return [view _normalInheritedTintColor];
	}
	if (!window.tintColor) {
		if (window.rootViewController) {
			//return window.rootViewController.view.tintColor;
		}
	}
	return window.tintColor;
}

UIColor *iconTintColorForCurrentApp() {
	NSString *bundleid = [[NSBundle mainBundle] bundleIdentifier];
	if ([bundleid isEqualToString:@"com.apple.springboard"]) {
		return [UIColor systemBlueColor];
	}

	UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:bundleid format:2 scale:[UIScreen mainScreen].scale];

	CGSize size = {1, 1};
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);

	[icon drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
	uint8_t *data = (uint8_t *)CGBitmapContextGetData(ctx);

	UIColor *color = [UIColor colorWithRed:data[2] / 255.0f green:data[1] / 255.0f blue:data[0] / 255.0f alpha:1];

	UIGraphicsEndImageContext();

	return color;
}

// Color from hex
static CGFloat colorComponentFrom(NSString *string, NSInteger start, NSInteger length) {
	NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

static UIColor *colorFromHexString(NSString *hexString) {
	CGFloat red, green, blue, alpha;
	switch(hexString.length) {
		case 3: // #RGB
			red = colorComponentFrom(hexString, 0, 1);
			green = colorComponentFrom(hexString, 1, 1);
			blue = colorComponentFrom(hexString, 2, 1);
			alpha = 1;
			break;
		case 4: // #RGBA
			red = colorComponentFrom(hexString, 0, 1);
			green = colorComponentFrom(hexString, 1, 1);
			blue = colorComponentFrom(hexString, 2, 1);
			alpha = colorComponentFrom(hexString, 3, 1);
			break;
		case 6: // #RRGGBB
			red = colorComponentFrom(hexString, 0, 2);
			green = colorComponentFrom(hexString, 2, 2);
			blue = colorComponentFrom(hexString, 4, 2);
			alpha = 1;
			break;
		case 8: // #RRGGBBAA
			red = colorComponentFrom(hexString, 0, 2);
			green = colorComponentFrom(hexString, 2, 2);
			blue = colorComponentFrom(hexString, 4, 2);
			alpha = colorComponentFrom(hexString, 6, 2);
			break;
        default: // Invalid color
			red = 0;
			green = 0;
			blue = 0;
			alpha = 0;
            break;
	}
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

UIColor *colorFromHexStringWithAlpha(NSString *hexString, double alpha) {
	unsigned rgbValue = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner setScanLocation:0];
	[scanner scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

// Preference Updates
static void refreshPrefs() {
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("xyz.skitty.spectrum"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("xyz.skitty.spectrum"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}
	if (!settings) {
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/xyz.skitty.spectrum.plist"];
	}

	// Profile
	NSString *path = @"/Library/Application Support/Spectrum/Profiles";
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
	NSMutableArray *plistFiles = [[NSMutableArray alloc] init];

	[files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *filename = (NSString *)obj;
		NSString *extension = [[filename pathExtension] lowercaseString];
		if ([extension isEqualToString:@"plist"]) {
			NSDictionary *contents = [[NSDictionary alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:filename]];
			if (contents[@"name"])
				[plistFiles addObject:contents];
		}
	}];

	int index = [[settings objectForKey:@"profile"] intValue];
	
	if (index == 0)
		isDefault = YES;
	else
		currentProfile = plistFiles[index - 1];

	// Settings
	enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
	customTintColor = [([settings objectForKey:@"customTintColor"] ?: @(YES)) boolValue];
	customDarkColors = [([settings objectForKey:@"customDarkColors"] ?: @(NO)) boolValue];
	customLightColors = [([settings objectForKey:@"customLightColors"] ?: @(NO)) boolValue];

	NSString *tintHex = (!customTintColor && currentProfile[@"tintColor"]) ? currentProfile[@"tintColor"] : ([settings objectForKey:@"tintColor"] ?: @"F22F6CFF");
	tint = colorFromHexString(tintHex);
	highlight = colorFromHexStringWithAlpha(tintHex, 0.3);

	darkGroupTableViewBackgroundColor = colorFromHexString([settings objectForKey:@"darkGroupTableViewBackgroundColor"] ?: @"000000FF");
	darkSeparatorColor = colorFromHexString([settings objectForKey:@"darkSeparatorColor"] ?: @"54545899");
	darkSystemBackgroundColor = colorFromHexString([settings objectForKey:@"darkSystemBackgroundColor"] ?: @"000000FF");
	darkSystemGroupedBackgroundColor = colorFromHexString([settings objectForKey:@"darkSystemGroupedBackgroundColor"] ?: @"000000FF");
	darkTableCellGroupedBackgroundColor = colorFromHexString([settings objectForKey:@"darkTableCellGroupedBackgroundColor"] ?: @"1C1C1EFF");
	darkSecondarySystemBackgroundColor = colorFromHexString([settings objectForKey:@"darkSecondarySystemBackgroundColor"] ?: @"1C1C1EFF");
	darkSecondarySystemGroupedBackgroundColor = colorFromHexString([settings objectForKey:@"darkSecondarySystemGroupedBackgroundColor"] ?: @"1C1C1EFF");
	darkTertiarySystemBackgroundColor = colorFromHexString([settings objectForKey:@"darkTertiarySystemBackgroundColor"] ?: @"2C2C2EFF");
	darkTertiarySystemGroupedBackgroundColor = colorFromHexString([settings objectForKey:@"darkTertiarySystemGroupedBackgroundColor"] ?: @"2C2C2EFF");
	darkLabelColor = colorFromHexString([settings objectForKey:@"darkLabelColor"] ?: @"FFFFFFFF");
	darkPlaceholderLabelColor = colorFromHexString([settings objectForKey:@"darkPlaceholderLabelColor"] ?: @"EBEBF54C");
	darkSecondaryLabelColor = colorFromHexString([settings objectForKey:@"darkSecondaryLabelColor"] ?: @"EBEBF599");
	darkTertiaryLabelColor = colorFromHexString([settings objectForKey:@"darkTertiaryLabelColor"] ?: @"EBEBF54C");

	lightGroupTableViewBackgroundColor = colorFromHexString([settings objectForKey:@"lightGroupTableViewBackgroundColor"] ?: @"F2F2F7FF");
	lightSeparatorColor = colorFromHexString([settings objectForKey:@"lightSeparatorColor"] ?: @"3C3C434C");
	lightSystemBackgroundColor = colorFromHexString([settings objectForKey:@"lightSystemBackgroundColor"] ?: @"FFFFFFFF");
	lightSystemGroupedBackgroundColor = colorFromHexString([settings objectForKey:@"lightSystemGroupedBackgroundColor"] ?: @"F2F2F7FF");
	lightTableCellGroupedBackgroundColor = colorFromHexString([settings objectForKey:@"lightTableCellGroupedBackgroundColor"] ?: @"FFFFFFFF");
	lightSecondarySystemBackgroundColor = colorFromHexString([settings objectForKey:@"lightSecondarySystemBackgroundColor"] ?: @"F2F2F7FF");
	lightSecondarySystemGroupedBackgroundColor = colorFromHexString([settings objectForKey:@"lightSecondarySystemGroupedBackgroundColor"] ?: @"FFFFFFFF");
	lightTertiarySystemBackgroundColor = colorFromHexString([settings objectForKey:@"lightTertiarySystemBackgroundColor"] ?: @"FFFFFFFF");
	lightTertiarySystemGroupedBackgroundColor = colorFromHexString([settings objectForKey:@"lightTertiarySystemGroupedBackgroundColor"] ?: @"F2F2F7FF");
	lightLabelColor = colorFromHexString([settings objectForKey:@"lightLabelColor"] ?: @"000000FF");
	lightPlaceholderLabelColor = colorFromHexString([settings objectForKey:@"lightPlaceholderLabelColor"] ?: @"3C3C434C");
	lightSecondaryLabelColor = colorFromHexString([settings objectForKey:@"lightSecondaryLabelColor"] ?: @"3C3C4399");
	lightTertiaryLabelColor = colorFromHexString([settings objectForKey:@"lightTertiaryLabelColor"] ?: @"3C3C434C");
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	refreshPrefs();
}

// Create a Dynamic color
static UIColor *dynamicColor(UIColor *defaultColor, UIColor *darkColor) {
	if (@available(iOS 13.0, *)) {
		return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
			if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
				return darkColor;
			} else {
				return defaultColor;
			}
		}];
	}
	return defaultColor;
}

static UIColor *dynamicColorWithOptions(UIColor *orig, NSString *lightKey, NSString *darkKey, UIColor *customLightColor, UIColor *customDarkColor) {
	UIColor *lightColor = [orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]];
	UIColor *darkColor = [orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]];

	if (customLightColors || customDarkColors) {
		if (customLightColors && customLightColor)
			lightColor = customLightColor;
		if (customDarkColors && customDarkColor)
			darkColor = customDarkColor;
	} else if (currentProfile && (currentProfile[lightKey] || currentProfile[darkKey])) {
		if (currentProfile[lightKey])
			lightColor = colorFromHexString(currentProfile[lightKey]);
		if (currentProfile[darkKey])
			darkColor = colorFromHexString(currentProfile[darkKey]);
	}

	return dynamicColor(lightColor, darkColor);
}

// Global Tint Color
%group UIColor

// Override apps that try to fake it
%hook UIColor
+ (id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {
	if (red == 0.0 && green == 122.0/255.0 && blue == 1.0) {
		return (customTintColor || currentProfile[@"tintColor"]) ? tint : %orig;
	}
	return %orig;
}
// Default tint
+ (id)systemBlueColor {
	return (customTintColor || currentProfile[@"tintColor"]) ? tint : %orig;
}
// Selection point
+ (id)insertionPointColor {
	return (customTintColor || currentProfile[@"tintColor"]) ? tint : %orig;
}
// Selection highlight
+ (id)selectionHighlightColor {
	return (customTintColor || currentProfile[@"tintColor"]) ? highlight : %orig;
}
// Selection grabbers
+ (id)selectionGrabberColor {
	return (customTintColor || currentProfile[@"tintColor"]) ? tint : %orig;
}
// Links
+ (id)linkColor {
	return (customTintColor || currentProfile[@"tintColor"]) ? tint : %orig;
}

// Primary color
+ (id)systemBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSystemBackgroundColor", @"darkSystemBackgroundColor", lightSystemBackgroundColor, darkSystemBackgroundColor);
}
+ (id)systemGroupedBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSystemGroupedBackgroundColor", @"darkSystemGroupedBackgroundColor", lightSystemGroupedBackgroundColor, darkSystemGroupedBackgroundColor);
}
+ (id)groupTableViewBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightGroupTableViewBackgroundColor", @"darkGroupTableViewBackgroundColor", lightGroupTableViewBackgroundColor, darkGroupTableViewBackgroundColor);
}
+ (id)tableBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightGroupTableViewBackgroundColor", @"darkGroupTableViewBackgroundColor", lightGroupTableViewBackgroundColor, darkGroupTableViewBackgroundColor);
}
+ (id)tableCellPlainBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSystemBackgroundColor", @"darkSystemBackgroundColor", lightSystemBackgroundColor, darkSystemBackgroundColor);
}
+ (id)tableCellGroupedBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightTableCellGroupedBackgroundColor", @"darkTableCellGroupedBackgroundColor", lightTableCellGroupedBackgroundColor, darkTableCellGroupedBackgroundColor);
}

// Secondary color
+ (id)secondarySystemBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSecondarySystemBackgroundColor", @"darkSecondarySystemBackgroundColor", lightSecondarySystemBackgroundColor, darkSecondarySystemBackgroundColor);
}
+ (id)secondarySystemGroupedBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSecondarySystemGroupedBackgroundColor", @"darkSecondarySystemGroupedBackgroundColor", lightSecondarySystemGroupedBackgroundColor, darkSecondarySystemGroupedBackgroundColor);
}

// Tertiary color
+ (id)tertiarySystemBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightTertiarySystemBackgroundColor", @"darkTertiarySystemBackgroundColor", lightTertiarySystemBackgroundColor, darkTertiarySystemBackgroundColor);
}
+ (id)tertiarySystemGroupedBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightTertiarySystemGroupedBackgroundColor", @"darkTertiarySystemGroupedBackgroundColor", lightTertiarySystemGroupedBackgroundColor, darkTertiarySystemGroupedBackgroundColor);
}

// Separator color
+ (id)separatorColor {
	return dynamicColorWithOptions(%orig, @"lightSeparatorColor", @"darkSeparatorColor", lightSeparatorColor, darkSeparatorColor);
}
+ (id)opaqueSeparatorColor {
	return dynamicColorWithOptions(%orig, @"lightSeparatorColor", @"darkSeparatorColor", lightSeparatorColor, darkSeparatorColor);
}
+ (id)tableSeparatorColor {
	return dynamicColorWithOptions(%orig, @"lightSeparatorColor", @"darkSeparatorColor", lightSeparatorColor, darkSeparatorColor);
}

// Label colors
+ (id)labelColor {
	return dynamicColorWithOptions(%orig, @"lightLabelColor", @"darkLabelColor", lightLabelColor, darkLabelColor);
}
+ (id)secondaryLabelColor {
	return dynamicColorWithOptions(%orig, @"lightSecondaryLabelColor", @"darkSecondaryLabelColor", lightSecondaryLabelColor, darkSecondaryLabelColor);
}
+ (id)placeholderLabelColor {
	return dynamicColorWithOptions(%orig, @"lightPlaceholderLabelColor", @"darkPlaceholderLabelColor", lightPlaceholderLabelColor, darkPlaceholderLabelColor);
}
+ (id)tertiaryLabelColor {
	return dynamicColorWithOptions(%orig, @"lightTertiaryLabelColor", @"darkTertiaryLabelColor", lightTertiaryLabelColor, darkTertiaryLabelColor);
}

+ (id)tablePlainHeaderFooterBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightTertiaryLabelColor", @"darkTertiaryLabelColor", lightTertiaryLabelColor, darkTertiaryLabelColor);
}

// UITableViewCell selection color
+ (id)systemGray4Color {
	return dynamicColorWithOptions(%orig, @"lightGray4Color", @"darkGray4Color", nil, nil);
}
+ (id)systemGray5Color {
	return dynamicColorWithOptions(%orig, @"lightGray5Color", @"darkGray5Color", nil, nil);
}

%end

%end

// Per App Tint Color
%group App

%hook UINavigationBar
%property (nonatomic, retain) UIColor *storedBarColor;
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if ((currentProfile[@"lightBarColor"] && currentStyle == UIUserInterfaceStyleLight) || (currentProfile[@"darkBarColor"] && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"lightBarColor", @"darkBarColor", nil, nil));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}
%end

%hook UIToolbar
%property (nonatomic, retain) UIColor *storedBarColor;
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if ((currentProfile[@"lightBarColor"] && currentStyle == UIUserInterfaceStyleLight) || (currentProfile[@"darkBarColor"] && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"lightBarColor", @"darkBarColor", nil, nil));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}
%end

%hook UITabBar
%property (nonatomic, retain) UIColor *storedBarColor;
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if ((currentProfile[@"lightBarColor"] && currentStyle == UIUserInterfaceStyleLight) || (currentProfile[@"darkBarColor"] && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"lightBarColor", @"darkBarColor", nil, nil));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}
%end

%hook UIView
- (UIColor *)tintColor {
	if (![self isKindOfClass:%c(UIWindow)] && [self _normalInheritedTintColor] == appTintColorFromWindow([self window])) {
		return (customTintColor || currentProfile[@"tintColor"]) ? tint : %orig;
	}
	return %orig;
}
%end

%end

// Message bubbles POC
/*%group Messages

%hook CKUITheme
- (id)blue_balloonColors {
	UIColor *topColor = [UIColor blueColor];
	UIColor *bottomColor = [UIColor redColor];
	return @[topColor, bottomColor]
}
// - (id)green_balloonColors
%end

%end*/

// App List
static NSMutableDictionary *appList() {
	NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
	for (SBApplication *app in [[NSClassFromString(@"SBApplicationController") sharedInstance] allApplications]) {
		bool add = YES;
		NSString *name = app.displayName ?: @"Error";
		for (NSString *id in systemIdentifiers) {
			if ([app.bundleIdentifier isEqual:id]) {
				add = NO;
			}
		}
		if (add) {
			[mutableDict setObject:name forKey:app.bundleIdentifier];
		}
	}

	return mutableDict;
}

static void getAppList(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
		return;
	}

	NSMutableDictionary *mutableDict = appList();

	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.skitty.spectrum.setapps"), nil, (__bridge CFDictionaryRef)mutableDict, true);
}

static NSArray *disabledApps() {
	NSArray *apps = @[];
	NSString *prefPath = @"/var/mobile/Library/Preferences/xyz.skitty.spectrum.apps.plist";
	if ([[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
		NSDictionary *appPrefs = [NSDictionary dictionaryWithContentsOfFile:prefPath];
		apps = appPrefs[@"Disabled"];
	}

	return apps;
}

%ctor {
	// Hidden system apps
	systemIdentifiers = @[@"com.apple.AppSSOUIService", @"com.apple.AuthKitUIService", @"com.apple.BusinessChatViewService", @"com.apple.CTNotifyUIService", @"com.apple.CarPlaySplashScreen", @"com.apple.FTMInternal", @"com.apple.appleseed.FeedbackAssistant", @"com.apple.FontInstallViewService", @"com.apple.BarcodeScanner", @"com.apple.icloud.spnfcurl", @"com.apple.ScreenTimeUnlock", @"com.apple.CarPlaySettings", @"com.apple.SharedWebCredentialViewService", @"com.apple.sidecar", @"com.apple.Spotlight", @"com.apple.iMessageAppsViewService", @"com.apple.AXUIViewService", @"com.apple.AccountAuthenticationDialog", @"com.apple.AdPlatformsDiagnostics", @"com.apple.CTCarrierSpaceAuth", @"com.apple.CheckerBoard", @"com.apple.CloudKit.ShareBear", @"com.apple.AskPermissionUI", @"com.apple.CompassCalibrationViewService", @"com.apple.sidecar.camera", @"com.apple.datadetectors.DDActionsService", @"com.apple.DataActivation", @"com.apple.DemoApp", @"com.apple.Diagnostics", @"com.apple.DiagnosticsService", @"com.apple.carkit.DNDBuddy", @"com.apple.family", @"com.apple.fieldtest", @"com.apple.gamecenter.GameCenterUIService", @"com.apple.HealthPrivacyService", @"com.apple.Home.HomeUIService", @"com.apple.InCallService", @"com.apple.MailCompositionService", @"com.apple.mobilesms.compose", @"com.apple.MobileReplayer", @"com.apple.MusicUIService", @"com.apple.PhotosViewService", @"com.apple.PreBoard", @"com.apple.PrintKit.Print-Center", @"com.apple.social.SLYahooAuth", @"com.apple.SafariViewService", @"org.coolstar.SafeMode", @"com.apple.ScreenshotServicesSharing", @"com.apple.ScreenshotServicesService", @"com.apple.ScreenSharingViewService", @"com.apple.SIMSetupUIService", @"com.apple.Magnifier", @"com.apple.purplebuddy", @"com.apple.SharedWebCredentialsViewService", @"com.apple.SharingViewService", @"com.apple.SiriViewService", @"com.apple.susuiservice", @"com.apple.StoreDemoViewService", @"com.apple.TVAccessViewService", @"com.apple.TVRemoteUIService", @"com.apple.TrustMe", @"com.apple.CoreAuthUI", @"com.apple.VSViewService", @"com.apple.PassbookStub", @"com.apple.PassbookUIService", @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI", @"com.apple.WebSheet", @"com.apple.iad.iAdOptOut", @"com.apple.ios.StoreKitUIService", @"com.apple.webapp", @"com.apple.webapp1", @"com.apple.springboard"];

	//iconTint = iconTintColorForCurrentApp();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("xyz.skitty.spectrum.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, getAppList, CFSTR("xyz.skitty.spectrum.getapps"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	refreshPrefs();

	NSArray *apps = disabledApps();

	if (enabled && ![apps containsObject:[[NSBundle mainBundle] bundleIdentifier]] && ![systemIdentifiers containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
		%init(App);
		if (global) {
			%init(UIColor);
		}
	}
}
