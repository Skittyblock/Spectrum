// SkittyColorPreviewView.m

#import "SkittyColorPreviewView.h"

@implementation SkittyColorPreviewView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.previousView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height)];
		[self addSubview:self.previousView];

		self.currentView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height)];
		[self addSubview:self.currentView];

		self.gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[self addGestureRecognizer:self.gesture];
	}

	return self;
}

- (void)setPreviousColor:(UIColor *)value {
	if (value != _previousColor) {
		_previousColor = value;

		self.previousView.backgroundColor = value;
	}
}

- (void)setCurrentColor:(UIColor *)value {
	if (value != _currentColor) {
		_currentColor = value;

		self.currentView.backgroundColor = value;
	}
}

- (void)handleTap:(UITapGestureRecognizer*)recognizer {
	CGPoint t = [recognizer locationInView:recognizer.view];
	if (t.x < self.bounds.size.width / 2) {
		self.currentColor = self.previousColor;
		if (self.delegate)
			[self.delegate updateWithColor:self.currentColor];
	}
}

@end
