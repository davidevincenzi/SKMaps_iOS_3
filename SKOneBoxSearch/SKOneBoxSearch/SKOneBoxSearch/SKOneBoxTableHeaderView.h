//
//  SKOneBoxTableHeaderView.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 16/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKOneBoxTableHeaderView : UIView

@property (nonatomic, strong, readonly) NSArray *buttons;

-(id)initWithFrame:(CGRect)frame andButtonsArray:(NSArray*)buttons;

@end
