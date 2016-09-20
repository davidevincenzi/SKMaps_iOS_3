//
//  SKOneBoxTestCaseResult.h
//  SKOneBoxSearch
//
//  Created by Dragos Dobrean on 18/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOneBoxTestCase.h"

@interface SKOneBoxTestCaseResult : NSObject

// Contains all the details for the old, correct test case
@property (strong, nonatomic) SKOneBoxTestCase *oldTestCase;

// Contains all the details for the newly computed results
@property (strong, nonatomic) SKOneBoxTestCase *latestTestCase;

// Will contain the accuracy of the test
@property (strong, nonatomic) NSNumber *accuracy;

- (instancetype)initWithOld:(SKOneBoxTestCase *)old andNew:(SKOneBoxTestCase *)testCase;

- (void)addMatchedResults:(NSArray *)results forProviderID:(NSNumber *)providerID;
- (void)addUnmatchedResults:(NSArray *)results forProviderID:(NSNumber *)providerID;
- (void)addNewResults:(NSArray *)results forProviderID:(NSNumber *)providerID;

- (NSDictionary *)allMatchedResults;
- (NSDictionary *)allUnmatchedResults;
- (NSDictionary *)allNewResults;

@end
