//
//  NSMutableAttributedString+OneBoxSearch.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "NSMutableAttributedString+OneBoxSearch.h"

@implementation NSMutableAttributedString (OneBoxSearch)

+ (NSMutableAttributedString*)attributedText:(NSString*)text highlightedText:(NSString*)highlightedText font:(UIFont*)font color:(UIColor*)color highlightedFont:(UIFont*)highlightedFont highlightedColor:(UIColor*)highlightedColor {
    if (![text length]) {
        text = @"";
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,text.length)];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0,text.length)];
    
    if ([highlightedText length]) {
        NSRange range = [[text lowercaseString] rangeOfString:[highlightedText lowercaseString]];
        if (range.location != NSNotFound) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:highlightedColor range:range];
            [attributedString addAttribute:NSFontAttributeName value:highlightedFont range:range];
        }
    }
    
    return attributedString;
}

@end
