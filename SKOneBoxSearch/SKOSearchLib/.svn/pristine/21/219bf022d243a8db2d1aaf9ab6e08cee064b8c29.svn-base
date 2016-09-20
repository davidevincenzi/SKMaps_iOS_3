//
//  SKOneBoxFilterController.m
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxFilterController.h"
#import "SKOneBoxFilterOperation.h"
#import "SKOneBoxFilter.h"
#import "SKOneBoxOrdering.h"
#import "SKOneBoxTopHit.h"

//a minimum of 2 providers needed for filtering
//still does not make sense if apple comes first and we match that with our results
int const kMinimumProvidersForFiltering = 3;

@interface SKOneBoxFilterController ()

/** The minimum relevancy type allowed.
 */
@property (nonatomic, assign) SKOneBoxSearchResultRelevancyType minimumRelevancyTypeAllowed;
@property (nonatomic, strong) SKOneBoxFilter    *filter;
@property (nonatomic, strong) SKOneBoxOrdering  *ordering;
@property (nonatomic, strong) SKOneBoxTopHit    *topHitMarker;

@property (nonatomic, strong) NSOperationQueue *filteringQueue;

@property (nonatomic, assign) BOOL clustersWereCleared;

@property (nonatomic, assign) int numberOfProvidersReceived;

@end

#pragma mark - Init

@implementation SKOneBoxFilterController

- (id)initWithMinimumRelevancy:(SKOneBoxSearchResultRelevancyType)relevancyType {
    self = [super init];
    if (self) {
        self.minimumRelevancyTypeAllowed = relevancyType;
        self.filter = [SKOneBoxFilter new];
        self.ordering = [SKOneBoxOrdering new];
        self.topHitMarker = [SKOneBoxTopHit new];
        
        self.clustersWereCleared = NO;
        self.filteringQueue = [[NSOperationQueue alloc] init];
        [self.filteringQueue setMaxConcurrentOperationCount:1];
        
        self.numberOfProvidersReceived = 0;

    }
    return self;
}

#pragma mark - Public

/**Relevancy type of the search result.
 If the search result is in the area of other search results from other providers -> SKOneBoxSearchResultHighRelevancy
 If the search result is not in the area of other search results from other providers, but the search term matches, and distance is not very far far away -> SKOneBoxSearchResultMediumRelevancy
 If the search result is not in the area of other search results from other providers, doesn't match the search term and distance is far far away -> SKOneBoxSearchResultLowRelevancy. This can be filtered out based on this relevancy type
 */

-(void)filterResults:(NSDictionary*)dictionaryToFilter searchObject:(SKOneBoxSearchObject*)searchObject completionBlock:(void (^)(NSDictionary *filteredDictionary))completionBlock andTopHitsBlock:(void (^)(NSDictionary *markedDictionary))topHitsBlock {
    
    self.numberOfProvidersReceived++;
    
    if (self.numberOfProvidersReceived < kMinimumProvidersForFiltering) {
        completionBlock(dictionaryToFilter);
        return;
    }
    // If the clusters were cleared, it means we have a new search, so we set the radius for the filter
    if (self.clustersWereCleared) {
        [self.filter setClustersRadius:searchObject];
    }
    
    self.clustersWereCleared = NO;
    
    // Filtering and ordering
    // Add the new filtering operation on an background thread
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableResultFilteringByDistance"]) {
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self.filter filterTheResultsFrom:dictionaryToFilter withSearchObject:searchObject completionBlock:^(NSDictionary *filteredDictionary) {
                // Execute the completition block on main thread
                
                
                [self.ordering orderResultsFrom:filteredDictionary withSearchObject:searchObject completionBlock:^(NSDictionary *resultValues) {                    
                    if (completionBlock) {
                        completionBlock(resultValues);
                    }
                    
                    // mark the top hit results as well
                    [self.topHitMarker markTopHitsFromResults:filteredDictionary withSearchProviders:self.providers andCompletitionBlock:^(NSDictionary *markedResults) {
                        if (topHitsBlock) {
                            topHitsBlock(markedResults);
                        }
                    }];
                }];
                
            } andProbableLocationBlock:^(SKOneBoxSearchResult *probableLocation) {
                // Execute the probable location block on main thread
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if ([self.delegate respondsToSelector:@selector(filterController:didFindMostProbableLocation:)]) {
                        [[self delegate] filterController:self didFindMostProbableLocation:[probableLocation copy]];
                    }
                }];
            }];
        }];
        
        [self.filteringQueue addOperation:blockOperation];
        [self.filteringQueue waitUntilAllOperationsAreFinished];
    } else {
        // Only ordering
        NSBlockOperation *orderingOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self.ordering orderResultsFrom:dictionaryToFilter withSearchObject:searchObject completionBlock:^(NSDictionary *filteredDictionary) {
                if (completionBlock) {
                    completionBlock(filteredDictionary);
                }
                
                // mark the top hit results as well
                [self.topHitMarker markTopHitsFromResults:filteredDictionary withSearchProviders:self.providers andCompletitionBlock:^(NSDictionary *markedResults) {
                    if (topHitsBlock) {
                        topHitsBlock(markedResults);
                    }
                }];
            }];
        }];
        
        [self.filteringQueue addOperation:orderingOperation];
        [self.filteringQueue waitUntilAllOperationsAreFinished];
    }
    
    // Filtering with distances
    
//    // Add the new filtering operation on an background thread
//    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
//        [self.filter filterTheResultsFrom:dictionaryToFilter withSearchObject:searchObject completionBlock:^(NSDictionary *filteredDictionary) {
//            // Execute the completition block on main thread
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                  NSLog(@"\n_____________\nFiltered dictionary %@", filteredDictionary);
//                
//                if (completionBlock) {
//                    
//                    completionBlock(filteredDictionary);
//                }
//            }];
//            
//        } andProbableLocationBlock:^(SKOneBoxSearchResult *probableLocation) {
//            // Execute the probable location block on main thread
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                if ([self.delegate respondsToSelector:@selector(filterController:didFindMostProbableLocation:)]) {
//                    [[self delegate] filterController:self didFindMostProbableLocation:[probableLocation copy]];
//                }
//            }];
//        }];
//    }];
//    
//    [self.filteringQueue addOperation:blockOperation];
//    [self.filteringQueue waitUntilAllOperationsAreFinished];
    
    
    // TODO: (DLD) old implementation
//    SKOneBoxFilterOperation *filterOp = [[SKOneBoxFilterOperation alloc] initWithMinimumRelevancyType:self.minimumRelevancyTypeAllowed minimumProviders:kMinimumProvidersForFiltering searchObject:searchObject dictionaryToFilter:[dictionaryToFilter mutableCopy] completionBlock:^(SKOneBoxFilterOperation *filterOperation, NSDictionary *filteredDictionary) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            completionBlock(filteredDictionary);
//        });
//    }];
//
//    [filterOp setFoundProbableLocationBlock:^(SKOneBoxSearchResult *mostProbableLocation) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([self.delegate respondsToSelector:@selector(filterController:didFindMostProbableLocation:)]) {
//                [[self delegate] filterController:self didFindMostProbableLocation:[mostProbableLocation copy]];
//            }
//        });
//    }];
//    
//    [[NSOperationQueue mainQueue] addOperation:filterOp];
}

- (void)resetClusters {
    // Stop all current searching operations
    [self.filteringQueue cancelAllOperations];
    [self.filter resetClusters];
    self.clustersWereCleared = YES;
    
    [self.ordering stopSearch];
    
    self.numberOfProvidersReceived = 0;
}

@end
