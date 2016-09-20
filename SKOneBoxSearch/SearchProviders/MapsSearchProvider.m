//
//  MapsSearchProvider.m
//

#import "MapsSearchProvider.h"
#import <SKMaps/SKMaps.h>
#import "Reachability.h"
#import "MapsSearchObject.h"
#import "MapsSearchService.h"

@interface MapsSearchProvider () <MapsSearchServiceDelegate>

@end

@implementation MapsSearchProvider

- (BOOL)isConnectedToInternet {
    return [Reachability reachabilityForInternetConnection].currentReachabilityStatus != NotReachable;
}

- (BOOL)shouldAppearInDefaultList {
    return YES;
}

- (BOOL)shouldShowSectionHeaderDefaultList {
    return YES;
}

- (NSInteger)numberOfCategoriesToShowDefaultList {
    return 4;
}

- (BOOL)shouldShowCategories {
    return YES;
}

- (NSArray *)categories {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    
    NSDictionary *categories = [[SKSearchService sharedInstance] categoriesFromMainCategories];
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *allKeys = [[categories allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 intValue] > [obj2 intValue]) {
            return NSOrderedDescending;
        } else if ([obj1 intValue] == [obj2 intValue]) {
            return NSOrderedSame;
        } else
            return NSOrderedAscending;
    }];
    
    //old categories
    for (NSNumber *categoryKey in allKeys) {
        [array addObject:({
            SKSearchProviderCategory *categoryNew = [[SKSearchProviderCategory alloc] init];
            categoryNew.localizedCategoryName = [MapsSearchProvider categoryNameForCategoryId:[categoryKey intValue]];
            categoryNew.categorySearchType = categoryKey;
            categoryNew.categoryImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:[NSString stringWithFormat:@"icon_onebox_%i",[MapsSearchProvider imageIdForCategoryId:[categoryKey intValue]]] ofType:@"png"]];
            categoryNew.isMainCategory = YES;
            categoryNew;
        })];
    }
    
    return array;
}

//MaGiC NuMbErS
+ (int)imageIdForCategoryId:(int)categoryId {
    switch (categoryId) {
        case 1:
            return 20;
            break;
        case 2:
            return 33;
            break;
        case 3:
            return 53;
            break;
        case 5:
            return 67;
            break;
        case 6:
            return 94;
            break;
        case 8:
            return 97;
            break;
        case 9:
            return 123;
            break;
        case 7:
            return 132;
            break;
        case 4:
            return 162;
            break;
        default:
            return -1;
            break;
    }
}

//MaGiC NuMbErS
+ (NSString *)categoryNameForCategoryId:(int)categoryId {
    switch (categoryId) {
        case 1:
            return NSLocalizedString(@"category_food_type_title_key", nil);
            break;
        case 2:
            return NSLocalizedString(@"category_health_type_title_key", nil);
            break;
        case 3:
            return NSLocalizedString(@"category_leisure_type_title_key", nil);
            break;
        case 5:
            return NSLocalizedString(@"category_public_type_title_key", nil);
            break;
        case 6:
            return NSLocalizedString(@"category_service_type_title_key", nil);
            break;
        case 8:
            return NSLocalizedString(@"category_sleeping_type_title_key", nil);
            break;
        case 9:
            return NSLocalizedString(@"category_transport_type_title_key", nil);
            break;
        case 7:
            return NSLocalizedString(@"category_shopping_type_title_key", nil);
            break;
        case 4:
            return NSLocalizedString(@"category_nightlife_type_title_key", nil);
            break;
        default:
            return @"";
            break;
    }
}

#pragma mark - SKSearchProviderProtocol

- (void)search:(SKOneBoxSearchObject *)searchObject {
    Class searchServiceClass = NSClassFromString(@"MapsSearchService");
    
    if (searchServiceClass) {
        MapsSearchObject *mapsSearchObject = [MapsSearchObject searchObject];
        
        mapsSearchObject.searchMode = self.searchMode;
        
        if (![self isConnectedToInternet]) {
            mapsSearchObject.searchMode = SKOSearchOffline; //go offline if not connected to internet
        }
        
        mapsSearchObject.searchTerm = searchObject.searchTerm;
        mapsSearchObject.coordinate = searchObject.coordinate;
        mapsSearchObject.radius = searchObject.radius;
        mapsSearchObject.searchLanguage = searchObject.searchLanguage;
        mapsSearchObject.itemsPerPage = searchObject.itemsPerPage;
        
        if (searchObject.searchCategory) {
            mapsSearchObject.searchCategories = @[searchObject.searchCategory];
        }
        
        mapsSearchObject.apiKey = self.apiKey;
        mapsSearchObject.apiSecret = self.apiSecret;
        
        [[searchServiceClass sharedInstance] setSearchServiceDelegate:self];
        [[searchServiceClass sharedInstance] search:mapsSearchObject];
    }
}

- (void)cancelSearch {
    Class searchServiceClass = NSClassFromString(@"MapsSearchService");
    
    if (searchServiceClass) {
        [[searchServiceClass sharedInstance] cancelSearch];
    }
}

- (SKOneBoxSearchResult *)mappedOneBoxSearchResultFromSearchResult:(SKOSearchResult*)searchResult {
    SKOneBoxSearchResult *result = [super mappedOneBoxSearchResultFromSearchResult:searchResult];
    
    NSMutableDictionary *additionalInformationMutable = [[result additionalInformation] mutableCopy];
    
    NSNumber *category = searchResult.additionalInformation[@"category"];
    
    if ([category intValue] != 0) {
        //we have a category, put the image for that category
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
        
        UIImage *catImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:[NSString stringWithFormat:@"icon_onebox_%i",[category intValue]] ofType:@"png"]];
        if (catImage) {
            [additionalInformationMutable setObject:catImage forKey:@"categoryIcon"];
        }
    }
    
    [result setAdditionalInformation:additionalInformationMutable];
    
    return result;
}

- (SKOneBoxSearchResultMetaData *)mappedMetaDataObjectFromSearchMetaData:(id)searchMetaData {
    return nil;
}

- (NSString *)localizedProviderName {
    return @"OpenStreetMap";
}

- (UIImage *)providerIcon {
    Class searchServiceClass = NSClassFromString(@"SKSearchService");
    
    if (searchServiceClass) {
        static UIImage *icon = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
            icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_osm_list_icon" ofType:@"png"]];
        });
        
        return icon;
    } else {
        return nil;
    }
}

- (NSArray *)sortingComparators {
    Class searchServiceClass = NSClassFromString(@"SKSearchService");
    
    if (searchServiceClass) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
        NSMutableArray *array = [NSMutableArray array];
        
        Class positionerServiceClass = NSClassFromString(@"SKPositionerService");
        
        [array addObject:({
            SKOneBoxSearchComparator *comparator = [SKOneBoxSearchComparator sortingComparatorWithTitle:@"Rank" image:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"best_match_sort_icon" ofType:@"png"]] activeImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"best_match_sort_icon_active" ofType:@"png"]] comparator:^NSComparisonResult(SKOneBoxSearchResult *obj1, SKOneBoxSearchResult *obj2) {
                
                //rankingIndex
                double ranking1 = [[[obj1 additionalInformation] objectForKey:@"ranking"] doubleValue];
                double ranking2 = [[[obj2 additionalInformation] objectForKey:@"ranking"] doubleValue];
                
                if (ranking1 < ranking2) {
                    return NSOrderedDescending;
                } else if (ranking1 > ranking2) {
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
            comparator.defaultSorting = YES;
            comparator;
        })];
        [array addObject:({
            SKOneBoxSearchComparator *comparator = [SKOneBoxSearchComparator sortingComparatorWithTitle:@"Name" image:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"name_sort_icon" ofType:@"png"]] activeImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"name_sort_icon_active" ofType:@"png"]] comparator:^NSComparisonResult(SKOneBoxSearchResult *obj1, SKOneBoxSearchResult *obj2) {
                NSString *first = [obj1 name];
                NSString *second = [obj2 name];
                return [first compare:second];
            }];
            comparator.defaultSorting = NO;
            comparator;
        })];
        [array addObject:({
            SKOneBoxSearchComparator *comparator = [SKOneBoxSearchComparator sortingComparatorWithTitle:@"Distance" image:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"distance_sort_icon" ofType:@"png"]] activeImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"distance_sort_icon_active" ofType:@"png"]] comparator:^NSComparisonResult(SKOneBoxSearchResult *obj1, SKOneBoxSearchResult *obj2) {
                CLLocationCoordinate2D currentLocation = [[positionerServiceClass sharedInstance] currentCoordinate];
                
                double distanceObj1 = [SKOSearchLibUtils getAirDistancePointA:currentLocation pointB:obj1.coordinate];
                double distanceObj2 = [SKOSearchLibUtils getAirDistancePointA:currentLocation pointB:obj2.coordinate];
                
                if (distanceObj1 < distanceObj2) {
                    return NSOrderedAscending;
                } else if (distanceObj1 > distanceObj2) {
                    return NSOrderedDescending;
                }
                return NSOrderedSame;
            }];
            comparator.defaultSorting = NO;
            comparator;
        })];
        return array;
    } else {
        return nil;
    }
}

#pragma mark - MapsSearchServiceDelegate

- (void)searchService:(MapsSearchService *)searchService didRetrieveSearchResults:(NSArray *)searchResults {
    for (id<SKSearchProviderDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(searchProvider:didReceiveResults:metaData:)]) {
            [delegate searchProvider:self didReceiveResults:searchResults metaData:nil];
        }
    }
}

- (void)searchServiceDidFailToRetrieveSearchResults:(MapsSearchService *)searchService {
    for (id<SKSearchProviderDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(searchProviderDidFailToRetrieveResults:)]) {
            [delegate searchProviderDidFailToRetrieveResults:self];
        }
    }
}

@end
