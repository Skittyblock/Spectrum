// ColorPicker.h

#import "../Preferences.h"

float pin(float, float, float);
UInt8 blend(UInt8, UInt8);
void hueToComponentFactors(float, float *, float *, float *);
void HSVtoRGB(float, float, float, float *, float *, float *);
CGContextRef createBGRxImageContext(int, int, void *);
CGImageRef createSaturationBrightnessSquareContentImageWithHue(float);
CGImageRef createHSVBarContentImage(int, float[3]);
CGImageRef createContentImage();
UIColor *colorFromHexString(NSString *);
NSString *stringFromColor(UIColor *);

@protocol SkittyColorPickerDelegate <NSObject>
- (void)updateColor;
- (void)updateWithColor:(UIColor *)color;
@end
