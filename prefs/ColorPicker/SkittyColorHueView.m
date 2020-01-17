// SkittyColorHueView.m

#import "SkittyColorHueView.h"

@implementation SkittyColorHueView

- (void)updateContent {
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    
	CGImageRef imageRef = createContentImage();
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

	CGFloat indicatorX =  self.hue * self.bounds.size.width;
	CGFloat indicatorY = self.bounds.size.height / 2;

    self.indicator.center = CGPointMake(indicatorX, indicatorY);

    self.indicator.color = [UIColor colorWithHue:self.hue saturation:1 brightness:1 alpha:1];
}

- (void)setHue:(float)value {
	if (value != _hue || self.imageView.image == nil) {
		_hue = value;
		
		if (self.delegate)
			[self.delegate updateColor];
		
		[self updateContent];
		[self setNeedsLayout];
	}
}

- (void)handlePanSwipe:(UIPanGestureRecognizer*)recognizer {
    CGPoint t = [recognizer locationInView:recognizer.view];

	self.hue = pin(0.0f, t.x / self.bounds.size.width, 1.0f);
}

@end
