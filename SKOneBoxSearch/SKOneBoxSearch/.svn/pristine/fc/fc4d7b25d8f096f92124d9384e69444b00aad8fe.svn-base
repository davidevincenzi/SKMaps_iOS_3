//
//  SKOneBoxFilteringAlgorithmTester.h
//  SKOneBoxSearch
//
//  Created by Dragos Dobrean on 15/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOneBoxTestCase.h"
#import "SKOneBoxTestCaseResult.h"

@class SKOneBoxFilteringAlgorithmTester;
@protocol SKOneBoxFilteringAlgorithmTesterDataProvider <NSObject>

/** Method called by filtering algorithm tester to
 fetch an SKOneBoxTestCase, it should return an object that contains
 all the results for the search object provided in order to
 compare the results with the correct ones
 */
- (SKOneBoxTestCase *)fiteringAlgorithmTester:(SKOneBoxFilteringAlgorithmTester *)tester getTestCaseForSearchObject:(SKOneBoxSearchObject *)searchObject;

@end

@protocol SKOneBoxFilteringAlgorithmTesterDelegate <NSObject>

/** Method called by filtering algorithm tester
 when the testing is finished, and provides all the testing results
 @param testResults - contains objects of type SKOneBoxTestCaseResult, obtained after the algorithm
 */
- (void)fiteringAlgorithmTester:(SKOneBoxFilteringAlgorithmTester *)tester hasFinishedWithTestResults:(NSArray *)testResults;

@end

/** Tests the filtering algorthm for one box search
 */
@interface SKOneBoxFilteringAlgorithmTester : NSObject

@property (weak, nonatomic) id<SKOneBoxFilteringAlgorithmTesterDelegate> delegate;

/** Initiate the object with the file paths
 of the json files which contain the correct results
 @param - filePaths contains objects of NSString * type
 */
- (instancetype)initWithCorrectResultsFilePaths:(NSArray *)filePaths andSearchDataProvider:(id<SKOneBoxFilteringAlgorithmTesterDataProvider>)searchDataProvider;

/** Starts the testing process 
 and returns a percent of the result and calls the delegate
 with the results
 */
- (double)testAccuracy;

@end
