// SkittyColorPickerView.m

#import "SkittyColorPickerView.h"

@implementation SkittyColorPickerView

- (id)init {
    self = [super init];

    if (self) {
    }

    return self;
}

- (void)updateContent {
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    
	CGImageRef imageRef = createSaturationBrightnessSquareContentImageWithHue(self.hue * 360);
	self.imageView.image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
}

- (void)layoutSubviews {
	if (!self.hue) {
        self.hue = 0;
	}
    if (!self.indicator) {
        self.indicator = [[SkittyColorIndicatorView alloc] initWithFrame:CGRectMake(116, 116, 24, 24)];
        [self addSubview:self.indicator];
    }
    if (!self.gesture) {
        self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
        [self addGestureRecognizer:self.gesture];
    }

	CGFloat indicatorX =  self.value.x * self.bounds.size.width;
	CGFloat indicatorY = self.bounds.size.height - self.value.y * self.bounds.size.height;

    self.indicator.center = CGPointMake(indicatorX, indicatorY);
    
    self.indicator.color = [UIColor colorWithHue:self.hue saturation:self.value.x brightness:self.value.y alpha:1];
}

- (void)setHue:(float)value {
	if (value != _hue || self.imageView.image == nil) {
		_hue = value;

        self.indicator.color = [UIColor colorWithHue:value saturation:self.value.x brightness:self.value.y alpha:1];
		
		[self updateContent];
	}
}

- (void)setValue:(CGPoint)newValue {
	if (!CGPointEqualToPoint(newValue, _value)) {
		_value = newValue;
		
		if (self.delegate)
			[self.delegate updateColor];

		//[self sendActionsForControlEvents:UIControlEventValueChanged];
		[self setNeedsLayout];
	}
}

- (void)handlePanSwipe:(UIPanGestureRecognizer*)recognizer {
    CGPoint t = [recognizer locationInView:recognizer.view];
	CGRect bounds = self.bounds;
	
	CGPoint touchValue;
	
	touchValue.x = t.x / bounds.size.width;
	
	touchValue.y = t.y / bounds.size.height;
	
	touchValue.x = pin(0.0f, touchValue.x, 1.0f);
	touchValue.y = 1.0f - pin(0.0f, touchValue.y, 1.0f);
	
	self.value = touchValue;
}

@end
