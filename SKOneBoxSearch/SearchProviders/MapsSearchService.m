//
//  MapsSearchService.m
//

#import "MapsSearchService.h"
#import <SKMaps/SKMaps.h>

@interface MapsSearchService () <SKSearchServiceDelegate>

@end

@implementation MapsSearchService

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)search:(MapsSearchObject *)searchObject {
    [self cancelSearch];
    
    Class searchSettingsClass = NSClassFromString(@"SKOneLineSearchSettings");
    
    if ([searchObject.searchCategories count]) {
        //category search
        Class searchSettingsClass = NSClassFromString(@"SKNearbySearchSettings");
        if (searchSettingsClass) {
            //use old nearbySearch
            [self nearbySearch:searchObject];
        }
        else if (searchSettingsClass) {
            [self onelineSearch:searchObject];
        }
    }
    else if (searchSettingsClass) {
        [self onelineSearch:searchObject];
    }
}

- (void)cancelSearch {
    Class searchServiceClass = NSClassFromString(@"SKSearchService");
    
    if (searchServiceClass) {
        [[searchServiceClass sharedInstance] cancelSearch];
    }
}

- (void)onelineSearch:(MapsSearchObject *)searchObject {
    Class searchSettingsClass = NSClassFromString(@"SKOneLineSearchSettings");
        
    if (searchSettingsClass) {
        SKOneLineSearchSettings *searchSettings = [searchSettingsClass oneLineSearchSettings];
        searchSettings.searchMode = (SKSearchMode)searchObject.searchMode;
        searchSettings.searchTerm = searchObject.searchTerm;
        searchSettings.coordinate = searchObject.coordinate;
        searchSettings.countryCode = searchObject.countryCode;
        
        Class searchServiceClass = NSClassFromString(@"SKSearchService");
        
        //set language
        [(SKSearchService *)[searchServiceClass sharedInstance] setSearchLanguage:[SKOSearchLibUtils codeForLanguage:searchObject.searchLanguage]];
        [[searchServiceClass sharedInstance] setSearchResultsNumber:[searchObject.itemsPerPage intValue]];
        
        [[searchServiceClass sharedInstance] setSearchServiceDelegate:self];
        
        [[searchServiceClass sharedInstance] startOneLineSearch:searchSettings];
    }
}

- (void)nearbySearch:(MapsSearchObject *)searchObject {
    Class searchSettingsClass = NSClassFromString(@"SKNearbySearchSettings");
    
    if (searchSettingsClass) {
        SKNearbySearchSettings *searchSettings = [searchSettingsClass nearbySearchSettings];
        searchSettings.searchMode = (SKSearchMode)searchObject.searchMode;
        searchSettings.searchTerm = searchObject.searchTerm;
        searchSettings.coordinate = searchObject.coordinate;
        searchSettings.radius = [searchObject.radius unsignedIntValue];
        searchSettings.searchCategories = searchObject.searchCategories;
        searchSettings.searchType = SKPOI;
        
        Class searchServiceClass = NSClassFromString(@"SKSearchService");
        
        //set language
        [(SKSearchService *)[searchServiceClass sharedInstance] setSearchLanguage:[SKOSearchLibUtils codeForLanguage:searchObject.searchLanguage]];
        [[searchServiceClass sharedInstance] setSearchResultsNumber:[searchObject.itemsPerPage intValue]];
        
        [[searchServiceClass sharedInstance] setSearchServiceDelegate:self];
        
        [[searchServiceClass sharedInstance] startNearbySearchWithSettings:searchSettings];
    }
}

#pragma mark - SKSearchServiceDelegate

- (void)searchService:(SKSearchService *)searchService didRetrieveNearbySearchResults:(NSArray *)searchResults withSearchMode:(SKSearchMode)searchMode {
    [self didReceiveResults:searchResults];
}

- (void)searchService:(SKSearchService *)searchService didFailToRetrieveNearbySearchResultsWithSearchMode:(SKSearchMode)searchMode {
    if ([self.searchServiceDelegate respondsToSelector:@selector(searchServiceDidFailToRetrieveSearchResults:)]) {
        [self.searchServiceDelegate searchServiceDidFailToRetrieveSearchResults:self];
    }
}

- (void)searchService:(SKSearchService *)searchService didRetrieveOneLineSearchResults:(NSArray *)searchResults {
    [self didReceiveResults:searchResults];
}

- (void)searchServiceDidFailToRetrieveOneLineSearchResults:(SKSearchService *)searchService {
    if ([self.searchServiceDelegate respondsToSelector:@selector(searchServiceDidFailToRetrieveSearchResults:)]) {
        [self.searchServiceDelegate searchServiceDidFailToRetrieveSearchResults:self];
    }
}

- (SKOSearchResultType)skoResultTypeFromSKResultType:(SKSearchResultType)type {
    switch (type) {
        case SKSearchResultCountry:
            return SKOSearchResultCountry;
            break;
        case SKSearchResultState:
            return SKOSearchResultAdministrativeArea;
            break;
        case SKSearchResultCity:
            return SKOSearchResultLocality;
            break;
        case SKSearchResultZipCode:
            return SKOSearchResultPostalCode;
            break;
        case SKSearchResultSuburb:
            return SKOSearchResultSubLocality;
            break;
        case SKSearchResultNeighbourhood:
            return SKOSearchResultNeighborhood;
            break;
        case SKSearchResultHamlet:
            return SKOSearchResultNeighborhood;
            break;
        case SKSearchResultStreet:
            return SKOSearchResultStreet;
            break;
        case SKSearchResultPOI:
            return SKOSearchResultPOI;
            break;
        case SKSearchResultHouseNumber:
            return SKOSearchResultStreet;
            break;
        case SKSearchResultWikiPoi:
            return SKOSearchResultPOI;
            break;
        case SKSearchResultCountryCode:
            return SKOSearchResultCountry;
            break;
        case SKSearchResultStateCode:
            return SKOSearchResultAdministrativeArea;
            break;
        default:
            return SKOSearchResultPOI;
            break;
    }
}

- (void)didReceiveResults:(NSArray *)searchResults {
    Class searchResultClass = NSClassFromString(@"SKSearchResult");
    
    if (searchResultClass) {
        NSMutableArray *ngxSearchResults = [NSMutableArray array];
        
        long rankingIndex = searchResults.count;
        for (SKSearchResult *searchResult in searchResults) {
            rankingIndex--;
            
            if (searchResult.name.length == 0) { //exclude results that don't have a name
                continue;
            }
            
            SKOSearchResult *skoSearchResult = [SKOSearchResult searchResult];
            
            skoSearchResult.name = searchResult.name;
            
            skoSearchResult.coordinate = searchResult.coordinate;
            
            [self populateOneBoxSearchResult:skoSearchResult withSearchResult:searchResult];
            
            NSInteger categoryId = (NSInteger)searchResult.category;
            
            Class searchServiceClass = NSClassFromString(@"SKSearchService");
            NSInteger featureId = [(SKSearchService *)[searchServiceClass sharedInstance] getTextureId:categoryId];
            
            if (featureId == 0) {
                categoryId = -1;
                featureId = -1;
            }
            skoSearchResult.additionalInformation = @{@"identifier":[NSNumber numberWithLongLong:searchResult.identifier],
                                                      @"skMapsCategoryId" : [NSNumber numberWithInteger:categoryId],
                                                      @"category" : [NSNumber numberWithInteger:featureId],
                                                      @"mainCategory" : [NSNumber numberWithInt:searchResult.mainCategory],
                                                      @"ranking" : [NSNumber numberWithLong:rankingIndex]};
            
            skoSearchResult.type = [self skoResultTypeFromSKResultType:searchResult.type];
            
            [ngxSearchResults addObject:skoSearchResult];
        }
        
        if ([self.searchServiceDelegate respondsToSelector:@selector(searchService:didRetrieveSearchResults:)]) {
            [self.searchServiceDelegate searchService:self didRetrieveSearchResults:ngxSearchResults];
        }
    }
}

- (void)populateOneBoxSearchResult:(SKOSearchResult *)skoSearchResult withSearchResult:(SKSearchResult *)searchResult {
    Class searchResultClass = NSClassFromString(@"SKSearchResult");
    
    if (searchResultClass) {
        for (SKSearchResultParent *parent in searchResult.parentSearchResults) {
            switch (parent.type) {
                case SKSearchResultCountry:
                {
                    skoSearchResult.country = parent.name;
                }
                    break;
                case SKSearchResultState:
                {
                    skoSearchResult.administrativeArea = parent.name;
                }
                    break;
                case SKSearchResultCity:
                {
                    skoSearchResult.locality = parent.name;
                }
                    break;
                case SKSearchResultSuburb:
                {
                    skoSearchResult.subLocality = parent.name;
                }
                    break;
                case SKSearchResultZipCode:
                {
                    skoSearchResult.postalCode = parent.name;
                }
                    break;
                case SKSearchResultCountryCode:
                {
                    skoSearchResult.ISOcountryCode = parent.name;
                }
                    break;
                case SKSearchResultStreet:
                {
                    skoSearchResult.street = parent.name;
                }
                    break;
                case SKSearchResultHouseNumber:
                {
                    skoSearchResult.houseNumber = parent.name;
                }
                    break;
                case SKSearchResultNeighbourhood:
                {
                    skoSearchResult.subAdministrativeArea = parent.name;
                }
                    break;
                case SKSearchResultHamlet:
                {
                    skoSearchResult.subLocality = parent.name;
                }
                    break;
                case SKSearchResultStateCode:
                {
                    skoSearchResult.administrativeAreaCode= parent.name;
                }
                    break;
                default:
                    break;
            }
        }
    }
}

@end
