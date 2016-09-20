//
//  SKTNavigationPanningView.m
//  SDKTools
//

//

#import "SKTNavigationPanningView.h"

#define kButtonSize ([UIDevice isiPad] ? CGSizeMake(100.0, 60.0) : CGSizeMake(50.0, 30.0))

@implementation SKTNavigationPanningView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self addPanningBackButton];
		[self addCenterButton];
        [self addZoomInButton];
        [self addZoomOutButton];
        
        self.touchTransparent = YES;
        self.backgroundColor = [UIColor clearColor];
	}
    
	return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _panningBackButton.frameY = self.contentYOffset;
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    uint32_t backColor = [self.colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIImage *backImage = [UIImage imageFromColor:[UIColor colorWithHex:backColor]];
    uint32_t highlightColor = [self.colorScheme[kSKTGenericHighlightColorKey] unsignedIntValue];
    UIImage *hiBackImage = [UIImage imageFromColor:[UIColor colorWithHex:highlightColor alpha:1.0]];
    
    [_panningBackButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [_panningBackButton setBackgroundImage:hiBackImage forState:UIControlStateHighlighted];
    
    [_centerButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [_centerButton setBackgroundImage:hiBackImage forState:UIControlStateHighlighted];
    
    [_zoomOutButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [_zoomOutButton setBackgroundImage:hiBackImage forState:UIControlStateHighlighted];
    
    [_zoomInButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [_zoomInButton setBackgroundImage:hiBackImage forState:UIControlStateHighlighted];
}

#pragma mark - UI creation

- (void)addPanningBackButton {
	_panningBackButton = [UIButton navigationBackButton]; 
    [_panningBackButton addTarget:self action:@selector(panningBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_panningBackButton];
}

- (void)addCenterButton {
    CGSize size = kButtonSize;
    _centerButton = [UIButton buttonWithFrame:CGRectMake(12.0, self.frameHeight - size.height - 12.0, size.width, size.height)
                                         icon:@"Icons/nav_arrow.png"
                              backgroundColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity]
                    highligtedBackgroundColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:1.0]];
    [_centerButton addTarget:self action:@selector(centerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _centerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	[self addSubview:_centerButton];
}

- (void)addZoomOutButton {
    CGSize size = kButtonSize;

    _zoomOutButton = [UIButton buttonWithFrame:CGRectMake(_zoomInButton.frameX - size.width - 1.0, self.frameHeight - size.height - 12.0, size.width, size.height)
                                          icon:@"Icons/zoom_out.png"
                               backgroundColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity]
                     highligtedBackgroundColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:1.0]];
    _zoomOutButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [_zoomOutButton addTarget:self action:@selector(zoomOutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_zoomOutButton];
}

- (void)addZoomInButton {
    CGSize size = kButtonSize;
    _zoomInButton = [UIButton buttonWithFrame:CGRectMake(self.frameWidth - size.width - 12.0, self.frameHeight - size.height - 12.0, size.width, size.height)
                                         icon:@"Icons/zoom_in.png"
                              backgroundColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity]
                    highligtedBackgroundColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:1.0]];
    _zoomInButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [_zoomInButton addTarget:self action:@selector(zoomInButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_zoomInButton];
}

#pragma mark - Actions

- (void)panningBackButtonClicked {
    if ([self.delegate respondsToSelector:@selector(panningViewDidClickBackButton:)]) {
        [self.delegate panningViewDidClickBackButton:self];
    }
}

- (void)centerButtonClicked {
    if ([self.delegate respondsToSelector:@selector(panningViewDidClickCenterButton:)]) {
        [self.delegate panningViewDidClickCenterButton:self];
    }
}

- (void)zoomInButtonClicked {
    if ([self.delegate respondsToSelector:@selector(panningViewDidClickZoomInButton:)]) {
        [self.delegate panningViewDidClickZoomInButton:self];
    }
}

- (void)zoomOutButtonClicked {
    if ([self.delegate respondsToSelector:@selector(panningViewDidClickZoomOutButton:)]) {
        [self.delegate panningViewDidClickZoomOutButton:self];
    }
}

@end
