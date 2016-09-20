//
//  SKTNavigationOverviewView.m
//  SDKTools
//

//

#import "SKTNavigationOverviewView.h"
#import <SKMaps/SKReverseGeocoderService.h>
#import <SKMaps/SKSearchResult.h>
#import <SKMaps/SKSearchResultParent.h>

#import "SKTNavigationUtils.h"

#define kFontSize ([UIDevice isiPad] ? 28.0 : 14.0)
#define kStreetFontSize ([UIDevice isiPad] ? 36.0 : 18.0)
#define kContainerHeight ([UIDevice isiPad] ? 130.0 : 90.0)
#define kLabelHeight ([UIDevice isiPad] ? 35.0 : 25.0)
#define kStreetLabelHeight ([UIDevice isiPad] ? 45.0 : 30.0)
#define kLabelX ([UIDevice isiPad] ? 20.0 : 10.0)

@implementation SKTNavigationOverviewView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addBackButton];
        [self addDestinationInfoView];
        self.backgroundColor = [UIColor clearColor];
        self.touchTransparent = YES;
    }
    return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    _backButton.frameY = self.contentYOffset;
    _infoContainer.frameY = _backButton.frameMaxY + 12.0;
}

#pragma mark - Public properties

- (void)setDestination:(CLLocationCoordinate2D)destination {
    _destination = destination;
    _streetLabel.text = @"";
    _cityLabel.text = @"";
    NSArray *names = [SKTNavigationUtils streetCityAndCountryForLocation:_destination];
    _streetLabel.text = names[0];
    _cityLabel.text = names[1];
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
    
    _infoContainer.backgroundColor = backColor;
    _titleLabel.textColor = textColor;
    _streetLabel.textColor = textColor;
    _cityLabel.textColor = textColor;
}

#pragma mark - UI creation methods

- (void)addBackButton {
    _backButton = [UIButton navigationBackButton];
    [_backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
}

- (void)addDestinationInfoView {
    CGFloat labelX = kLabelX;
    _infoContainer = [[UIView alloc] initWithFrame:CGRectMake(12.0, _backButton.frameMaxY + 12.0, self.frameWidth - 24.0, kContainerHeight)];
    _infoContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _infoContainer.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
    [self addSubview:_infoContainer];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 3.0, _infoContainer.frameWidth - labelX - 5.0, kLabelHeight)];
    _titleLabel.text = NSLocalizedString(kSKTDestinationKey, nil);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont mediumNavigationFontWithSize:kFontSize];
    [_infoContainer addSubview:_titleLabel];
    
    _streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, _titleLabel.frameMaxY + 5.0, _infoContainer.frameWidth - labelX - 5.0, kStreetLabelHeight)];
    _streetLabel.text = @"";
    _streetLabel.backgroundColor = [UIColor clearColor];
    _streetLabel.textColor = [UIColor whiteColor];
    _streetLabel.font = [UIFont mediumNavigationFontWithSize:kStreetFontSize];
    [_infoContainer addSubview:_streetLabel];
    
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, _streetLabel.frameMaxY - 4.0, _infoContainer.frameWidth - labelX - 5.0, kLabelHeight)];
    _cityLabel.text = @"";
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.textColor = [UIColor whiteColor];
    _cityLabel.font = [UIFont lightNavigationFontWithSize:kFontSize];
    [_infoContainer addSubview:_cityLabel];
}

#pragma mark - Actions

- (void)backButtonClicked {
    if ([self.delegate respondsToSelector:@selector(navigationOverviewViewDidClickBackButton:)]) {
        [self.delegate navigationOverviewViewDidClickBackButton:self];
    }
}

@end
