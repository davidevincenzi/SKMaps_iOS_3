//
//  SKOneBoxOrdering.m
//  SKOSearchLib
//
//  Created by Dragos Dobrean on 25/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxOrdering.h"
#import "SKOSearchLibUtils.h"
#import "SKOneBoxSearchResult+TableViewCellHelper.h"

#define kSKOneBoxOrderingDistanceKey                      @"kSKOneBoxFilterDistanceKey"
#define kSKOneBoxOrderingMajorCityWeight                  10.0
#define kSKOneBoxOrderingMajorCityMinimumWeight           0.5f
#define kSKOneBoxOrderingEpsilon                          0.000001

@interface SKOneBoxOrdering()

// An array which contains all the processed providers
@property (strong, nonatomic) NSMutableArray *processedProviders;

// An array which contains all the current oredered results
@property (strong, nonatomic) NSMutableDictionary *currentlyOrderedResults;

@end

@implementation SKOneBoxOrdering

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.processedProviders = [NSMutableArray new];
        self.currentlyOrderedResults = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma  mark - Public Methods

- (void)stopSearch {
    [self.processedProviders removeAllObjects];
    [self.currentlyOrderedResults removeAllObjects];
}

/** Order the results
 @param dictionaryToFilter - the dictionary of the results we need to filter
 @param seachObject - the search object used for filtering
 @param completitionBlock - the completition block with the results
 */
- (void)orderResultsFrom:(NSDictionary *)dictionaryToFilter withSearchObject:(SKOneBoxSearchObject *)searchObject completionBlock:(void (^)(NSDictionary *filteredDictionary))completionBlock {
    
    self.currentlyOrderedResults = [[NSMutableDictionary alloc] initWithDictionary:dictionaryToFilter];
    
    for (NSNumber *providerID in [dictionaryToFilter allKeys]) {
        
        if ([self providerAlreadyProcessed:providerID]) {
            // The provider was already processed, moving on to the next on
            continue;
        }
        
        NSArray *resultsForProvider = dictionaryToFilter[providerID];
        if (resultsForProvider.count == 0) {
            // If there are no results for provider continue
            continue;
        }
        
        // The provider was not processed, we have to process all the results
        for (SKOneBoxSearchResult *result in resultsForProvider) {
            
            //Compute the distance from the starting object
            double distance = [SKOSearchLibUtils getAirDistancePointA:result.coordinate pointB:searchObject.coordinate];
            distance = distance;
            
            if (result.additionalInformation) {
                NSMutableDictionary *additionalInfo = [[NSMutableDictionary alloc] initWithDictionary:result.additionalInformation];
                [additionalInfo setValue:@(distance) forKey:kSKOneBoxOrderingDistanceKey];
                
                [result setAdditionalInformation:additionalInfo];
            } else {
                NSDictionary *additionalInformation = [[NSMutableDictionary alloc] init];
                [additionalInformation setValue:@(distance) forKey:kSKOneBoxOrderingDistanceKey];
                [result setAdditionalInformation:additionalInformation];
            }
            
        }
        
        // Order the results by name and distance
        NSArray *sortedByName = [self orderResults:resultsForProvider byNameAndDistanceWithSearchObject:searchObject];
        
        [self.currentlyOrderedResults setObject:sortedByName forKey:providerID];
        
        [self.processedProviders addObject:providerID];
    }
    
    if (completionBlock) {
        completionBlock(self.currentlyOrderedResults);
    }
}

#pragma mark - Private Methods

// Checks if a provider was already processed
- (BOOL)providerAlreadyProcessed:(NSNumber *)provider {
    
    return [self.processedProviders containsObject:provider];
}

// Orders the results based on name and distance
- (NSArray *)orderResults:(NSArray *)results byNameAndDistanceWithSearchObject:(SKOneBoxSearchObject *)searchObject {
    
    // Contains the results and the weights for the current search provider results
    NSMutableDictionary *weights = [NSMutableDictionary new];
    // Construct the array by placing all the results at the weight key
    for (SKOneBoxSearchResult *result in results) {
        double weight;
        
        if ([result matchesSearchTerm:searchObject.searchTerm rankingWeight:&weight]) {
            [result setRelevancyType:SKOneBoxSearchResultHighRelevancy];
        }
        
        NSMutableArray *values = weights[@(weight)];
        if (!values) {
            values = [NSMutableArray new];
        }
        
        [result setNewRanking:weight];
        
        [values addObject:result];
        [weights setObject:values forKey:@(weight)];
    }
    
    // Order the keys
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedWeightsKeys = [weights.allKeys sortedArrayUsingDescriptors:sortDescriptors];
    
    // For the sorted keys take every value and add it to the sorted array
    NSMutableArray *sortedResults = [NSMutableArray new];
    for (int i = 0; i < sortedWeightsKeys.count; i++) {
        
        // Contains the current weight
        NSNumber *currentWeight = [sortedWeightsKeys objectAtIndex:i];
        
        // We have the results sorted by weights,
        // now we should sort them by distance
        NSArray *allResultsForKey = weights[currentWeight];
        
        NSArray *sortedByDistance = [allResultsForKey sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            SKOneBoxSearchResult *res1 = (SKOneBoxSearchResult *)obj1;
            SKOneBoxSearchResult *res2 = (SKOneBoxSearchResult *)obj2;
            
            NSNumber *distance1 = res1.additionalInformation[kSKOneBoxOrderingDistanceKey];
            NSNumber *distance2 = res2.additionalInformation[kSKOneBoxOrderingDistanceKey];
            
            return [distance1 compare:distance2];
        }];
        
        // For each result with the same weight give is a value which is between the
        // current weight and the next one,
        // the next weight is lower then the current one, as this
        // is an descending array of values
        NSNumber *nextWeight;
        if (i == sortedWeightsKeys.count - 1) {
            if ([currentWeight isEqual:@(0)]) {
                // If the current value is 0,
                // put the next value to -1 to have a correct range
                nextWeight = @(-1);
            } else {
                nextWeight = @(0);
            }
            
        } else {
            nextWeight = [sortedWeightsKeys objectAtIndex:(i + 1)];
        }
        
        double step = (currentWeight.doubleValue - nextWeight.doubleValue) / (sortedByDistance.count + 1);
        double currentValue = currentWeight.doubleValue;
        
        // The results are sorted by distance descendenting
        for (SKOneBoxSearchResult *result in sortedByDistance) {
            currentValue = currentValue - step;
            
            double newRanking = currentValue;
            
            // In case we are in [0;-1] range put the correct value
            if ((currentValue - 0.0) < kSKOneBoxOrderingEpsilon) {
                newRanking = -(1.0 + currentValue);
            }
            
            // If the result is a major city && term matches 50% in title we should increase
            // its weight, to be on top of the results
            
            double weight = [result rankingWeightTitleForSearchTerm:searchObject.searchTerm];
            
            if ([result isMajorCity] && weight >= kSKOneBoxOrderingMajorCityMinimumWeight) {
                newRanking += kSKOneBoxOrderingMajorCityWeight;
            }

            [result setNewRanking:newRanking];
        }
        
        // Add the results to the sorted array
        [sortedResults addObjectsFromArray:sortedByDistance];
    }
    
    NSLog(@"Ranking for results ________\n");
    for (SKOneBoxSearchResult *result in sortedResults) {
        NSNumber *val =  result.additionalInformation[@"ranking"];
        NSLog(@"%@ Ranking: %@, distance : %@",result.name, val, result.additionalInformation[kSKOneBoxOrderingDistanceKey]);
    }
    
    return sortedResults;
}


@end
