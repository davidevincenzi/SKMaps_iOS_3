//
//  AppleSearchService.m
//

#import "AppleSearchService.h"

@implementation AppleSearchService {
    __block CLGeocoder *lastCoder;
}

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Public methods

- (void)startAddressSearchWithObject:(AppleSearchObject *)appleSearchObject inRegion:(CLRegion *)region withCompletionHandler:(CLGeocodeCompletionHandler)completionHandler {
    
    NSString *searchString = [self searchStringFromAppleSearchObject:appleSearchObject];
    
    if ([searchString length] > 0) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        lastCoder = geocoder;
        if (region) {
            [geocoder geocodeAddressString:searchString inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
                completionHandler(placemarks, error);
            }];
        } else {
            [geocoder geocodeAddressString:searchString completionHandler:^(NSArray *placemarks, NSError *error) {
                completionHandler(placemarks, error);
            }];
        }
        
    }
}

- (void)cancelSearch {
    [lastCoder cancelGeocode];
}

- (NSArray *)supportedCountries {
    return @[@"GB", @"US"];
}

#pragma mark - Private methods

- (NSString *)searchStringFromAppleSearchObject:(AppleSearchObject *)appleSearchObject {
    NSString *searchString = @"";
    
    if ([appleSearchObject.houseNumber length] > 0) {
        NSString *houseNr = [NSString stringWithFormat:@"%@ ", appleSearchObject.houseNumber];
        searchString = [searchString stringByAppendingString:houseNr];
    }
    
    if ([appleSearchObject.street length] > 0) {
        NSString *street = [NSString stringWithFormat:@"%@, ", appleSearchObject.street];
        searchString = [searchString stringByAppendingString:street];
    }
    
    if ([appleSearchObject.city length] > 0) {
        NSString *city = [NSString stringWithFormat:@"%@, ", appleSearchObject.city];
        searchString = [searchString stringByAppendingString:city];
    }
    
    if ([appleSearchObject.state length] > 0) {
        NSString *state = [NSString stringWithFormat:@"%@, ", appleSearchObject.state];
        searchString = [searchString stringByAppendingString:state];
    }
    
    if ([appleSearchObject.country length] > 0) {
        NSString *country = [NSString stringWithFormat:@"%@", appleSearchObject.country];
        searchString = [searchString stringByAppendingString:country];
    }
    
    return searchString;
}

@end
