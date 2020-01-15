// SkittyColorViewController.m

#import "SkittyColorViewController.h"
#import "ColorPicker.h"

@implementation SkittyColorViewController

- (id)initWithProperties:(NSDictionary *)properties {
	self = [super init];
	if (self) {
		self.properties = properties;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	if (@available(iOS 13, *)) {
		self.view.backgroundColor = [UIColor systemBackgroundColor];
	} else {
		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	}

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.properties[@"defaults"]]];

	NSString *hex = [settings objectForKey:self.properties[@"key"]] ?: self.properties[@"default"];
	UIColor *color = colorFromHexString(hex);

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

	self.alphaView = [[SkittyColorAlphaView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 128, 436, 256, 40)];
	self.alphaView.delegate = self;
	self.alphaView.alphaValue = alpha;
	[self.view addSubview:self.alphaView];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	self.pickerView.hue = self.hueView.hue;
}

- (void)updateHue:(float)hue {
	self.pickerView.hue = hue;

	// write color
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.properties[@"defaults"]]];

	UIColor *color = [UIColor colorWithHue:hue saturation:self.pickerView.value.x brightness:self.pickerView.value.y alpha:self.alphaView.alphaValue];
	
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

	NSString *hex = [NSString stringWithFormat:@"%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255)];
	
	[settings setObject:hex forKey:self.properties[@"key"]];

	//[settings writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:///var/mobile/Library/Preferences/%@.plist", self.properties[@"defaults"]]] error:nil];
	CFPreferencesSetAppValue((CFStringRef)self.properties[@"key"], (CFStringRef)hex, (CFStringRef)self.properties[@"defaults"]);

	[[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.spectrum.colorupdate" object:self];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)self.properties[@"PostNotification"], nil, nil, true);
}

- (void)updateAlpha:(float)alpha {
	[self updateHue:self.hueView.hue];
}

@end
