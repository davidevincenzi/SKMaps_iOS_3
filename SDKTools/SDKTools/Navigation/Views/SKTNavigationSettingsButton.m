//
//  SKTNavigationSettingsButton.m
//  SDKTools
//

//

#import "SKTNavigationSettingsButton.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTNavigationConstants.h"

#define kFontSize ([UIDevice isiPad] ? 24.0 : 12.0)
#define kInfoSize ([UIDevice isiPad] ? 40 : 20)

@implementation SKTNavigationSettingsButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addCustomImageView];
        [self addLabels];
        [self addBackground];
    }
    return self;
}

+ (instancetype)settingsButtonWithImage:(UIImage *)image topText:(NSString *)topText bottomText:(NSString *)bottomText {
    SKTNavigationSettingsButton *button = [[SKTNavigationSettingsButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    button.infoLabelView.topLabel.text = topText;
    button.infoLabelView.bottomLabel.text = bottomText;
    button.customImageView.image = image;
    return button;
}

#pragma mark - UI creation

- (void)addCustomImageView {
    _customImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight)];
    _customImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_customImageView];
}

- (void)addLabels {
    _infoLabelView = [[SKTNavigationDoubleLabelView alloc] initWithFrame:CGRectMake(0.0, 10.0, self.frameWidth, kInfoSize)];
    _infoLabelView.topLabel.font = [UIFont lightNavigationFontWithSize:kFontSize];
    _infoLabelView.topLabel.textColor = [UIColor whiteColor];
    _infoLabelView.bottomLabel.font = [UIFont lightNavigationFontWithSize:kFontSize];
    _infoLabelView.bottomLabel.textColor = [UIColor whiteColor];
    _infoLabelView.userInteractionEnabled = NO;
    _infoLabelView.backgroundColor = [UIColor clearColor];
    [self addSubview:_infoLabelView];
}

- (void)addBackground {
    [self setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:1.0]] forState:UIControlStateHighlighted];

    return;
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat infoHeight = [_infoLabelView.topLabel.text sizeWithFont:_infoLabelView.topLabel.font].height;
    infoHeight += [_infoLabelView.bottomLabel.text sizeWithFont:_infoLabelView.bottomLabel.font].height;
    _infoLabelView.frameHeight = infoHeight;
    
    
    CGSize size = _customImageView.image.size;
    
    CGFloat totalSize = infoHeight + size.height;// - 12.0;
    _customImageView.frame = CGRectMake(roundf((self.frameWidth - size.width) / 2.0),
                                        roundf((self.frameHeight - totalSize) / 2.0),
                                        size.width,
                                        size.height);
    
    _infoLabelView.frameY = _customImageView.frameMaxY;// - 12.0;
    _infoLabelView.frameWidth = self.frameWidth;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGSize imageSize = [self imageForState:UIControlStateNormal].size;
    CGFloat infoHeight = [_infoLabelView.topLabel.text sizeWithFont:_infoLabelView.topLabel.font].height;
    infoHeight += [_infoLabelView.topLabel.text sizeWithFont:_infoLabelView.bottomLabel.font].height;
    
    return CGRectMake(roundf((contentRect.size.width - imageSize.width) / 2.0),
                      roundf((contentRect.size.height - imageSize.height - infoHeight) / 2.0),
                      imageSize.width,
                      imageSize.height);
}

@end
