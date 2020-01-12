// SkittyColorPickerView.m

#import "SkittyColorPickerView.h"

#define kContentInsetX 20
#define kContentInsetY 20

#define kIndicatorSize 24

static float pin(float minValue, float value, float maxValue)
{
	if (minValue > value)
		return minValue;
	else if (maxValue < value)
		return maxValue;
	else
		return value;
}

static void hueToComponentFactors(float h, float* r, float* g, float* b) {
	float h_prime = h / 60.0f;
	float x = 1.0f - fabsf(fmodf(h_prime, 2.0f) - 1.0f);
	
	if (h_prime < 1.0f) {
		*r = 1;
		*g = x;
		*b = 0;
	}
	else if (h_prime < 2.0f) {
		*r = x;
		*g = 1;
		*b = 0;
	}
	else if (h_prime < 3.0f) {
		*r = 0;
		*g = 1;
		*b = x;
	}
	else if (h_prime < 4.0f) {
		*r = 0;
		*g = x;
		*b = 1;
	}
	else if (h_prime < 5.0f) {
		*r = x;
		*g = 0;
		*b = 1;
	}
	else {
		*r = 1;
		*g = 0;
		*b = x;
	}
}

static CGContextRef createBGRxImageContext(int w, int h, void* data) {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGBitmapInfo kBGRxBitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	// BGRA is the most efficient on the iPhone.
	
	CGContextRef context = CGBitmapContextCreate(data, w, h, 8, w * 4, colorSpace, kBGRxBitmapInfo);
	
	CGColorSpaceRelease(colorSpace);
	
	return context;
}

static UInt8 blend(UInt8 value, UInt8 percentIn255) {
	return (UInt8) ((int) value * percentIn255 / 255);
}

static CGImageRef createSaturationBrightnessSquareContentImageWithHue(float hue) {
	void* data = malloc(256 * 256 * 4);
	if (data == nil)
		return nil;
	
	CGContextRef context = createBGRxImageContext(256, 256, data);
	
	if (context == nil) {
		free(data);
		return nil;
	}
	
	UInt8* dataPtr = data;
	size_t rowBytes = CGBitmapContextGetBytesPerRow(context);
	
	float r, g, b;
	hueToComponentFactors(hue, &r, &g, &b);
	
	UInt8 r_s = (UInt8) ((1.0f - r) * 255);
	UInt8 g_s = (UInt8) ((1.0f - g) * 255);
	UInt8 b_s = (UInt8) ((1.0f - b) * 255);
	
	for (int s = 0; s < 256; ++s) {
		register UInt8* ptr = dataPtr;
		
		register unsigned int r_hs = 255 - blend(s, r_s);
		register unsigned int g_hs = 255 - blend(s, g_s);
		register unsigned int b_hs = 255 - blend(s, b_s);
		
		for (register int v = 255; v >= 0; --v) {
			ptr[0] = (UInt8) (v * b_hs >> 8);
			ptr[1] = (UInt8) (v * g_hs >> 8);
			ptr[2] = (UInt8) (v * r_hs >> 8);
			
			// Really, these should all be of the form used in blend(),
			// which does a divide by 255. However, integer divide is
			// implemented in software on ARM, so a divide by 256
			// (done as a bit shift) will be *nearly* the same value,
			// and is faster. The more-accurate versions would look like:
			//	ptr[0] = blend(v, b_hs);
			
			ptr += rowBytes;
		}
		
		dataPtr += 4;
	}
	
	// Return an image of the context's content:
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	
	CGContextRelease(context);
	free(data);
	
	return image;
}

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
			[self.delegate updateHue:self.hue];

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
/*
- (void)trackIndicatorWithTouch:(UITouch *)touch {
	CGRect bounds = self.bounds;
	
	CGPoint touchValue;
	
	touchValue.x = [touch locationInView:self].x / bounds.size.width;
	
	touchValue.y = [touch locationInView: self].y / bounds.size.height;
	
	touchValue.x = pin(0.0f, touchValue.x, 1.0f);
	touchValue.y = 1.0f - pin(0.0f, touchValue.y, 1.0f);
	
	self.value = touchValue;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[self trackIndicatorWithTouch:touch];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[self trackIndicatorWithTouch:touch];
	return YES;
}
*/
@end
