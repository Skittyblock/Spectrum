// SkittyColorHueView.m

#import "SkittyColorHueView.h"

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

static void HSVtoRGB(float h, float s, float v, float* r, float* g, float* b)
{
	hueToComponentFactors(h, r, g, b);
	
	float c = v * s;
	float m = v - c;
	
	*r = *r * c + m;
	*g = *g * c + m;
	*b = *b * c + m;
}

static CGContextRef createBGRxImageContext(int w, int h, void* data) {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGBitmapInfo kBGRxBitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	// BGRA is the most efficient on the iPhone.
	
	CGContextRef context = CGBitmapContextCreate(data, w, h, 8, w * 4, colorSpace, kBGRxBitmapInfo);
	
	CGColorSpaceRelease(colorSpace);
	
	return context;
}

static CGImageRef createHSVBarContentImage(int barComponentIndex, float hsv[3])
{
	UInt8 data[256 * 4];
	
	// Set up the bitmap context for filling with color:
	
	CGContextRef context = createBGRxImageContext(256, 1, data);
	
	if (context == nil)
		return nil;
	
	// Draw into context here:
	
	UInt8* ptr = CGBitmapContextGetData(context);
	if (ptr == nil) {
		CGContextRelease(context);
		return nil;
	}
	
	float r, g, b;
	for (int x = 0; x < 256; ++x) {
		hsv[barComponentIndex] = (float) x / 255.0f;
		
		HSVtoRGB(hsv[0] * 360.0f, hsv[1], hsv[2], &r, &g, &b);
		
		ptr[0] = (UInt8) (b * 255.0f);
		ptr[1] = (UInt8) (g * 255.0f);
		ptr[2] = (UInt8) (r * 255.0f);
		
		ptr += 4;
	}
	
	// Return an image of the context's content:
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	
	CGContextRelease(context);
	
	return image;
}

static CGImageRef createContentImage()
{
	float hsv[] = { 0.0f, 1.0f, 1.0f };
	return createHSVBarContentImage(0, hsv);
}

@implementation SkittyColorHueView

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
			[self.delegate updateHue:value];
		
		[self updateContent];
		[self setNeedsLayout];
	}
}

- (void)handlePanSwipe:(UIPanGestureRecognizer*)recognizer {
    CGPoint t = [recognizer locationInView:recognizer.view];

	self.hue = pin(0.0f, t.x / self.bounds.size.width, 1.0f);
}

@end
