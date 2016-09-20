//
//  SKSearchProviderCategory.m
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKSearchProviderCategory.h"

@implementation SKSearchProviderCategory

#pragma mark - Other

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToCategory:object];
}

-(BOOL)isEqualToCategory:(SKSearchProviderCategory*)object {
    return [self.localizedCategoryName isEqualToString:object.localizedCategoryName] && [self.categorySearchType isEqual:object.categorySearchType] && self.isMainCategory == object.isMainCategory;
}

@end
