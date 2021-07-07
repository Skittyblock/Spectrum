// Spectrum, by Skitty (and Even)
// Customize system colors!

#import "Tweak.h"

#define BUNDLE_ID @"xyz.skitty.spectrum"

static NSMutableDictionary *settings;
static NSArray *systemIdentifiers;

static bool isDefault;
static NSDictionary *currentProfile;

static UIColor *tint;
static UIColor *highlight;

// Dark Colors
static UIColor *darkBarColor;

// Light Colors
static UIColor *lightBarColor;

static NSDictionary *defaults;

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

// Preferences
static bool getPrefBool(NSString *key) {
	return [([settings objectForKey:key] ?: defaults[key]) boolValue];
}
static NSString *getPrefString(NSString *key) {
	return [settings objectForKey:key] ?: defaults[key];
}
static UIColor *getPrefColor(NSString *key) {
	return colorFromHexString([settings objectForKey:key] ?: defaults[key]);
}
static void refreshPrefs() {
	defaults = @{
		@"enabled": @YES,
		@"hookSpringBoard": @YES,
		@"customTintColor": @YES,
		@"customDarkColors": @NO,
		@"customLightColors": @NO,
		@"tintColor": @"F22F6C",

		@"useBadgeColor": @NO,

		@"darkGroupTableViewBackgroundColor": @"000000",
		@"darkSeparatorColor": @"54545899",
		@"darkSystemBackgroundColor": @"000000",
		@"darkSystemGroupedBackgroundColor": @"000000",
		@"darkTableCellGroupedBackgroundColor": @"1C1C1E",
		@"darkSecondarySystemBackgroundColor": @"1C1C1E",
		@"darkSecondarySystemGroupedBackgroundColor": @"1C1C1E",
		@"darkTertiarySystemBackgroundColor": @"2C2C2E",
		@"darkTertiarySystemGroupedBackgroundColor": @"2C2C2E",
		@"darkLabelColor": @"FFFFFF",
		@"darkPlaceholderLabelColor": @"EBEBF54C",
		@"darkSecondaryLabelColor": @"EBEBF599",
		@"darkTertiaryLabelColor": @"EBEBF54C",
		@"darkTableViewCellSelectionColor": @"2C2C2E",
		@"darkBarColor": @"00000000",
		@"darkBadgeColor": @"FF0000",
		@"darkBadgeTextColor": @"FFFFFF",

		@"lightGroupTableViewBackgroundColor": @"F2F2F7",
		@"lightSeparatorColor": @"3C3C434C",
		@"lightSystemBackgroundColor": @"FFFFFF",
		@"lightSystemGroupedBackgroundColor": @"F2F2F7",
		@"lightTableCellGroupedBackgroundColor": @"FFFFFF",
		@"lightSecondarySystemBackgroundColor": @"F2F2F7",
		@"lightSecondarySystemGroupedBackgroundColor": @"FFFFFF",
		@"lightTertiarySystemBackgroundColor": @"FFFFFF",
		@"lightTertiarySystemGroupedBackgroundColor": @"F2F2F7",
		@"lightLabelColor": @"000000",
		@"lightPlaceholderLabelColor": @"3C3C434C",
		@"lightSecondaryLabelColor": @"3C3C4399",
		@"lightTertiaryLabelColor": @"3C3C434C",
		@"lightTableViewCellSelectionColor": @"E5E5EA",
		@"lightBarColor": @"00000000",
		@"lightBadgeColor": @"FF0000",
		@"lightBadgeTextColor": @"FFFFFF",
	};

	CFPreferencesSynchronize((CFStringRef)BUNDLE_ID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)BUNDLE_ID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)BUNDLE_ID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}
	if (!settings) {
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", BUNDLE_ID]];
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
	NSString *tintHex = (!getPrefBool(@"customTintColor") && currentProfile[@"tintColor"]) ? currentProfile[@"tintColor"] : ([settings objectForKey:@"tintColor"] ?: @"F22F6CFF");
	tint = colorFromHexString(tintHex);
	highlight = colorFromHexStringWithAlpha(tintHex, 0.3);

	if ([getPrefString(@"darkBarColor") isEqualToString:@"00000000"]) darkBarColor = nil;
	else darkBarColor = colorFromHexString([settings objectForKey:@"darkBarColor"]);

	if ([getPrefString(@"lightBarColor") isEqualToString:@"00000000"]) lightBarColor = nil;
	else lightBarColor = colorFromHexString([settings objectForKey:@"lightBarColor"]);
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

static UIColor *dynamicColorWithOptions(UIColor *orig, NSString *lightKey, NSString *darkKey) {
	UIColor *lightColor = orig ? [orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]] : [UIColor whiteColor];
	UIColor *darkColor = orig ? [orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]] : [UIColor blackColor];

	if (getPrefBool(@"customLightColors") || getPrefBool(@"customDarkColors")) {
		if (getPrefBool(@"customLightColors"))
			lightColor = getPrefColor(lightKey);
		if (getPrefBool(@"customDarkColors"))
			darkColor = getPrefColor(darkKey);
	}
	if (getPrefBool(@"hookSpringBoard") && ([lightKey isEqualToString:@"lightBadgeColor"] || [lightKey isEqualToString:@"lightBadgeTextColor"])) {
		lightColor = getPrefColor(lightKey);
	}
	if (getPrefBool(@"hookSpringBoard") && ([darkKey isEqualToString:@"darkBadgeColor"] || [darkKey isEqualToString:@"darkBadgeTextColor"])) {
		darkColor = getPrefColor(darkKey);
	}
	if (currentProfile && (currentProfile[lightKey] || currentProfile[darkKey])) {
		if (currentProfile[lightKey])
			lightColor = colorFromHexString(currentProfile[lightKey]);
		if (currentProfile[darkKey])
			darkColor = colorFromHexString(currentProfile[darkKey]);
	}

	return dynamicColor(lightColor, darkColor);
}

// UIColor Hooks
%group UIColor

// Override apps that try to fake it
%hook UIColor
+ (id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {
	if (red == 0.0 && green == 122.0/255.0 && blue == 1.0) {
		return (getPrefBool(@"customTintColor") || currentProfile[@"tintColor"]) ? tint : %orig;
	}
	return %orig;
}
// Default tint
+ (id)systemBlueColor {
	return (getPrefBool(@"customTintColor") || currentProfile[@"tintColor"]) ? tint : %orig;
}
+ (id)_systemBlueColor2 {
	return (getPrefBool(@"customTintColor") || currentProfile[@"tintColor"]) ? tint : %orig;
}
// Selection point
+ (id)insertionPointColor {
	return (getPrefBool(@"customTintColor") || currentProfile[@"tintColor"]) ? tint : %orig;
}
// Selection highlight
+ (id)selectionHighlightColor {
	return (getPrefBool(@"customTintColor") || currentProfile[@"tintColor"]) ? highlight : %orig;
}
// Selection grabbers
+ (id)selectionGrabberColor {
	return (getPrefBool(@"customTintColor") || currentProfile[@"tintColor"]) ? tint : %orig;
}
// Links
+ (id)linkColor {
	return (getPrefBool(@"customTintColor") || currentProfile[@"tintColor"]) ? tint : %orig;
}

// Primary color
+ (id)systemBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSystemBackgroundColor", @"darkSystemBackgroundColor");
}
+ (id)systemGroupedBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSystemGroupedBackgroundColor", @"darkSystemGroupedBackgroundColor");
}
+ (id)groupTableViewBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightGroupTableViewBackgroundColor", @"darkGroupTableViewBackgroundColor");
}
+ (id)tableBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightGroupTableViewBackgroundColor", @"darkGroupTableViewBackgroundColor");
}
+ (id)tableCellPlainBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSystemBackgroundColor", @"darkSystemBackgroundColor");
}
+ (id)tableCellGroupedBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightTableCellGroupedBackgroundColor", @"darkTableCellGroupedBackgroundColor");
}

// Secondary color
+ (id)secondarySystemBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSecondarySystemBackgroundColor", @"darkSecondarySystemBackgroundColor");
}
+ (id)secondarySystemGroupedBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightSecondarySystemGroupedBackgroundColor", @"darkSecondarySystemGroupedBackgroundColor");
}

// Tertiary color
+ (id)tertiarySystemBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightTertiarySystemBackgroundColor", @"darkTertiarySystemBackgroundColor");
}
+ (id)tertiarySystemGroupedBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightTertiarySystemGroupedBackgroundColor", @"darkTertiarySystemGroupedBackgroundColor");
}

// Separator color
+ (id)separatorColor {
	return dynamicColorWithOptions(%orig, @"lightSeparatorColor", @"darkSeparatorColor");
}
+ (id)opaqueSeparatorColor {
	return dynamicColorWithOptions(%orig, @"lightSeparatorColor", @"darkSeparatorColor");
}
+ (id)tableSeparatorColor {
	return dynamicColorWithOptions(%orig, @"lightSeparatorColor", @"darkSeparatorColor");
}

// Label colors
+ (id)labelColor {
	return dynamicColorWithOptions(%orig, @"lightLabelColor", @"darkLabelColor");
}
+ (id)secondaryLabelColor {
	return dynamicColorWithOptions(%orig, @"lightSecondaryLabelColor", @"darkSecondaryLabelColor");
}
+ (id)placeholderLabelColor {
	return dynamicColorWithOptions(%orig, @"lightPlaceholderLabelColor", @"darkPlaceholderLabelColor");
}
+ (id)tertiaryLabelColor {
	return dynamicColorWithOptions(%orig, @"lightTertiaryLabelColor", @"darkTertiaryLabelColor");
}

+ (id)tablePlainHeaderFooterBackgroundColor {
	return dynamicColorWithOptions(%orig, @"lightTertiaryLabelColor", @"darkTertiaryLabelColor");
}

// UITableViewCell selection color
+ (id)systemGray4Color {
	return dynamicColorWithOptions(%orig, @"lightTableViewCellSelectionColor", @"darkTableViewCellSelectionColor");
}
+ (id)systemGray5Color {
	return dynamicColorWithOptions(%orig, @"lightTableViewCellSelectionColor", @"darkTableViewCellSelectionColor");
}

%end

%end

// App Hooks
%group App

%hook UINavigationBar
%property (nonatomic, retain) UIColor *storedBarColor;
-(void)didMoveToSuperview {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((currentProfile[@"lightBarColor"] || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((currentProfile[@"darkBarColor"] || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((currentProfile[@"lightBarColor"] || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((currentProfile[@"darkBarColor"] || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"lightBarColor", @"darkBarColor"));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}
%end

%hook UIToolbar
%property (nonatomic, retain) UIColor *storedBarColor;
-(void)didMoveToSuperview {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((currentProfile[@"lightBarColor"] || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((currentProfile[@"darkBarColor"] || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((currentProfile[@"lightBarColor"] || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((currentProfile[@"darkBarColor"] || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"lightBarColor", @"darkBarColor"));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}
%end

%hook UITabBar
%property (nonatomic, retain) UIColor *storedBarColor;
-(void)didMoveToSuperview {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((currentProfile[@"lightBarColor"] || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((currentProfile[@"darkBarColor"] || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((currentProfile[@"lightBarColor"] || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((currentProfile[@"darkBarColor"] || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"lightBarColor", @"darkBarColor"));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}
%end

%hook UIView
- (UIColor *)tintColor {
	if (![self isKindOfClass:%c(UIWindow)] && [self _normalInheritedTintColor] == appTintColorFromWindow([self window])) {
		return (getPrefBool(@"customTintColor") || currentProfile[@"tintColor"]) ? tint : %orig;
	}
	return %orig;
}
%end

%end

// SpringBoard Hooks
%group SpringBoard

// Badge color
%hook SBIconBadgeView

- (void)configureForIcon:(id)arg1 infoProvider:(SBIconView *)arg2 {
	%orig;
	[self updateColor];
}

- (void)drawRect:(CGRect)arg1 {
	%orig;
	[self updateColor];
}

%new
- (void)updateColor {
	UIImageView *textView = [self valueForKey:@"_textView"];
	UIImageView *backgroundView = [self valueForKey:@"_backgroundView"];

	if (getPrefBool(@"useBadgeColor")) {
		textView.image = [textView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[textView setTintColor:dynamicColorWithOptions(nil, @"lightBadgeTextColor", @"darkBadgeTextColor")];

		backgroundView.image = [backgroundView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[backgroundView setTintColor:dynamicColorWithOptions(nil, @"lightBadgeColor", @"darkBadgeColor")];
	} else {
		textView.image = [textView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		backgroundView.image = [backgroundView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	}
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

	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)[BUNDLE_ID stringByAppendingString:@".setapps"], nil, (__bridge CFDictionaryRef)mutableDict, true);
}

static NSArray *disabledApps() {
	NSArray *apps = @[];
	NSString *prefPath = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.apps.plist", BUNDLE_ID];
	if ([[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
		NSDictionary *appPrefs = [NSDictionary dictionaryWithContentsOfFile:prefPath];
		apps = appPrefs[@"Disabled"];
	}

	return apps;
}

%ctor {
	// Hidden system apps
	systemIdentifiers = @[@"com.apple.AppSSOUIService", @"com.apple.AuthKitUIService", @"com.apple.BusinessChatViewService", @"com.apple.CTNotifyUIService", @"com.apple.ctkui", @"com.apple.ClipViewService", @"com.apple.CredentialSharingService", @"com.apple.CarPlaySplashScreen", @"com.apple.HealthENLauncher", @"com.apple.HealthENBuddy", @"com.apple.PublicHealthRemoteUI", @"com.apple.FTMInternal", @"com.apple.appleseed.FeedbackAssistant", @"com.apple.FontInstallViewService", @"com.apple.BarcodeScanner", @"com.apple.icloud.spnfcurl", @"com.apple.ScreenTimeUnlock", @"com.apple.CarPlaySettings", @"com.apple.SharedWebCredentialViewService", @"com.apple.sidecar", @"com.apple.Spotlight", @"com.apple.iMessageAppsViewService", @"com.apple.AXUIViewService", @"com.apple.AccountAuthenticationDialog", @"com.apple.AdPlatformsDiagnostics", @"com.apple.CTCarrierSpaceAuth", @"com.apple.CheckerBoard", @"com.apple.CloudKit.ShareBear", @"com.apple.AskPermissionUI", @"com.apple.CompassCalibrationViewService", @"com.apple.sidecar.camera", @"com.apple.datadetectors.DDActionsService", @"com.apple.DataActivation", @"com.apple.DemoApp", @"com.apple.Diagnostics", @"com.apple.DiagnosticsService", @"com.apple.carkit.DNDBuddy", @"com.apple.family", @"com.apple.fieldtest", @"com.apple.gamecenter.GameCenterUIService", @"com.apple.HealthPrivacyService", @"com.apple.Home.HomeUIService", @"com.apple.InCallService", @"com.apple.MailCompositionService", @"com.apple.mobilesms.compose", @"com.apple.MobileReplayer", @"com.apple.MusicUIService", @"com.apple.PhotosViewService", @"com.apple.PreBoard", @"com.apple.PrintKit.Print-Center", @"com.apple.social.SLYahooAuth", @"com.apple.SafariViewService", @"org.coolstar.SafeMode", @"com.apple.ScreenshotServicesSharing", @"com.apple.ScreenshotServicesService", @"com.apple.ScreenSharingViewService", @"com.apple.SIMSetupUIService", @"com.apple.Magnifier", @"com.apple.purplebuddy", @"com.apple.SharedWebCredentialsViewService", @"com.apple.SharingViewService", @"com.apple.SiriViewService", @"com.apple.susuiservice", @"com.apple.StoreDemoViewService", @"com.apple.TVAccessViewService", @"com.apple.TVRemoteUIService", @"com.apple.TrustMe", @"com.apple.CoreAuthUI", @"com.apple.VSViewService", @"com.apple.PassbookStub", @"com.apple.PassbookUIService", @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI", @"com.apple.WebSheet", @"com.apple.iad.iAdOptOut", @"com.apple.ios.StoreKitUIService", @"com.apple.webapp", @"com.apple.webapp1", @"com.apple.springboard", @"com.apple.PassbookSecureUIService", @"com.apple.Photos.PhotosUIService", @"com.apple.RemoteiCloudQuotaUI", @"com.apple.shortcuts.runtime", @"com.apple.SleepLockScreen", @"com.apple.SubcredentialUIService", @"com.apple.dt.XcodePreviews", @"com.apple.icq"];

	//iconTint = iconTintColorForCurrentApp();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[BUNDLE_ID stringByAppendingString:@".prefschanged"], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, getAppList, (CFStringRef)[BUNDLE_ID stringByAppendingString:@".getapps"], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	refreshPrefs();

	NSArray *apps = disabledApps();

	if (getPrefBool(@"enabled") && ((![apps containsObject:[[NSBundle mainBundle] bundleIdentifier]] && ![systemIdentifiers containsObject:[[NSBundle mainBundle] bundleIdentifier]]) || (getPrefBool(@"hookSpringBoard") && [[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]))) {
		%init(App);
		%init(UIColor);
	}
	if (getPrefBool(@"enabled") && getPrefBool(@"hookSpringBoard") && [[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
		%init(SpringBoard)
	}
}
