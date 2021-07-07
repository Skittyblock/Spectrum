// Preferences.h

#import <Preferences/PSTableCell.h>

CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface UIImage (Private)
+ (id)_applicationIconImageForBundleIdentifier:(id)identifier format:(int)format scale:(int)scale;
@end

@interface PSTableCell (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

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
