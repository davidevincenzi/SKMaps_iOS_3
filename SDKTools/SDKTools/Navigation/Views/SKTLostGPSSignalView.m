//
//  SKTLostGPSSignalView.m
//  FrameworkIOSDemo
//

//

#import "SKTLostGPSSignalView.h"
#import "UIDevice+Additions.h"
#import "SKTInsetLabel.h"
#import "SKTNavigationConstants.h"

#define kLabelFontSize ([UIDevice isiPad] ? 40.0 : 24.0)
#define kImageX ([UIDevice isiPad] ? 40.0 : 20.0)

@implementation SKTLostGPSSignalView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addImageView];
		[self addMessageLabel];

        self.backgroundColor = [UIColor colorWithHex:kSKTRedBackgroundColor alpha:kSKTBackgroundOpacity];
        self.hasContentUnderStatusBar = YES;
	}
	return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
	[super layoutSubviews];

	_imageView.frameY = roundf((self.frameHeight - 60.0 - self.contentYOffset) / 2.0) + self.contentYOffset;
}

- (void)setContentYOffset:(CGFloat)contentYOffset {
    [super setContentYOffset:contentYOffset];
    _messageLabel.contentYOffset = contentYOffset;
    
    [self setNeedsLayout];
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    uint32_t color = [colorScheme[kSKTGenericWarningColorKey] unsignedIntValue];
    self.backgroundColor = [UIColor colorWithHex:color];
}

#pragma mark - UI creation

- (void)addImageView {
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageX, roundf((self.frameHeight - 65.0) / 2.0), 60, 60)];
	_imageView.image = [UIImage navigationImageNamed:@"Icons/icon_no_gps.png"];
	_imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	[self addSubview:_imageView];
}

- (void)addMessageLabel {
	_messageLabel = [[SKTInsetLabel alloc] initWithFrame:CGRectMake(_imageView.frameMaxX + 5.0,
	                                                          0.0,
	                                                          self.frameWidth - _imageView.frameMaxX - 10.0,
	                                                          self.frameHeight)];
	_messageLabel.text = NSLocalizedString(kSKTGPSDroppedKey, nil);
	_messageLabel.font = [UIFont mediumNavigationFontWithSize:kLabelFontSize];
	_messageLabel.textColor = [UIColor whiteColor];
	_messageLabel.backgroundColor = [UIColor clearColor];
	_messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_messageLabel.textAlignment = NSTextAlignmentCenter;
	[self addSubview:_messageLabel];
}

@end
