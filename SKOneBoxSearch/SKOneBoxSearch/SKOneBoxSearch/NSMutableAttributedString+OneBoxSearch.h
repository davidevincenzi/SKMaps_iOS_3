//
//  NSMutableAttributedString+OneBoxSearch.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (OneBoxSearch)

+ (NSMutableAttributedString*)attributedText:(NSString*)text highlightedText:(NSString*)highlightedText font:(UIFont*)font color:(UIColor*)color highlightedFont:(UIFont*)highlightedFont highlightedColor:(UIColor*)highlightedColor;

@end
