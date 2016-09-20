//
//  SKTNavigationInfoView.m
//  SDKTools
//

//

#import "SKTNavigationInfoView.h"
#import "SKTNavigationUtils.h"

#define kFontSize ([UIDevice isiPad] ? 28.0 : 14.0)
#define kStreetFontSize ([UIDevice isiPad] ? 36.0 : 18.0)
#define kContainerHeight ([UIDevice isiPad] ? 130.0 : 95.0)
#define kLabelHeight ([UIDevice isiPad] ? 35.0 : 25.0)
#define kStreetLabelHeight ([UIDevice isiPad] ? 45.0 : 30.0)
#define kLabelX ([UIDevice isiPad] ? 20.0 : 10.0)

@implementation SKTNavigationInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addBackButton];
        [self addCurrentPosition];
        [self addDestination];
        self.backgroundColor = [UIColor clearColor];
        self.touchTransparent = YES;
    }
    return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backButton.frameY = self.contentYOffset;
    _currentLocationInfoContainer.frameY = _backButton.frameMaxY + 12.0;
    _destinationInfoContainer.frameY = _currentLocationInfoContainer.frameMaxY + 1.0;
}

#pragma mark - Public properties

- (void)setCurrentLocation:(CLLocationCoordinate2D)currentLocation {
    _currentLocation = currentLocation;
    NSArray *names = [SKTNavigationUtils streetCityAndCountryForLocation:currentLocation];
    _currentStreetLabel.text = names[0];
    _currentCityLabel.text = [[NSString stringWithFormat:@"%@ %@", names[1], names[2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)setDestinationLocation:(CLLocationCoordinate2D)destinationLocation {
    _destinationLocation = destinationLocation;
    NSArray *names = [SKTNavigationUtils streetCityAndCountryForLocation:destinationLocation];
    _destinationStreetLabel.text = names[0];
    _destinationCityLabel.text = [[NSString stringWithFormat:@"%@ %@", names[1], names[2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    uint32_t value = [colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *backColor = [UIColor colorWithHex:value];
    value = [colorScheme[kSKTGenericHighlightColorKey] unsignedIntValue];
    UIColor *hiBackColor = [UIColor colorWithHex:value alpha:1.0];

    value = [colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    
    [_backButton setBackgroundImage:[UIImage imageFromColor:backColor] forState:UIControlStateNormal];
    [_backButton setBackgroundImage:[UIImage imageFromColor:hiBackColor] forState:UIControlStateHighlighted];
    
    _currentLocationInfoContainer.backgroundColor = backColor;
    _currentLocationTitleLabel.textColor = textColor;
    _currentStreetLabel.textColor = textColor;
    _currentCityLabel.textColor = textColor;
    
    _destinationInfoContainer.backgroundColor = backColor;
    _destinationTitleLabel.textColor = textColor;
    _destinationStreetLabel.textColor = textColor;
    _destinationCityLabel.textColor = textColor;
}

#pragma mark - UI creation

- (void)addBackButton {
    _backButton = [UIButton navigationBackButton];
    [_backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
}

- (void)addCurrentPosition {
    CGFloat labelX = kLabelX;
    _currentLocationInfoContainer = [self containerWithFrame:CGRectMake(12.0, _currentLocationTitleLabel.frameMaxY + 12.0, self.frameWidth - 24.0, kContainerHeight)];
    [self addSubview:_currentLocationInfoContainer];
    
    _currentLocationTitleLabel = [self labelWithFrame:CGRectMake(labelX, 5.0, _currentLocationInfoContainer.frameWidth - labelX - 5.0, kLabelHeight)];
    _currentLocationTitleLabel.font = [UIFont mediumNavigationFontWithSize:kFontSize];
    _currentLocationTitleLabel.text = NSLocalizedString(kSKTCurrentPositionKey, nil);
    [_currentLocationInfoContainer addSubview:_currentLocationTitleLabel];
    
    _currentStreetLabel = [self labelWithFrame:CGRectMake(labelX, _currentLocationTitleLabel.frameMaxY + 9.0, _currentLocationInfoContainer.frameWidth - labelX - 5.0, kStreetLabelHeight)];
    _currentStreetLabel.font = [UIFont mediumNavigationFontWithSize:kStreetFontSize];
    [_currentLocationInfoContainer addSubview:_currentStreetLabel];
    
    _currentCityLabel = [self labelWithFrame:CGRectMake(labelX, _currentStreetLabel.frameMaxY - 4.0, _currentLocationInfoContainer.frameWidth - labelX - 5.0, kLabelHeight)];
    [_currentLocationInfoContainer addSubview:_currentCityLabel];
}

- (void)addDestination {
    CGFloat labelX = kLabelX;
    _destinationInfoContainer = [self containerWithFrame:CGRectMake(12.0, _currentLocationInfoContainer.frameMaxY + 1.0, self.frameWidth - 24.0, kContainerHeight)];
    [self addSubview:_destinationInfoContainer];
    
    _destinationTitleLabel = [self labelWithFrame:CGRectMake(labelX, 5.0, _destinationInfoContainer.frameWidth - labelX - 5.0, kLabelHeight)];
    _destinationTitleLabel.font = [UIFont mediumNavigationFontWithSize:kFontSize];
    _destinationTitleLabel.text = NSLocalizedString(kSKTDestinationKey, nil);
    [_destinationInfoContainer addSubview:_destinationTitleLabel];
    
    _destinationStreetLabel = [self labelWithFrame:CGRectMake(labelX, _destinationTitleLabel.frameMaxY + 9.0, _destinationInfoContainer.frameWidth - labelX - 5.0, kStreetLabelHeight)];
    _destinationStreetLabel.font = [UIFont mediumNavigationFontWithSize:kStreetFontSize];
    [_destinationInfoContainer addSubview:_destinationStreetLabel];
    
    _destinationCityLabel = [self labelWithFrame:CGRectMake(labelX, _destinationStreetLabel.frameMaxY - 4.0, _destinationInfoContainer.frameWidth - labelX - 5.0, kLabelHeight)];
    [_destinationInfoContainer addSubview:_destinationCityLabel];
}

- (UILabel *)labelWithFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont lightNavigationFontWithSize:kFontSize];
    label.textColor = [UIColor whiteColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return label;
}

- (UIView *)containerWithFrame:(CGRect)frame {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return view;
}

#pragma mark - Actions

- (void)backButtonClicked {
    if ([self.delegate respondsToSelector:@selector(navigationInfoViewDidClickBackButton:)]) {
        [self.delegate navigationInfoViewDidClickBackButton:self];
    }
}

@end
