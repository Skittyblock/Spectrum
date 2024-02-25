// SPCSettingsController.m

#import "SPCSettingsController.h"
#import "Preferences.h"
#import <rootless.h>

@implementation SPCSettingsController

- (void)resetSettings {
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("xyz.skitty.spectrum"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		CFPreferencesSetMultiple(nil, keyList, CFSTR("xyz.skitty.spectrum"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		CFRelease(keyList);
	}
	[[NSFileManager defaultManager] removeItemAtPath:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/xyz.skitty.spectrum.plist") error:nil];

	[self respring];
}

- (void)respring {
	SBSRelaunchAction *restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:SBSRelaunchOptionsFadeToBlack targetURL:[NSURL URLWithString:@"prefs:root=Spectrum"]];
	NSSet *actions = [NSSet setWithObject:restartAction];
	FBSSystemService *frontBoardService = [NSClassFromString(@"FBSSystemService") sharedService];
	[frontBoardService sendActions:actions withResult:nil];
}

@end
