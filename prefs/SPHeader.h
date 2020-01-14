// SPHeader.m

#import <Preferences/PSSpecifier.h>
#import "Preferences.h"

@interface SPHeader : UITableViewCell

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain)  UILabel *subtitle;

- (id)initWithSpecifier:(PSSpecifier *)specifier;

@end
