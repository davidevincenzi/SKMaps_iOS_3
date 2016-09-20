//
//  SKOneBoxSwipeTableCell.h
//  ForeverMapNGX
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//
#import "SKOneBoxSwipeTableCell.h"

@interface SKOneBoxSwipeTableInputOverlay : UIView

@property (nonatomic, weak) SKOneBoxSwipeTableCell * currentCell;

@end

@implementation SKOneBoxSwipeTableInputOverlay

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_currentCell && CGRectContainsPoint(_currentCell.bounds, [self convertPoint:point toView:_currentCell])) {
        return nil;
    }
    [_currentCell hideSwipeAnimated:YES];
    return nil; //return nil to allow swipping a new cell while the current one is hidding
}

@end

#pragma mark Button Container View and transitions

@interface SKOneBoxSwipeButtonsView : UIView

@property (nonatomic, weak) SKOneBoxSwipeTableCell * cell;
@property (nonatomic, strong) NSArray   *buttons;
@property (nonatomic, strong) UIView    *container;
@property (nonatomic, assign) BOOL      fromLeft;
@property (nonatomic, strong) UIView    *expandedButton;
@property (nonatomic, strong) UIView    *expandedButtonAnimated;
@property (nonatomic, strong) UIView    *expansionBackground;
@property (nonatomic, strong) UIView    *expansionBackgroundAnimated;
@property (nonatomic, strong) UIColor   *backgroundCopy;
@property (nonatomic, assign) CGRect    expandedButtonBoundsCopy;
@property (nonatomic, assign) SKOneBoxSwipeExpansionLayout expansionLayout;
@property (nonatomic, assign) CGFloat       expansionOffset;
@property (nonatomic, assign) BOOL          autoHideExpansion;

@end

@implementation SKOneBoxSwipeButtonsView

#pragma mark Layout

- (instancetype)initWithButtons:(NSArray *)buttonsArray direction:(SKOneBoxSwipeDirection)direction differentWidth:(BOOL)differentWidth andCell:(SKOneBoxSwipeTableCell *)cell {
    CGFloat containerWidth = 0;
    CGSize maxSize = CGSizeMake(cell.buttonWidth, 0);
    self.cell = cell;
    
    for (UIView * button in buttonsArray) {
        containerWidth += button.bounds.size.width;
        maxSize.width = MAX(maxSize.width, button.bounds.size.width);
        maxSize.height = MAX(maxSize.height, button.bounds.size.height);
    }
    
    if (!differentWidth) {
        containerWidth = maxSize.width * buttonsArray.count;
    }
    
    if (self = [super initWithFrame:CGRectMake(0, 0, containerWidth, maxSize.height)]) {
        self.fromLeft = direction == SKOneBoxSwipeDirectionLeftToRight;
        self.container = [[UIView alloc] initWithFrame:self.bounds];
        self.container.clipsToBounds = YES;
        self.container.backgroundColor = [UIColor clearColor];
        [self addSubview:self.container];
        self.buttons = self.fromLeft ? buttonsArray: [[buttonsArray reverseObjectEnumerator] allObjects];
        for (UIView * button in self.buttons) {
            if ([button isKindOfClass:[UIButton class]]) {
                [(UIButton *)button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            if (!differentWidth) {
                button.frame = CGRectMake(0, 0, maxSize.width, maxSize.height);
            }
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [self.container insertSubview:button atIndex: self.fromLeft ? 0: self.container.subviews.count];
        }
        [self resetButtons];
    }
    
    return self;
}

- (void)dealloc {
    for (UIView * button in self.buttons) {
        if ([button isKindOfClass:[UIButton class]]) {
            [(UIButton *)button removeTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)resetButtons {
    CGFloat offsetX = 0;
    for (UIView * button in self.buttons) {
        button.frame = CGRectMake(offsetX, 0, button.bounds.size.width, self.bounds.size.height);
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        offsetX += button.bounds.size.width;
    }
}

- (void)layoutExpansion:(CGFloat)offset {
    self.expansionOffset = offset;
    self.container.frame = CGRectMake(self.fromLeft ? 0: self.bounds.size.width - offset, 0, offset, self.bounds.size.height);
    if (self.expansionBackgroundAnimated && self.expandedButtonAnimated) {
        self.expansionBackgroundAnimated.frame = [self expansionBackgroundRect:self.expandedButtonAnimated];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.expandedButton) {
        [self layoutExpansion:self.expansionOffset];
    } else {
        self.container.frame = self.bounds;
    }
}

- (CGRect)expansionBackgroundRect:(UIView *)button {
    CGFloat extra = 100.0f; //extra size to avoid expansion background size issue on iOS 7.0
    if (self.fromLeft) {
        return CGRectMake(-extra, 0, button.frame.origin.x + extra, self.container.bounds.size.height);
    } else {
        return CGRectMake(button.frame.origin.x +  button.bounds.size.width, 0,
                   self.container.bounds.size.width - (button.frame.origin.x + button.bounds.size.width ) + extra
                          ,self.container.bounds.size.height);
    }
    
}

- (void)expandToOffset:(CGFloat)offset settings:(SKOneBoxSwipeExpansionSettings *)settings {
    if (settings.buttonIndex < 0 || settings.buttonIndex >= self.buttons.count) {
        return;
    }
    if (!self.expandedButton) {
        self.expandedButton = [_buttons objectAtIndex: self.fromLeft ? settings.buttonIndex : self.buttons.count - settings.buttonIndex - 1];
        CGRect previusRect = _container.frame;
        [self layoutExpansion:offset];
        [self resetButtons];
        if (!self.fromLeft) { //Fix expansion animation for right buttons
            for (UIView * button in _buttons) {
                CGRect frame = button.frame;
                frame.origin.x += self.container.bounds.size.width - previusRect.size.width;
                button.frame = frame;
            }
        }
        self.expansionBackground = [[UIView alloc] initWithFrame:[self expansionBackgroundRect:self.expandedButton]];
        self.expansionBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (settings.expansionColor) {
            self.backgroundCopy = self.expandedButton.backgroundColor;
            self.expandedButton.backgroundColor = settings.expansionColor;
        }
        self.expansionBackground.backgroundColor = self.expandedButton.backgroundColor;
        if (UIColor.clearColor == self.expandedButton.backgroundColor) {
          // Provides access to more complex content for display on the background
          self.expansionBackground.layer.contents = self.expandedButton.layer.contents;
        }
        [self.container addSubview:self.expansionBackground];
        self.expansionLayout = settings.expansionLayout;
        
        CGFloat duration = _fromLeft ? _cell.leftExpansion.animationDuration : _cell.rightExpansion.animationDuration;
        [UIView animateWithDuration: duration animations:^{
            self.expandedButton.hidden = NO;

            if (self.expansionLayout == SKOneBoxSwipeExpansionLayoutCenter) {
                self.expandedButtonBoundsCopy = self.expandedButton.bounds;
                self.expandedButton.layer.mask = nil;
                self.expandedButton.layer.transform = CATransform3DIdentity;
                self.expandedButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                [self.expandedButton.superview bringSubviewToFront:self.expandedButton];
                self.expandedButton.frame = self.container.bounds;
            } else if (self.fromLeft) {
                self.expandedButton.frame = CGRectMake(self.container.bounds.size.width - self.expandedButton.bounds.size.width, 0, self.expandedButton.bounds.size.width, self.expandedButton.bounds.size.height);
                self.expandedButton.autoresizingMask|= UIViewAutoresizingFlexibleLeftMargin;
            } else {
                self.expandedButton.frame = CGRectMake(0, 0, self.expandedButton.bounds.size.width, self.expandedButton.bounds.size.height);
                self.expandedButton.autoresizingMask|= UIViewAutoresizingFlexibleRightMargin;
            }
            self.expansionBackground.frame = [self expansionBackgroundRect:self.expandedButton];

        }];
        return;
    }
    [self layoutExpansion:offset];
}

- (void)endExpansioAnimated:(BOOL)animated {
    if (self.expandedButton) {
        self.expandedButtonAnimated = self.expandedButton;
        if (_expansionBackgroundAnimated && self.expansionBackgroundAnimated != self.expansionBackground) {
            [_expansionBackgroundAnimated removeFromSuperview];
        }
        self.expansionBackgroundAnimated = self.expansionBackground;
        self.expansionBackground = nil;
        self.expandedButton = nil;
        if (self.backgroundCopy) {
            self.expansionBackgroundAnimated.backgroundColor = self.backgroundCopy;
            self.expandedButtonAnimated.backgroundColor = self.backgroundCopy;
            self.backgroundCopy = nil;
        }
        CGFloat duration = self.fromLeft ? self.cell.leftExpansion.animationDuration : self.cell.rightExpansion.animationDuration;
        [UIView animateWithDuration: animated ? duration : 0.0 animations:^{
            self.container.frame = self.bounds;
            if (self.expansionLayout == SKOneBoxSwipeExpansionLayoutCenter) {
                self.expandedButtonAnimated.frame = self.expandedButtonBoundsCopy;
            }
            [self resetButtons];
            self.expansionBackgroundAnimated.frame = [self expansionBackgroundRect:self.expandedButtonAnimated];
        } completion:^(BOOL finished) {
            [self.expansionBackgroundAnimated removeFromSuperview];
        }];
    } else if (_expansionBackground) {
        [self.expansionBackground removeFromSuperview];
        self.expansionBackground = nil;
    }
}

- (UIView *)getExpandedButton {
    return _expandedButton;
}

#pragma mark Trigger Actions

- (BOOL)handleClick:(id)sender fromExpansion:(BOOL)fromExpansion {
    bool autoHide = false;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([sender respondsToSelector:@selector(callSwipeConvenienceCallback:)]) {
        //call convenience block callback if exits (usage of SKOneBoxSwipeButton class is not compulsory)
        autoHide = [sender performSelector:@selector(callSwipeConvenienceCallback:) withObject:_cell];
    }
#pragma clang diagnostic pop
    
    if (_cell.delegate && [_cell.delegate respondsToSelector:@selector(swipeTableCell:tappedButtonAtIndex:direction:fromExpansion:)]) {
        NSInteger index = [_buttons indexOfObject:sender];
        if (!_fromLeft) {
            index = _buttons.count - index - 1; //right buttons are reversed
        }
        autoHide|= [_cell.delegate swipeTableCell:_cell tappedButtonAtIndex:index direction:_fromLeft ? SKOneBoxSwipeDirectionLeftToRight : SKOneBoxSwipeDirectionRightToLeft fromExpansion:fromExpansion];
    }
    
    if (fromExpansion && autoHide) {
        _expandedButton = nil;
        _cell.swipeOffset = 0;
    } else if (autoHide) {
        [_cell hideSwipeAnimated:YES];
    }
    
    return autoHide;

}

//button listener
- (void)buttonClicked:(id)sender {
    [self handleClick:sender fromExpansion:NO];
}

#pragma mark Transitions

- (void)transitionStatic:(CGFloat)t {
    const CGFloat dx = self.bounds.size.width * (1.0 - t);
    CGFloat offsetX = 0;
    
    for (UIView *button in _buttons) {
        CGRect frame = button.frame;
        frame.origin.x = offsetX + (_fromLeft ? dx : -dx);
        button.frame = frame;
        offsetX += frame.size.width;
    }
}

- (void)transitionDrag:(CGFloat)t {
    //No Op, nothing to do ;)
}

- (void)transitionClip:(CGFloat)t {
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat offsetX = 0;
    
    for (UIView *button in _buttons) {
        CGRect frame = button.frame;
        CGFloat dx = roundf(frame.size.width * 0.5 * (1.0 - t)) ;
        frame.origin.x = _fromLeft ? (selfWidth - frame.size.width - offsetX) * (1.0 - t) + offsetX + dx : offsetX * t - dx;
        button.frame = frame;

        CAShapeLayer *maskLayer = [CAShapeLayer new];
        CGRect maskRect = CGRectMake(dx - 0.5, 0, frame.size.width - 2 * dx + 1.5, frame.size.height);
        CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
        maskLayer.path = path;
        CGPathRelease(path);
        
        button.layer.mask = maskLayer;

        offsetX += frame.size.width;
    }
}

- (void)transtitionFloatBorder:(CGFloat)t {
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat offsetX = 0;
    
    for (UIView *button in _buttons) {
        CGRect frame = button.frame;
        frame.origin.x = _fromLeft ? (selfWidth - frame.size.width - offsetX) * (1.0 - t) + offsetX : offsetX * t;
        button.frame = frame;
        offsetX += frame.size.width;
    }
}

- (void)transition3D:(CGFloat)t {
    const CGFloat invert = _fromLeft ? 1.0 : -1.0;
    const CGFloat angle = M_PI_2 * (1.0 - t) * invert;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/400.0f; //perspective 1/z
    const CGFloat dx = -_container.bounds.size.width * 0.5 * invert;
    const CGFloat offset = dx * 2 * (1.0 - t);
    transform = CATransform3DTranslate(transform, dx - offset, 0, 0);
    transform = CATransform3DRotate(transform, angle, 0.0, 1.0, 0.0);
    transform = CATransform3DTranslate(transform, -dx, 0, 0);
    _container.layer.transform = transform;
}

- (void)transition:(SKOneBoxSwipeTransition)mode percent:(CGFloat)t {
    switch (mode) {
        case SKOneBoxSwipeTransitionStatic: [self transitionStatic:t]; break;
        case SKOneBoxSwipeTransitionDrag: [self transitionDrag:t]; break;
        case SKOneBoxSwipeTransitionClipCenter: [self transitionClip:t]; break;
        case SKOneBoxSwipeTransitionBorder: [self transtitionFloatBorder:t]; break;
        case SKOneBoxSwipeTransition3D: [self transition3D:t]; break;
    }
    if (_expandedButtonAnimated && _expansionBackgroundAnimated) {
        _expansionBackgroundAnimated.frame = [self expansionBackgroundRect:_expandedButtonAnimated];
    }
}

@end

#pragma mark Settings Classes
@implementation SKOneBoxSwipeSettings

- (instancetype)init {
    if (self = [super init]) {
        self.transition = SKOneBoxSwipeTransitionBorder;
        self.threshold = 0.5;
        self.offset = 0;
        self.animationDuration = 0.3;
    }
    
    return self;
}

@end

@implementation SKOneBoxSwipeExpansionSettings

- (instancetype)init {
    if (self = [super init]) {
        self.buttonIndex = -1;
        self.threshold = 1.3;
        self.animationDuration = 0.2;
    }
    
    return self;
}

@end

typedef struct SKOneBoxSwipeAnimationData {
    CGFloat from;
    CGFloat to;
    CFTimeInterval duration;
    CFTimeInterval start;
} SKOneBoxSwipeAnimationData;


#pragma mark SKOneBoxSwipeTableCell Implementation

@implementation SKOneBoxSwipeTableCell
{
    UITapGestureRecognizer * _tapRecognizer;
    UIPanGestureRecognizer * _panRecognizer;
    CGPoint _panStartPoint;
    CGFloat _panStartOffset;
    CGFloat _targetOffset;
    
    UIView * _swipeOverlay;
    UIImageView * _swipeView;
    UIView * _swipeContentView;
    SKOneBoxSwipeButtonsView * _leftView;
    SKOneBoxSwipeButtonsView * _rightView;
    bool _allowSwipeRightToLeft;
    bool _allowSwipeLeftToRight;
    __weak SKOneBoxSwipeButtonsView * _activeExpansion;

    SKOneBoxSwipeTableInputOverlay * _tableInputOverlay;
    bool _overlayEnabled;
    __weak UITableView * _cachedParentTable;
    UITableViewCellSelectionStyle _previusSelectionStyle;
    NSMutableSet * _previusHiddenViews;
    BOOL _triggerStateChanges;
    
    SKOneBoxSwipeAnimationData _animationData;
    void (^_animationCompletion)();
    CADisplayLink * _displayLink;
}

#pragma mark View creation & layout

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews:YES];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self initViews:YES];
    }
    
    return self;
}

- (void)awakeFromNib {
    if (!_panRecognizer) {
        [self initViews:YES];
    }
}

- (void)dealloc {
    [self hideSwipeOverlayIfNeeded];
}

- (void)initViews:(BOOL)cleanButtons {
    if (cleanButtons) {
        _leftButtons = [NSArray array];
        _rightButtons = [NSArray array];
        _leftSwipeSettings = [[SKOneBoxSwipeSettings alloc] init];
        _rightSwipeSettings = [[SKOneBoxSwipeSettings alloc] init];
        _leftExpansion = [[SKOneBoxSwipeExpansionSettings alloc] init];
        _rightExpansion = [[SKOneBoxSwipeExpansionSettings alloc] init];
    }
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self addGestureRecognizer:_panRecognizer];
    _panRecognizer.delegate = self;
    _activeExpansion = nil;
    _previusHiddenViews = [NSMutableSet set];
    _swipeState = SKOneBoxSwipeStateNone;
    _triggerStateChanges = YES;
    _allowsSwipeWhenTappingButtons = YES;
    
    __weak typeof(self) welf = self;
    self.didTapAccessoryRegion = ^() {
        if (welf.delegate && [welf.delegate respondsToSelector:@selector(swipeTableCell:canSwipe:)]) {
            if ([welf.delegate swipeTableCell:welf canSwipe:SKOneBoxSwipeDirectionRightToLeft]) {
                [welf showSwipe:SKOneBoxSwipeDirectionRightToLeft animated:YES completion:^{
                    
                }];
            }
        }
    };
}

- (void)cleanViews {
    [self hideSwipeAnimated:NO];
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    if (_swipeOverlay) {
        [_swipeOverlay removeFromSuperview];
        _swipeOverlay = nil;
    }
    _leftView = _rightView = nil;
    if (_panRecognizer) {
        _panRecognizer.delegate = nil;
        [self removeGestureRecognizer:_panRecognizer];
        _panRecognizer = nil;
    }
}

- (UIView *)swipeContentView {
    if (!_swipeContentView) {
        _swipeContentView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _swipeContentView.backgroundColor = [UIColor clearColor];
        _swipeContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _swipeContentView.layer.zPosition = 9;
        [self.contentView addSubview:_swipeContentView];
    }
    return _swipeContentView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_swipeContentView) {
        _swipeContentView.frame = self.contentView.bounds;
    }
    if (_swipeOverlay) {
        _swipeOverlay.frame = CGRectMake(0, 0, self.bounds.size.width, self.contentView.bounds.size.height);
    }
}

- (void)fetchButtonsIfNeeded {
    if (_leftButtons.count == 0 && _delegate && [_delegate respondsToSelector:@selector(swipeTableCell:swipeButtonsForDirection:swipeSettings:expansionSettings:)]) {
        _leftButtons = [_delegate swipeTableCell:self swipeButtonsForDirection:SKOneBoxSwipeDirectionLeftToRight swipeSettings:_leftSwipeSettings expansionSettings:_leftExpansion];
    }
    if (_rightButtons.count == 0 && _delegate && [_delegate respondsToSelector:@selector(swipeTableCell:swipeButtonsForDirection:swipeSettings:expansionSettings:)]) {
        _rightButtons = [_delegate swipeTableCell:self swipeButtonsForDirection:SKOneBoxSwipeDirectionRightToLeft swipeSettings:_rightSwipeSettings expansionSettings:_rightExpansion];
    }
}

- (void)createSwipeViewIfNeeded {
    if (!_swipeOverlay) {
        _swipeOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _swipeOverlay.hidden = YES;
        _swipeOverlay.backgroundColor = [self backgroundColorForSwipe];
        _swipeOverlay.layer.zPosition = 10; //force render on top of the contentView;
        _swipeView = [[UIImageView alloc] initWithFrame:_swipeOverlay.bounds];
        _swipeView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _swipeView.contentMode = UIViewContentModeCenter;
        _swipeView.clipsToBounds = YES;
        [_swipeOverlay addSubview:_swipeView];
        [self.contentView addSubview:_swipeOverlay];
    }
    
    [self fetchButtonsIfNeeded];
    if (!_leftView && _leftButtons.count > 0) {
        _leftView = [[SKOneBoxSwipeButtonsView alloc] initWithButtons:_leftButtons direction:SKOneBoxSwipeDirectionLeftToRight differentWidth:_allowsButtonsWithDifferentWidth andCell:self];
        _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _leftView.frame = CGRectMake(-_leftView.bounds.size.width, 0, _leftView.bounds.size.width, _swipeOverlay.bounds.size.height);
        [_swipeOverlay addSubview:_leftView];
    }
    if (!_rightView && _rightButtons.count > 0) {
        _rightView = [[SKOneBoxSwipeButtonsView alloc] initWithButtons:_rightButtons direction:SKOneBoxSwipeDirectionRightToLeft differentWidth:_allowsButtonsWithDifferentWidth andCell:self];
        _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        _rightView.frame = CGRectMake(_swipeOverlay.bounds.size.width, 0, _rightView.bounds.size.width, _swipeOverlay.bounds.size.height);
        [_swipeOverlay addSubview:_rightView];
    }
}


- (void)showSwipeOverlayIfNeeded {
    if (_overlayEnabled) {
        return;
    }
    _overlayEnabled = YES;
    
    self.selected = NO;
    if (_swipeContentView)
        [_swipeContentView removeFromSuperview];
    _swipeView.image = [self imageFromView:self];
    _swipeOverlay.hidden = NO;
    if (_swipeContentView)
        [_swipeView addSubview:_swipeContentView];
    
    if (!_allowsMultipleSwipe) {
        //input overlay on the whole table
        UITableView * table = [self parentTable];
        _tableInputOverlay = [[SKOneBoxSwipeTableInputOverlay alloc] initWithFrame:table.bounds];
        _tableInputOverlay.currentCell = self;
        [table addSubview:_tableInputOverlay];
    }

    _previusSelectionStyle = self.selectionStyle;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setAccesoryViewsHidden:YES];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _tapRecognizer.cancelsTouchesInView = YES;
    _tapRecognizer.delegate = self;
    [self addGestureRecognizer:_tapRecognizer];
}

- (void)hideSwipeOverlayIfNeeded {
    if (!_overlayEnabled) {
        return;
    }
    _overlayEnabled = NO;
    _swipeOverlay.hidden = YES;
    _swipeView.image = nil;
    if (_swipeContentView) {
        [_swipeContentView removeFromSuperview];
        [self.contentView addSubview:_swipeContentView];
    }
    
    if (_tableInputOverlay) {
        [_tableInputOverlay removeFromSuperview];
        _tableInputOverlay = nil;
    }
    
    self.selectionStyle = _previusSelectionStyle;
    NSArray * selectedRows = self.parentTable.indexPathsForSelectedRows;
    if ([selectedRows containsObject:[self.parentTable indexPathForCell:self]]) {
        self.selected = YES;
    }
    [self setAccesoryViewsHidden:NO];
    
    if (_tapRecognizer) {
        [self removeGestureRecognizer:_tapRecognizer];
        _tapRecognizer = nil;
    }
}

- (void)refreshContentView {
    CGFloat currentOffset = _swipeOffset;
    BOOL prevValue = _triggerStateChanges;
    _triggerStateChanges = NO;
    self.swipeOffset = 0;
    self.swipeOffset = currentOffset;
    _triggerStateChanges = prevValue;
}

- (void)refreshButtons:(BOOL)usingDelegate {
    if (usingDelegate) {
        self.leftButtons = @[];
        self.rightButtons = @[];
    }
    if (_leftView) {
        [_leftView removeFromSuperview];
        _leftView = nil;
    }
    if (_rightView) {
        [_rightView removeFromSuperview];
        _rightView = nil;
    }
    [self createSwipeViewIfNeeded];
    [self refreshContentView];
}

#pragma mark Handle Table Events

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) { //remove the table overlay when a cell is removed from the table
        [self hideSwipeOverlayIfNeeded];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self cleanViews];
    if (_swipeState != SKOneBoxSwipeStateNone) {
        _triggerStateChanges = YES;
        [self updateState:SKOneBoxSwipeStateNone];
    }
    BOOL cleanButtons = _delegate && [_delegate respondsToSelector:@selector(swipeTableCell:swipeButtonsForDirection:swipeSettings:expansionSettings:)];
    [self initViews:cleanButtons];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) { //disable swipe buttons when the user sets table editing mode
        self.swipeOffset = 0;
    }
}

- (void)setEditing:(BOOL)editing {
    [super setEditing:YES];
    if (editing) { //disable swipe buttons when the user sets table editing mode
        self.swipeOffset = 0;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_swipeOverlay && !_swipeOverlay.hidden) {
        //override hitTest to give swipe buttons a higher priority (diclosure buttons can steal input)
        UIView * targets[] = {_leftView, _rightView};
        for (int i = 0; i< 2; ++i) {
            UIView * target = targets[i];
            if (!target) continue;
            
            CGPoint p = [self convertPoint:point toView:target];
            if (CGRectContainsPoint(target.bounds, p)) {
                return [target hitTest:p withEvent:event];
            }
        }
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark Some utility methods

- (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setAccesoryViewsHidden:(BOOL)hidden {
    if (self.accessoryView) {
        self.accessoryView.hidden = hidden;
    }
    for (UIView * view in self.contentView.superview.subviews) {
        if (view != self.contentView && ([view isKindOfClass:[UIButton class]] || [NSStringFromClass(view.class) rangeOfString:@"Disclosure"].location != NSNotFound)) {
            view.hidden = hidden;
        }
    }
    
    for (UIView * view in self.contentView.subviews) {
        if (view == _swipeOverlay || view == _swipeContentView) continue;
        if (hidden && !view.hidden) {
            view.hidden = YES;
            [_previusHiddenViews addObject:view];
        }
        else if (!hidden && [_previusHiddenViews containsObject:view]) {
            view.hidden = NO;
        }
    }
    
    if (!hidden) {
        [_previusHiddenViews removeAllObjects];
    }
}

- (UIColor *)backgroundColorForSwipe {
    if (_swipeBackgroundColor) {
        return _swipeBackgroundColor; //user defined color
    } else if (self.contentView.backgroundColor && ![self.contentView.backgroundColor isEqual:[UIColor clearColor]]) {
        return self.contentView.backgroundColor;
    } else if (self.backgroundColor) {
        return self.backgroundColor;
    }
    
    return [UIColor clearColor];
}

- (UITableView *)parentTable {
    if (_cachedParentTable) {
        return _cachedParentTable;
    }
    
    UIView * view = self.superview;
    while(view != nil) {
        if([view isKindOfClass:[UITableView class]]) {
            _cachedParentTable = (UITableView*) view;
        }
        view = view.superview;
    }
    
    return _cachedParentTable;
}

- (void)updateState:(SKOneBoxSwipeState)newState {
    if (!_triggerStateChanges || _swipeState == newState) {
        return;
    }
    _swipeState = newState;
    if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCell:didChangeSwipeState:gestureIsActive:)]) {
        [_delegate swipeTableCell:self didChangeSwipeState:_swipeState gestureIsActive: self.isSwipeGestureActive] ;
    }
}

#pragma mark Swipe Animation

- (void)setSwipeOffset:(CGFloat)newOffset {
    _swipeOffset = newOffset;
    
    CGFloat sign = newOffset > 0 ? 1.0 : -1.0;
    CGFloat offset = fabs(newOffset);
    
    SKOneBoxSwipeButtonsView * activeButtons = sign < 0 ? _rightView : _leftView;
    if (!activeButtons || offset == 0) {
        if (_leftView)
            [_leftView endExpansioAnimated:NO];
        if (_rightView)
            [_rightView endExpansioAnimated:NO];
        [self hideSwipeOverlayIfNeeded];
        _targetOffset = 0;
        [self updateState:SKOneBoxSwipeStateNone];
        return;
    } else {
        [self showSwipeOverlayIfNeeded];
        CGFloat swipeThreshold = sign < 0 ? _rightSwipeSettings.threshold : _leftSwipeSettings.threshold;
        _targetOffset = offset > activeButtons.bounds.size.width * swipeThreshold ? activeButtons.bounds.size.width * sign : 0;
    }
    
    _swipeView.transform = CGAffineTransformMakeTranslation(newOffset, 0);
    //animate existing buttons
    SKOneBoxSwipeButtonsView* but[2] = {_leftView, _rightView};
    SKOneBoxSwipeSettings* settings[2] = {_leftSwipeSettings, _rightSwipeSettings};
    SKOneBoxSwipeExpansionSettings * expansions[2] = {_leftExpansion, _rightExpansion};
    
    for (int i = 0; i< 2; ++i) {
        SKOneBoxSwipeButtonsView * view = but[i];
        if (!view) continue;

        //buttons view position
        CGFloat translation = MIN(offset, view.bounds.size.width) * sign + settings[i].offset * sign;
        view.transform = CGAffineTransformMakeTranslation(translation, 0);

        if (view != activeButtons) continue; //only transition if active (perf. improvement)
        bool expand = expansions[i].buttonIndex >= 0 && offset > view.bounds.size.width * expansions[i].threshold;
        if (expand) {
            [view expandToOffset:offset settings:expansions[i]];
            _targetOffset = expansions[i].fillOnTrigger ? self.bounds.size.width * sign : 0;
            _activeExpansion = view;
            [self updateState:i ? SKOneBoxSwipeStateExpandingRightToLeft : SKOneBoxSwipeStateExpandingLeftToRight];
        }
        else {
            [view endExpansioAnimated:YES];
            _activeExpansion = nil;
            CGFloat t = MIN(1.0f, offset/view.bounds.size.width);
            [view transition:settings[i].transition percent:t];
            [self updateState:i ? SKOneBoxSwipeStateSwippingRightToLeft : SKOneBoxSwipeStateSwippingLeftToRight];
        }
    }
}


- (void)updateSwipe:(CGFloat)offset {
    bool allowed = offset > 0 ? _allowSwipeLeftToRight : _allowSwipeRightToLeft;
    UIView * buttons = offset > 0 ? _leftView : _rightView;
    if (!buttons || ! allowed) {
        offset = 0;
    }
    self.swipeOffset = offset;
}

- (void)hideSwipeAnimated:(BOOL)animated completion:(void(^)())completion {
    [self setSwipeOffset:0 animated:animated completion:completion];
}

- (void)hideSwipeAnimated:(BOOL)animated {
    [self setSwipeOffset:0 animated:animated completion:nil];
}

- (void)showSwipe:(SKOneBoxSwipeDirection)direction animated:(BOOL)animated {
    [self showSwipe:direction animated:animated completion:nil];
}

- (void)showSwipe:(SKOneBoxSwipeDirection)direction animated:(BOOL)animated completion:(void(^)())completion {
    [self createSwipeViewIfNeeded];
    _allowSwipeLeftToRight = _leftButtons.count > 0;
    _allowSwipeRightToLeft = _rightButtons.count > 0;
    UIView * buttonsView = direction == SKOneBoxSwipeDirectionLeftToRight ? _leftView : _rightView;
    
    if (buttonsView) {
        CGFloat s = direction == SKOneBoxSwipeDirectionLeftToRight ? 1.0 : -1.0;
        [self setSwipeOffset:buttonsView.bounds.size.width * s animated:animated completion:completion];
    }
}

- (void)expandSwipe:(SKOneBoxSwipeDirection)direction animated:(BOOL)animated {
    CGFloat s = direction == SKOneBoxSwipeDirectionLeftToRight ? 1.0 : -1.0;
    SKOneBoxSwipeExpansionSettings* expSetting = direction == SKOneBoxSwipeDirectionLeftToRight ? _leftExpansion : _rightExpansion;
    
    // only perform animation if there's no pending expansion animation and requested direction has fillOnTrigger enabled
    if(!_activeExpansion && expSetting.fillOnTrigger) {
        [self createSwipeViewIfNeeded];
        _allowSwipeLeftToRight = _leftButtons.count > 0;
        _allowSwipeRightToLeft = _rightButtons.count > 0;
        UIView * buttonsView = direction == SKOneBoxSwipeDirectionLeftToRight ? _leftView : _rightView;
        
        if (buttonsView) {
            __weak SKOneBoxSwipeButtonsView * expansionView = direction == SKOneBoxSwipeDirectionLeftToRight ? _leftView : _rightView;
            __weak SKOneBoxSwipeTableCell * weakself = self;
            [self setSwipeOffset:buttonsView.bounds.size.width * s * expSetting.threshold * 2 animated:animated completion:^{
                [expansionView endExpansioAnimated:YES];
                [weakself setSwipeOffset:0 animated:NO completion:nil];
            }];
        }
    }
}

- (void)animationTick:(CADisplayLink *)timer {
    if (!_animationData.start) {
        _animationData.start = timer.timestamp;
    }
    CFTimeInterval elapsed = timer.timestamp - _animationData.start;
    CGFloat t = MIN(elapsed/_animationData.duration, 1.0f);
    bool completed = t>=1.0f;
    if (completed) {
        _triggerStateChanges = YES;
    }
    //CubicEaseOut interpolation
    t--;
    self.swipeOffset = (t * t * t + 1.0) * (_animationData.to - _animationData.from) + _animationData.from;
    //call animation completion and invalidate timer
    if (completed){
        [timer invalidate];
        _displayLink = nil;
        if (_animationCompletion) {
            _animationCompletion();
        }
    }
}

- (void)setSwipeOffset:(CGFloat)offset animated:(BOOL)animated completion:(void(^)())completion {
    _animationCompletion = completion;
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
    if (!animated) {
        self.swipeOffset = offset;
        return;
    }
    
    _triggerStateChanges = NO;
    _animationData.from = _swipeOffset;
    _animationData.to = offset;
    _animationData.duration = _swipeOffset > 0 ? _leftSwipeSettings.animationDuration : _rightSwipeSettings.animationDuration;
    _animationData.start = 0;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTick:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark Gestures

- (void)cancelPanGesture {
    if (_panRecognizer.state != UIGestureRecognizerStateEnded) {
        _panRecognizer.enabled = NO;
        _panRecognizer.enabled = YES;
        [self hideSwipeAnimated:YES];
    }
}

- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    [self hideSwipeAnimated:YES];
}

- (void)panHandler:(UIPanGestureRecognizer *)gesture {
    CGPoint current = [gesture translationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.highlighted = NO;
        [self createSwipeViewIfNeeded];
        _panStartPoint = current;
        _panStartOffset = _swipeOffset;
        
        if (!_allowsMultipleSwipe) {
            NSArray * cells = [self parentTable].visibleCells;
            for (SKOneBoxSwipeTableCell * cell in cells) {
                if ([cell isKindOfClass:[SKOneBoxSwipeTableCell class]] && cell != self) {
                    [cell cancelPanGesture];
                }
            }
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat offset = _panStartOffset + current.x - _panStartPoint.x;
        [self updateSwipe:offset];
    } else {
        SKOneBoxSwipeButtonsView * expansion = _activeExpansion;
        if (expansion) {
            UIView * expandedButton = [expansion getExpandedButton];
            [self setSwipeOffset:_targetOffset animated:YES completion:^{
                BOOL autoHide = [expansion handleClick:expandedButton fromExpansion:YES];
                if (autoHide) {
                    [expansion endExpansioAnimated:NO];
                }
            }];
        } else {
            CGFloat velocity = [_panRecognizer velocityInView:self].x;
            CGFloat inertiaThreshold = 100.0; //points per second
            if (velocity > inertiaThreshold) {
                _targetOffset = _swipeOffset < 0 ? 0 : (_leftView ? _leftView.bounds.size.width : _targetOffset);
            } else if (velocity < -inertiaThreshold) {
                _targetOffset = _swipeOffset > 0 ? 0 : (_rightView ? -_rightView.bounds.size.width : _targetOffset);
            }
            
            [self setSwipeOffset:_targetOffset animated:YES completion:nil];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer == _panRecognizer) {
        
        if (self.isEditing) {
            return NO; //do not swipe while editing table
        }
        
        CGPoint translation = [_panRecognizer translationInView:self];
        if (fabs(translation.y) > fabs(translation.x)) {
            return NO; // user is scrolling vertically
        }
        if (_swipeView) {
            CGPoint point = [_tapRecognizer locationInView:_swipeView];
            if (!CGRectContainsPoint(_swipeView.bounds, point)) {
                return _allowsSwipeWhenTappingButtons; //user clicked outside the cell or in the buttons area
            }
        }
        
        if (_swipeOffset != 0.0) {
            return YES; //already swipped, don't need to check buttons or canSwipe delegate
        }
        
        //make a decision according to existing buttons or using the optional delegate
        if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCell:canSwipe:)]) {
            _allowSwipeLeftToRight = [_delegate swipeTableCell:self canSwipe:SKOneBoxSwipeDirectionLeftToRight];
            _allowSwipeRightToLeft = [_delegate swipeTableCell:self canSwipe:SKOneBoxSwipeDirectionRightToLeft];
        } else {
            [self fetchButtonsIfNeeded];
            _allowSwipeLeftToRight = _leftButtons.count > 0;
            _allowSwipeRightToLeft = _rightButtons.count > 0;
        }
        
        return (_allowSwipeLeftToRight && translation.x > 0) || (_allowSwipeRightToLeft && translation.x < 0);
    } else if (gestureRecognizer == _tapRecognizer) {
        CGPoint point = [_tapRecognizer locationInView:_swipeView];
        return CGRectContainsPoint(_swipeView.bounds, point);
    }
    
    return YES;
}

- (BOOL)isSwipeGestureActive {
    return _panRecognizer.state == UIGestureRecognizerStateBegan || _panRecognizer.state == UIGestureRecognizerStateChanged;
}

@end
