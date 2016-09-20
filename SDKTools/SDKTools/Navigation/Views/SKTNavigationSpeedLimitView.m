//
//  SKTNavigationSpeedLimitView.m
//  FrameworkIOSDemo
//

//

#import "SKTNavigationSpeedLimitView.h"
#import "SKTProgressView.h"
#import "SKTNavigationConstants.h"

#define kSpeedFontSize ([UIDevice isiPad] ? 40 : 20.0)
#define kWarningFontSize ([UIDevice isiPad] ? 80.0 : 40.0)
#define kWarningSize ([UIDevice isiPad] ? 90.0 : 49.0)
#define kBackgroundLineWidth ([UIDevice isiPad] ? 10.0 : 5.0)
#define kBackgroundSize ([UIDevice isiPad] ? 110.0 : 52.0)

@implementation SKTNavigationSpeedLimitView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self addBackgroundView];
		[self addSpeedLimitLabel];
		[self addWarningLabel];
		[self addButton];
        
		self.blinkWarning = NO;
        self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

- (void)dealloc {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateWarning) object:nil];
}

#pragma mark - Public properties

- (void)setBlinkWarning:(BOOL)blinkWarning {
	if (_blinkWarning != blinkWarning) {
		_blinkWarning = blinkWarning;
        _warningLabel.alpha = 0.0;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateWarning) object:nil];
		if (_blinkWarning) {
			[self performSelector:@selector(animateWarning) withObject:nil afterDelay:0.5];
		}
	}
}

#pragma mark - UI creation

- (void)addBackgroundView {
	_backgroundView = [SKTProgressView progressViewWithFrame:CGRectMake(roundf((self.frameWidth - kBackgroundSize) / 2.0),
                                                                       roundf((self.frameHeight - kBackgroundSize) / 2.0),
                                                                       kBackgroundSize,
                                                                       kBackgroundSize)
	                                             trackColor:[UIColor colorWithHex:kSKTRedBackgroundColor]
	                                          progressColor:[UIColor clearColor]
                                                  lineWidth:kBackgroundLineWidth];
	_backgroundView.percent = 0.0;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	[self addSubview:_backgroundView];
}

- (void)addSpeedLimitLabel {
	_speedLimitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight)];
	_speedLimitLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_speedLimitLabel.font = [UIFont mediumNavigationFontWithSize:kSpeedFontSize];
	_speedLimitLabel.textAlignment = NSTextAlignmentCenter;
	_speedLimitLabel.text = @"0";
	_speedLimitLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_speedLimitLabel];
}

- (void)addWarningLabel {
	_warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(roundf((self.frameWidth - kWarningSize) / 2.0),
                                                                      roundf((self.frameHeight - kWarningSize) / 2.0),
                                                                      kWarningSize,
                                                                      kWarningSize)];
	_warningLabel.text = @"!";
	_warningLabel.font = [UIFont mediumNavigationFontWithSize:kWarningFontSize];
	_warningLabel.backgroundColor = [UIColor colorWithHex:kSKTRedBackgroundColor];
	_warningLabel.textColor = [UIColor whiteColor];
	_warningLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	_warningLabel.textAlignment = NSTextAlignmentCenter;
    _warningLabel.backgroundColor = [UIColor colorWithHex:kSKTRedBackgroundColor];
    _warningLabel.layer.cornerRadius = kWarningSize / 2.0;
    _warningLabel.clipsToBounds = YES;
    _warningLabel.alpha = 0.0;
	[self addSubview:_warningLabel];
}

- (void)addButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor = [UIColor clearColor];
	button.frame = CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight);
	button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
}

#pragma mark - Private methods

- (void)animateWarning {
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
	    self.warningLabel.alpha = 1.0;
	} completion: ^(BOOL finished) {
	    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations: ^{
	        self.warningLabel.alpha = 0.0;
		} completion: ^(BOOL finished) {
	        if (self.blinkWarning) {
	            [self performSelector:@selector(animateWarning) withObject:nil afterDelay:0.5];
			}
		}];
	}];
}

#pragma mark - Actions

- (void)buttonTapped {
	if ([self.delegate respondsToSelector:@selector(speedLimitViewTapped:)]) {
		[self.delegate speedLimitViewTapped:self];
	}
}

@end
