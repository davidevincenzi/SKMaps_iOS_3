//
//  NoSignalView.m
//  FrameworkIOSDemo
//

//

#import "SKTWaitingGPSSignalView.h"
#import "SKTNavigationConstants.h"

#define kTitleFontSize ([UIDevice isiPad] ? 40.0 : 20.0)
#define kTextFontSize ([UIDevice isiPad] ? 36.0 : 18.0)
#define kOkButtonWidth ([UIDevice isiPad] ? 600.0 : 300.0)
#define kOkButtonHeight ([UIDevice isiPad] ? 88.0 : 44.0)

@implementation SKTWaitingGPSSignalView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addTitleLabel];
		[self addImageView];
		[self addTextLabel];
		[self addActivityIndicator];
		[self addOkButton];

		self.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
        self.hasContentUnderStatusBar = YES;
	}
	return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
	[super layoutSubviews];

	CGSize maxSize = CGSizeMake(self.frameWidth - 20.0, 10000.0);
	CGFloat titleHeight = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:maxSize].height;
	_titleLabel.frame = CGRectMake(10.0, self.contentYOffset + 10.0, self.frameWidth - 20.0, titleHeight);

	_imageView.frameY = _titleLabel.frameMaxY + 5.0;

	CGFloat textHeight = [_textLabel.text sizeWithFont:_textLabel.font constrainedToSize:maxSize].height;
	_textLabel.frame = CGRectMake(10.0, _imageView.frameMaxY + 5.0, self.frameWidth - 20.0, textHeight);

	_activityView.frame = CGRectMake(roundf(self.frameWidth / 2.0 - 20.0), _textLabel.frameMaxY + 15.0, 40.0, 40.0);

	_okButton.frameWidth = MIN(kOkButtonWidth, self.frameWidth - 20.0);
	_okButton.frameX = roundf((self.frameWidth - _okButton.frameWidth) / 2.0);
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    uint32_t value = [colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *backColor = [UIColor colorWithHex:value];
    value = [colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    
    self.backgroundColor = backColor;
    _titleLabel.textColor = textColor;
    _textLabel.textColor = textColor;
}

#pragma mark - UI creation

- (void)addTitleLabel {
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.contentYOffset + 10.0, self.frameWidth - 20.0, 40.0)];
	_titleLabel.textAlignment = NSTextAlignmentCenter;
	_titleLabel.font = [UIFont mediumNavigationFontWithSize:kTitleFontSize];
	_titleLabel.text = NSLocalizedString(kSKTWaitingGPSTitleKey, nil);
	_titleLabel.textColor = [UIColor whiteColor];
	_titleLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_titleLabel];
}

- (void)addImageView {
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, _titleLabel.frameMaxY + 10.0, self.frameWidth, 155.0)];
	_imageView.image = [UIImage navigationImageNamed:@"Icons/icon_waiting_for_gps.png"];
	_imageView.contentMode = UIViewContentModeCenter;
	_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:_imageView];
}

- (void)addTextLabel {
	_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, _imageView.frameMaxY + 10.0, self.frameWidth - 20.0, 60.0)];
	_textLabel.font = [UIFont lightNavigationFontWithSize:kTextFontSize];
	_textLabel.textAlignment = NSTextAlignmentCenter;
	_textLabel.textColor = [UIColor whiteColor];
	_textLabel.backgroundColor = [UIColor clearColor];
	_textLabel.text = NSLocalizedString(kSKTWaitingGPSTextKey, nil);
	_textLabel.numberOfLines = 0;
	[self addSubview:_textLabel];
}

- (void)addActivityIndicator {
	_activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(roundf(self.frameWidth / 2.0 - 20.0), _textLabel.frameMaxY + 15.0, 40.0, 40.0)];
	[_activityView startAnimating];
	[self addSubview:_activityView];
}

- (void)addOkButton {
    _okButton = [UIButton buttonWithFrame:CGRectMake(roundf((self.frameWidth - kOkButtonWidth) / 2.0), self.frameHeight - kOkButtonHeight - 12.0, kOkButtonWidth, kOkButtonHeight)
                                     icon:nil
                     backgroundImageNamed:@"Backgrounds/button_main_inact.png"
                  highlightedBkImageNamed:@"Backgrounds/button_main_act.png"];
	_okButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	_okButton.titleLabel.font = [UIFont mediumNavigationFontWithSize:kTextFontSize];
	[_okButton setTitle:[NSLocalizedString(kSKTOKKey, nil) uppercaseString] forState:UIControlStateNormal];
	[_okButton addTarget:self action:@selector(okButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_okButton];
}

#pragma mark - Actions

- (void)okButtonClicked {
	if ([self.delegate respondsToSelector:@selector(skWaitingGPSSignalDidClickOkButton:)]) {
		[self.delegate skWaitingGPSSignalDidClickOkButton:self];
	}
}

@end
