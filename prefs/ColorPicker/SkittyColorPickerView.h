// SkittyColorPickerView.h

#import "SkittyColorIndicatorView.h"
#import "ColorPicker.h"

@interface SkittyColorPickerView : UIView

@property (nonatomic, weak) id<SkittyColorPickerDelegate> delegate;
@property (nonatomic, retain) SkittyColorIndicatorView *indicator;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) float hue;
@property (nonatomic, assign) CGPoint value;
@property (nonatomic, retain) UIPanGestureRecognizer *gesture;

@end