// Spectrum, by Skitty (and Even)
// Customize system colors!

#import "Tweak.h"
#import "NSString+Spectrum.h"
#import <rootless.h>

#define BUNDLE_ID @"xyz.skitty.spectrum"

static NSArray *systemIdentifiers;
static NSMutableDictionary *settings;
static NSDictionary *generals;

static BOOL isDefault;
static NSDictionary *currentProfile;

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
	if (!hexString) return nil;
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
BOOL getPrefBool(NSString *key) {
	return [([settings objectForKey:key] ?: defaults[key]) boolValue];
}
static NSString *getPrefString(NSString *key) {
	return [settings objectForKey:key] ?: defaults[key];
}
static UIColor *getPrefColor(NSString *key) {
	return colorFromHexString([settings objectForKey:key] ?: defaults[key]);
}
static UIColor *getProfileColor(NSString *mode, NSString *key) {
	if (!currentProfile) return nil;

	NSDictionary *colors = [currentProfile objectForKey:key];
	if (colors && colors[mode]) return colorFromHexString(colors[mode]);

	return nil;
}
static void refreshPrefs() {
	defaults = @{
		@"enabled": @YES,
		@"hookSpringBoard": @YES,
		@"customTintColor": @YES,
		@"customDarkColors": @NO,
		@"customLightColors": @NO,
		@"tintColor": @"F22F6C",

		@"useBarColor": @NO,
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
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/%@.plist"), BUNDLE_ID]];
	}

	// Profile
	NSString *path = ROOT_PATH_NS(@"/Library/Spectrum");
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
	NSMutableArray *plistFiles = [[NSMutableArray alloc] init];
	NSMutableArray *plistNames = [[NSMutableArray alloc] init];

	[files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *filename = (NSString *)obj;
		NSString *extension = [[filename pathExtension] lowercaseString];
		if ([extension isEqualToString:@"plist"]) {
			NSDictionary *contents = [[NSDictionary alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:filename]];
			if (contents[@"name"] && ![contents[@"name"] isEqualToString:@"Default"]) {
				[plistFiles addObject:contents];
				[plistNames addObject:contents[@"name"]];
			}
		}
	}];

	NSInteger index = [plistNames indexOfObject:[NSString stringWithFormat:@"%@", [settings objectForKey:@"profile"]]];
	if (index == NSNotFound) index = -1;
	
	if (index < 0) isDefault = YES;
	else currentProfile = plistFiles[index];

	// Settings
	useTint = getPrefBool(@"customTintColor") || currentProfile[@"tintColor"];
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

UIColor *dynamicColorWithOptions(UIColor *orig, NSString *key) {
	NSString *lightKey = [@"light" stringByAppendingString:[key capitalizeFirstLetter]];
	NSString *darkKey = [@"dark" stringByAppendingString:[key capitalizeFirstLetter]];
	UIColor *lightColor = orig ? [orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]] : [UIColor whiteColor];
	UIColor *darkColor = orig ? [orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]] : [UIColor blackColor];

	if (getPrefBool(@"customLightColors") || getPrefBool(@"customDarkColors")) {
		if (getPrefBool(@"customLightColors") && getPrefColor(lightKey))
			lightColor = getPrefColor(lightKey);
		if (getPrefBool(@"customDarkColors") && getPrefColor(darkKey))
			darkColor = getPrefColor(darkKey);
	}
	if (getPrefBool(@"hookSpringBoard") && ([lightKey isEqualToString:@"lightBadgeColor"] || [lightKey isEqualToString:@"lightBadgeTextColor"])) {
		lightColor = getPrefColor(lightKey);
	}
	if (getPrefBool(@"hookSpringBoard") && ([darkKey isEqualToString:@"darkBadgeColor"] || [darkKey isEqualToString:@"darkBadgeTextColor"])) {
		darkColor = getPrefColor(darkKey);
	}
	if (currentProfile && currentProfile[key]) {
		if (getProfileColor(@"light", key))
			lightColor = getProfileColor(@"light", key);
		if (getProfileColor(@"dark", key))
			darkColor = getProfileColor(@"dark", key);
	}

	return dynamicColor(lightColor, darkColor);
}

UIColor *staticColor(NSString *mode, NSString *key) {
	NSString *prefKey = [mode stringByAppendingString:[key capitalizeFirstLetter]];

	UIColor *color = nil;

	if ((getPrefBool(@"customLightColors") && [mode isEqualToString:@"light"]) || (getPrefBool(@"customDarkColors") && [mode isEqualToString:@"dark"])) {
		color = getPrefColor(prefKey);
	} else if (currentProfile && getProfileColor(mode, key)) {
		color = getProfileColor(mode, key);
	}

	return color;
}

// UIColor Hooks
%group UIColor

%hook UIDynamicSystemColor

- (id)initWithName:(NSString *)name colorsByThemeKey:(NSDictionary *)colors {
	// Generalize some colors for the custom color selection, not color profiles
	if (!generals) {
		generals = @{
			@"tableBackgroundColor": @"groupTableViewBackgroundColor",
			@"tableCellPlainBackgroundColor": @"systemBackgroundColor",
			@"opaqueSeparatorColor": @"separatorColor",
			@"tableSeparatorColor": @"separatorColor",
			@"tablePlainHeaderFooterBackgroundColor": @"tertiaryLabelColor",
			@"systemGray4Color": @"tableViewCellSelectionColor",
			@"systemGray5Color": @"tableViewCellSelectionColor"
		};
	}

	NSString *keyName = name;
	if (generals[name]) keyName = generals[name];

	NSString *lightKey = [@"light" stringByAppendingString:[keyName capitalizeFirstLetter]];
	NSString *darkKey = [@"dark" stringByAppendingString:[keyName capitalizeFirstLetter]];

	BOOL overridesLight = getPrefBool(@"customLightColors") && getPrefColor(lightKey);
	BOOL overridesDark = getPrefBool(@"customDarkColors") && getPrefColor(darkKey);
	BOOL customColorOverride = overridesLight || overridesDark;
	BOOL profileOverride = currentProfile && currentProfile[name];

	if (customColorOverride || profileOverride) {
		NSMutableDictionary *newColors = [colors mutableCopy];

		if (overridesLight) [newColors setObject:getPrefColor(lightKey) forKey:@0];
		else if (getProfileColor(@"light", name)) [newColors setObject:getProfileColor(@"light", name) forKey:@0];

		if (overridesDark) [newColors setObject:getPrefColor(darkKey) forKey:@2];
		else if (getProfileColor(@"dark", name)) [newColors setObject:getProfileColor(@"dark", name) forKey:@2];

		return %orig(name, newColors);
	}

	return %orig;
}

%end

// These can also be set with the previous hook, but I've simplified some of the keys for people making custom profiles
// e.g. just do tintColor instead of systemBlueColor, _systemBlueColor2, etc.
%hook UIColor

// Override apps that try to fake it
+ (id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {
	if (red == 0.0 && green == 122.0/255.0 && blue == 1.0) {
		return useTint ? tint : %orig;
	}
	return %orig;
}

+ (id)systemBlueColor {
	return useTint ? tint : %orig;
}

+ (id)_systemBlueColor2 {
	return useTint ? tint : %orig;
}

// Selection point
+ (id)insertionPointColor {
	return useTint ? tint : %orig;
}

// Selection highlight
+ (id)selectionHighlightColor {
	return useTint ? highlight : %orig;
}

// Selection grabbers
+ (id)selectionGrabberColor {
	return useTint ? tint : %orig;
}

// Links
+ (id)linkColor {
	return useTint ? tint : %orig;
}

%end

%end

// App Hooks
%group App

%hook UINavigationBar
%property (nonatomic, retain) UIColor *storedBarColor;

- (void)didMoveToSuperview {
	%orig;
	[self updateSpectrumColors];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	[self updateSpectrumColors];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"barColor"));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}

%new
- (void)updateSpectrumColors {
	if (!(getPrefBool(@"useBarColor") || currentProfile[@"barColor"])) return;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((getProfileColor(@"light", @"barColor") || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((getProfileColor(@"dark", @"barColor") || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

%end

%hook UIToolbar
%property (nonatomic, retain) UIColor *storedBarColor;

- (void)didMoveToSuperview {
	%orig;
	[self updateSpectrumColors];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	[self updateSpectrumColors];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"barColor"));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}

%new
- (void)updateSpectrumColors {
	if (!(getPrefBool(@"useBarColor") || currentProfile[@"barColor"])) return;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((getProfileColor(@"light", @"barColor") || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((getProfileColor(@"dark", @"barColor") || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

%end

%hook UITabBar
%property (nonatomic, retain) UIColor *storedBarColor;

- (void)didMoveToSuperview {
	%orig;
	[self updateSpectrumColors];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;
	[self updateSpectrumColors];
}

- (void)setBarTintColor:(UIColor *)color {
	if ([color isEqual:[UIColor cyanColor]]) return %orig(dynamicColorWithOptions(dynamicColor([UIColor clearColor], [UIColor clearColor]), @"barColor"));
	if ([color isEqual:[UIColor magentaColor]]) return %orig(nil);
	if (color) self.storedBarColor = color;
	%orig(color);
}

%new
- (void)updateSpectrumColors {
	if (!(getPrefBool(@"useBarColor") || currentProfile[@"barColor"])) return;
	UIUserInterfaceStyle currentStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
	if (((getProfileColor(@"light", @"barColor") || lightBarColor) && currentStyle == UIUserInterfaceStyleLight) || ((getProfileColor(@"dark", @"barColor") || darkBarColor) && currentStyle == UIUserInterfaceStyleDark))
		[self setBarTintColor:self.storedBarColor ?: [UIColor cyanColor]];
	else
		[self setBarTintColor:self.storedBarColor ?: [UIColor magentaColor]];
}

%end

%hook UIView

- (UIColor *)tintColor {
	if (![self isKindOfClass:%c(UIWindow)] && [self _normalInheritedTintColor] == appTintColorFromWindow([self window])) {
		return useTint ? tint : %orig;
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
		[textView setTintColor:dynamicColorWithOptions(nil, @"badgeTextColor")];

		backgroundView.image = [backgroundView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[backgroundView setTintColor:dynamicColorWithOptions(nil, @"badgeColor")];
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
	return @[topColor, bottomColor];
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
			if ([app.bundleIdentifier isEqual:id]) add = NO;
		}
		if (add) [mutableDict setObject:name forKey:app.bundleIdentifier];
	}

	return mutableDict;
}

static void getAppList(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) return;

	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)[BUNDLE_ID stringByAppendingString:@".setapps"], nil, (__bridge CFDictionaryRef)appList(), true);
}

static NSArray *disabledApps() {
	NSArray *apps = @[];
	NSString *prefPath = [NSString stringWithFormat:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/%@.apps.plist"), BUNDLE_ID];
	if ([[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
		NSDictionary *appPrefs = [NSDictionary dictionaryWithContentsOfFile:prefPath];
		apps = appPrefs[@"Enabled"];
	}

	return apps;
}

%ctor {
	// Hidden system apps
	systemIdentifiers = @[@"com.apple.AppSSOUIService", @"com.apple.AuthKitUIService", @"com.apple.BusinessChatViewService", @"com.apple.CTNotifyUIService", @"com.apple.ctkui", @"com.apple.ClipViewService", @"com.apple.CredentialSharingService", @"com.apple.CarPlaySplashScreen", @"com.apple.HealthENLauncher", @"com.apple.HealthENBuddy", @"com.apple.PublicHealthRemoteUI", @"com.apple.FTMInternal", @"com.apple.appleseed.FeedbackAssistant", @"com.apple.FontInstallViewService", @"com.apple.BarcodeScanner", @"com.apple.icloud.spnfcurl", @"com.apple.ScreenTimeUnlock", @"com.apple.CarPlaySettings", @"com.apple.SharedWebCredentialViewService", @"com.apple.sidecar", @"com.apple.Spotlight", @"com.apple.iMessageAppsViewService", @"com.apple.AXUIViewService", @"com.apple.AccountAuthenticationDialog", @"com.apple.AdPlatformsDiagnostics", @"com.apple.CTCarrierSpaceAuth", @"com.apple.CheckerBoard", @"com.apple.CloudKit.ShareBear", @"com.apple.AskPermissionUI", @"com.apple.CompassCalibrationViewService", @"com.apple.sidecar.camera", @"com.apple.datadetectors.DDActionsService", @"com.apple.DataActivation", @"com.apple.DemoApp", @"com.apple.Diagnostics", @"com.apple.DiagnosticsService", @"com.apple.carkit.DNDBuddy", @"com.apple.family", @"com.apple.fieldtest", @"com.apple.gamecenter.GameCenterUIService", @"com.apple.HealthPrivacyService", @"com.apple.Home.HomeUIService", @"com.apple.InCallService", @"com.apple.MailCompositionService", @"com.apple.mobilesms.compose", @"com.apple.MobileReplayer", @"com.apple.MusicUIService", @"com.apple.PhotosViewService", @"com.apple.PreBoard", @"com.apple.PrintKit.Print-Center", @"com.apple.social.SLYahooAuth", @"com.apple.SafariViewService", @"org.coolstar.SafeMode", @"com.apple.ScreenshotServicesSharing", @"com.apple.ScreenshotServicesService", @"com.apple.ScreenSharingViewService", @"com.apple.SIMSetupUIService", @"com.apple.Magnifier", @"com.apple.purplebuddy", @"com.apple.SharedWebCredentialsViewService", @"com.apple.SharingViewService", @"com.apple.SiriViewService", @"com.apple.susuiservice", @"com.apple.StoreDemoViewService", @"com.apple.TVAccessViewService", @"com.apple.TVRemoteUIService", @"com.apple.TrustMe", @"com.apple.CoreAuthUI", @"com.apple.VSViewService", @"com.apple.PassbookStub", @"com.apple.PassbookUIService", @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI", @"com.apple.WebSheet", @"com.apple.iad.iAdOptOut", @"com.apple.ios.StoreKitUIService", @"com.apple.webapp", @"com.apple.webapp1", @"com.apple.springboard", @"com.apple.PassbookSecureUIService", @"com.apple.Photos.PhotosUIService", @"com.apple.RemoteiCloudQuotaUI", @"com.apple.shortcuts.runtime", @"com.apple.SleepLockScreen", @"com.apple.SubcredentialUIService", @"com.apple.dt.XcodePreviews", @"com.apple.icq"];

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[BUNDLE_ID stringByAppendingString:@".prefschanged"], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, getAppList, (CFStringRef)[BUNDLE_ID stringByAppendingString:@".getapps"], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	refreshPrefs();

	NSArray *blacklistedApps = disabledApps();

	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	BOOL isBlacklisted = [blacklistedApps containsObject:bundleIdentifier] || [systemIdentifiers containsObject:bundleIdentifier];
	BOOL isSpringBoard = getPrefBool(@"hookSpringBoard") && [bundleIdentifier isEqual:@"com.apple.springboard"];
	BOOL isTwitter = [bundleIdentifier isEqual:@"com.atebits.Tweetie2"];

	if (getPrefBool(@"enabled") && !isTwitter && (!isBlacklisted || isSpringBoard)) {
		%init(App);
		%init(UIColor);
	}
	if (getPrefBool(@"enabled") && isSpringBoard) {
		%init(SpringBoard)
	}
}
