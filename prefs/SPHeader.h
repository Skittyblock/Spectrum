// SPHeader.m

#import <Preferences/PSSpecifier.h>

#define kTintColor [UIColor systemBlueColor]

@interface SPHeader : UITableViewCell

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain)  UILabel *subtitle;

- (id)initWithSpecifier:(PSSpecifier *)specifier;

@end
