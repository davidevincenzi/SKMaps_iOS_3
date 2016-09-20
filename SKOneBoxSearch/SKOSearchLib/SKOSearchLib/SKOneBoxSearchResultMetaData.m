//
//  SKOneBoxSearchResultMetaData.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchResultMetaData.h"

@implementation SKOneBoxSearchResultMetaData

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.items = 0;
        self.total = 0;
    }
    return self;
}

+ (instancetype)oneBoxSearchMetaData {
    SKOneBoxSearchResultMetaData *oneBoxSearchMetaData = [[SKOneBoxSearchResultMetaData alloc] init];
    return oneBoxSearchMetaData;
}

#pragma mark - Public

-(BOOL)hasMoreResults {
    if (self.total > 0 && self.items > 0) {
        float result = (float)self.total/(float)self.items;
        return  result > self.page;
    }
    else {
        return (self.hasMore && self.nextPage);
    }
    
    return NO;
}

@end
