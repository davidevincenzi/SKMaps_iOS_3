//
//  SKSearchBaseProvider.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKSearchBaseProvider.h"
#import <SKOSearchLib.h>

static int kDefaultNumberOfResultsToShow = 2;
static int kDefaultSearchNumberOfItemsPerPage = 20;

@interface SKSearchBaseProvider ()
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *apiSecret;
@end

@implementation SKSearchBaseProvider

@synthesize delegates = _delegates;
@dynamic localizedProviderName;

@synthesize providerIcon;
@synthesize numberOfResultsToShow;
@synthesize shouldShowSectionHeader;
@synthesize shouldShowSearchProviderInSearchResults;

@synthesize shouldAppearInDefaultList;
@synthesize shouldShowCategories;
@synthesize shouldShowSectionHeaderDefaultList;
@synthesize numberOfCategoriesToShowDefaultList;
@synthesize providerID;
@synthesize searchNumberOfItemsPerPage;

@synthesize providerResultTableViewCell;
@synthesize populateResultTableViewCell;
@synthesize customResultsCellHeight;

@synthesize searchRadius;

@synthesize categories;
@synthesize allowsPagination;
@synthesize allowsFiltering;

#pragma mark - Init

- (instancetype)init {
    self = [self initWithAPIKey:nil apiSecret:nil];
    if (self) {

    }
    return self;
}

- (instancetype)initWithAPIKey:(NSString*)apiKey apiSecret:(NSString *)apiSecret {
    self = [super init];
    if (self) {
        self.apiKey = apiKey;
        self.apiSecret = apiSecret;
        self.numberOfResultsToShow = kDefaultNumberOfResultsToShow;
        self.shouldShowSectionHeader = YES;
        self.shouldShowSearchProviderInSearchResults = YES;
        self.searchNumberOfItemsPerPage = [NSNumber numberWithInt:kDefaultSearchNumberOfItemsPerPage];
        self.customResultsCellHeight = 0.0f;
        self.searchRadius = @10000; //10km
        self.allowsPagination = YES;
        self.allowsFiltering = YES;
    }
    return self;
}

#pragma mark - Overrides

- (SKOSearchMode)searchMode {
    if ([self.dataSource respondsToSelector:@selector(searchProviderSearchMode)]) {
        return [self.dataSource searchProviderSearchMode];
    }
    return SKOSearchOnline;
}

#pragma mark - SKSearchProviderProtocol

- (void)search:(SKOneBoxSearchObject *)searchObject {
    
}

- (void)cancelSearch {
    
}

-(SKOneBoxSearchResultType)oneBoxTypeFromSKOResultType:(SKOSearchResultType)type {
    switch (type) {
        case SKOSearchResultCountry:
            return SKOneBoxSearchResultCountry;
            break;
        case SKOSearchResultAdministrativeArea:
            return SKOneBoxSearchResultAdministrativeArea;
            break;
        case SKOSearchResultLocality:
            return SKOneBoxSearchResultLocality;
            break;
        case SKOSearchResultSubLocality:
            return SKOneBoxSearchResultSubLocality;
            break;
        case SKOSearchResultNeighborhood:
            return SKOneBoxSearchResultNeighborhood;
            break;
        case SKOSearchResultStreet:
            return SKOneBoxSearchResultStreet;
            break;
        case SKOSearchResultPostalCode:
            return SKOneBoxSearchResultPostalCode;
            break;
        case SKOSearchResultPOI:
            return SKOneBoxSearchResultPOI;
            break;
        default:
            return SKOneBoxSearchResultPOI;
            break;
    }
}

- (SKOneBoxSearchResult *)mappedOneBoxSearchResultFromSearchResult:(SKOSearchResult*)searchResult {
    SKOneBoxSearchResult *oneBoxSearchResult = [SKOneBoxSearchResult oneBoxSearchResult];
    
    oneBoxSearchResult.type = [self oneBoxTypeFromSKOResultType:searchResult.type];
    
    oneBoxSearchResult.name = searchResult.name;
    oneBoxSearchResult.coordinate = searchResult.coordinate;
    
    oneBoxSearchResult.street = searchResult.street;
    oneBoxSearchResult.locality = searchResult.locality;
    oneBoxSearchResult.subLocality = searchResult.subLocality;
    oneBoxSearchResult.administrativeArea = searchResult.administrativeArea;
    oneBoxSearchResult.administrativeAreaCode = searchResult.administrativeAreaCode;
    oneBoxSearchResult.subAdministrativeArea = searchResult.subAdministrativeArea;
    oneBoxSearchResult.postalCode = searchResult.postalCode;
    oneBoxSearchResult.houseNumber = searchResult.houseNumber;
    oneBoxSearchResult.ISOcountryCode = searchResult.ISOcountryCode;
    oneBoxSearchResult.country = searchResult.country;
    oneBoxSearchResult.uid = searchResult.uid;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:((SKOSearchResult *)searchResult).additionalInformation];
    
    if (self.providerID) {
        dictionary[@"providerID"] = self.providerID;
    }
    if (self.providerIcon) {
        dictionary[@"icon"] = self.providerIcon;
    }
    
    oneBoxSearchResult.additionalInformation = dictionary;
    return oneBoxSearchResult;
}

- (SKOneBoxSearchResultMetaData *)mappedMetaDataObjectFromSearchMetaData:(id)searchMetaData {
    return nil;
}

- (NSArray *)categories {
    return categories;
}

- (NSArray *)sortingComparators {
    return nil;
}

- (BOOL)isSearchProviderEnabled {
    return YES;
}

#pragma mark -

- (NSHashTable *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (void)addDelegate:(id<SKSearchProviderDelegate>)delegateObj {
    [self.delegates addObject:delegateObj];
}

- (void)removeDelegate:(id<SKSearchProviderDelegate>)delegateObj {
    [self.delegates removeObject:delegateObj];
}

- (BOOL)isEqual:(id)object {
    return [self isMemberOfClass:[object class]];
}

- (NSUInteger)hash {
    return [self.localizedProviderName hash];
}

@end
