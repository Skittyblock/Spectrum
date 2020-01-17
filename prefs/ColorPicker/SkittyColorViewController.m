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

	self.doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
	[self.doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	self.doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
	self.doneButton.frame = CGRectMake(self.view.bounds.size.width - 83, self.view.safeAreaInsets.top ?: 20, 75, 44);
	[self.view addSubview:self.doneButton];

	CFStringRef ref = CFPreferencesCopyAppValue((CFStringRef)self.properties[@"key"], (CFStringRef)self.properties[@"defaults"]);
	NSString *hex = (__bridge NSString *)ref ?: self.properties[@"default"];
	UIColor *color = colorFromHexString(hex);

	CGFloat hue, saturation, brightness, alpha;
	[color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

	float offset = 80;

	self.hexField = [[SkittyColorHexField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 128, offset, 128, 40)];
	self.hexField.delegate = self;
	self.hexField.borderStyle = UITextBorderStyleNone;
	self.hexField.returnKeyType = UIReturnKeyDone;
	self.hexField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.hexField.text = [@"#" stringByAppendingString:[hex substringToIndex:6]];
	[self.view addSubview:self.hexField];

	self.previewView = [[SkittyColorPreviewView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, offset, 128, 40)];
	self.previewView.delegate = self;
	self.previewView.previousColor = color;
	self.previewView.currentColor = color;
	[self.view addSubview:self.previewView];

	self.pickerView = [[SkittyColorPickerView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 128, offset + 50, 256, 256)];
	self.pickerView.delegate = self;
	self.pickerView.hue = hue;
	self.pickerView.value = CGPointMake(saturation, brightness);
	[self.view addSubview:self.pickerView];

	self.hueView = [[SkittyColorHueView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 128, offset + 316, 256, 40)];
	self.hueView.delegate = self;
	self.hueView.hue = hue;
	[self.view addSubview:self.hueView];

	self.alphaView = [[SkittyColorAlphaView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 128, offset + 366, 256, 40)];
	self.alphaView.delegate = self;
	self.alphaView.alphaValue = alpha;
	[self.view addSubview:self.alphaView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.doneButton.frame = CGRectMake(self.view.bounds.size.width - 83, self.view.safeAreaInsets.top ?: 20, 75, 44);
}

- (void)dismiss {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	self.pickerView.hue = self.hueView.hue;
}

- (void)updateColor {
	self.pickerView.hue = self.hueView.hue;

	// write color
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.properties[@"defaults"]]];

	UIColor *color = [UIColor colorWithHue:self.pickerView.hue saturation:self.pickerView.value.x brightness:self.pickerView.value.y alpha:self.alphaView.alphaValue];

	self.previewView.currentColor = color;

	NSString *hex = stringFromColor(color);

	self.hexField.text = [@"#" stringByAppendingString:[hex substringToIndex:6]];
	
	[settings setObject:hex forKey:self.properties[@"key"]];

	[settings writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:///var/mobile/Library/Preferences/%@.plist", self.properties[@"defaults"]]] error:nil];
	CFPreferencesSetAppValue((CFStringRef)self.properties[@"key"], (CFStringRef)hex, (CFStringRef)self.properties[@"defaults"]);

	[[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.spectrum.colorupdate" object:self];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)self.properties[@"PostNotification"], nil, nil, true);
}

- (void)updateWithColor:(UIColor *)color {
	CGFloat hue, saturation, brightness, alpha;
	[color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

	self.pickerView.hue = hue;
	self.pickerView.value = CGPointMake(saturation, brightness);
	self.hueView.hue = hue;
	self.alphaView.alphaValue = alpha;

	[self updateColor];
}

// Hex Field

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	NSString *text = textField.text;
	if (!colorFromHexString(text) || !([[text substringToIndex:1] isEqualToString:@"#"] && text.length == 7)) {
		UIColor *color = [UIColor colorWithHue:self.pickerView.hue saturation:self.pickerView.value.x brightness:self.pickerView.value.y alpha:self.alphaView.alphaValue];
		textField.text = [@"#" stringByAppendingString:[stringFromColor(color) substringToIndex:6]];
	} else {
		[self updateWithColor:colorFromHexString(text)];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {        
    [textField resignFirstResponder];
    return YES;
}

@end
