//
//  SKTNavigationETAView.m
//  FrameworkIOSDemo
//

//

#import "SKTNavigationETAView.h"
#import "SKTProgressView.h"
#import "UIDevice+Additions.h"
#import "SKTNavigationDoubleLabelView.h"

#define kCircleSize ([UIDevice isiPad] ? 15.0 : 6.0)
#define kCircleXOffset ([UIDevice isiPad] ? 10.0 : 4.0)
#define kFontSize ([UIDevice isiPad] ? 24.0 : 16.0)

typedef NS_ENUM(NSUInteger, SKETADisplayOption) {
	SKETADisplayOptionTimeLeft,
	SKETADisplayOptionArrivalTime
};

@interface SKTNavigationETAView ()

@property (nonatomic, assign) SKETADisplayOption displayOption;
@property (nonatomic, strong) UIView *leftCircle;
@property (nonatomic, strong) UIView *rightCircle;

@end

@implementation SKTNavigationETAView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self addTimeLeftView];
		[self addFlipButton];
		self.timeFormat = SKTNavigationTimeFormat12h;
	}

	return self;
}

#pragma mark - Public properties

- (void)setTimeToArrival:(int)timeToArrival {
	_timeToArrival = timeToArrival;
	[self updateTimeDisplay];
}

- (void)setTimeFormat:(SKTNavigationTimeFormat)timeFormat {
	_timeFormat = timeFormat;
	[self updateTimeDisplay];
}

#pragma mark - UI creation

- (void)addTimeLeftView {
    _infoView = [[SKTNavigationDoubleLabelView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight)];
    _infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _infoView.backgroundColor = [UIColor clearColor];
    [self addSubview:_infoView];

    CGFloat yOffset = ([UIDevice isiPad] ? 3.0 : 1.0);
    _leftCircle = [[UIView alloc] initWithFrame:CGRectMake(kCircleXOffset,
                                                           roundf((_infoView.bottomLabel.frameHeight - kCircleSize) / 2) + yOffset,
                                                           kCircleSize,
                                                           kCircleSize)];
    _leftCircle.backgroundColor = [UIColor colorWithHex:kSKTGreenBackgroundColor];
    _leftCircle.layer.cornerRadius = roundf(kCircleSize / 2.0);
	_leftCircle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	[_infoView.bottomLabel addSubview:_leftCircle];

    _rightCircle = [[UIView alloc] initWithFrame:CGRectMake(_infoView.bottomLabel.frameWidth - 2.0 - kCircleSize - kCircleXOffset,
                                                            roundf((_infoView.bottomLabel.frameHeight - kCircleSize) / 2) + yOffset,
                                                            kCircleSize,
                                                            kCircleSize)];
    _rightCircle.backgroundColor = [UIColor whiteColor];
    _rightCircle.layer.cornerRadius = kCircleSize / 2.0;
	_rightCircle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	[_infoView.bottomLabel addSubview:_rightCircle];
}

- (void)addFlipButton {
	UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flipButton.frame = CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight);
	flipButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	flipButton.backgroundColor = [UIColor clearColor];
	[flipButton addTarget:self action:@selector(flipButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:flipButton];
}

#pragma mark - Private methods

- (void)updateTimeDisplay {
	NSInteger hour = _timeToArrival / 3600;
	NSInteger secondsRest = _timeToArrival;
	secondsRest -= hour * 3600.0;
	NSInteger minutes = secondsRest / 60.0;

	_infoView.bottomLabel.text = (hour > 1 ? @"h" : @"min");

	if (self.displayOption == SKETADisplayOptionArrivalTime) {
		NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:_timeToArrival];
		NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;

		NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:endDate];
		hour = [components hour];
		minutes = [components minute];

		_infoView.topLabel.text = @"";
		if (self.timeFormat == SKTNavigationTimeFormat12h) {
			_infoView.bottomLabel.text = @"am";
			if (hour > 12) {
				hour -= 12;
				_infoView.bottomLabel.text = @"pm";
			}
		}
	}

	if (hour < 10) {
		if (minutes < 10) {
			_infoView.topLabel.text = [NSString stringWithFormat:@"0%zd:0%zd", hour, minutes];
		}
		else {
			_infoView.topLabel.text = [NSString stringWithFormat:@"0%zd:%zd", hour, minutes];
		}
	} else if (minutes < 10) {
		_infoView.topLabel.text = [NSString stringWithFormat:@"%zd:0%zd", hour, minutes];
	} else {
		_infoView.topLabel.text = [NSString stringWithFormat:@"%zd:%zd", hour, minutes];
	}

	//update circle colors
	if (self.displayOption == SKETADisplayOptionTimeLeft) {
        _leftCircle.backgroundColor = [UIColor colorWithHex:kSKTGreenBackgroundColor];
        _rightCircle.backgroundColor = [UIColor whiteColor];
	} else {
        _leftCircle.backgroundColor = [UIColor whiteColor];
        _rightCircle.backgroundColor = [UIColor colorWithHex:kSKTGreenBackgroundColor];

	}

	[_rightCircle setNeedsDisplay];
	[_leftCircle setNeedsDisplay];
}

#pragma mark - Actions

- (void)flipButtonClicked {
	if (self.displayOption == SKETADisplayOptionTimeLeft) {
		self.displayOption = SKETADisplayOptionArrivalTime;
	}
	else {
		self.displayOption = SKETADisplayOptionTimeLeft;
	}

	[self updateTimeDisplay];
}

@end
