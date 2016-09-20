//
//  NSString+Additions.m
//  
//

//

#import "NSString+Additions.h"
#import <Foundation/Foundation.h>

@implementation NSString (Additions)

- (BOOL)isNotEmptyOrWhiteSpace {
    return ([self stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0);
}

- (BOOL)isEmptyOrWhiteSpace {
    return ([self stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0);
}

@end
