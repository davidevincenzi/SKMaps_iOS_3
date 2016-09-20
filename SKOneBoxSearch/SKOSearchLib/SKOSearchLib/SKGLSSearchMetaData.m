//
//  SKGLSSearchMetaData.m
//  SKMaps
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOGLSSearchMetaData.h"

@implementation SKOGLSSearchMetaData

- (id)init {
    self = [super init];
    if (self) {
        self.page = 0;
        self.items = 0;
        self.total = 0;
    }
    return self;
}

+ (instancetype)glsSearchMetaData {
    SKOGLSSearchMetaData *glsSearchMetaData = [[SKOGLSSearchMetaData alloc] init];
    return glsSearchMetaData;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setPage:self.page];
        [copy setItems:self.items];
        [copy setTotal:self.total];
    }
    
    return copy;
}

@end
