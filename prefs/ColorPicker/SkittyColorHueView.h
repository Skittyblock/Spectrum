// SkittyColorHueView.h

#import "SkittyColorIndicatorView.h"
#import "ColorPicker.h"

@interface SkittyColorHueView : UIView

@property (nonatomic, retain) id<SkittyColorPickerDelegate> delegate;
@property (nonatomic, retain) SkittyColorIndicatorView *indicator;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) float hue;
@property (nonatomic, retain) UIPanGestureRecognizer *gesture;

@end