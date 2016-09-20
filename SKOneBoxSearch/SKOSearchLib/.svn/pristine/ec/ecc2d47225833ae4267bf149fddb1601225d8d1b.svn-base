//
//  SKOneBoxDataController.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxDataController.h"
#import "SKSearchProviderProtocol.h"
#import "SKSearchProviderDataController.h"
#import "SKOneBoxFilterController.h"

@interface SKOneBoxDataController () <SKSearchProviderDataControllerDelegate>

@property (nonatomic, strong) NSArray *providerDataControllers;

@property (atomic, strong) NSMutableDictionary *mutableResults;

@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, strong) SKOneBoxFilterController *filterController;

@property (nonatomic, strong) NSArray *searchProviders;

@end

@implementation SKOneBoxDataController

#pragma mark - Init

- (instancetype)initWithSearchProviders:(NSArray *)searchProviders filteringController:(SKOneBoxFilterController*)filterController  {
    self = [super init];
    
    if (self) {
        NSMutableArray *providerDataControllers = [NSMutableArray array];
        
        self.mutableResults = [NSMutableDictionary dictionary];
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"SKOneBoxDataControllerLock";

        self.filterController = filterController;
        self.filterController.providers = searchProviders;
        self.searchProviders = searchProviders;
        
        for (id<SKSearchProviderProtocol> searchProvider in searchProviders) {
            SKSearchProviderDataController *dataController = [[SKSearchProviderDataController alloc] initWithSearchProvider:searchProvider];
            if (dataController) {
                [providerDataControllers addObject:dataController];
                dataController.delegate = self;
                
                [self.mutableResults setObject:[NSMutableArray array] forKey:[searchProvider providerID]];
            }
        }
        
        self.providerDataControllers = providerDataControllers;
    }
    
    return self;
}

#pragma mark - Public

- (void)search:(SKOneBoxSearchObject *)searchObject forProvider:(id<SKSearchProviderProtocol>)provider  {
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([providerDataController.searchProvider isEqual:provider]) {
            [self search:searchObject forProviderDataController:providerDataController];
        }
    }
}

- (void)search:(SKOneBoxSearchObject *)searchObject {
    for (SKSearchProviderDataController *dataController in self.providerDataControllers) {
        [self search:searchObject forProviderDataController:dataController];
    }
}

- (void)cancelSearch {
    for (SKSearchProviderDataController *dataController in self.providerDataControllers) {
        [self cancelSearchForProviderDataController:dataController];
    }
    
    // Reset the search providers
    [self.mutableResults removeAllObjects];
    for (id<SKSearchProviderProtocol> searchProvider in self.searchProviders) {
        [self.mutableResults setObject:[NSMutableArray array] forKey:[searchProvider providerID]];
    }
    
    [self.filterController resetClusters];
}

- (void)cancelSearchForProvider:(id<SKSearchProviderProtocol>)provider {
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([providerDataController.searchProvider isEqual:provider]) {
            [self cancelSearchForProviderDataController:providerDataController];
        }
    }
}

- (void)clearSearchData {
    for (SKSearchProviderDataController *dataController in self.providerDataControllers) {
        [self clearSearchForProviderDataController:dataController];
    }
}

- (void)clearSearchForProvider:(id<SKSearchProviderProtocol>)provider {
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([providerDataController.searchProvider isEqual:provider]) {
            [self clearSearchForProviderDataController:providerDataController];
        }
    }
}

- (SKOneBoxSearchResultMetaData *)currentMetaDataForProvider:(id<SKSearchProviderProtocol>)provider {
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([providerDataController.searchProvider isEqual:provider]) {
            return providerDataController.metaData;
        }
    }
    
    return nil;
}

- (SKOneBoxSearchObject *)currentSearchObjectForProvider:(id<SKSearchProviderProtocol>)provider {
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([providerDataController.searchProvider isEqual:provider]) {
            return providerDataController.searchObject;
        }
    }
    
    return nil;
}

- (id<SKSearchProviderProtocol>)providerForProviderId:(NSNumber*)providerId {
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([providerDataController.searchProvider.providerID isEqual:providerId]) {
            return providerDataController.searchProvider;
        }
    }
    
    return nil;
}

- (NSDictionary *)results {
    @synchronized(self) {
        return [self.mutableResults copy];
    }
}

-(BOOL)isProviderSearching:(id<SKSearchProviderProtocol>)provider {
    BOOL searching = NO;
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([providerDataController.searchProvider isEqual:provider]) {
            return providerDataController.isSearching;
        }
    }
    return searching;
}

-(NSArray*)resultsForProvider:(id<SKSearchProviderProtocol>)provider {
    NSDictionary *dictResults = self.results;
    for (NSNumber *searchProviderId in [dictResults allKeys]) {
        if ([[provider providerID] isEqualToNumber:searchProviderId]) {
            return [dictResults objectForKey:searchProviderId];
        }
    }
    return @[];
}

#pragma mark - Private 

-(void)search:(SKOneBoxSearchObject *)searchObject forProviderDataController:(SKSearchProviderDataController*)providerDataController {
    [providerDataController search:searchObject];
}

-(void)cancelSearchForProviderDataController:(SKSearchProviderDataController*)providerDataController {
    [providerDataController cancelSearch];
}

-(void)clearSearchForProviderDataController:(SKSearchProviderDataController*)providerDataController {
    [self.mutableResults setObject:@[] forKey:[providerDataController.searchProvider providerID]];
    [providerDataController clearSearch];
}

#pragma mark - Properties

-(BOOL)isSearching {
    BOOL searching = NO;
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([providerDataController isSearching]) {
            searching = [providerDataController isSearching];
        }
    }
    return searching;
}

-(BOOL)areProvidersSearching:(NSArray*)providers {
    BOOL searching = NO;
    for (id<SKSearchProviderProtocol> provider in providers) {
        for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
            if ([[[providerDataController searchProvider] providerID] isEqual:[provider providerID]] && [providerDataController isSearching]) {
                searching = [providerDataController isSearching];
            }
        }
    }

    return searching;
}

-(NSDictionary *)filterEnabledResults {
    NSMutableDictionary *resultsToFilter = [self.mutableResults mutableCopy];
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if (![[providerDataController searchProvider] allowsFiltering] && [resultsToFilter objectForKey:[[providerDataController searchProvider] providerID]]) {
            [resultsToFilter removeObjectForKey:[[providerDataController searchProvider] providerID]];
        }
    }
    
    return resultsToFilter;
}

-(NSDictionary *)filterDisabledResults {
    NSMutableDictionary *resultsToFilter = [self.mutableResults mutableCopy];
    for (SKSearchProviderDataController *providerDataController in self.providerDataControllers) {
        if ([[providerDataController searchProvider] allowsFiltering] && [resultsToFilter objectForKey:[[providerDataController searchProvider] providerID]]) {
            [resultsToFilter removeObjectForKey:[[providerDataController searchProvider] providerID]];
        }
    }
    
    return resultsToFilter;
}

#pragma mark - SKSearchProviderDataControllerDelegate

- (void)searchProviderDataController:(SKSearchProviderDataController *)dataController didReceiveSearchResults:(NSArray *)results{
    @synchronized(self) {
        [self.lock lock];
        [self.mutableResults setObject:results forKey:[dataController.searchProvider providerID]];
        [self.lock unlock];
        
        if (self.filterController && [dataController.searchProvider allowsFiltering]) {
            NSDictionary *resultsToFilter = [self filterEnabledResults];
            
            SKOneBoxSearchObject *searchObject = [dataController searchObject];
            
            [self.filterController filterResults:resultsToFilter searchObject:searchObject completionBlock:^(NSDictionary *filteredDictionary) {
                NSMutableDictionary *allResultsDict = [[self filterDisabledResults] mutableCopy];
                [allResultsDict addEntriesFromDictionary:filteredDictionary];
                
                if ([self.delegate respondsToSelector:@selector(oneBoxDataController:didReceiveResults:fromProvider:)]) {
                    [self.delegate oneBoxDataController:self didReceiveResults:filteredDictionary fromProvider:dataController.searchProvider];
                }
            } andTopHitsBlock:^(NSDictionary *markedDictionary) {
                if ([self.delegate respondsToSelector:@selector(oneBoxDataController:didReceiveTopHitResults:)]) {
                    [self.delegate oneBoxDataController:self didReceiveTopHitResults:[markedDictionary copy]];
                }
            }];
        }
        else {
            NSDictionary *resultsToFilter = [[self mutableResults] copy];
            
            if ([self.delegate respondsToSelector:@selector(oneBoxDataController:didReceiveResults:fromProvider:)]) {
                [self.delegate oneBoxDataController:self didReceiveResults:resultsToFilter fromProvider:dataController.searchProvider];
            }
        }
    }
}

@end
