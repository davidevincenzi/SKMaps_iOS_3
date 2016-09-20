//
//  SKTNavigationVisualAdviceView.m
//  FrameworkIOSDemo
//

//

#import "SKTNavigationVisualAdviceView.h"
#import "SKTNavigationShortVisualAdviceView.h"
#import "SKTAnimatedLabel.h"
#import "SKTNavigationUtils.h"

//sign sizes
#define kSignImagePercent (0.8)

//advice sizes
#define kFontSize ([UIDevice isiPad] ? 32.0 : 16.0)
#define kDistanceFontSize ([UIDevice isiPad] ? 50.0 : 25.0)

//x position for the labels
//there are different positions for ipad and iphone in ladscape and portrait
#define kLabelXPosition ([UIDevice isiPad] ? \
                            (self.orientation == SKTUIOrientationPortrait ? 140.0 : 100.0) : \
                            (self.orientation == SKTUIOrientationPortrait ? 70.0 : 55.0))

@implementation SKTNavigationVisualAdviceView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addImageView];
		[self addDistanceLabel];
		[self addStreetLabel];
		[self addExitNumberLabel];
        [self addSeparatorLabel];
        [self addButton];
        
        self.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
        self.hasContentUnderStatusBar = YES;
	}
    
	return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
	[super layoutSubviews];

    CGFloat labelXPosition = kLabelXPosition;
    CGFloat signSize = roundf((self.frameHeight - self.contentYOffset) * kSignImagePercent);
    _signImageView.frame = CGRectMake(5.0,
                                      roundf((self.frameHeight - self.contentYOffset - signSize) / 2.0) + self.contentYOffset,
                                      signSize,
                                      signSize);
    
    [self updateLabelSizes];
    
	if (self.orientation == SKTUIOrientationPortrait) {
         //center vertically the labels
        CGFloat totalHeight = _exitNumberLabel.frameHeight + _distanceLabel.frameHeight + _streetLabel.frameHeight;
        _distanceLabel.frameY = roundf((self.frameHeight - self.contentYOffset - totalHeight) / 2.0) + self.contentYOffset;
        _exitNumberLabel.frameOrigin = CGPointMake(labelXPosition, _distanceLabel.frameMaxY);
        _streetLabel.frameOrigin = CGPointMake(labelXPosition, _exitNumberLabel.frameMaxY - 3.0);
        _streetLabel.frameWidth = self.frameWidth - labelXPosition - 5.0;
        _separatorLabel.hidden = YES;
	} else {
        //position the labels one after the other, vertically centered, bottom aligned at the baseline with the distance label
        _distanceLabel.frameY = roundf((self.frameHeight - self.contentYOffset - _distanceLabel.frameHeight) / 2.0) + self.contentYOffset;
		_exitNumberLabel.frameOrigin = CGPointMake(_distanceLabel.frameMaxX + 5.0, floorf(_distanceLabel.frameY + (_distanceLabel.font.ascender - _exitNumberLabel.font.ascender)));
        _separatorLabel.frameOrigin = CGPointMake(_exitNumberLabel.frameMaxX + 2.0, _exitNumberLabel.frameY + roundf((_exitNumberLabel.frameHeight - _separatorLabel.frameHeight) / 2.0));
        _separatorLabel.hidden = (_exitNumberLabel.isHidden || _streetLabel.isHidden || [_streetLabel.label.text isEmptyOrWhiteSpace]);
        if (_exitNumberLabel.hidden) {
            _streetLabel.frameY = _distanceLabel.frameY;
            _streetLabel.frameOrigin = CGPointMake(_distanceLabel.frameMaxX + 5.0,
                                                   floorf(_distanceLabel.frameY + (_distanceLabel.font.ascender - _streetLabel.label.font.ascender)));
            _streetLabel.frameWidth = MIN(_streetLabel.frameWidth, self.frameWidth - _distanceLabel.frameMaxX - 2.0);
        } else {
            _streetLabel.frameOrigin = CGPointMake(_separatorLabel.frameMaxX + 2.0,
                                                   floorf(_distanceLabel.frameY + (_distanceLabel.font.ascender - _streetLabel.label.font.ascender)));
            _streetLabel.frameWidth = MIN(_streetLabel.frameWidth, self.frameWidth - _separatorLabel.frameMaxX - 2.0);
        }
	}
    
    [_streetLabel restartAnimation];
}

- (void)updateLabelSizes {
    //calculate label sizes, zero them if empty
    CGSize size = [_distanceLabel.text sizeWithFont:_distanceLabel.font];
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    _distanceLabel.frame = CGRectMake(kLabelXPosition,
                                      self.contentYOffset + 5.0,
                                      size.width,
                                      size.height);
    if ([_exitNumberLabel.text isEmptyOrWhiteSpace]) {
        _exitNumberLabel.frameSize = CGSizeZero;
    } else {
        size = [_exitNumberLabel.text sizeWithFont:_exitNumberLabel.font];
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
        _exitNumberLabel.frameSize = size;
    }
    
    if ([_streetLabel.label.text isEmptyOrWhiteSpace]) {
        _streetLabel.frameSize = CGSizeZero;
    } else {
        size = [_streetLabel.label.text sizeWithFont:_streetLabel.label.font];
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
        _streetLabel.label.frameSize = size;
        _streetLabel.frameSize = size;
    }
}

- (void)updateStatusBarStyle {
    if (self.active && self.isUnderStatusBar) {
        NSString *statusKey = [SKTNavigationUtils statusBarStyleNameForStreetType:self.streetType];
        BOOL defaultStatusBar = [self.colorScheme[statusKey] boolValue];
        UIStatusBarStyle style = (defaultStatusBar ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
        if ([self.baseViewDelegate respondsToSelector:@selector(baseView:requiresStatusBarStyle:)]) {
            [self.baseViewDelegate baseView:self requiresStatusBarStyle:style];
        }
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
        [self updateStatusBarStyle];
    }
}

#pragma mark - UI creation

- (void)addImageView {
	_signImageView = [[UIImageView alloc] init];
	_signImageView.backgroundColor = [UIColor clearColor];
	[self addSubview:_signImageView];
}

- (void)addDistanceLabel {
	_distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 90.0, 20.0)];
	_distanceLabel.font = [UIFont mediumNavigationFontWithSize:kDistanceFontSize];
	_distanceLabel.backgroundColor = [UIColor clearColor];
	_distanceLabel.textAlignment = NSTextAlignmentLeft;
    _distanceLabel.textColor = [UIColor whiteColor];
	_distanceLabel.text = @"0 km";
	_distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	[self addSubview:_distanceLabel];
}

- (void)addStreetLabel {
	_streetLabel = [[SKTAnimatedLabel alloc] initWithFrame:CGRectMake(5.0, _distanceLabel.frameMaxY + 5.0, self.frameWidth - 10.0, 20.0)];
	_streetLabel.label.font = [UIFont lightNavigationFontWithSize:kFontSize];
	_streetLabel.label.textAlignment = NSTextAlignmentLeft;
	_streetLabel.label.text = @"";
    _streetLabel.label.textColor = [UIColor whiteColor];
	_streetLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:_streetLabel];
}

- (void)addExitNumberLabel {
	_exitNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, _streetLabel.frameMaxY + 5.0, _distanceLabel.frameWidth, 20.0)];
	_exitNumberLabel.font = [UIFont lightNavigationFontWithSize:kFontSize];
	_exitNumberLabel.textAlignment = NSTextAlignmentLeft;
	_exitNumberLabel.text = @"";
	_exitNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_exitNumberLabel.hidden = YES;
	[self addSubview:_exitNumberLabel];
}

- (void)addSeparatorLabel {
    _separatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 30.0)];
    _separatorLabel.backgroundColor = [UIColor clearColor];
    _separatorLabel.font = [UIFont lightNavigationFontWithSize:kFontSize];
    _separatorLabel.textColor = [UIColor whiteColor];
    _separatorLabel.text = @"|";
    _separatorLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_separatorLabel];
    _separatorLabel.hidden = YES;
}

- (void)addButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight);
    button.backgroundColor = [UIColor clearColor];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
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
    
    self.backgroundColor = backgroundColor;
    _distanceLabel.textColor = textColor;
    _streetLabel.label.textColor = textColor;
    _separatorLabel.textColor = textColor;
    _exitNumberLabel.textColor = textColor;
}

#pragma mark - Actions

- (void)buttonClicked {
    if ([self.delegate respondsToSelector:@selector(visualAdviceViewTapped:)]) {
        [self.delegate visualAdviceViewTapped:self];
    }
}

@end
