//
//  UIViewController+SKOneBoxNavigationTitle.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "UIViewController+SKOneBoxNavigationTitle.h"

@implementation UIViewController (SKOneBoxNavigationTitle)

-(UIView*)titleViewWithText:(NSAttributedString*)text {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationController.navigationBar.frame), CGRectGetHeight(self.navigationController.navigationBar.frame))];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] initWithFrame:titleView.frame];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [label setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:label];
    
    [label setAttributedText:text];
    
    return titleView;
}

@end
