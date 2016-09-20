//
//  SKOneBoxBaseTableItem.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SKOneBoxBaseTableItem : NSObject

@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *rightAccesoryText;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL showTopSeparator; //for special items that need to be separated from the rest, eg. see all categories
@property (nonatomic, strong) void (^selectionBlock)();

@end
