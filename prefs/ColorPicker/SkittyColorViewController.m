// SkittyColorViewController.m

#import "SkittyColorViewController.h"

@implementation SkittyColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
        //self.modalInPresentation = YES;
    }

    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/xyz.skitty.spectrum.plist"];

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:[settings objectForKey:@"hexPick"] ?: @"ff0000"];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];

    UIColor *color = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    CGFloat hue, saturation, brightness, alpha;

    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

    self.pickerView = [[SkittyColorPickerView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 128, 100, 256, 256)];
    self.pickerView.delegate = self;
    self.pickerView.hue = hue;
    self.pickerView.value = CGPointMake(saturation, brightness);
    [self.view addSubview:self.pickerView];

    self.hueView = [[SkittyColorHueView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 128, 376, 256, 40)];
    self.hueView.delegate = self;
    self.hueView.hue = hue;
    [self.view addSubview:self.hueView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.pickerView.hue = self.hueView.hue;
}

- (void)updateHue:(float)hue {
    self.pickerView.hue = hue;

    // write color
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/xyz.skitty.spectrum.plist"];

    UIColor *color = [UIColor colorWithHue:hue saturation:self.pickerView.value.x brightness:self.pickerView.value.y alpha:1];
    
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

    NSString *hex = [NSString stringWithFormat:@"%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255)];
    
    [settings setObject:hex forKey:@"hexPick"];

    [settings writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", @"/var/mobile/Library/Preferences/xyz.skitty.spectrum.plist"]] error:nil];
}

@end
