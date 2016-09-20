//
//  SKTBaseView.m
//  SDKTools
//

//

#import "SKTBaseView.h"

@implementation SKTBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _touchTransparent = NO;
        _contentYOffset = 0.0;
        _hasContentUnderStatusBar = NO;
        _active = NO;
    }
    return self;
}

#pragma mark - Overidden

//we want the touches to pass through this view but not through its subviews
-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self && self.isTouchTransparent) {
        return nil;
    }
    
    return hitView;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    
    if ([view isKindOfClass:[SKTBaseView class]]) {
        SKTBaseView *skView = (SKTBaseView *)view;
        [self setViewProperties:skView];
    }
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [super insertSubview:view atIndex:index];
    if ([view isKindOfClass:[SKTBaseView class]]) {
        SKTBaseView *skView = (SKTBaseView *)view;
        [self setViewProperties:skView];
    }
}

#pragma mark - Public properties

- (void)setOrientation:(SKTUIOrientation)orientation {
    if (_orientation != orientation) {
        _orientation = orientation;
    
        //forward the orientation to the relevant subviews
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[SKTBaseView class]]) {
                ((SKTBaseView *)view).orientation = orientation;
            }
        }
        
        [self setNeedsLayout];
    }
}

- (void)setIsUnderStatusBar:(BOOL)isUnderStatusBar {
    if (_isUnderStatusBar != isUnderStatusBar) {
        _isUnderStatusBar = isUnderStatusBar;
        [self updateStatusBarStyle];
        
        //forward the state to the relevant subviews
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[SKTBaseView class]]) {
                ((SKTBaseView *)view).isUnderStatusBar = isUnderStatusBar;
            }
        }
        
        [self setNeedsLayout];
    }
}

- (void)setContentYOffset:(CGFloat)contentYOffset {
    if (fabsf(contentYOffset - _contentYOffset) > 0.1) {
        _contentYOffset = contentYOffset;
        //forward the offset to the relevant subviews
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[SKTBaseView class]]) {
                ((SKTBaseView *)view).contentYOffset = contentYOffset;
            }
        }

        [self setNeedsLayout];
    }
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    _colorScheme = colorScheme;
    [self updateStatusBarStyle];
    
    //forward the scheme to the relevant subviews
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[SKTBaseView class]]) {
            ((SKTBaseView *)view).colorScheme = colorScheme;
        }
    }
}

- (void)setActive:(BOOL)active {
    _active = active;
    
    [self updateStatusBarStyle];
}

- (void)setHasContentUnderStatusBar:(BOOL)hasContentUnderStatusBar {
    _hasContentUnderStatusBar = hasContentUnderStatusBar;
    
    [self updateStatusBarStyle];
}

- (void)updateStatusBarStyle {
    if (self.active && self.isUnderStatusBar) {
        NSString *statusKey = (self.hasContentUnderStatusBar ? kSKTGenericStatusBarStyleDefaultKey : kSKTGenericStatusBarStyleOnMapDefaultKey);
        BOOL defaultStatusBar = [self.colorScheme[statusKey] boolValue];
        UIStatusBarStyle style = (defaultStatusBar ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
        if ([self.baseViewDelegate respondsToSelector:@selector(baseView:requiresStatusBarStyle:)]) {
            [self.baseViewDelegate baseView:self requiresStatusBarStyle:style];
        }
    }
}

- (void)setViewProperties:(SKTBaseView *)view {
    view.contentYOffset = self.contentYOffset;
    view.orientation = self.orientation;
    view.colorScheme = self.colorScheme;
    view.isUnderStatusBar = self.isUnderStatusBar;
}

@end
