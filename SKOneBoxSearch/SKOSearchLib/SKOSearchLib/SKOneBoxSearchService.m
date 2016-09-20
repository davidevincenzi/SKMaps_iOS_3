//
//  SKOneBoxSearchService.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 02/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchService.h"
#import "SKOneBoxFilterController.h"

#define SEND_RESONSE_WITH_WAIT

@interface SKOneBoxSearchService () <SKOneBoxDataControllerDelegate,SKOneBoxFilterControllerDelegate>

@property (nonatomic, strong) SKOneBoxDataController *dataController;
@property (nonatomic, strong) NSHashTable *delegates;

// Contains the latest recived results
@property (nonatomic, strong) NSDictionary *currentResults;

// Contains all the providers for which the results have been returned
@property (nonatomic, strong) NSMutableSet *returnedProviders;

// All the provider ID for which we have recieved values
@property (nonatomic, strong) NSMutableSet *recievedProvidersResults;

@property (nonatomic, strong) SKOneBoxSearchObject *lastSearchObject; //keep a reference of the current search, report results only for current search

@end

@implementation SKOneBoxSearchService
@synthesize delegates = _delegates;

#pragma mark - Init

- (instancetype)initWithSearchProviders:(NSArray *)searchProviders withMinimumRelevancy:(SKOneBoxSearchResultRelevancyType)relevancyType shouldUseFilter:(BOOL)shouldUseFilter {
    self = [super init];
    
    if (self) {
        _searchProviders = searchProviders;
        
        SKOneBoxFilterController *filter = nil;
        if (shouldUseFilter) {
            filter = [[SKOneBoxFilterController alloc] initWithMinimumRelevancy:relevancyType];
            filter.delegate = self;
        }

        self.dataController = [[SKOneBoxDataController alloc] initWithSearchProviders:searchProviders filteringController:filter];
        self.dataController.delegate = self;
        
        self.currentResults = [NSDictionary new];
        self.returnedProviders = [NSMutableSet new];
        self.recievedProvidersResults = [NSMutableSet new];
    }
    
    return self;
}

#pragma mark - Public

- (void)search:(SKOneBoxSearchObject *)searchObject forProvider:(id<SKSearchProviderProtocol>)provider {
    self.lastSearchObject = searchObject;
    
    //reset in case of api search or pagination
    if ([self.returnedProviders containsObject:[provider providerID]]) {
        [self.returnedProviders removeObject:[provider providerID]];
    }
    if ([self.recievedProvidersResults containsObject:[provider providerID]]) {
        [self.recievedProvidersResults removeObject:[provider providerID]];
    }
    
    if ((!searchObject.pageIndex && !searchObject.pageToLoad) || (searchObject.pageIndex && searchObject.pageIndex == 0)) {
        [[self dataController] clearSearchForProvider:provider];
    }
    [self.dataController search:searchObject forProvider:provider];
}

- (void)search:(SKOneBoxSearchObject *)searchObject {
    self.lastSearchObject = searchObject;
    
    if (searchObject.pageToLoad || searchObject.pageIndex == 0) {
        [[self dataController] clearSearchData];
    }
    [self.dataController search:searchObject];
}

- (void)cancelSearch {
    [self.dataController cancelSearch];
    [self resetValuesForNewSearch];
}

- (void)cancelSearchForProvider:(id<SKSearchProviderProtocol>)provider {
    [self.dataController cancelSearchForProvider:provider];
}

- (SKOneBoxSearchResultMetaData *)currentMetaDataForProvider:(id<SKSearchProviderProtocol>)provider {
    return [self.dataController currentMetaDataForProvider:provider];
}

- (SKOneBoxSearchObject *)currentSearchObjectForProvider:(id<SKSearchProviderProtocol>)provider {
    return [self.dataController currentSearchObjectForProvider:provider];
}


- (void)addDelegate:(id<SKOneBoxSearchServiceDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<SKOneBoxSearchServiceDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

- (id<SKSearchProviderProtocol>)providerForProviderId:(NSNumber*)providerId {
    return [self.dataController providerForProviderId:providerId];
}

- (void)clearSearchData {
    [self.dataController clearSearchData];
}

- (void)clearSearchDataProvider:(id<SKSearchProviderProtocol>)provider {
    [self.dataController clearSearchForProvider:provider];
}

-(BOOL)isProviderSearching:(id<SKSearchProviderProtocol>)provider {
    return [self.dataController isProviderSearching:provider];
}


#pragma mark - Properties

-(BOOL)isSearching {
    return [self.dataController isSearching];
}

-(BOOL)areProvidersSearching:(NSArray*)providers {
    return [self.dataController areProvidersSearching:providers];
}

- (NSHashTable *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

#pragma mark - Private

-(void)addMostProbableLocation:(SKOneBoxSearchResult *)result {
    NSLog(@"most probable location = %@, %f %f",result.locality,result.coordinate.latitude,result.coordinate.longitude);
    @synchronized(self) {
        if ([self.searchProviders count]) {
            id<SKSearchProviderProtocol> firstProvider = [self searchProviders][0];
            NSArray *results = [[self.dataController resultsForProvider:firstProvider] copy];
            
            NSMutableArray *cleanResults = [NSMutableArray array];
            for (SKOneBoxSearchResult *searchResult in results) {
                if (![[searchResult additionalInformation] valueForKey:@"locationSuggestion"]) {
                    [cleanResults addObject:searchResult];
                }
            }
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:cleanResults];
            
            if (result) {
                NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
                UIImage *icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"add_location_icon" ofType:@"png"]];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[result additionalInformation]];
                [dict setValue:[NSNumber numberWithBool:YES] forKey:@"locationSuggestion"];
                [dict setValue:icon forKey:@"icon"];
                
                [result setAdditionalInformation:dict];
                
                [newArray insertObject:result atIndex:0];
            }


            for (id<SKOneBoxSearchServiceDelegate> delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(searchService:didReceiveResults:forProvider:)]) {
                    [delegate searchService:self didReceiveResults:newArray forProvider:firstProvider];
                }
            }
        }
    }
}

- (void)resetValuesForNewSearch {
    self.currentResults = [NSDictionary new];
    [self.returnedProviders removeAllObjects];
    [self.recievedProvidersResults removeAllObjects];
}

- (void)sendCurrentResultsForProviderID:(NSNumber *)latestProviderID {
    [self.recievedProvidersResults addObject:latestProviderID];
    
    for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
        NSNumber *currentProviderID = [provider providerID];
        
        if ([self canSendValuesForProviderID:currentProviderID]) {
            // Send all the values
            
            // For all the recieved providers
            for (NSNumber *recivedProviderID in self.recievedProvidersResults) {
                
                // If the provider is before the current one or equal to it
                if ([self isProvider:recivedProviderID beforeProvider:currentProviderID] ||
                    recivedProviderID.intValue == currentProviderID.intValue) {
                    
                    // And we haven't send the values for it
                    if (![self.returnedProviders containsObject:recivedProviderID]) {
                        // We haven't returned the results for the current provider
                        
                        [self sendValuesForProviderID:recivedProviderID];
                        
                        // Mark the result as sent
                        [self.returnedProviders addObject:recivedProviderID];
                    }
                }
            }
        }
    }
}

/** Sends the current result for the given
 providerID
 */
- (void)sendValuesForProviderID:(NSNumber *)providerID {
    // Send results for provider
    for (id<SKOneBoxSearchServiceDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(searchService:didReceiveResults:forProvider:)]) {
            NSArray *resultsArray = [self.currentResults objectForKey:providerID];
            id<SKSearchProviderProtocol> provider = [self providerForProviderId:providerID];
            
            SKOneBoxSearchObject *searchObject = [self currentSearchObjectForProvider:provider];
            
            if (resultsArray && [self.lastSearchObject isEqualToSearchObject:searchObject]) {
                // Execute the delegate on main thread
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [delegate searchService:self didReceiveResults:[resultsArray copy] forProvider:provider];
                }];
            }
        }
    }
}

/** Returns YES if we have sent all the values
 to the previous providers, or we have the data to do so
 */
- (BOOL)canSendValuesForProviderID:(NSNumber *)providerID {
    // Find all the providers which have an id which is less
    // the the current one
    NSMutableArray *previousProviders = [NSMutableArray new];
    for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
        NSNumber *provID = [provider providerID];
        
        if ([self isProvider:provID beforeProvider:providerID]) {
            [previousProviders addObject:provID];
        }
    }
    
    // For each previous provider, check if
    // we have send the values or we have them, otherwise
    // return NO
    for (NSNumber *prevProv in previousProviders) {
        if (![self.returnedProviders containsObject:prevProv] &&
            ![self.recievedProvidersResults containsObject:prevProv]) {
            return NO;
        }
    }
    
    return YES;
}

/** Checks if a provider comes before another one 
 in the initial set of search providers
 */
- (BOOL)isProvider:(NSNumber *)firstID beforeProvider:(NSNumber *)secondID {
    BOOL wendOverFirst = NO;
    
    for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
        if ([provider providerID].intValue == firstID.intValue) {
            wendOverFirst = YES;
        }
        
        if ([provider providerID].intValue == secondID.intValue) {
            if (wendOverFirst) {
                return YES;
            }
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - SKOneBoxDataControllerDelegate

- (void)oneBoxDataController:(SKOneBoxDataController *)dataController didReceiveResults:(NSDictionary*)results fromProvider:(id<SKSearchProviderProtocol>)provider {
#ifdef SEND_RESONSE_WITH_WAIT
    @synchronized(self) {
        self.currentResults = results;
        [self sendCurrentResultsForProviderID:[provider providerID]];
    }
#else
    @synchronized(self) {
        SKOneBoxSearchObject *searchObject = [dataController currentSearchObjectForProvider:provider];
        if (![self.lastSearchObject isEqualToSearchObject:searchObject]) {
            return;
        }
        for (id<SKOneBoxSearchServiceDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(searchService:didReceiveResults:forProvider:)]) {
                NSArray *resultsArray = [results objectForKey:[provider providerID]];
                
                if (resultsArray) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [delegate searchService:self didReceiveResults:[resultsArray copy] forProvider:provider];
                    }];
                }
            }
        }
    }

    
#endif
    
}

- (void)oneBoxDataController:(SKOneBoxDataController *)dataController didReceiveTopHitResults:(NSDictionary *)results {
    for (id<SKOneBoxSearchServiceDelegate> delegate in self.delegates) {
        
        if ([delegate respondsToSelector:@selector(searchService:didMarkTopHitResults:)]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [delegate searchService:self didMarkTopHitResults:[results copy]];
            }];
        }
    }

}

#pragma mark - SKOneBoxFilterControllerDelegate

-(void)filterController:(SKOneBoxFilterController *)controller didFindMostProbableLocation:(SKOneBoxSearchResult *)result {
    [self addMostProbableLocation:result];
}

@end
