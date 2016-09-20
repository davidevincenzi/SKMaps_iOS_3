//
//  SKTRouteInfoView.m
//  FrameworkIOSDemo
//

//

#import "SKTRouteInfoView.h"

#define kTopFontSize ([UIDevice isiPad] ? 40.0 : 20.0)
#define kBottomFontSize ([UIDevice isiPad] ? 36.0 : 18.0)

@implementation SKTRouteInfoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addLabel];
        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - UI creation

- (void)addLabel {
    _infoLabel = [[SKTNavigationDoubleLabelView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight)];
    _infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.topLabel.font = [UIFont mediumNavigationFontWithSize:kTopFontSize];
    self.infoLabel.bottomLabel.font = [UIFont lightNavigationFontWithSize:kBottomFontSize];
    [self addSubview:_infoLabel];
}

- (void)addButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight);
    button.backgroundColor = [UIColor clearColor];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [button addTarget : self action : @selector(buttonClicked) forControlEvents : UIControlEventTouchUpInside];
    [self addSubview:button];
}

#pragma mark - Actions

- (void)buttonClicked {
    if ([self.delegate respondsToSelector:@selector(routeInfoViewClicked:)]) {
        [self.delegate routeInfoViewClicked:self];
    }
}

@end
