//
//  SKTNavigationView.m
//  SDKTools
//

//

#import "SKTNavigationView.h"
#import "SKTNavigationETAView.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTNavigationSpeedLimitView.h"
#import "SKTNavigationVisualAdviceView.h"
#import "SKTNavigationShortVisualAdviceView.h"
#import "SKTAnimatedLabel.h"
#import "SKTNavigationUtils.h"

//height for speed, eta, dta views
#define kBottomNavigationViewHeight ([UIDevice isiPad] ? 80 : 44.0)
#define kBottomNavigationViewWidth ([UIDevice isiPad] ? 130.0 : 70.0)

//visual advice
#define kVisualAdviceViewHeight ([UIDevice isiPad] ? \
                                 (self.orientation == SKTUIOrientationPortrait ? 150.0 : 100.0) : \
                                 (self.orientation == SKTUIOrientationPortrait ? 70 : 45.0))

#define kShortAdviceHeight ([UIDevice isiPad] ? \
                            (self.orientation == SKTUIOrientationPortrait ? 55.0 : 100.0) : \
                            (self.orientation == SKTUIOrientationPortrait ? 35.0 : 45.0))

@interface SKTNavigationView () <SKTBaseViewDelegate>

@end

@implementation SKTNavigationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addVisualAdviceView];
        [self addShortAdviceView];
        [self addSpeedView];
		[self addSpeedLimitView];
		[self addEtaView];
		[self addDtaView];
        
        self.backgroundColor = [UIColor clearColor];
        self.touchTransparent = YES;
        self.hasContentUnderStatusBar = YES;
    }
    return self;
}

#pragma mark - Overidden

- (void)setNavigationViewType:(SKTNavigationViewType)type {
    _navigationViewType = type;
    [self configureUIForState:type];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat shortAdviceHeight = kShortAdviceHeight;
    _visualAdviceView.frameHeight = self.contentYOffset + kVisualAdviceViewHeight;
    if (self.orientation == SKTUIOrientationPortrait) {
        //move DTA at the bottom
        _dtaView.frame = CGRectMake(_speedView.frameMaxX,
                                    self.frameHeight - kBottomNavigationViewHeight,
                                    self.frameWidth - _etaView.frameWidth - _speedView.frameWidth,
                                    kBottomNavigationViewHeight);
        _dtaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _visualAdviceView.frameWidth = self.frameWidth;
        _shortAdviceView.frame = CGRectMake(0.0, _visualAdviceView.frameMaxY + 1.0, self.frameWidth, shortAdviceHeight);
        _shortAdviceView.streetLabel.hidden = NO;
    } else {
        //move the DTA view on top ETA view
        _dtaView.frame = CGRectMake(self.frameWidth - kBottomNavigationViewWidth, _etaView.frameY - kBottomNavigationViewHeight - 1.0, kBottomNavigationViewWidth, kBottomNavigationViewHeight);
        _dtaView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        _visualAdviceView.frameWidth = self.frameWidth;
        if (!_shortAdviceView.isHidden) {
            _visualAdviceView.frameWidth -= kBottomNavigationViewWidth;
        }
        _shortAdviceView.frame = CGRectMake(self.frameWidth - kBottomNavigationViewWidth, 0.0, kBottomNavigationViewWidth, self.contentYOffset + shortAdviceHeight);
        _shortAdviceView.streetLabel.hidden = YES;
    }
}

- (void)setContentYOffset:(CGFloat)contentYOffset {
    [super setContentYOffset:contentYOffset];
    
    //we want the short advice to be offset only in landscape
    if (self.orientation != SKTUIOrientationLandscape) {
        _shortAdviceView.contentYOffset = 0.0;
    }
}

- (void)setOrientation:(SKTUIOrientation)orientation {
    [super setOrientation:orientation];
    
    if (orientation == SKTUIOrientationLandscape) {
        _shortAdviceView.contentYOffset = self.contentYOffset;
    } else {
        _shortAdviceView.contentYOffset = 0.0;
    }
}

- (void)updateStatusBarStyle {
    if (self.active && self.isUnderStatusBar) {
        NSString *statusKey = [SKTNavigationUtils statusBarStyleNameForStreetType:_visualAdviceView.streetType];
        BOOL defaultStatusBar = [self.colorScheme[statusKey] boolValue];
        UIStatusBarStyle statusBarStyle = (defaultStatusBar ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
        
        if ([self.baseViewDelegate respondsToSelector:@selector(baseView:requiresStatusBarStyle:)]) {
            [self.baseViewDelegate baseView:self requiresStatusBarStyle:statusBarStyle];
        }
    }
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
        
    uint32_t value = [colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *backColor = [UIColor colorWithHex:value];
    
    value = [colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    
    _speedView.backgroundColor = backColor;
    _speedView.topLabel.textColor = textColor;
    _speedView.bottomLabel.textColor = textColor;
    
    _dtaView.backgroundColor = backColor;
    _dtaView.topLabel.textColor = textColor;
    _dtaView.bottomLabel.textColor = textColor;
    
    _etaView.backgroundColor = backColor;
    _etaView.infoView.topLabel.textColor = textColor;
    _etaView.infoView.bottomLabel.textColor = textColor;
    
    _positionerButton.backgroundColor = backColor;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    
    _visualAdviceView.active = active;
    _shortAdviceView.active = active;
}

#pragma mark - Actions

- (void)positionerButtonPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigationView:didPressPositionerButton:)]) {
        [self.delegate navigationView:self didPressPositionerButton:self.positionerButton];
    }
}

#pragma mark - UI creation

- (void)addVisualAdviceView {
	//visual advice covers the top of the screen
	_visualAdviceView = [[SKTNavigationVisualAdviceView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, kVisualAdviceViewHeight)];
	_visualAdviceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _visualAdviceView.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
    _visualAdviceView.exitNumberLabel.hidden = YES;
    _visualAdviceView.baseViewDelegate = self;
	[self addSubview:_visualAdviceView];
}

- (void)addShortAdviceView {
	_shortAdviceView = [[SKTNavigationShortVisualAdviceView alloc] initWithFrame:CGRectMake(0.0, self.frameHeight + 1.0, self.frameWidth, kShortAdviceHeight)];
	_shortAdviceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	_shortAdviceView.hidden = YES;
	[self addSubview:_shortAdviceView];
}

- (void)addEtaView {
	//ETA goes on the bottom left corner
	_etaView = [[SKTNavigationETAView alloc] initWithFrame:CGRectMake(self.frameWidth - kBottomNavigationViewWidth,
                                                                     self.frameHeight - kBottomNavigationViewHeight,
                                                                     kBottomNavigationViewWidth,
                                                                     kBottomNavigationViewHeight)];
	_etaView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	_etaView.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
	[self addSubview:_etaView];
}

- (void)addDtaView {
	//DTA goes all over the bottom part except ETA view
	_dtaView = [[SKTNavigationDoubleLabelView alloc] initWithFrame:CGRectMake(_speedView.frameMaxX,
                                                                             self.frameHeight - kBottomNavigationViewHeight,
                                                                             self.frameWidth - _etaView.frameWidth - _speedView.frameWidth,
                                                                             kBottomNavigationViewHeight)];
	_dtaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_dtaView.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
	[self addSubview:_dtaView];
}

- (void)addSpeedView {
    [_speedView removeFromSuperview];
	//speed view goes on the bottom right corner
	_speedView = [[SKTNavigationDoubleLabelView alloc] initWithFrame:CGRectMake(0.0, self.frameHeight - kBottomNavigationViewHeight, kBottomNavigationViewWidth, kBottomNavigationViewHeight)];
	_speedView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	[self addSubview:_speedView];
}

- (void)addSpeedLimitView {
    [_speedLimitView removeFromSuperview];
	//speed limit view goes on top of the speed view
	_speedLimitView = [[SKTNavigationSpeedLimitView alloc] initWithFrame:CGRectMake(0.0, _speedView.frameY - kBottomNavigationViewWidth, kBottomNavigationViewWidth, kBottomNavigationViewWidth)];
	_speedLimitView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	_speedLimitView.hidden = YES;
	[self addSubview:_speedLimitView];
}

- (void)addPositionerButton {
    [_positionerButton removeFromSuperview];
    CGRect positionerButtonFrame = CGRectMake(0.0, self.frameHeight - kBottomNavigationViewHeight, kBottomNavigationViewWidth, kBottomNavigationViewHeight);
    _positionerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _positionerButton.frame = positionerButtonFrame;
    _positionerButton.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
    [_positionerButton setImage:[UIImage navigationImageNamed:@"Pedestrian/icon_historical_positions.png"] forState:UIControlStateNormal];
    _positionerButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [_positionerButton addTarget:self action:@selector(positionerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_positionerButton];
}

#pragma mark - Private methods

- (void)configureUIForState:(SKTNavigationViewType)state {
    switch (state) {
        case SKTNavigationViewTypeCar:
            [self configureUIForCar];
            break;
        case SKTNavigationViewTypePedestrian:
            [self configureUIForPedestrian];
            break;
            
        default:
            break;
    }
}

- (void)configureUIForCar {
    [self addSpeedView];
    [self addSpeedLimitView];
    [self.positionerButton removeFromSuperview];
}

- (void)configureUIForPedestrian {
    [self.speedLimitView removeFromSuperview];
    [self.speedView removeFromSuperview];
    [self addPositionerButton];
}

#pragma mark - SKTBaseViewDelegate

- (void)baseView:(SKTBaseView *)view requiresStatusBarStyle:(UIStatusBarStyle)style {
    if ([self.baseViewDelegate respondsToSelector:@selector(baseView:requiresStatusBarStyle:)]) {
        [self.baseViewDelegate baseView:view requiresStatusBarStyle:style];
    }
}

@end
