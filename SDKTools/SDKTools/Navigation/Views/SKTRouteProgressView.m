//
//  SKTRouteProgressView.m
//  FrameworkIOSDemo
//

//

#import "SKTRouteProgressView.h"
#import "SKTNavigationConstants.h"

const float kFakeInterval = 100.0;
const NSTimeInterval kUpdateInterval = 1.0;
#define kFontSize ([UIDevice isiPad] ? 36.0 : 18.0)

@interface SKTRouteProgressView ()

@property (atomic, assign) float                        currentProgress;
@property (atomic, strong) NSTimer                      *timer;
@property (nonatomic, assign) float                     fakeFactor;

@end

@implementation SKTRouteProgressView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addActivityIndicator];
		[self addProgressLabel];
        
        self.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
	}
	return self;
}

- (void)dealloc {
    [_timer invalidate];
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //center vertically the activity indicator and the label
    CGFloat textHeight = [_progressLabel.text sizeWithFont:_progressLabel.font].height;
    _progressLabel.frameHeight = textHeight;
    
    _activityIndicator.frameY = roundf((self.frameHeight - _activityIndicator.frameHeight - textHeight - 8.0) / 2.0);
    _progressLabel.frameY = _activityIndicator.frameMaxY - 8.0;
}

#pragma mark - UI creation

- (void)addActivityIndicator {
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, roundf(self.frameHeight * 0.6))];
    _activityIndicator.activityIndicatorViewStyle = ([UIDevice isiPad] ? UIActivityIndicatorViewStyleWhiteLarge : UIActivityIndicatorViewStyleWhite);
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _activityIndicator.backgroundColor = [UIColor clearColor];
    _activityIndicator.color = [UIColor whiteColor];
    [_activityIndicator startAnimating];
    [self addSubview:_activityIndicator];
}

- (void)addProgressLabel {
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, _activityIndicator.frameMaxY, self.frameWidth, self.frameHeight - _activityIndicator.frameHeight)];
    _progressLabel.text = @"0 %";
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.font = [UIFont mediumNavigationFontWithSize:kFontSize];
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_progressLabel];
}

- (void)startProgress {
    _progressLabel.text = @"0 %";
    _currentProgress = 0.0;
    
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kUpdateInterval target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [_activityIndicator startAnimating];

}

- (void)resumeProgress {
    _timer = [NSTimer scheduledTimerWithTimeInterval:kUpdateInterval target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [_activityIndicator startAnimating];
}

- (void)resetProgress {
    _progressLabel.text = @"0 %";
    _currentProgress = 0.0;
}

- (void)stopProgress {
    [_timer invalidate];
    [_activityIndicator stopAnimating];
}

- (void)updateProgress {
    _fakeFactor = (((arc4random() % 6) + 5) / 100.0);
    float progress = (kFakeInterval - _currentProgress) * _fakeFactor;
    _currentProgress += progress;
    _progressLabel.text = [NSString stringWithFormat:@"%d %%", (int)_currentProgress];
}

@end
