//
//  UIButton+Additions.m
//  SDKTools
//

#import "UIButton+Additions.h"
#import "SKTNavigationConstants.h"

@implementation UIButton (Additions)

+ (UIButton *)buttonWithFrame:(CGRect)frame icon:(NSString *)iconName backgroundImageNamed:(NSString *)bkImageName highlightedBkImageNamed:(NSString *)hiBkImageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.adjustsImageWhenHighlighted = NO;
    
    if (iconName) {
        [button setImage:[UIImage navigationImageNamed:iconName] forState:UIControlStateNormal];
    }
    
    UIEdgeInsets insets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    if (bkImageName) {
        UIImage *bkImg = [[UIImage navigationImageNamed:bkImageName] resizableImageWithCapInsets:insets];
        [button setBackgroundImage:bkImg forState:UIControlStateNormal];
    }
    
    if (hiBkImageName) {
        UIImage *hiBkImg = [[UIImage navigationImageNamed:hiBkImageName] resizableImageWithCapInsets:insets];
        [button setBackgroundImage:hiBkImg forState:UIControlStateHighlighted];
        [button setBackgroundImage:hiBkImg forState:UIControlStateSelected];
        [button setBackgroundImage:hiBkImg forState:UIControlStateHighlighted | UIControlStateSelected];
    }
    
    return button;
}

+ (UIButton *)buttonWithFrame:(CGRect)frame icon:(NSString *)iconName backgroundColor:(UIColor *)backgroundColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.adjustsImageWhenHighlighted = NO;
    
    if (iconName) {
        [button setImage:[UIImage navigationImageNamed:iconName] forState:UIControlStateNormal];
    }
    
    [button setBackgroundImage:[UIImage imageFromColor:backgroundColor] forState:UIControlStateNormal];
    button.backgroundColor = backgroundColor;
    
    return button;
}

+ (UIButton *)buttonWithFrame:(CGRect)frame icon:(NSString *)iconName backgroundColor:(UIColor *)backgroundColor highligtedBackgroundColor:(UIColor *)highligtedBackgroundColor {
    UIButton *button = [UIButton buttonWithFrame:frame icon:iconName backgroundColor:backgroundColor];
    [button setBackgroundImage:[UIImage imageFromColor:highligtedBackgroundColor] forState:UIControlStateHighlighted];
    button.adjustsImageWhenHighlighted = NO;
    
    return button;
}

+ (UIButton *)navigationBackButton {
    CGRect frame = CGRectMake(12.0, 20.0, 50.0, 30.0);
    if ([UIDevice isiPad]) {
        frame = CGRectMake(12.0, 20.0, 100.0, 60.0);
    }
    return [UIButton buttonWithFrame:frame
                         icon:@"Icons/back_arrow.png"
              backgroundColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity]
    highligtedBackgroundColor:[UIColor colorWithHex:kSKTBlueHighlightColor alpha:1.0]];
}

@end
