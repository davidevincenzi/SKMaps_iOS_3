//
//  SKOneBoxFilter.m
//  SKOSearchLib
//
//  Created by Dragos Dobrean on 06/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxFilter.h"
#import "SKOneBoxSearchCluster.h"
#import "SKOSearchLibUtils.h"
#import "SKOneBoxSearchResult+TableViewCellHelper.h"

#define kSKOneBoxFilterAverageDistanceThreashold        50.0 //50 km
#define kSKOneBoxFilterDistanceKey                      @"kSKOneBoxFilterDistanceKey"
#define kSKOneBoxFilterOSMProviderKey                   1
#define kSKOneBoxFilterEpsilon                          0.00001

@interface SKOneBoxFilter()

// The current clusters
@property (strong, atomic) NSMutableArray *clusters;

// The processed providers (the ones that returned at least a search result)
@property (strong, atomic) NSMutableArray *processedProviders;

// The currently filtered result list
@property (strong, atomic) NSMutableDictionary *currentFilteredResults;

// The radius used for the clusters
@property (assign, atomic) int radius;

// All the providers keys
@property (strong, atomic) NSArray *allProvidersKeys;

// Contains the sorted clusters
@property (strong, atomic) NSMutableArray *sortedClusters;

// Sum of distances between the results and the search object location
@property (assign, atomic) double sumOfDistances;

// Number of results in all clusters
@property (assign, atomic) int numberOfResults;

// Indicates that a probable location was found
@property (assign, atomic) BOOL probableLocationFound;

// Probable location
@property (strong, atomic) SKOneBoxSearchResult *probableLocation;

// Current dictionary to filter
@property (strong, atomic) NSDictionary *currentDictionaryToFilter;

// Autocomplete, other results with 0,0 coords
@property (strong, atomic) NSMutableDictionary *notToFilteredResults;

@end

@implementation SKOneBoxFilter

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.clusters = [NSMutableArray new];
        self.processedProviders = [NSMutableArray new];
        self.currentFilteredResults = [NSMutableDictionary new];
        self.sortedClusters = [NSMutableArray new];
        self.radius = 150;
        self.sumOfDistances = 0;
        self.numberOfResults = 0;
        self.allProvidersKeys = nil;
        self.currentDictionaryToFilter = nil;
        self.notToFilteredResults = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Public Methods

/** Resets all the clusters
 Prepares the object for a new search
 */

- (void)resetClusters {
    [self.clusters removeAllObjects];
    [self.processedProviders removeAllObjects];
    [self.currentFilteredResults removeAllObjects];
    [self.sortedClusters removeAllObjects];
    [self.notToFilteredResults removeAllObjects];
    self.allProvidersKeys = nil;
    self.sumOfDistances = 0;
    self.numberOfResults = 0;
    self.probableLocationFound = NO;
    self.probableLocation = nil;
    self.radius = 150;
    self.currentDictionaryToFilter = nil;
}

- (void)setClustersRadius:(SKOneBoxSearchObject *)searchObject {
    self.radius = 2 * [searchObject.radius intValue]/1000;
}

- (void)filterTheResultsFrom:(NSDictionary *)dictionaryToFilter withSearchObject:(SKOneBoxSearchObject *)searchObject completionBlock:(void (^)(NSDictionary *filteredDictionary))completionBlock andProbableLocationBlock:(void(^)(SKOneBoxSearchResult *probableLocation))probableLocationBlock {
    
    self.currentDictionaryToFilter = dictionaryToFilter;
    
    if (!self.allProvidersKeys) {
        self.allProvidersKeys = [[NSArray alloc] initWithArray:[dictionaryToFilter allKeys]];
    }
    
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
        
        if ([providerID isEqual:@2]) { //make somethign better
            self.notToFilteredResults[providerID] = resultsForProvider;
            continue;
        }
        
        // The provider was not processed, we have to process all the results
        for (SKOneBoxSearchResult *result in resultsForProvider) {
            // Fetch the cluster for the location of the result
            SKOneBoxSearchCluster *cluster = [self clusterForLocation:result.coordinate];
            
            [cluster addResult:result fromProviderID:providerID];
            
            //Compute the distance from the starting object
            double distance = [SKOSearchLibUtils getAirDistancePointA:result.coordinate pointB:searchObject.coordinate];
            distance = distance / 1000;
            
            self.sumOfDistances += distance;
            self.numberOfResults++;
            
            if (result.additionalInformation) {
                NSMutableDictionary *additionalInfo = [[NSMutableDictionary alloc] initWithDictionary:result.additionalInformation];
                [additionalInfo setValue:@(distance) forKey:kSKOneBoxFilterDistanceKey];
                
                [result setAdditionalInformation:additionalInfo];
            } else {
                NSDictionary *additionalInformation = [[NSMutableDictionary alloc] init];
                [additionalInformation setValue:@(distance) forKey:kSKOneBoxFilterDistanceKey];
                [result setAdditionalInformation:additionalInformation];
            }
            
        }
        
        [self.processedProviders addObject:providerID];
    }
    
    // Check periodically if the thread is canceled
    [self checkIfThreadIsCanceledAndExit];
    
    // Here we have added all the results to the clusters, we have to rank the clusters now
    [self rankTheCurrentClusters];
    
    // Find the most probable location if there is any
    [self searchForMostProbableLocationWithSearchObject:searchObject andLocationBlock:probableLocationBlock];
    
    // Check periodically if the thread is canceled
    [self checkIfThreadIsCanceledAndExit];
    
    // Remove the incorrect results from the cluster
    [self removeIncorrectResultsWithSearchObject:searchObject];
    
    // Set the order of the results
//    [self orderResultsByWeight:searchObject];
    
    // Check periodically if the thread is canceled
    [self checkIfThreadIsCanceledAndExit];
    
    // Add the results which were not filtered
    [self addNotFilteredResults];
    
    // Call the completition block
    if (completionBlock) {
        completionBlock([self.currentFilteredResults copy]);
    }
}

#pragma mark - Private Methods

// Adds the results which were not filtered
// eq. from recents, favorites
-(void)addNotFilteredResults {
    for (NSNumber *providerID in [self.notToFilteredResults allKeys]) {
        
        NSArray *resultsForProvider = self.notToFilteredResults[providerID];
        if (resultsForProvider.count == 0) {
            // If there are no results for provider continue
            continue;
        }
        
        NSMutableArray *results = self.currentFilteredResults[providerID];
        if (!results) {
            results = [NSMutableArray array];
        }
        
        for (SKOneBoxSearchResult *result in resultsForProvider) {
            [results addObject:result];
        }
        
        self.currentFilteredResults[providerID] = results;
    }
}

/**Checks if the current thread is canceled, if so it exits.
 */
- (void)checkIfThreadIsCanceledAndExit {
    if ([[NSThread currentThread] isCancelled]) {
        [NSThread exit];
    }
}

// Checks if a provider was already processed
- (BOOL)providerAlreadyProcessed:(NSNumber *)provider {
    
    return [self.processedProviders containsObject:provider];
}

- (SKOneBoxSearchCluster *)clusterForLocation:(CLLocationCoordinate2D)location {
    for (SKOneBoxSearchCluster *cluster in self.clusters) {
        if ([cluster containsCoordinate:location]) {
            return cluster;
        }
    }
    
    // This means the cluster was not created, so we create a new one
    SKOneBoxSearchCluster *newCluster = [[SKOneBoxSearchCluster alloc] initWithCoordinate:location andRadius:self.radius];
    [self.clusters addObject:newCluster];
    
    return newCluster;
}

- (void)searchForMostProbableLocationWithSearchObject:(SKOneBoxSearchObject *)searchObject andLocationBlock:(void(^)(SKOneBoxSearchResult *probableLocation))probableLocationBlock {
    // Find the most probable location if there is any
    SKOneBoxSearchResult *mostProbableLocation = [self findMostProbableLocation];
    
    if (mostProbableLocation) {
        //check distance between current search and most probable location found, should be higher than the radius
        const double distance = [SKOSearchLibUtils getAirDistancePointA:searchObject.coordinate pointB:mostProbableLocation.coordinate];
        
        if (distance > [searchObject.radius integerValue]) {
            self.probableLocationFound = YES;
            self.probableLocation = mostProbableLocation;
            NSLog(@"Found most probable location");
            
            if (probableLocationBlock) {
                probableLocationBlock(mostProbableLocation);
            }
        }
    }
}

- (void)rankTheCurrentClusters {
    // Create an dictionary for sorting the keys are the weigth of the cluster, the value is the cluster
    NSMutableDictionary *mappedClusters = [NSMutableDictionary new];
    
    for (SKOneBoxSearchCluster *cluster in self.clusters) {
        NSNumber *weight = @([cluster weight]);
        
        NSMutableArray *clusters = mappedClusters[weight];
        if (!clusters) {
            clusters = [NSMutableArray new];
        }
        
        [clusters addObject:cluster];
        
        [mappedClusters setObject:clusters forKey:weight];
    }
    
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSArray *weights = [mappedClusters allKeys];
    
    weights = [weights sortedArrayUsingDescriptors:@[highestToLowest]];
    
    // Now we have the keys sorted, descendenting by the weight of the cluster
    // Construct the current search result array
    
    self.currentFilteredResults = [NSMutableDictionary new];
    
    for (NSNumber *providerID in self.processedProviders) {
        [self.currentFilteredResults setObject:[NSMutableArray new] forKey:providerID];
    }
    
    [self.sortedClusters removeAllObjects];
    
    for (NSNumber *weight in weights) {
        // Fetch the clusters for the current weight
        NSMutableArray *clustersForWeight = mappedClusters[weight];
        
        [self.sortedClusters addObjectsFromArray:clustersForWeight];
        
        // put the results from each cluster, to the final array
        for (SKOneBoxSearchCluster *cluster in clustersForWeight) {
            for (NSNumber *providerID in self.currentFilteredResults.allKeys) {
                
                NSMutableArray *results = self.currentFilteredResults[providerID];
                [results addObjectsFromArray:[cluster resultsForProvider:providerID]];
            }
        }
    }

    // Put empty arrays for the keys which were not processed yet
    for (NSNumber *providerKey in self.allProvidersKeys) {
        if (![self.currentFilteredResults.allKeys containsObject:providerKey]) {
            [self.currentFilteredResults setObject:[NSMutableArray new] forKey:providerKey];
        }
    }
}

- (SKOneBoxSearchResult *)findMostProbableLocation {
    if (!self.sortedClusters || self.sortedClusters.count == 0) {
        return nil;
    }
    
    // Fetch the one of the best clusters (there can be multiple with the same weight)
    SKOneBoxSearchCluster *oneOfTheBestClusters = self.sortedClusters[0];
    long bestClusterWeight = oneOfTheBestClusters.weight;
    
    for (SKOneBoxSearchResult *result in oneOfTheBestClusters.allResults) {
        if ([result hasLocationData]) {
            return result;
        }
    }
    
    // This means the results from the first cluster did not have the location data
    // We have to look on other clusters which have the same weight as the first one
    if (self.sortedClusters.count > 1) {
        for (int i = 1; i < self.sortedClusters.count; i++) {
            SKOneBoxSearchCluster *cluster = self.sortedClusters[i];
            
            // If the weight is lower then the weight for the best cluster return
            if (cluster.weight < bestClusterWeight) {
                return nil;
            }
            
            // Otherwise look trough the results to find the first one with a location
            for (SKOneBoxSearchResult *result in cluster.allResults) {
                if ([result hasLocationData]) {
                    return result;
                }
            }
        }
    }
    
    return nil;
}

- (double)averageDistance {
    return self.sumOfDistances / self.numberOfResults;
}

// Gets the average distance from the clusters which
// have their distance from the search place
// lower then the average distance of the clusters
- (double)averageDistanceForTopClusters {
    double averageDistanceBetweenClusters = [self averageDistanceBetweenClusters];
    if (averageDistanceBetweenClusters == 0 || self.clusters.count == 0) {
        return 0;
    }
    
    double sumOfResultsDistances = 0;
    double numberOfTopClusters = 0;
    
    for (SKOneBoxSearchCluster *cluster in self.sortedClusters) {
        SKOneBoxSearchResult *result = cluster.allResults[0];
        NSNumber *distance = result.additionalInformation[kSKOneBoxFilterDistanceKey];
        
        if ((averageDistanceBetweenClusters - distance.doubleValue) > kSKOneBoxFilterEpsilon) {
            sumOfResultsDistances += distance.doubleValue;
            numberOfTopClusters++;
        }
    }
    
    return sumOfResultsDistances / numberOfTopClusters;
}

// Gets the average distance between clusters
- (double)averageDistanceBetweenClusters {
    if (!self.clusters || self.clusters.count == 0) {
        return 0.0;
    }
    
    double sumOfClusterDistances = 0;
    
    for (SKOneBoxSearchCluster *cluster in self.clusters) {
        // Get a result from the cluster
        SKOneBoxSearchResult *result = cluster.allResults[0];
        NSNumber *distance = result.additionalInformation[kSKOneBoxFilterDistanceKey];
        sumOfClusterDistances += distance.doubleValue;
    }
    
    return sumOfClusterDistances / self.clusters.count;
}

- (SKOneBoxSearchResult *)findBestResultWithPositiveDistance {
    for (SKOneBoxSearchCluster *cluster in self.sortedClusters) {
        for (SKOneBoxSearchResult *result in cluster.allResults) {
            NSNumber *distance = result.additionalInformation[kSKOneBoxFilterDistanceKey];
            if (distance.intValue >= 0) {
                return result;
            }
        }
    }
    
    return nil;
}

- (void)removeIncorrectResultsWithSearchObject:(SKOneBoxSearchObject *)searchObject {
    // See how many providers we have, if only one provider, we are offline, don't filter
    
    if (self.processedProviders.count > 2) {
        // Removes the results with a greater distance then the average one
        [self removeResultsWithGreaterDistanceWithSearchObject:searchObject];
        
        // Remove results which do not match the term in quotes
        [self removeResultsWhichDoNotMatchQuoteString:searchObject];
    }
}

- (BOOL)isSeachResult:(SKOneBoxSearchResult *)result majorCity:(SKOneBoxSearchObject *)searchObject {
    if ([result isMajorCity]) {
        return YES;
    }
    
    // replace all the diacritical letters
    NSString *resultTitle = [result.title stringByFoldingWithOptions: NSDiacriticInsensitiveSearch locale: [NSLocale localeWithLocaleIdentifier: @"en_GB"]];
    if ([resultTitle.lowercaseString isEqualToString:searchObject.searchTerm.lowercaseString]){
        return YES;
    }

    return NO;
    
}

- (BOOL)isMajorLocation:(CLLocationCoordinate2D)coordinate1 theSameAs:(CLLocationCoordinate2D)coordinate2 {
    //this gives 10000m precision
    double epsilon = 0.01000;
    
    return fabs(coordinate1.latitude - coordinate2.latitude) <= epsilon && fabs(coordinate1.longitude - coordinate2.longitude) <= epsilon;
}

- (void)orderResultsByWeight:(SKOneBoxSearchObject *)searchObject {
    for (NSNumber *providerID in self.currentFilteredResults.allKeys) {
        NSMutableArray *results = self.currentFilteredResults[providerID];
        
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
        for (NSNumber *key in sortedWeightsKeys) {
            // We have the results sorted by weights,
            // now we should sort them by distance
            
            NSArray *allResultsForKey = weights[key];
            
            NSArray *sortedByName = [allResultsForKey sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                SKOneBoxSearchResult *res1 = (SKOneBoxSearchResult *)obj1;
                SKOneBoxSearchResult *res2 = (SKOneBoxSearchResult *)obj2;
                
                NSNumber *distance1 = res1.additionalInformation[kSKOneBoxFilterDistanceKey];
                NSNumber *distance2 = res2.additionalInformation[kSKOneBoxFilterDistanceKey];
                
                return [distance2 compare:distance1];
            }];
            
            // Add the results to the sorted array
            [sortedResults addObjectsFromArray:sortedByName];
        }
        
        [self.currentFilteredResults setObject:sortedResults forKey:providerID];
    }
}

#pragma mark - Removal of the results

/** Removes the results with an distance greater then average
 It only removes the results if average distance is greater then provided threashold,
 and if a probable location was not found
 */
- (void)removeResultsWithGreaterDistanceWithSearchObject:(SKOneBoxSearchObject *)searchObject {
    // Get the a search result from the best cluster
    if (!self.sortedClusters || self.sortedClusters.count <= 0) {
        return;
    }
    
    SKOneBoxSearchResult *bestResult = [self findBestResultWithPositiveDistance];
    if (!bestResult) {
        return;
    }
    
    // We have the best distance
    for (NSNumber *providerID in self.currentFilteredResults.allKeys) {
        NSMutableArray *results = self.currentFilteredResults[providerID];
        
        NSMutableArray *itemsToRemove = [NSMutableArray new];
        
        for (SKOneBoxSearchResult *result in results) {
            NSNumber *distanceOfResult = result.additionalInformation[kSKOneBoxFilterDistanceKey];
            
            // This means we have results that are in another location than the searched one
            // We should also leave this results, eq: bar Berlin
            if ((distanceOfResult.doubleValue - kSKOneBoxFilterAverageDistanceThreashold) > kSKOneBoxFilterEpsilon) {
                double distanceBetweenBestResultAndCurrent = [SKOSearchLibUtils getAirDistancePointA:bestResult.coordinate pointB:result.coordinate];
                distanceBetweenBestResultAndCurrent = distanceBetweenBestResultAndCurrent / 1000;
                
                if ((kSKOneBoxFilterAverageDistanceThreashold - distanceBetweenBestResultAndCurrent) < kSKOneBoxFilterEpsilon) {
                    // if the distance between them is greater then the threashold remove the results
                    if (![self isSeachResult:result majorCity:searchObject]) {
                        [itemsToRemove addObject:result];
                        continue;
                    }
                }
                
            } else if ((distanceOfResult.doubleValue - [self averageDistanceForTopClusters]) > kSKOneBoxFilterEpsilon) {
                // Delete all the results that have their distace higher then the average distance nearby results
                
                if (![self isSeachResult:result majorCity:searchObject]) {
                    [itemsToRemove addObject:result];
                    continue;
                }
                
            }
            
            [result setRelevancyType:SKOneBoxSearchResultMediumRelevancy];
        }
        
        // Check periodically if the thread is canceled
        [self checkIfThreadIsCanceledAndExit];
        
//        [results removeObjectsInArray:itemsToRemove];
        [self.currentFilteredResults setObject:results forKey:providerID];
        
        for (SKOneBoxSearchResult *result in itemsToRemove) {
            [result setRelevancyType:SKOneBoxSearchResultLowRelevancy];
        }
    }

}

/** If the search term contains a term in "quotes" only search eliminate
 all the results which do not contain the term in quotes, or do not contain the search result
 */
- (void)removeResultsWhichDoNotMatchQuoteString:(SKOneBoxSearchObject *)searchObject {
    for (NSNumber *providerID in self.currentFilteredResults.allKeys) {
        NSMutableArray *results = self.currentFilteredResults[providerID];
        NSMutableSet *itemsToRemove = [NSMutableSet new];
        
        for (SKOneBoxSearchResult *result in results) {
            if (searchObject.quoteString && searchObject.quoteString.length >= 1) {
                if (![result.name containsString:searchObject.quoteString]) {
                    // If the result does not contain the quoted string in the name, remove it
                    [itemsToRemove addObject:result];
                }
            }
        }
        
        // Check periodically if the thread is canceled
        [self checkIfThreadIsCanceledAndExit];
        
//        [results removeObjectsInArray:[itemsToRemove allObjects]];
        
        for (SKOneBoxSearchResult *result in itemsToRemove) {
            [result setRelevancyType:SKOneBoxSearchResultLowRelevancy];
        }
    }
}

@end
