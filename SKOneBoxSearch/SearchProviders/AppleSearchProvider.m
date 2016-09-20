//
//  AppleSearchProvider.m
//

#import "AppleSearchProvider.h"
#import "Reachability.h"
#import <MapKit/MapKit.h>
#import <SKMaps/SKPositionerService.h>

@interface AppleSearchProvider ()

@property (nonatomic, strong) MKLocalSearch *localSearch;

@end

@implementation AppleSearchProvider

#pragma mark - SKSearchProviderProtocol

- (void)search:(SKOneBoxSearchObject *)searchObject {
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // Confine the map search area to the user's current location.
    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(searchObject.coordinate, [searchObject.radius doubleValue], [searchObject.radius doubleValue]);
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchObject.searchTerm;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
        if (error != nil) {
            for (id<SKSearchProviderDelegate> delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(searchProviderDidFailToRetrieveResults:)]) {
                    [delegate searchProviderDidFailToRetrieveResults:self];
                }
            }
        } else {
            NSArray *placemarks = nil;
            if (response) {
                placemarks = [response mapItems];
            }
            
            for (id<SKSearchProviderDelegate> delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(searchProvider:didReceiveResults:metaData:)]) {
                    [delegate searchProvider:self didReceiveResults:placemarks metaData:nil];
                }
            }
        }
    };
    
    if ([searchObject.searchTerm length] > 0) {
        if (self.searchMode == SKOSearchOffline) {
            completionHandler(nil, nil);
        } else {
            if (self.localSearch != nil) {
                self.localSearch = nil;
            }
            self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
            
            [self.localSearch startWithCompletionHandler:completionHandler];
        }
    } else {
        completionHandler(nil, nil);
    }
}

- (void)cancelSearch {
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
}

typedef NS_ENUM (NSInteger, SKAppleResultType)
{
    SKAppleResultLocality,
    SKAppleResultSubLocality,
    SKAppleResultAdministrativeArea,
    SKAppleResultSubAdministrativeArea,
    SKAppleResultPostalCode,
    SKAppleResultStreet,
    SKAppleResultHouseNumber,
    SKAppleResultCountry,
    SKAppleResultPOI
};

-(SKOneBoxSearchResultType)oneBoxTypeFromAppleType:(SKAppleResultType)appleType {
    switch (appleType) {
        case SKAppleResultLocality:
            return SKOneBoxSearchResultLocality;
            break;
        case SKAppleResultSubLocality:
            return SKOneBoxSearchResultSubLocality;
            break;
        case SKAppleResultAdministrativeArea:
            return SKOneBoxSearchResultAdministrativeArea;
            break;
        case SKAppleResultSubAdministrativeArea:
            return SKOneBoxSearchResultAdministrativeArea;
            break;
        case SKAppleResultPostalCode:
            return SKOneBoxSearchResultPostalCode;
            break;
        case SKAppleResultStreet:
            return SKOneBoxSearchResultStreet;
            break;
        case SKAppleResultHouseNumber:
            return SKOneBoxSearchResultStreet;
            break;
        case SKAppleResultCountry:
            return SKOneBoxSearchResultCountry;
            break;
        default:
            return SKOneBoxSearchResultPOI;
            break;
    }
}

-(SKAppleResultType)appleResultTypeForMapItem:(MKMapItem*)mapItem {
    SKAppleResultType type = SKAppleResultPOI;
    
    if ([mapItem.name isEqualToString:mapItem.placemark.thoroughfare]) {
        type = SKAppleResultStreet;
    }
    else if ([mapItem.name isEqualToString:mapItem.placemark.subThoroughfare]) {
        type = SKAppleResultHouseNumber;
    }
    else if ([mapItem.name isEqualToString:mapItem.placemark.locality]) {
        type = SKAppleResultLocality;
    }
    else if ([mapItem.name isEqualToString:mapItem.placemark.subLocality]) {
        type = SKAppleResultSubLocality;
    }
    else if ([mapItem.name isEqualToString:mapItem.placemark.administrativeArea]) {
        type = SKAppleResultAdministrativeArea;
    }
    else if ([mapItem.name isEqualToString:mapItem.placemark.subAdministrativeArea]) {
        type = SKAppleResultSubAdministrativeArea;
    }
    else if ([mapItem.name isEqualToString:mapItem.placemark.postalCode]) {
        type = SKAppleResultPostalCode;
    }
    else if ([mapItem.name isEqualToString:mapItem.placemark.country]) {
        type = SKAppleResultCountry;
    }
    else if ([mapItem.name isEqualToString:mapItem.placemark.countryCode]) {
        type = SKAppleResultCountry;
    }
    
    return type;
}

- (SKOneBoxSearchResult *)mappedOneBoxSearchResultFromSearchResult:(MKMapItem *)searchResult {
    SKOneBoxSearchResult *oneBoxSearchResult = [SKOneBoxSearchResult oneBoxSearchResult];
    
    oneBoxSearchResult.name = searchResult.placemark.name;
    oneBoxSearchResult.coordinate = [[searchResult.placemark location]  coordinate];
    
    oneBoxSearchResult.street = searchResult.placemark.thoroughfare;
    oneBoxSearchResult.locality = searchResult.placemark.locality;
    oneBoxSearchResult.subLocality = searchResult.placemark.subLocality;
    oneBoxSearchResult.administrativeArea = searchResult.placemark.administrativeArea;
    oneBoxSearchResult.subAdministrativeArea = searchResult.placemark.subAdministrativeArea;
    oneBoxSearchResult.postalCode = searchResult.placemark.postalCode;
    oneBoxSearchResult.ISOcountryCode = searchResult.placemark.ISOcountryCode;
    oneBoxSearchResult.country = searchResult.placemark.country;
    oneBoxSearchResult.houseNumber = searchResult.placemark.subThoroughfare;
    
    if (self.providerIcon) {
        oneBoxSearchResult.additionalInformation = @{@"icon":self.providerIcon};
    }
    
    SKAppleResultType type = [self appleResultTypeForMapItem:searchResult];
    
    oneBoxSearchResult.type = [self oneBoxTypeFromAppleType:type];
    
    return oneBoxSearchResult;
}

- (NSArray *)sortingComparators {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    NSMutableArray *array = [NSMutableArray array];
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
            NSString *first = [obj1 title];
            NSString *second = [obj2 title];
            
            NSComparisonResult result = [first compare:second];
            
            return result;
        }];
        comparator.defaultSorting = NO;
        comparator;
    })];
    [array addObject:({
        SKOneBoxSearchComparator *comparator = [SKOneBoxSearchComparator sortingComparatorWithTitle:@"Distance" image:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"distance_sort_icon" ofType:@"png"]] activeImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"distance_sort_icon_active" ofType:@"png"]] comparator:^NSComparisonResult(SKOneBoxSearchResult *obj1, SKOneBoxSearchResult *obj2) {
            CLLocationCoordinate2D currentLocation = [[SKPositionerService sharedInstance] currentCoordinate];
            
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
}

- (SKOneBoxSearchResultMetaData *)mappedMetaDataObjectFromSearchMetaData:(id)searchMetaData {
    return nil;
}

- (NSString *)localizedProviderName {
    return @"Apple";
}

- (BOOL)shouldAppearInDefaultList {
    return NO;
}

- (BOOL)shouldShowCategories {
    return NO;
}

- (UIImage *)providerIcon {
    static UIImage *icon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
        icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_apple_list_icon" ofType:@"png"]];
    });
    
    return icon;
}

@end
