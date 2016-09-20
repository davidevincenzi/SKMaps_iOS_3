//
//  SKTNavigationCalculatingRouteView.m
//  FrameworkIOSDemo
//

//

#import "SKTNavigationCalculatingRouteView.h"
#import "UIDevice+Additions.h"

#define kRouteViewHeight ([UIDevice isiPad] ? 140.0 : 70.0)

#define kStartButtonHeight ([UIDevice isiPad] ? 88.0 : 44.0)
#define kStartButtonFontSize ([UIDevice isiPad] ? 40.0 : 20.0)

@interface SKTNavigationCalculatingRouteView () <SKTRouteInfoViewDelegate>

@end

@implementation SKTNavigationCalculatingRouteView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_infoViews = [NSMutableArray array];
		_progressViews = [NSMutableArray array];

		[self addStartButton];
		[self addContainer];
        [self addStatusBarView];
        
        self.touchTransparent = YES;
        self.hasContentUnderStatusBar = YES;
	}
	return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
	[super layoutSubviews];

	[self layoutButtons];
}

#pragma mark - Public properties

- (void)setNumberOfRoutes:(NSInteger)numberOfRoutes {
	if (_numberOfRoutes != numberOfRoutes) {
		_numberOfRoutes = numberOfRoutes;
		[self deleteRouteViews];
		[self createRouteViews];
		[self setNeedsLayout];
	}
}

- (void)setContentYOffset:(CGFloat)contentYOffset {
    [super setContentYOffset:contentYOffset];
	_container.frameHeight = kRouteViewHeight;
    if (contentYOffset > 0) {
        _statusBarView.frameHeight = contentYOffset;
        _statusBarView.hidden = NO;
        _container.frameY = contentYOffset + 1.0;
    } else {
        _container.frameY = 0.0;
        _statusBarView.hidden = YES;
    }
}

- (void)setSelectedInfoIndex:(NSInteger)selectedInfoIndex {
    _selectedInfoIndex = selectedInfoIndex;
    
    //clear all other views
    [_infoViews enumerateObjectsUsingBlock:^(SKTRouteInfoView *view, NSUInteger idx, BOOL *stop) {
        view.selected = (idx == _selectedInfoIndex);
    }];
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    uint32_t value = [colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *backColor = [UIColor colorWithHex:value];
    uint32_t highlightColor = [self.colorScheme[kSKTGenericHighlightColorKey] unsignedIntValue];
    UIColor *hiBackColor = [UIColor colorWithHex:highlightColor alpha:1.0];
    
    value = [colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    UIColor *textColor = [UIColor colorWithHex:value];
    
    _statusBarView.backgroundColor = backColor;
    [_startButton setBackgroundImage:[UIImage imageFromColor:backColor] forState:UIControlStateNormal];
    [_startButton setBackgroundImage:[UIImage imageFromColor:hiBackColor] forState:UIControlStateHighlighted];
    [_startButton setTitleColor:textColor forState:UIControlStateNormal];
    
    for (UIView *view in _progressViews) {
        SKTRouteProgressView *progress = (SKTRouteProgressView *)view;
        progress.backgroundColor = backColor;
        progress.progressLabel.textColor = textColor;
    }
    
    [_infoViews enumerateObjectsUsingBlock:^(SKTRouteInfoView *view, NSUInteger idx, BOOL *stop) {
        view.selected = (idx == _selectedInfoIndex);
        view.infoLabel.topLabel.textColor = textColor;
        view.infoLabel.bottomLabel.textColor = textColor;
        [view setBackgroundImage:[UIImage imageFromColor:backColor] forState:UIControlStateNormal];
        [view setBackgroundImage:[UIImage imageFromColor:hiBackColor] forState:UIControlStateHighlighted];
        [view setBackgroundImage:[UIImage imageFromColor:hiBackColor] forState:UIControlStateSelected];
        [view setBackgroundImage:[UIImage imageFromColor:hiBackColor] forState:UIControlStateSelected | UIControlStateHighlighted];
    }];
}

#pragma mark - Public methods

- (void)showInfoViewAtIndex:(NSInteger)index {
    ((SKTRouteInfoView *)_infoViews[index]).hidden = NO;
    ((SKTRouteProgressView *)_progressViews[index]).hidden = YES;
}

- (void)showInfoViews {
    [_progressViews enumerateObjectsUsingBlock:^(SKTRouteProgressView *view, NSUInteger idx, BOOL *stop) {
        view.hidden = YES;
    }];
    
    [_infoViews enumerateObjectsUsingBlock:^(SKTRouteInfoView *view, NSUInteger idx, BOOL *stop) {
        view.hidden = NO;
    }];
}

- (void)showProgressViewAtIndex:(NSInteger)index {
    ((SKTRouteInfoView *)_infoViews[index]).hidden = YES;
    ((SKTRouteProgressView *)_infoViews[index]).hidden = NO;
}

- (void)showProgressViews {
    [_progressViews enumerateObjectsUsingBlock:^(SKTRouteProgressView *view, NSUInteger idx, BOOL *stop) {
        view.hidden = NO;
    }];
    
    [_infoViews enumerateObjectsUsingBlock:^(SKTRouteInfoView *view, NSUInteger idx, BOOL *stop) {
        view.hidden = YES;
    }];
}

#pragma mark - UI creation

- (void)addStartButton {
	_startButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, self.frameHeight - kStartButtonHeight, self.frameWidth, kStartButtonHeight)];
    [_startButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity]] forState:UIControlStateNormal];
    [_startButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:kSKTBlackBackgroundColor alpha:1.0]] forState:UIControlStateHighlighted];
	[_startButton setTitle:NSLocalizedString(kSKTStartNavigationKey, nil) forState:UIControlStateNormal];
	[_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _startButton.titleLabel.font = [UIFont mediumNavigationFontWithSize:kStartButtonFontSize];
	_startButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[_startButton addTarget:self action:@selector(startButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_startButton];
}

- (void)addContainer {
	_container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, kRouteViewHeight)];
	_container.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_container.backgroundColor = [UIColor clearColor];
	[self addSubview:_container];
}

- (void)createRouteViews {
    CGFloat width = (self.frameWidth - (self.numberOfRoutes - 1)) / self.numberOfRoutes;
    
    uint32_t value = [self.colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    UIColor *backColor = [UIColor colorWithHex:value alpha:kSKTBackgroundOpacity];
    value = [self.colorScheme[kSKTGenericHighlightColorKey] unsignedIntValue];
    UIColor *highlightColor = [UIColor colorWithHex:value alpha:1.0];
    
    UIImage *backImage = [UIImage imageFromColor:backColor];
    UIImage *hiBackImage =[UIImage imageFromColor:highlightColor];
    
    //add info views between the separators
    for (int i = 0; i < _numberOfRoutes; i++) {
		CGRect viewFrame = CGRectMake(i * width + i, _container.frameHeight - kRouteViewHeight, width, kRouteViewHeight);
        
		SKTRouteInfoView *infoView = [[SKTRouteInfoView alloc] initWithFrame:viewFrame];
		infoView.delegate = self;
		infoView.tag = i;
		infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [infoView setBackgroundImage:backImage forState:UIControlStateNormal];
        [infoView setBackgroundImage:hiBackImage forState:UIControlStateHighlighted];
        [infoView setBackgroundImage:hiBackImage forState:UIControlStateSelected];
        [infoView setBackgroundImage:hiBackImage forState:UIControlStateSelected | UIControlStateHighlighted];
		[_container addSubview:infoView];
		[_infoViews addObject:infoView];
        
		SKTRouteProgressView *progressView = [[SKTRouteProgressView alloc] initWithFrame:viewFrame];
		progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        progressView.backgroundColor = backColor;
		[_container addSubview:progressView];
		[_progressViews addObject:progressView];
	}
    
    [self layoutButtons];
}

- (void)deleteRouteViews {
	for (UIView *view in _progressViews) {
		[view removeFromSuperview];
	}
	[_progressViews removeAllObjects];

	for (UIView *view in _infoViews) {
		[view removeFromSuperview];
	}

	[_infoViews removeAllObjects];
}

- (void)layoutButtons {
    CGFloat width = (int)self.frameWidth / self.numberOfRoutes;
    CGFloat extra = self.frameWidth - width * self.numberOfRoutes;
    
	for (int i = 0; i < _numberOfRoutes; i++) {
        UIView *prev = nil;
        if (i > 0) {
            prev = _infoViews[i - 1];
        }
        
        CGFloat actualWidth = width;
        if (extra > 0.0) {
            actualWidth += 1.0;
            extra -= 1.0;
        }
        
        CGFloat frameX = 0.0;
        if (prev) {
            frameX = prev.frameMaxX + 1.0;
        }
        
		CGRect viewFrame = CGRectMake(frameX, _container.frameHeight - kRouteViewHeight, actualWidth, kRouteViewHeight);
        
		SKTRouteInfoView *infoView = _infoViews[i];
        infoView.frame = viewFrame;

		SKTRouteProgressView *progressView = _progressViews[i];
        progressView.frame = viewFrame;
	}
}

- (void)addStatusBarView {
    _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight)];
    _statusBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _statusBarView.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
    _statusBarView.hidden = YES;
    [self addSubview:_statusBarView];
}

#pragma mark - Actions

- (void)startButtonClicked {
	if ([self.delegate respondsToSelector:@selector(calculatingRouteViewStartClicked:)]) {
		[self.delegate calculatingRouteViewStartClicked:self];
	}
}

#pragma mark - SKTRouteInfoViewDelegate methods

- (void)routeInfoViewClicked:(SKTRouteInfoView *)view {
	if ([self.delegate respondsToSelector:@selector(calculatingRouteView:didSelectRouteAtIndex:)]) {
		[self.delegate calculatingRouteView:self didSelectRouteAtIndex:view.tag];
	}
}

@end
