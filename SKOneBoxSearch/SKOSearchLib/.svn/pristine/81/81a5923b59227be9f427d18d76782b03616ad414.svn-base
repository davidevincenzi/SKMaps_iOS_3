//
//  SKSearchProviderDataController.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 02/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKSearchProviderDataController.h"
#import "SKOneBoxSearchResultMetaData.h"
#import "SKOneBoxSearchResult.h"

@interface SKSearchProviderDataController () <SKSearchProviderDelegate>

@property (atomic, strong) SKOneBoxSearchResultMetaData *metaData;
@property (nonatomic, strong) id<SKSearchProviderProtocol> searchProvider;
@property (atomic, strong) NSMutableArray *mutableResults;
@property (atomic, assign) BOOL isSearching;

@end

@implementation SKSearchProviderDataController

- (instancetype)initWithSearchProvider:(id<SKSearchProviderProtocol>)searchProvider {
    self = [super init];
    
    if (self) {
        [searchProvider addDelegate:self];
        self.searchProvider = searchProvider;
        
        self.mutableResults = [NSMutableArray array];
    }
    
    return self;
}

- (void)search:(SKOneBoxSearchObject *)searchObject {
    _isSearching = YES;
    _searchObject = searchObject;
    [_searchProvider search:searchObject];
}

- (void)cancelSearch {
    _isSearching = NO;
    [_searchProvider cancelSearch];
}

- (void)clearSearch {
    [self.mutableResults removeAllObjects];
}

- (NSArray *)results {
    @synchronized(self) {
        return [self.mutableResults copy];
    }
}

-(void)dealloc {
    [self.searchProvider removeDelegate:self];
}

#pragma mark - SKSearchProviderDelegate

- (void)searchProvider:(id<SKSearchProviderProtocol>)searchProvider didReceiveResults:(NSArray *)results metaData:(id)metaData {
    @synchronized(self) {
        _isSearching = NO;
        self.metaData = [searchProvider mappedMetaDataObjectFromSearchMetaData:metaData];

        if (!self.metaData || (self.metaData.previousPage == nil && self.metaData.page == 1) || self.metaData.page == 0) {
            // If this is the first page it means that the search term has change so we need to clear out all the saved results
            [self clearSearch];
        }
        
        //set category for search result if available, will be used for map pois
        SKOneBoxSearchObject *originalSearchObject = self.searchObject;
        
        int rankingIndex = 0;
        for (id searchResult in results) {
            rankingIndex++;
            SKOneBoxSearchResult *mappedResult = [searchProvider mappedOneBoxSearchResultFromSearchResult:searchResult];
            
            NSMutableDictionary *dictionary = [NSMutableDictionary new];
            if (mappedResult.additionalInformation) {
                dictionary = [NSMutableDictionary dictionaryWithDictionary:mappedResult.additionalInformation];
            }
            
            if (originalSearchObject.searchCategory) {
                if (!dictionary[@"category"]) {
                    dictionary[@"category"] = originalSearchObject.searchCategory;
                }
                
            }
            
            if (!dictionary[@"ranking"]) {
                dictionary[@"ranking"] = [NSNumber numberWithInt:rankingIndex];
            }
            
            mappedResult.additionalInformation = dictionary;
            
            [self.mutableResults addObject:mappedResult];
        }
        
        if ([self.delegate respondsToSelector:@selector(searchProviderDataController:didReceiveSearchResults:)]) {
            [self.delegate searchProviderDataController:self didReceiveSearchResults:self.results];
        }
    }
}

- (void)searchProviderDidFailToRetrieveResults:(id<SKSearchProviderProtocol>)searchProvider {
    _isSearching = NO;
    [self.mutableResults removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(searchProviderDataController:didReceiveSearchResults:)]) {
        [self.delegate searchProviderDataController:self didReceiveSearchResults:self.results];
    }
}

@end
