// SkittyColorViewController.h

#import "SkittyColorHexField.h"
#import "SkittyColorPreviewView.h"
#import "SkittyColorPickerView.h"
#import "SkittyColorHueView.h"
#import "SkittyColorAlphaView.h"

@interface SkittyColorViewController : UIViewController <SkittyColorPickerDelegate, UITextFieldDelegate>

@property (nonatomic, retain) NSDictionary *properties;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) SkittyColorHexField *hexField;
@property (nonatomic, retain) SkittyColorPreviewView *previewView;
@property (nonatomic, retain) SkittyColorPickerView *pickerView;
@property (nonatomic, retain) SkittyColorHueView *hueView;
@property (nonatomic, retain) SkittyColorAlphaView *alphaView;

- (id)initWithProperties:(NSDictionary *)properties;

@end
