//
//  SKTReroutingInfoView.m
//  FrameworkIOSDemo
//

//

#import "SKTReroutingInfoView.h"
#import "SKTInsetLabel.h"
#import "SKTNavigationConstants.h"

#define kReroutingFontSize ([UIDevice isiPad] ? 40.0 : 20.0)

@implementation SKTReroutingInfoView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addMessageLabel];
        self.hasContentUnderStatusBar = YES;
	}
    
	return self;
}

- (void)setContentYOffset:(CGFloat)contentYOffset {
    [super setContentYOffset:contentYOffset];
    _messageLabel.contentYOffset = contentYOffset;
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    uint32_t value = [self.colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    value = [self.colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *backgroundColor = [UIColor colorWithHex:value];
    
    self.backgroundColor = backgroundColor;
    _messageLabel.textColor = textColor;
}

#pragma mark - UI creation

- (void)addMessageLabel {
    _messageLabel = [[SKTInsetLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight)];
	_messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_messageLabel.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
	_messageLabel.font = [UIFont lightNavigationFontWithSize:kReroutingFontSize];
	_messageLabel.text = NSLocalizedString(kSKTReroutingKey, nil);
    _messageLabel.textColor = [UIColor whiteColor];
	_messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.contentYOffset = 0.0;
	[self addSubview:_messageLabel];
}

@end
