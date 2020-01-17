// ColorPicker.m

#import "ColorPicker.h"

float pin(float minValue, float value, float maxValue) {
	if (minValue > value)
		return minValue;
	else if (maxValue < value)
		return maxValue;
	else
		return value;
}

UInt8 blend(UInt8 value, UInt8 percentIn255) {
	return (UInt8) ((int) value * percentIn255 / 255);
}

void hueToComponentFactors(float h, float *r, float *g, float *b) {
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

void HSVtoRGB(float h, float s, float v, float *r, float *g, float *b) {
	hueToComponentFactors(h, r, g, b);
	
	float c = v * s;
	float m = v - c;
	
	*r = *r * c + m;
	*g = *g * c + m;
	*b = *b * c + m;
}

CGContextRef createBGRxImageContext(int w, int h, void *data) {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGBitmapInfo kBGRxBitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	// BGRA is the most efficient on the iPhone.
	
	CGContextRef context = CGBitmapContextCreate(data, w, h, 8, w * 4, colorSpace, kBGRxBitmapInfo);
	
	CGColorSpaceRelease(colorSpace);
	
	return context;
}

CGImageRef createSaturationBrightnessSquareContentImageWithHue(float hue) {
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

CGImageRef createHSVBarContentImage(int barComponentIndex, float hsv[3]) {
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

CGImageRef createContentImage() {
	float hsv[] = { 0.0f, 1.0f, 1.0f };
	return createHSVBarContentImage(0, hsv);
}

CGFloat colorComponentFrom(NSString *string, NSInteger start, NSInteger length) {
	NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

UIColor *colorFromHexString(NSString *hexString) {
	if ([[hexString substringToIndex:1] isEqualToString:@"#"])
		hexString = [hexString substringWithRange:NSMakeRange(1, hexString.length - 1)];
	CGFloat red, green, blue, alpha;
	switch(hexString.length) {
		case 3: // #RGB
			red = colorComponentFrom(hexString, 0, 1);
			green = colorComponentFrom(hexString, 1, 1);
			blue = colorComponentFrom(hexString, 2, 1);
			alpha = 1;
			break;
		case 4: // #RGBA
			red = colorComponentFrom(hexString, 0, 1);
			green = colorComponentFrom(hexString, 1, 1);
			blue = colorComponentFrom(hexString, 2, 1);
			alpha = colorComponentFrom(hexString, 3, 1);
			break;
		case 6: // #RRGGBB
			red = colorComponentFrom(hexString, 0, 2);
			green = colorComponentFrom(hexString, 2, 2);
			blue = colorComponentFrom(hexString, 4, 2);
			alpha = 1;
			break;
		case 8: // #RRGGBBAA
			red = colorComponentFrom(hexString, 0, 2);
			green = colorComponentFrom(hexString, 2, 2);
			blue = colorComponentFrom(hexString, 4, 2);
			alpha = colorComponentFrom(hexString, 6, 2);
			break;
        default: // Invalid color
			return nil;
	}
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

NSString *stringFromColor(UIColor *color) {
	CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
	const CGFloat *components = CGColorGetComponents(color.CGColor);

	CGFloat r = 0, g = 0, b = 0, a = 0;

	if (colorSpace == kCGColorSpaceModelMonochrome) {
		r = components[0];
		g = components[0];
		b = components[0];
		a = components[1];
	} else if (colorSpace == kCGColorSpaceModelRGB) {
		r = components[0];
		g = components[1];
		b = components[2];
		a = components[3];
	}

	return [NSString stringWithFormat:@"%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255)];
}
