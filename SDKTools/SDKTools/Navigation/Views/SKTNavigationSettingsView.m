//
//  SKTNavigationSettingsView.m
//  SDKTools
//

//

#import <AVFoundation/AVAudioSession.h>

#import "SKTNavigationSettingsView.h"
#import "SKTNavigationSettingsButton.h"
#import "SKTNavigationBlockRoadsView.h"

#define kButtonSpacing ([UIDevice isiPad] ? 12 : 12)
#define kVolumeContainerWidth ([UIDevice isiPad] ? 55.0 : 55.0)
#define kVolumeContainerHeight ([UIDevice isiPad] ? 70.0 : 45.0)
#define kFontSize ([UIDevice isiPad] ? 28.0 : 14.0)

@interface SKTNavigationSettingsView ()

@property (nonatomic, strong) SKTNavigationBlockRoadsView *blockRoadsView;

@end

@implementation SKTNavigationSettingsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addBackButton];
        [self addVolume];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backButton.frameY = self.contentYOffset;
    if (self.orientation == SKTUIOrientationPortrait) {
        _volumeContainer.frame = CGRectMake(0.0,
                                            self.frameHeight - kVolumeContainerHeight,
                                            self.frameWidth,
                                            kVolumeContainerHeight);
        _volumeView.transform = CGAffineTransformIdentity;
        _volumeView.frame = CGRectMake(kButtonSpacing, 5.0, self.frameWidth - 2 * kButtonSpacing, 15.0);
    } else {
        _volumeContainer.frame = CGRectMake(self.frameWidth - kButtonSpacing - kVolumeContainerWidth,
                                            _backButton.frameMaxY + kButtonSpacing,
                                            kVolumeContainerWidth,
                                            self.frameHeight - _backButton.frameMaxY - 2 * kButtonSpacing);
        CGFloat sliderHeight = roundf(_volumeContainer.frameHeight * 0.9);
        _volumeView.frame = CGRectMake(kButtonSpacing, roundf((_volumeContainer.frameHeight - sliderHeight) / 2.0), sliderHeight, 15.0);
        _volumeView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
        _volumeView.frameY = roundf((_volumeContainer.frameHeight - sliderHeight) / 2.0);
        CGFloat xOffset = ([UIDevice isiPad] ? 3.0 : 3.0);
        _volumeView.frameX = roundf((_volumeContainer.frameWidth - _volumeView.frameWidth) / 2.0) - xOffset;
    }
    
    [self layoutButtons];
}

- (void)layoutButtons {
    NSUInteger nrOfCols = (self.orientation == SKTUIOrientationPortrait ? self.portraitNumberOfColumns : self.landscapeNumberOfColumns);
    NSInteger nrOfRows = self.settingsButtons.count / nrOfCols;
    if (nrOfCols * nrOfRows < self.settingsButtons.count) {
        nrOfRows++;
    }
    
    CGFloat buttonSpacing = kButtonSpacing;
    
    CGFloat horizontalSpace = (nrOfCols + 1) * buttonSpacing;
    CGFloat verticalSpace = (nrOfRows + 1) * buttonSpacing;
    
    if (self.orientation == SKTUIOrientationLandscape) {
        horizontalSpace = (nrOfCols + 2) * buttonSpacing;
    }
    
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    CGFloat startX = buttonSpacing;
    if (self.orientation == SKTUIOrientationPortrait) {
        width = roundf((self.frameWidth - horizontalSpace) / nrOfCols);
        height = roundf((self.frameHeight - _backButton.frameMaxY - _volumeContainer.frameHeight - verticalSpace) / nrOfRows);
    } else {
        width = roundf((self.frameWidth - _volumeContainer.frameWidth - horizontalSpace) / nrOfCols);
        height = roundf((self.frameHeight - _backButton.frameMaxY - verticalSpace) / nrOfRows);
    }
    [_settingsButtons enumerateObjectsUsingBlock:^(SKTNavigationSettingsButton *button, NSUInteger idx, BOOL *stop) {
        NSInteger row = idx / nrOfCols;
        NSInteger col = idx % nrOfCols;
        button.frame = CGRectMake(col * width + col * buttonSpacing + startX,
                                  row * height + row * buttonSpacing + _backButton.frameMaxY + buttonSpacing,
                                  width,
                                  height);
    }];
}

#pragma mark - Public properties

- (void)setSettingsButtons:(NSArray *)settingsButtons {
    uint32_t value = [self.colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *backColor = [UIColor colorWithHex:value];
    value = [self.colorScheme[kSKTGenericHighlightColorKey] unsignedIntValue];
    UIColor *hiBackColor = [UIColor colorWithHex:value alpha:1.0];
    value = [self.colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    
    for (SKTNavigationSettingsButton *button in _settingsButtons) {
        [button removeFromSuperview];
    }
    
    _settingsButtons = settingsButtons;
    
    for (SKTNavigationSettingsButton *button in _settingsButtons) {
        [self addSubview:button];
        [button setBackgroundImage:[UIImage imageFromColor:backColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageFromColor:hiBackColor] forState:UIControlStateHighlighted];
        [button setTitleColor:textColor forState:UIControlStateNormal];
    }
    
    [self setNeedsLayout];
}

- (void)setOrientation:(SKTUIOrientation)orientation {
    [super setOrientation:orientation];
    if (orientation == SKTUIOrientationPortrait) {
        _volumeLabel.hidden = NO;
    } else {
        _volumeLabel.hidden = YES;
    }
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    uint32_t value = [colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *backColor = [UIColor colorWithHex:value];
    value = [colorScheme[kSKTGenericHighlightColorKey] unsignedIntValue];
    UIColor *hiBackColor = [UIColor colorWithHex:value alpha:1.0];
    
    value = [colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    
    _volumeContainer.backgroundColor = backColor;
    _volumeLabel.textColor = textColor;
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setBackgroundImage:[UIImage imageFromColor:backColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageFromColor:hiBackColor] forState:UIControlStateHighlighted];
            [button setTitleColor:textColor forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UI creation

- (void)addBackButton {
	_backButton = [UIButton navigationBackButton];
    [_backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_backButton];
}

- (void)addVolume {
    _volumeContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frameHeight - kVolumeContainerHeight, self.frameWidth, kVolumeContainerHeight)];
    _volumeContainer.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
    [self addSubview:_volumeContainer];
    
    CGFloat sliderWidth = roundf(_volumeContainer.frameWidth * 0.8);
    _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(roundf((_volumeContainer.frameWidth - sliderWidth) / 2.0), 5.0, sliderWidth, 15.0)];
    NSString *thumbImageName = ([UIDevice majorSystemVersion] >= 7 ? @"Settings/volume_slider_thumb_iOS7.png" : @"Settings/volume_slider_thumb.png");
    UIImage *minImage = [[UIImage navigationImageNamed:@"Settings/volume_slider_minimum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    UIImage *maxImage = [[UIImage navigationImageNamed:@"Settings/volume_slider_maximum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    [_volumeView setMinimumVolumeSliderImage:minImage forState:UIControlStateNormal];
    [_volumeView setMaximumVolumeSliderImage:maxImage forState:UIControlStateNormal];
    [_volumeView setVolumeThumbImage:[UIImage navigationImageNamed:thumbImageName] forState:UIControlStateNormal];
    [_volumeContainer addSubview:_volumeView];
    
    for (UIView *view in [self.volumeView subviews]) {
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
            self.volumeSlider = (UISlider *)view;
        }
    }
    
    CGFloat yOffset = ([UIDevice isiPad] ? 5.0 : 2.0);
    _volumeLabel = [[UILabel alloc] init];
    _volumeLabel.backgroundColor = [UIColor clearColor];
    _volumeLabel.textColor = [UIColor whiteColor];
    _volumeLabel.text = [NSLocalizedString(kSKTSettingsVolumeKey, nil) uppercaseString];
    _volumeLabel.textAlignment = NSTextAlignmentCenter;
    _volumeLabel.font = [UIFont lightNavigationFontWithSize:kFontSize];
    _volumeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    CGFloat height = ceilf([_volumeLabel.text sizeWithFont:_volumeLabel.font].height);
    _volumeLabel.frame = CGRectMake(0.0, _volumeContainer.frameHeight - yOffset - height, _volumeContainer.frameWidth, height);
    [_volumeContainer addSubview:_volumeLabel];
}

#pragma mark - Actions

- (void)backButtonClicked {
    if ([self.delegate respondsToSelector:@selector(navigationSettingsViewDidClickBackButton:)]) {
        [self.delegate navigationSettingsViewDidClickBackButton:self];
    }
}

#pragma mark - SKTNavigationBlockRoadsViewDelegate methods

- (void)blockRoadsViewDidPressBackButton:(SKTNavigationBlockRoadsView *)view {
    [view removeFromSuperview];
    
}

@end
