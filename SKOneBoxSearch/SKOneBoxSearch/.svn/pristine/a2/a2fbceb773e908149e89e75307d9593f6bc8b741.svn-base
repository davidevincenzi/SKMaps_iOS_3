//
//  SKOneBoxUITextField.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxUITextField.h"

@interface SKOneBoxUITextField ()
@property (nonatomic, assign) CGPoint inset;
@property (nonatomic, assign) CGFloat rightViewWidth;
@end

@implementation SKOneBoxUITextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rightViewWidth = 0.0;
    }
    return self;
}

- (void)setInsetText:(CGPoint)inset {
    _inset = inset;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {

    CGRect newSize;
    if (bounds.size.width > self.rightViewWidth && self.rightViewWidth > 0.0) {
        newSize = CGRectMake(bounds.origin.x + self.inset.x, bounds.origin.y + self.inset.y, bounds.size.width - self.rightViewWidth - + self.inset.x, bounds.size.height - self.inset.y);
    } else {
        newSize = CGRectInset(bounds, self.inset.x, self.inset.y);
    }
   
    return newSize;
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect newSize;
    if (bounds.size.width > self.rightViewWidth && self.rightViewWidth > 0.0)  {
        newSize = CGRectMake(bounds.origin.x + self.inset.x, bounds.origin.y + self.inset.y, bounds.size.width - self.rightViewWidth - + self.inset.x, bounds.size.height - self.inset.y);
    } else {
        newSize = CGRectInset(bounds, self.inset.x, self.inset.y);
    }
    
    return newSize;
}

- (void)setRightView:(UIView *)rightView {
    [super setRightView:rightView];
    
    self.rightViewWidth = rightView.frame.size.width;
}

@end
