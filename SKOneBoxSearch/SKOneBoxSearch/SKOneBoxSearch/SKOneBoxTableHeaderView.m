//
//  SKOneBoxTableHeaderView.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 16/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxTableHeaderView.h"
#import "UIColor+SKOneBoxColors.h"

@interface SKOneBoxTableHeaderView ()
@property (nonatomic, strong, readwrite) NSArray *buttons;
@end

@implementation SKOneBoxTableHeaderView

-(id)initWithFrame:(CGRect)frame andButtonsArray:(NSArray*)buttons {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.buttons = buttons;
        
        for (UIButton *button in buttons) {
            [self addSubview:button];
        }
        
        self.backgroundColor = [UIColor hexF3F3F3];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width/self.buttons.count;
    
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *button = [self.buttons objectAtIndex:i];
        
        [button setFrame:CGRectMake(width*i, 0, width, self.frame.size.height)];
    }
}

@end
