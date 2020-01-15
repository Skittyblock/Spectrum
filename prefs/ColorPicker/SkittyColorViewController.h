// SkittyColorViewController.h

#import "SkittyColorPickerView.h"
#import "SkittyColorHueView.h"
#import "SkittyColorAlphaView.h"

@interface SkittyColorViewController : UIViewController <SkittyColorPickerDelegate>

@property (nonatomic, retain) NSDictionary *properties;
@property (nonatomic, retain) SkittyColorPickerView *pickerView;
@property (nonatomic, retain) SkittyColorHueView *hueView;
@property (nonatomic, retain) SkittyColorAlphaView *alphaView;

- (id)initWithProperties:(NSDictionary *)properties;

@end
