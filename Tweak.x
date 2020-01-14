// Spectrum, by Skitty (and Even)
// Customize system colors!

#import "Tweak.h"

static NSMutableDictionary *settings;
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
static UIColor *darkOpaqueSeparatorColor;
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
static UIColor *lightOpaqueSeparatorColor;
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

// Color from hex function
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
	if(keyList) {
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

	NSString  *tintHex = [settings objectForKey:@"tintColor"] ?: @"F22F6C";
	tint = customTintColor ? colorFromHexStringWithAlpha(tintHex, 1.0) : colorFromHexStringWithAlpha([settings objectForKey:@"tintColor"] ?: @"FF0000", 1.0);
	highlight = colorFromHexStringWithAlpha(tintHex, 0.2);

	darkGroupTableViewBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkGroupTableViewBackgroundColor"] ?: @"000000", 1.0);
	darkOpaqueSeparatorColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkOpaqueSeparatorColor"] ?: @"38383A", 1.0);
	darkSeparatorColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkSeparatorColor"] ?: @"545458", 0.6);
	darkSystemBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkSystemBackgroundColor"] ?: @"000000", 1.0);
	darkSystemGroupedBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkSystemGroupedBackgroundColor"] ?: @"000000", 1.0);
	darkTableCellGroupedBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkTableCellGroupedBackgroundColor"] ?: @"1C1C1E", 1.0);
	darkSecondarySystemBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkSecondarySystemBackgroundColor"] ?: @"1C1C1E", 1.0);
	darkSecondarySystemGroupedBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkSecondarySystemGroupedBackgroundColor"] ?: @"1C1C1E", 1.0);
	darkTertiarySystemBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkTertiarySystemBackgroundColor"] ?: @"2C2C2E", 1.0);
	darkTertiarySystemGroupedBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkTertiarySystemGroupedBackgroundColor"] ?: @"2C2C2E", 1.0);
	darkLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkLabelColor"] ?: @"FFFFFF", 1.0);
	darkPlaceholderLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkPlaceholderLabelColor"] ?: @"EBEBF5", 0.3);
	darkSecondaryLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkSecondaryLabelColor"] ?: @"EBEBF5", 0.6);
	darkTertiaryLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkTertiaryLabelColor"] ?: @"EBEBF5", 0.3);

	lightGroupTableViewBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightGroupTableViewBackgroundColor"] ?: @"F2F2F7", 1.0);
	lightOpaqueSeparatorColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightOpaqueSeparatorColor"] ?: @"C6C6C8", 1.0);
	lightSeparatorColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightSeparatorColor"] ?: @"3C3C43", 0.29);
	lightSystemBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightSystemBackgroundColor"] ?: @"FFFFFF", 1.0);
	lightSystemGroupedBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightSystemGroupedBackgroundColor"] ?: @"F2F2F7", 1.0);
	lightTableCellGroupedBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightTableCellGroupedBackgroundColor"] ?: @"FFFFFF", 1.0);
	lightSecondarySystemBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightSecondarySystemBackgroundColor"] ?: @"F2F2F7", 1.0);
	lightSecondarySystemGroupedBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightSecondarySystemGroupedBackgroundColor"] ?: @"FFFFFF", 1.0);
	lightTertiarySystemBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightTertiarySystemBackgroundColor"] ?: @"FFFFFF", 1.0);
	lightTertiarySystemGroupedBackgroundColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightTertiarySystemGroupedBackgroundColor"] ?: @"F2F2F7", 1.0);
	lightLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightLabelColor"] ?: @"000000", 1.0);
	lightPlaceholderLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightPlaceholderLabelColor"] ?: @"3C3C43", 0.3);
	lightSecondaryLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightSecondaryLabelColor"] ?: @"3C3C43", 0.6);
	lightTertiaryLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"lightTertiaryLabelColor"] ?: @"3C3C43", 0.3);
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
			lightColor = colorFromHexStringWithAlpha(currentProfile[lightKey], 1.0);
		if (currentProfile[darkKey])
			darkColor = colorFromHexStringWithAlpha(currentProfile[darkKey], 1.0);
	}

	return dynamicColor(lightColor, darkColor);
}

// Global Tint Color
%group UIColor

// Override apps that try to fake it
%hook UIColor
+ (id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {
	if (red == 0.0 && green == 122.0/255.0 && blue == 1.0) {
		return tint;
	}
	return %orig;
}
// Default tint
+ (id)systemBlueColor {
	return tint;
}
// Selection point
+ (id)insertionPointColor {
	return tint;
}
// Selection highlight
+ (id)selectionHighlightColor {
	return highlight;
}
// Selection grabbers
+ (id)selectionGrabberColor {
	return tint;
}
// Links
+ (id)linkColor {
	return tint;
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
	return dynamicColorWithOptions(%orig, @"lightOpaqueSeparatorColor", @"darkOpaqueSeparatorColor", lightOpaqueSeparatorColor, darkOpaqueSeparatorColor);
}
+ (id)tableSeparatorColor {
	return dynamicColorWithOptions(%orig, @"lightSeparatorColor", @"darkSeparatorColor", lightSeparatorColor, darkSeparatorColor);
}

// UITableViewCell selection color
/*+ (id)systemGray5Color {
	return [[UIColor blackColor] colorWithAlphaComponent:0.2];
}*/

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
		return tint;
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

static void getAppList(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
		return;
	}
	//NSLog(@"[SPEC] getAppList2");

	// Ignore hidden system apps
	NSArray *ids = @[@"com.apple.AppSSOUIService", @"com.apple.AuthKitUIService", @"com.apple.BusinessChatViewService", @"com.apple.CTNotifyUIService", @"com.apple.CarPlaySplashScreen", @"com.apple.FTMInternal", @"com.apple.appleseed.FeedbackAssistant", @"com.apple.FontInstallViewService", @"com.apple.BarcodeScanner", @"com.apple.icloud.spnfcurl", @"com.apple.ScreenTimeUnlock", @"com.apple.CarPlaySettings", @"com.apple.SharedWebCredentialViewService", @"com.apple.sidecar", @"com.apple.Spotlight", @"com.apple.iMessageAppsViewService", @"com.apple.AXUIViewService", @"com.apple.AccountAuthenticationDialog", @"com.apple.AdPlatformsDiagnostics", @"com.apple.CTCarrierSpaceAuth", @"com.apple.CheckerBoard", @"com.apple.CloudKit.ShareBear", @"com.apple.AskPermissionUI", @"com.apple.CompassCalibrationViewService", @"com.apple.sidecar.camera", @"com.apple.datadetectors.DDActionsService", @"com.apple.DataActivation", @"com.apple.DemoApp", @"com.apple.Diagnostics", @"com.apple.DiagnosticsService", @"com.apple.carkit.DNDBuddy", @"com.apple.family", @"com.apple.fieldtest", @"com.apple.gamecenter.GameCenterUIService", @"com.apple.HealthPrivacyService", @"com.apple.Home.HomeUIService", @"com.apple.InCallService", @"com.apple.MailCompositionService", @"com.apple.mobilesms.compose", @"com.apple.MobileReplayer", @"com.apple.MusicUIService", @"com.apple.PhotosViewService", @"com.apple.PreBoard", @"com.apple.PrintKit.Print-Center", @"com.apple.social.SLYahooAuth", @"com.apple.SafariViewService", @"org.coolstar.SafeMode", @"com.apple.ScreenshotServicesSharing", @"com.apple.ScreenshotServicesService", @"com.apple.ScreenSharingViewService", @"com.apple.SIMSetupUIService", @"com.apple.Magnifier", @"com.apple.purplebuddy", @"com.apple.SharedWebCredentialsViewService", @"com.apple.SharingViewService", @"com.apple.SiriViewService", @"com.apple.susuiservice", @"com.apple.StoreDemoViewService", @"com.apple.TVAccessViewService", @"com.apple.TVRemoteUIService", @"com.apple.TrustMe", @"com.apple.CoreAuthUI", @"com.apple.VSViewService", @"com.apple.PassbookStub", @"com.apple.PassbookUIService", @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI", @"com.apple.WebSheet", @"com.apple.iad.iAdOptOut", @"com.apple.ios.StoreKitUIService", @"com.apple.webapp", @"com.apple.webapp1"];

	NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
	for (SBApplication *app in [[NSClassFromString(@"SBApplicationController") sharedInstance] allApplications]) {
		bool add = YES;
		NSString *name = app.displayName ?: @"Error";
		for (NSString *id in ids) {
			if ([app.bundleIdentifier isEqual:id]) {
				add = NO;
			}
		}
		if (add) {
			[mutableDict setObject:name forKey:app.bundleIdentifier];
		}
	}

	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.skitty.spectrum.setapps"), nil, (__bridge CFDictionaryRef)mutableDict, true);
}

%ctor {
	//iconTint = iconTintColorForCurrentApp();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("xyz.skitty.spectrum.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, getAppList, CFSTR("xyz.skitty.spectrum.getapps"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	refreshPrefs();

	if (enabled) {
		%init(App);
		if (global) {
			%init(UIColor);
		}
	}
}
