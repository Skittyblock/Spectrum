// Preferences.h

#import <Preferences/PSTableCell.h>

#define kTintColor [UIColor systemBlueColor]

CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface UIImage (Private)
+ (id)_applicationIconImageForBundleIdentifier:(id)identifier format:(int)format scale:(int)scale;
@end

@interface PSTableCell (Private)
- (UIViewController *)_viewControllerForAncestor;
@end
