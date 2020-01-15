// SkittyColorAlphaView.h

#import "SkittyColorIndicatorView.h"
#import "ColorPicker.h"

@interface SkittyColorAlphaView : UIView

@property (nonatomic, weak) id<SkittyColorPickerDelegate> delegate;
@property (nonatomic, retain) SkittyColorIndicatorView *indicator;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) float alphaValue;
@property (nonatomic, retain) UIPanGestureRecognizer *gesture;

@end