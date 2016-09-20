//
//  SKTActionSheet.m
//  SDKTools
//

//

#import "SKTActionSheet.h"
#import "SKTNavigationConstants.h"

#define kButtonHeight ([UIDevice isiPad] ? 88.0 : 44.0)
#define kFontSize ([UIDevice isiPad] ? 40.0 : 20.0)

const CGFloat kButtonOpacity = 0.7;
const uint32_t kSheetBackGroundColor = 0x7f3f3f3f;

@interface SKTActionSheet ()

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation SKTActionSheet

- (id)initWithButtonTitles:(NSArray *)buttonTitles cancelButtonTitle:(NSString *)cancelButtonTitle {
    self = [super init];
    if (self) {
        _cancelButtonIndex = buttonTitles.count;
        [self createButtonsWithTitles:[buttonTitles arrayByAddingObject:cancelButtonTitle]];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
//        tapRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

#pragma mark - Factories

+ (instancetype)actionSheetWithButtonTitles:(NSArray *)buttonTitles cancelButtonTitle:(NSString *)cancelButtonTitle {
    SKTActionSheet *actionSheet = [[SKTActionSheet alloc] initWithButtonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle];
    return actionSheet;
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_buttons enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.frame = CGRectMake(0.0,
                                  self.frameHeight - kButtonHeight * (_buttons.count - idx) - (_buttons.count - idx) + 1.0,
                                  self.frameWidth,
                                  kButtonHeight);
    }];
}

#pragma mark - Public properties

- (void)showInView:(UIView *)view {
    self.frame = CGRectMake(0.0, view.frameHeight, view.frameWidth, view.frameHeight);
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.frameY = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = [UIColor colorWithHex:kSheetBackGroundColor];
        }];
    }];
}

- (void)dismiss {
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.3 animations:^{
        self.frameY = self.frameHeight;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dismissInstantly {
    [self removeFromSuperview];
}

#pragma mark - UI creation

- (void)createButtonsWithTitles:(NSArray *)titles {
    _buttons = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIColor *highlightColor = (idx == _cancelButtonIndex ? [UIColor colorWithHex:kSKTRedBackgroundColor] : [UIColor colorWithHex:kSKTBlueHighlightColor]);
        UIButton *button = [UIButton buttonWithFrame:CGRectZero
                                                icon:nil
                                     backgroundColor:[UIColor colorWithWhite:1.0 alpha:kButtonOpacity]
                           highligtedBackgroundColor:highlightColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitle:title forState:UIControlStateNormal];
        if (idx == _cancelButtonIndex) {
            button.titleLabel.font = [UIFont mediumNavigationFontWithSize:kFontSize];
        } else {
            button.titleLabel.font = [UIFont lightNavigationFontWithSize:kFontSize];
        }
        button.tag = idx;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [_buttons addObject:button];
    }];
}

#pragma mark - Actions

- (void)buttonClicked:(UIButton *)button {
    if (button.tag == _cancelButtonIndex) {
        if ([self.delegate respondsToSelector:@selector(actionSheetDidDismiss:)]) {
            [self.delegate actionSheetDidDismiss:self];
        } else {
            [self dismiss];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(actionSheet:didSelectButtonAtIndex:)]) {
            [self.delegate actionSheet:self didSelectButtonAtIndex:button.tag];
        }
    }
}

- (void)viewTapped {
    if ([self.delegate respondsToSelector:@selector(actionSheetDidDismiss:)]) {
        [self.delegate actionSheetDidDismiss:self];
    } else {
        [self dismiss];
    }
}

@end
