//
//  SKOneBoxTestCaseResult.m
//  SKOneBoxSearch
//
//  Created by Dragos Dobrean on 18/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxTestCaseResult.h"

@interface SKOneBoxTestCaseResult()
// An dictionary which contains all the matched results for each provider
@property (strong, nonatomic) NSMutableDictionary *matchedResults;

// An dictionary which contains all unmatched results for each provider
@property (strong, nonatomic) NSMutableDictionary *unmatchedResuts;

// An dictionary which contains all the new results for each provider
@property (strong, nonatomic) NSMutableDictionary *mNewResults;

@end

@implementation SKOneBoxTestCaseResult

#pragma mark - Lifecycle

- (instancetype)initWithOld:(SKOneBoxTestCase *)old andNew:(SKOneBoxTestCase *)new {
    self = [super init];
    
    if (self) {
        self.oldTestCase = old;
        self.latestTestCase = new;
        self.matchedResults = [NSMutableDictionary new];
        self.unmatchedResuts = [NSMutableDictionary new];
        self.mNewResults = [NSMutableDictionary new];
        self.accuracy = @(0);
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)addMatchedResults:(NSArray *)results forProviderID:(NSNumber *)providerID {
    [self.matchedResults setObject:results forKey:providerID];
}

- (void)addUnmatchedResults:(NSArray *)results forProviderID:(NSNumber *)providerID {
    [self.unmatchedResuts setObject:results forKey:providerID];
}

- (void)addNewResults:(NSArray *)results forProviderID:(NSNumber *)providerID {
    [self.mNewResults setObject:results forKey:providerID];
}

- (NSDictionary *)allMatchedResults {
    return self.matchedResults;
}

- (NSDictionary *)allUnmatchedResults {
    return self.unmatchedResuts;
}

- (NSDictionary *)allNewResults {
    return self.mNewResults;
}

@end
