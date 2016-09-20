//
//  SKOneBoxFilteringAlgorithmTester.m
//  SKOneBoxSearch
//
//  Created by Dragos Dobrean on 15/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxFilteringAlgorithmTester.h"

@interface SKOneBoxFilteringAlgorithmTester()
// An array of names of the JSON files which contain the data for which the tests should be run
@property (strong, nonatomic) NSArray *correctResultsJSONNamesPaths;

// An array of SKOneBoxTestCase which contains the correct results
@property (strong, nonatomic) NSMutableArray *correctResults;

// An array of SKOneBoxTestCase whith the test data
@property (strong, nonatomic) NSMutableArray *testData;

// Contains all the results for each test case
@property (strong, nonatomic) NSMutableArray *testResults;

// The the provider of the new results for the search terms
@property (weak, nonatomic) id<SKOneBoxFilteringAlgorithmTesterDataProvider> searchDataProvider;

@end

@implementation SKOneBoxFilteringAlgorithmTester

#pragma mark - Lifestyle

- (instancetype)initWithCorrectResultsFilePaths:(NSArray *)filePaths andSearchDataProvider:(id<SKOneBoxFilteringAlgorithmTesterDataProvider>)searchDataProvider {
    self = [super init];
    if (self) {
        self.correctResultsJSONNamesPaths = filePaths;
        self.correctResults = [NSMutableArray new];
        self.testData = [NSMutableArray new];
        self.testResults = [NSMutableArray new];
        self.searchDataProvider = searchDataProvider;
        
        // Load the correct results;
        [self loadTheJSONFiles];
    }
    
    return self;
}

#pragma mark - Public Methods

- (double)testAccuracy {
    // If the data provider is not set do not start the testing
    if (self.searchDataProvider) {
        self.testResults = [NSMutableArray new];
        [self loadTestData];
        
        return [self compareResults];
    }
    
    return 0.0;
}

#pragma mark - Private Methods

/** Populates the corect test cases with the content from the file
 paths provided at the initialization of the object
 */
- (void)loadTheJSONFiles {
    for (NSString *filePath in self.correctResultsJSONNamesPaths) {
        NSError *error = nil;
        NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
       
        if (error) {
            // The file path is not correct
            NSLog(@"Could not read the file from the path:%@", filePath);
            continue;
        }
        
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
        
        if (error) {
            // Coult not parse the file as JSON;
            NSLog(@"JSON Data at file path:%@ is corrupt!", filePath);
            continue;
        }
        
        // Create an test case from the dictionary
        SKOneBoxTestCase *test = [[SKOneBoxTestCase alloc] initFromJSONDictionary:jsonDictionary];
        
        // Add it to the correct results
        [self.correctResults addObject:test];
    }
}

/** Makes searches for all the correct results and stores the results
 */
- (void)loadTestData {
    [self.testData removeAllObjects];
    
    // For every correct search result, launch a new search and fetch the actuall results
    // add those values to the test data
    for (SKOneBoxTestCase *testCase in self.correctResults) {
        SKOneBoxTestCase *resultForTest = [self.searchDataProvider fiteringAlgorithmTester:self getTestCaseForSearchObject:testCase.searchObject];
        
        [self.testData addObject:resultForTest];
    }
}

/** Compares the new results with the correct ones
 */
- (double)compareResults {
    double totalMatchingPercentage = 0;
    
    for (int index = 0; index < self.correctResults.count; index++) {
        // Compares the results
        SKOneBoxTestCase *correct = self.correctResults[index];
        SKOneBoxTestCase *new = self.testData[index];
        
        double matchingPercentage = [self compareAndGetPercent:correct to:new];
        totalMatchingPercentage += matchingPercentage;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fiteringAlgorithmTester:hasFinishedWithTestResults:)]) {
        [self.delegate fiteringAlgorithmTester:self hasFinishedWithTestResults:[self.testResults copy]];
    }
    
    return totalMatchingPercentage / self.correctResults.count;
}

/** Compares two test cases
 @return - returns a value between 0 and 1 where 0 is worst and 1 the best
 */
- (double)compareAndGetPercent:(SKOneBoxTestCase *)old to:(SKOneBoxTestCase *)new {

    SKOneBoxTestCaseResult *testResult = [[SKOneBoxTestCaseResult alloc] initWithOld:old andNew:new];
    
    double noMatchedResults = 0;
    double noTotalResults = 0;
    double noNewResults = 0;
    
    // Get all the results for each provider
    // We should have the same number of providers
    for (NSNumber *providerID in old.allResults.allKeys) {
        NSMutableArray *oldUnmatchedResults = [NSMutableArray new];
        NSMutableArray *matchedResults = [NSMutableArray new];
        NSMutableArray *newMatchedResults = [NSMutableArray new];
        
        NSArray *oldResults = old.allResults[providerID];
        NSArray *newResults = new.allResults[providerID];
        
        // Compare all the old results against the new ones
        for (SKOneBoxSearchResult *result in oldResults) {
            noTotalResults++;
            
            if ([self does:newResults containsSearchResult:result]) {
                // The results matched exits in the list
                [matchedResults addObject:result];
                noMatchedResults++;
            } else {
                // The result does not exist
                [oldUnmatchedResults addObject:result];
            }
        }
        
        // Compare the new results agains the old ones in
        // order to obtain the new results
        for (SKOneBoxSearchResult *newResult in newResults) {
            // If the new result is not in the old ones
            // its a newly discovered result
            if (![self does:oldResults containsSearchResult:newResult]) {
                [newMatchedResults addObject:newResult];
                noNewResults++;
            }
        }
        
        // Add the results to the test result object
        [testResult addMatchedResults:matchedResults forProviderID:providerID];
        [testResult addUnmatchedResults:oldUnmatchedResults forProviderID:providerID];
        [testResult addNewResults:newMatchedResults forProviderID:providerID];
    }
    
    // Compute the matched percentage (value between 0 and 1)
    double comparisionPercentage = noMatchedResults / noTotalResults;
    testResult.accuracy = @(comparisionPercentage);
    
    // Add the results for the current test to all results
    [self.testResults addObject:testResult];
    
    return comparisionPercentage;
}

- (BOOL)does:(NSArray *)array containsSearchResult:(SKOneBoxSearchResult *)result {
    for (SKOneBoxSearchResult *old in array) {
        if ([self is:old equalTo:result]) {
            return YES;
        }
    }
    
    return NO;
}

/** Checks if two search results are equal
 */
- (BOOL)is:(SKOneBoxSearchResult *)first equalTo:(SKOneBoxSearchResult *)second {
    if (![first.name isEqualToString:second.name]) {
        return NO;
    }
    
    if (![self isSameLocation:first.coordinate asLocation:second.coordinate]) {
        return NO;
    }
    
    return YES;
}

/** Checks if two locations are the same
 */
- (BOOL)isSameLocation:(CLLocationCoordinate2D)firstLocation asLocation:(CLLocationCoordinate2D)secondLocation {
    double epsilon = 0.001;//up to 110m
    double latitudeDifference = fabs(firstLocation.latitude - secondLocation.latitude);
    double longitudeDifference = fabs(firstLocation.longitude - secondLocation.longitude);
    
    BOOL returnVal = latitudeDifference <= epsilon && longitudeDifference <= epsilon;
    return returnVal;
}

@end
