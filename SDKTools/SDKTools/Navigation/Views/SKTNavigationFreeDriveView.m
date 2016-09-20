//
//  SKTNavigationFreeDriveView.m
//  SDKTools
//

//

#import "SKTNavigationFreeDriveView.h"
#import "SKTAnimatedLabel.h"
#import "SKTInsetLabel.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTNavigationSpeedLimitView.h"
#import "SKTNavigationConstants.h"
#import "SKTNavigationUtils.h"

#define kFreeDriveFontSize ([UIDevice isiPad] ? 36.0 : 18.0)
#define kBottomNavigationViewHeight ([UIDevice isiPad] ? 80 : 44.0)
#define kBottomNavigationViewWidth ([UIDevice isiPad] ? 130.0 : 70.0)
#define kFreeDriveHeight ([UIDevice isiPad] ? 120 : 50.0)

@implementation SKTNavigationFreeDriveView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addStreetLabel];
        [self addSpeedView];
		[self addSpeedLimitView];
        self.touchTransparent = YES;
        self.hasContentUnderStatusBar = YES;
    }
    return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _animatedLabel.frameHeight = kFreeDriveHeight + self.contentYOffset;
    _streetLabel.contentYOffset = self.contentYOffset;
}

- (void)updateStatusBarStyle {
    if (self.active && self.isUnderStatusBar) {
        NSString *statusKey = nil;
        if (self.animatedLabel.hidden) {
            statusKey = kSKTGenericStatusBarStyleOnMapDefaultKey;
        } else {
            statusKey = [SKTNavigationUtils statusBarStyleNameForStreetType:self.streetType];
        }
    
        BOOL defaultStatusBar = [self.colorScheme[statusKey] boolValue];
        UIStatusBarStyle style = (defaultStatusBar ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
        if ([self.baseViewDelegate respondsToSelector:@selector(baseView:requiresStatusBarStyle:)]) {
            [self.baseViewDelegate baseView:self requiresStatusBarStyle:style];
        }
    }
}

- (void)setNavigationFreeDriveViewType:(SKTNavigationFreeDriveViewType)navigationFreeDriveViewType {
    _navigationFreeDriveViewType = navigationFreeDriveViewType;
    [self configureUIForState:navigationFreeDriveViewType];
}

#pragma mark - Actions

- (void)positionerButtonPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigationFreeDriveView:didPressPositionerButton:)]) {
        [self.delegate navigationFreeDriveView:self didPressPositionerButton:self.positionerButton];
    }
}

#pragma mark - Public properties

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    [self updateColorsFromScheme];
}

- (void)setStreetType:(SKStreetType)streetType {
    _streetType = streetType;
    
    [self updateColorsFromScheme];
    [self updateStatusBarStyle];
}

#pragma mark - UI creation

- (void)addStreetLabel {
    [_streetLabel removeFromSuperview];
    [_animatedLabel removeFromSuperview];
    
    _streetLabel = [[SKTInsetLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, kFreeDriveHeight)];
    _streetLabel.backgroundColor = [UIColor clearColor];
	_streetLabel.font = [UIFont lightNavigationFontWithSize:kFreeDriveFontSize];
	_streetLabel.text = @"";
	_streetLabel.textAlignment = NSTextAlignmentCenter;
    _streetLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _streetLabel.contentYOffset = 0.0;

    _animatedLabel = [[SKTAnimatedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, kFreeDriveHeight) label:_streetLabel];
    _animatedLabel.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
    _animatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_animatedLabel];
}

- (void)addSpeedView {
    [_speedView removeFromSuperview];
    
	//speed view goes on the bottom right corner
	_speedView = [[SKTNavigationDoubleLabelView alloc] initWithFrame:CGRectMake(0.0, self.frameHeight - kBottomNavigationViewHeight, kBottomNavigationViewWidth, kBottomNavigationViewHeight)];
	_speedView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	_speedView.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
	[self addSubview:_speedView];
}

- (void)addSpeedLimitView {
    [_speedLimitView removeFromSuperview];
    
	//speed limit view goes on top of the speed view
	_speedLimitView = [[SKTNavigationSpeedLimitView alloc] initWithFrame:CGRectMake(0.0, self.frameHeight - kBottomNavigationViewWidth - kBottomNavigationViewHeight, kBottomNavigationViewWidth, kBottomNavigationViewWidth)];
	_speedLimitView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	_speedLimitView.hidden = NO;
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

- (void)updateColorsFromScheme {
    uint32_t value = [self.colorScheme[[SKTNavigationUtils streetTextColorNameForStreetType:self.streetType]] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    value = [self.colorScheme[[SKTNavigationUtils backgroundColorNameForStreetType:self.streetType]] unsignedIntValue];
    UIColor *backgroundColor = [UIColor colorWithHex:value];
    
    value = [self.colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *genericBackgroundColor = [UIColor colorWithHex:value];
    value = [self.colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    UIColor *genericTextColor = [UIColor colorWithHex:value];
    
    _streetLabel.textColor = textColor;
    _animatedLabel.backgroundColor = backgroundColor;
    
    _speedView.backgroundColor = genericBackgroundColor;
    _speedView.topLabel.textColor = genericTextColor;
    _speedView.bottomLabel.textColor = genericTextColor;
    
    _positionerButton.backgroundColor = genericBackgroundColor;
}

- (void)configureUIForState:(SKTNavigationFreeDriveViewType)state {
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
    [self addStreetLabel];
    [self addSpeedView];
    [self addSpeedLimitView];
    [self.positionerButton removeFromSuperview];
}

- (void)configureUIForPedestrian {
    [self.speedLimitView removeFromSuperview];
    [self.speedView removeFromSuperview];
    [self.streetLabel removeFromSuperview];
    
    if (!self.positionerButton) {
        [self addPositionerButton];
    }
}

@end
