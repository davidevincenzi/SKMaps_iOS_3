//
//  SKOneBoxSearchResult.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOSearchResult.h"
#import "NSString+SKOneBoxStringAdditions.h"

@implementation SKOSearchResult

- (id)init {
    self = [super init];
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake(0, 0);
        self.name = @"";
        self.type = SKOSearchResultStreet;
    }
    return self;
}

+ (instancetype)searchResult {
    SKOSearchResult *searchResult = [[SKOSearchResult alloc] init];
    return searchResult;
}

@end
