//
//  SKOneBoxFilterOperation.m
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxFilterOperation.h"
#import "SKSearchProviderProtocol.h"
#import "SKOBBox.h"
#import <SKOSearchLibUtils.h>

NSString *const kBBox = @"bbox";
NSString *const kProviders = @"providers";

@interface SKOneBoxFilterOperation ()

@property (nonatomic, assign) SKOneBoxSearchResultRelevancyType minimumRelevancyTypeAllowed;
@property (nonatomic, assign) int minimumProvidersForFiltering;
@property (nonatomic, assign) int clusterRadius;
@property (nonatomic, assign) int maxTopHits;
@property (nonatomic, strong) NSMutableDictionary *dictionaryToFilter;
@property (nonatomic, strong) SKOneBoxSearchObject *searchObject;
@property (nonatomic, copy) void (^completion)(SKOneBoxFilterOperation *filterOperation,NSDictionary *filteredDictionary);

@end

@implementation SKOneBoxFilterOperation

-(id)initWithMinimumRelevancyType:(SKOneBoxSearchResultRelevancyType)minimumRelevancyType minimumProviders:(int)minimumProviders searchObject:(SKOneBoxSearchObject*)searchObject dictionaryToFilter:(NSMutableDictionary*)dictionaryToFilter completionBlock:(void (^)(SKOneBoxFilterOperation *filterOperation,NSDictionary *filteredDictionary))completionBlock {
    self = [super init];
    if (self) {
        self.minimumRelevancyTypeAllowed = minimumRelevancyType;
        self.minimumProvidersForFiltering = minimumProviders;
        self.clusterRadius = [searchObject.radius intValue]/1000;
        self.dictionaryToFilter = dictionaryToFilter;
        self.completion = completionBlock;
        self.searchObject = searchObject;
        self.maxTopHits = 2;
    }
    return self;
}

-(void)main {
    NSMutableDictionary *dictionary = self.dictionaryToFilter;
    //get the first 2, numberOfResultsToShow
    NSMutableArray *topResults = [NSMutableArray array];
    NSMutableArray *clusters = [NSMutableArray array];
    int i = 0;
    if ([[dictionary allKeys] count] >= self.minimumProvidersForFiltering && self.minimumRelevancyTypeAllowed != SKOneBoxSearchResultLowRelevancy) {
        NSMutableArray *topResultsForProviders = [NSMutableArray array]; //first provider.numberOfResultsToShow of each provider
        NSMutableDictionary *allResults = [NSMutableDictionary dictionary]; //all the results from each provider
        for (NSNumber *providerId in [dictionary allKeys]) {
            NSArray *results = [dictionary objectForKey:providerId];
            if ([results count]) {
                //for filtering
                [allResults setObject:results forKey:providerId];
                
                //for top hits
                NSArray *subResults = [results subarrayWithRange:NSMakeRange(0, MIN(self.maxTopHits, [results count]))];
                [topResultsForProviders addObjectsFromArray:subResults];
            }
            i++;
        }
        
        //clustering, go through all results and create clusters of location
        /*
         p1 p2 p3
         1  4  1
         2  2  5
         3  5  2
         clusters
         11
         222
         55
         */
        for (NSNumber *providerId in [allResults allKeys]) {
            NSArray *results1 = [allResults objectForKey:providerId];
            for (SKOneBoxSearchResult *result1 in results1) {
                [result1 setTopResult:NO]; //reset top result
                
                [self addClusterForResult:result1 inArray:clusters provider:providerId];
                for (NSNumber *providerName2 in [allResults allKeys]) {
                    NSArray *results2 = [allResults objectForKey:providerName2];
                    if (results1 == results2) {
                        continue;
                    }
                    for (SKOneBoxSearchResult *result2 in results2) {
                        if ([self clusterResult:result2 inArray:clusters provider:providerName2]) {
                            break;
                        }
                        
                    }
                }
            }
        }
        
        
        //top result matching
        for (SKOneBoxSearchResult *result1 in topResultsForProviders) {
            for (SKOneBoxSearchResult *result2 in topResultsForProviders) {
                if (result1 == result2) {
                    continue;
                }
                if (![result1 isEqual:result2]) {
                    continue;
                }
                
                BOOL alreadyAdded = NO;
                for (NSArray *matchedResults in topResults) {
                    i++;
                    if ([matchedResults containsObject:result1] || [matchedResults containsObject:result2]) {
                        alreadyAdded = YES;
                        break;
                    }
                }
                if (!alreadyAdded) {
                    [topResults addObject:[NSArray arrayWithObjects:result1,result2, nil]];
                }
                i++;
            }
        }
        
        //NSLog(@"filtering number of iterations = %i",i);
        for (NSArray *results in topResults) {
            if ([results count] > 0) {
                SKOneBoxSearchResult *result = [results objectAtIndex:0];
                [result setTopResult:YES];
            }
        }
        
        [self setRelevancyForClusters:clusters results:allResults searchObject:self.searchObject];
    }    
    if (![self isCancelled]) {
        self.completion(self,dictionary);
    }

}

#pragma mark - Private

-(BOOL)clusterResult:(SKOneBoxSearchResult*)result inArray:(NSMutableArray*)clusters provider:(NSNumber*)provider{
    for (NSMutableDictionary *cluster in clusters) {
        SKOBBox *bbox = [cluster objectForKey:kBBox];
        NSMutableDictionary *providers = [[cluster objectForKey:kProviders] mutableCopy];
        
        if ([bbox containsLocation:result.coordinate]) {
            //we can cluster this result
            //try to get the array of clustered results for the provider
            if ([providers objectForKey:provider]) {
                //we have the provider
                NSArray *clusteredResultsForProvider = [providers objectForKey:provider];
                if (![clusteredResultsForProvider containsObject:result]) {
                    //add it to the current locations]
                    NSMutableArray *newLocations = [NSMutableArray arrayWithArray:clusteredResultsForProvider];
                    [newLocations addObject:result];
                    [providers setObject:newLocations forKey:provider];
                    [cluster setValue:providers forKey:kProviders];
                    return YES;
                }
            }
            else {
                //need to create a new dictionary for this provider and add the result
                NSArray *locations = [NSArray arrayWithObject:result];
                [providers setObject:locations forKey:provider];
                [cluster setValue:providers forKey:kProviders];
                return YES;
            }
        }
        
        
    }
    return NO;
}

-(void)addClusterForResult:(SKOneBoxSearchResult*)result inArray:(NSMutableArray*)clusters provider:(NSNumber*)providerId {
    BOOL found = NO;
    for (NSMutableDictionary *cluster in clusters) {
        SKOBBox *bbox = [cluster objectForKey:kBBox];
        if ([bbox containsLocation:result.coordinate]) {
            found = YES;
            break;
        }
    }
    
    if (!found) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSMutableArray arrayWithObject:result],providerId, nil];
        SKOBBox *bbox = [SKOBBox boundingBoxForCoordinate:result.coordinate radius:self.clusterRadius];
        NSMutableDictionary *newBBoxDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:bbox,kBBox,dict,kProviders, nil];
        [clusters addObject:newBBoxDict];
    }
}

-(NSComparisonResult)descendingComparisonResultBetweenFirst:(NSUInteger)first andSecond:(NSUInteger)second {
    if (first > second) {
        return (NSComparisonResult)NSOrderedAscending;
    } else if (first < second) {
        return (NSComparisonResult)NSOrderedDescending;
    } else {
        return (NSComparisonResult)NSOrderedSame;
    }
}

-(void)setRelevancyForClusters:(NSMutableArray*)clusters results:(NSMutableDictionary*)allResults searchObject:(SKOneBoxSearchObject*)searchObject {
    NSArray *sortedClusters = [clusters sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        //reversed, need to sort clusters based on the cluster with the biggest number of results from each provider
        NSDictionary *firstProviders = [obj1 objectForKey:kProviders];
        NSDictionary *secondProviders = [obj2 objectForKey:kProviders];
        
        NSUInteger first = [[firstProviders allKeys] count];
        NSUInteger second = [[secondProviders allKeys] count];
        
        NSUInteger firstResults = 0;
        NSUInteger secondResults = 0;
        
        if (first == second) {
            //separate based on the number of results from each
            //this might not be correct, foursquare might provide 20 results which are not at all related to the query, but found in the current area
            for (NSNumber *key in [firstProviders allKeys]) {
                NSArray *providerResults = [firstProviders objectForKey:key];
                firstResults += [providerResults count];
            }
            for (NSNumber *key in [secondProviders allKeys]) {
                NSArray *providerResults = [secondProviders objectForKey:key];
                secondResults += [providerResults count];
            }
            return [self descendingComparisonResultBetweenFirst:firstResults andSecond:secondResults];
        }
        else {
            //separate based on the unique providers results
            return [self descendingComparisonResultBetweenFirst:first andSecond:second];
        }
    }];
    
    NSUInteger bestCountCluster = 0;
    
    NSMutableArray *resultsSetRelevancy = [NSMutableArray array];
    
    SKOneBoxSearchResult *mostProbableLocation = nil;
    
    //get the best clusters
    for (NSDictionary *cluster in sortedClusters) {
        NSDictionary *providersDict = [cluster objectForKey:kProviders];
        
        BOOL isBestCluster = NO;
        
        NSArray *clusterProviders = [providersDict allKeys];
        
        if ([clusterProviders count] == 1) {
            continue; //only 1 cluster is not best cluster
        }
        if (bestCountCluster < [clusterProviders count]) {
            bestCountCluster = [clusterProviders count];
        }
        if ([clusterProviders count] == bestCountCluster) { //cluster 1 might be equal in size to another cluster
            isBestCluster = YES;
        }
        
        if (isBestCluster) {
            for (NSNumber *key in [providersDict allKeys]) {
                NSArray *clusterLocations = [providersDict objectForKey:key];
                for (SKOneBoxSearchResult *result in clusterLocations) {
                    if ([result hasLocationData] && !mostProbableLocation) {
                        mostProbableLocation = result;
                    }
                    
                    double rankingWeight = 0.0f;
                    
                    if ([result matchesSearchTerm:searchObject.searchTerm rankingWeight:&rankingWeight]) {
                        [result setRelevancyType:SKOneBoxSearchResultHighRelevancy];
                    }
                    else {
                        [result setRelevancyType:SKOneBoxSearchResultMediumRelevancy];
                    }
                    
                    [resultsSetRelevancy addObject:result];
                }
            }
        }
    }
    for (NSNumber *providerName in [allResults allKeys]) {
        NSArray *results = [allResults objectForKey:providerName];
        for (SKOneBoxSearchResult *result in results) {
            BOOL found = NO;
            for (SKOneBoxSearchResult *resultSetRelevancy in resultsSetRelevancy) {
                if (result == resultSetRelevancy) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                double rankingWeight = 0.0f;
                
                if ([result matchesSearchTerm:searchObject.searchTerm rankingWeight:&rankingWeight]) {
                    [result setRelevancyType:SKOneBoxSearchResultMediumRelevancy];
                }
                else {
                    [result setRelevancyType:SKOneBoxSearchResultLowRelevancy];
                }
            }
        }
    }
    
    if (mostProbableLocation) {
        //check distance between current search and most probable location found, should be higher than the radius
        const double distance = [SKOSearchLibUtils getAirDistancePointA:searchObject.coordinate pointB:mostProbableLocation.coordinate];
        if (distance > [searchObject.radius integerValue]) {
            self.foundProbableLocationBlock(mostProbableLocation);
        }
        else {
            self.foundProbableLocationBlock(nil);
        }
    }
}

@end
