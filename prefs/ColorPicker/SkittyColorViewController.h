// SkittyColorViewController.h

#import "SkittyColorPickerView.h"
#import "SkittyColorHueView.h"

@interface SkittyColorViewController : UIViewController <SkittyColorPickerDelegate>

@property (nonatomic, retain) NSDictionary *properties;
@property (nonatomic, retain) SkittyColorPickerView *pickerView;
@property (nonatomic, retain) SkittyColorHueView *hueView;

- (id)initWithProperties:(NSDictionary *)properties;

@end
