// SPProfileCell.h

#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

@interface PSTableCell (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface SPProfileCell : PSTableCell
@end
