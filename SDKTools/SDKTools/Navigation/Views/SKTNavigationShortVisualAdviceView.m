//
//  SKTNavigationShortVisualAdvice.m
//  FrameworkIOSDemo
//

//

#import "SKTNavigationShortVisualAdviceView.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTAnimatedLabel.h"
#import "SKTNavigationUtils.h"

#define kSignImagePercent (0.8)
#define kSignImageSize ([UIDevice isiPad] ? 50.0 : 30.0)
#define kLeftContainerWidth ([UIDevice isiPad] ? 90.0 : 60.0)
#define kDTAFontSize ([UIDevice isiPad] ? 28.0 : 14.0)
#define kDTAWidth ([UIDevice isiPad] ? 90.0 : 45.0)
#define kStreetLabelFontSize ([UIDevice isiPad] ? 28.0 : 14.0)

//x position for the labels
//there are different positions for ipad and iphone in ladscape and portrait
#define kDTAXPosition ([UIDevice isiPad] ? \
                        (self.orientation == SKTUIOrientationPortrait ? 140.0 : 100.0) : \
                        (self.orientation == SKTUIOrientationPortrait ? 70.0 : 35.0))

@implementation SKTNavigationShortVisualAdviceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSignImageView];
        [self addDtaView];
        [self addStreetLabel];
        
        self.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
    }
    return self;
}


#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat dtaXPosition = kDTAXPosition;
    CGFloat imageX = roundf((dtaXPosition - kSignImageSize) / 2.0);
    _signImageView.frame = CGRectMake((self.orientation == SKTUIOrientationPortrait ? imageX : 4.0),
                                      roundf((self.frameHeight - self.contentYOffset - kSignImageSize) / 2.0) + self.contentYOffset,
                                      kSignImageSize,
                                      kSignImageSize);
    
    if (self.orientation == SKTUIOrientationPortrait) {
        _dtaView.frame = CGRectMake(dtaXPosition, self.contentYOffset, kDTAWidth, self.frameHeight - self.contentYOffset);
    } else {
        _dtaView.frame = CGRectMake(_signImageView.frameMaxX + 4.0, self.contentYOffset, self.frameWidth - _signImageView.frameMaxX - 4.0, self.frameHeight - self.contentYOffset);
    }
    
    _streetLabel.frame = CGRectMake(_dtaView.frameMaxX, self.contentYOffset, self.frameWidth - _dtaView.frameMaxX - 5.0, self.frameHeight - self.contentYOffset);
    [_streetLabel restartAnimation];
}

- (void)updateStatusBarStyle {
    
}

#pragma mark - Public properties

- (void)setDistanceToTurn:(NSString *)distanceToTurn {
    _distanceToTurn = distanceToTurn;
    
    if (self.orientation == SKTUIOrientationPortrait) {
        _dtaView.topLabel.text = distanceToTurn;
        _dtaView.bottomLabel.text = @"";
    } else {
        NSArray *components = [distanceToTurn componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _dtaView.topLabel.text = components[0];
        _dtaView.bottomLabel.text = components[1];
    }
    [_dtaView setNeedsLayout];
    [self setNeedsLayout];
}

#pragma mark - Public properties

- (void) setOrientation:(SKTUIOrientation)orientation {
    [super setOrientation:orientation];
    
    //reset distance to turn
    self.distanceToTurn = self.distanceToTurn;
    
    uint32_t value = [self.colorScheme[[SKTNavigationUtils backgroundColorNameForStreetType:self.streetType]] unsignedIntValue];
    if (self.orientation == SKTUIOrientationLandscape) {
        self.backgroundColor = [UIColor colorWithHex:value alpha:1.0];
    } else {
        self.backgroundColor = [UIColor colorWithHex:value];
    }
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    [self updateColorsFromScheme];
}

- (void)setStreetType:(SKStreetType)streetType {
    if (_streetType != streetType) {
        _streetType = streetType;
    
        [self updateColorsFromScheme];
    }
}

#pragma mark - UI creation

- (void)addSignImageView {
    _signImageView = [[UIImageView alloc] init];
    _signImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _signImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_signImageView];
}

- (void)addDtaView {
    _dtaView = [[SKTNavigationDoubleLabelView alloc] initWithFrame:CGRectMake(_signImageView.frameMaxX,
                                                                     0.0,
                                                                     30.0,
                                                                     self.frameHeight)];
    _dtaView.backgroundColor = [UIColor clearColor];
    _dtaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _dtaView.topLabel.font = [UIFont mediumNavigationFontWithSize:kDTAFontSize];
    _dtaView.bottomLabel.font = [UIFont lightNavigationFontWithSize:kDTAFontSize - 2.0];
    _dtaView.topLabel.textAlignment = NSTextAlignmentLeft;
    _dtaView.bottomLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_dtaView];
    
}

- (void)addStreetLabel {
    _streetLabel = [[SKTAnimatedLabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 30.0, self.frameHeight)];
//    _streetLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _streetLabel.label.font = [UIFont lightNavigationFontWithSize:kStreetLabelFontSize];
    _streetLabel.label.backgroundColor = [UIColor clearColor];
    _streetLabel.label.text = @"Street";
    _streetLabel.label.textColor = [UIColor whiteColor];
    [self addSubview:_streetLabel];
}

#pragma mark - Private methods

- (void)updateColorsFromScheme {
    if (!self.colorScheme) {
        return;
    }
    
    uint32_t value = [self.colorScheme[[SKTNavigationUtils streetTextColorNameForStreetType:self.streetType]] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    value = [self.colorScheme[[SKTNavigationUtils backgroundColorNameForStreetType:self.streetType]] unsignedIntValue];
    UIColor *backgroundColor = [UIColor colorWithHex:value];
    UIColor *hiBackgroundColor = [UIColor colorWithHex:value alpha:1.0];
    
    if (self.orientation == SKTUIOrientationLandscape) {
        self.backgroundColor = hiBackgroundColor;
    } else {
        self.backgroundColor = backgroundColor;
    }
    
    _streetLabel.label.textColor = textColor;
    _dtaView.topLabel.textColor = textColor;
    _dtaView.bottomLabel.textColor = textColor;
}

@end
