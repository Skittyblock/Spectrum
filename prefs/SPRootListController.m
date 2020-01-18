// SPRootListController.m

#import "SPRootListController.h"

@interface FBSSystemService : NSObject
+ (instancetype)sharedService;
- (void)sendActions:(NSSet *)arg1 withResult:(id)arg2 ;
@end

typedef enum {
	None = 0,
	SBSRelaunchOptionsRestartRenderServer = (1 << 0),
	SBSRelaunchOptionsSnapshot = (1 << 1),
	SBSRelaunchOptionsFadeToBlack = (1 << 2),
} SBSRelaunchOptions;

@interface SBSRelaunchAction : NSObject
+ (SBSRelaunchAction *)actionWithReason:(NSString *)reason options:(SBSRelaunchOptions)options targetURL:(NSURL *)url;
@end

@interface SBSRestartRenderServerAction : NSObject
+ (instancetype)restartActionWithTargetRelaunchURL:(NSURL *)targetURL;
@property(readonly, nonatomic) NSURL *targetURL;
@end

@implementation SPRootListController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.view.tintColor = kTintColor;
	[UIApplication sharedApplication].keyWindow.tintColor = kTintColor;
	[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = kTintColor;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[UIApplication sharedApplication].keyWindow.tintColor = nil;
}

- (void)resetSettings {
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("xyz.skitty.spectrum"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		CFPreferencesSetMultiple(nil, keyList, CFSTR("xyz.skitty.spectrum"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		CFRelease(keyList);
	}
	[[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/xyz.skitty.spectrum.plist" error:nil];

	[self respring];
}

- (void)respring {
    SBSRelaunchAction *restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:SBSRelaunchOptionsFadeToBlack targetURL:[NSURL URLWithString:@"prefs:root=Spectrum"]];
    NSSet *actions = [NSSet setWithObject:restartAction];
    FBSSystemService *frontBoardService = [NSClassFromString(@"FBSSystemService") sharedService];
    [frontBoardService sendActions:actions withResult:nil];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
