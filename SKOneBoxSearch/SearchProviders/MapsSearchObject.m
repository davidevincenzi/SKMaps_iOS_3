//
//  MapsSearchObject.m
//

#import "MapsSearchObject.h"

@implementation MapsSearchObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.countryCode = @"";
        self.searchTerm = @"";
        self.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        self.itemsPerPage = @20;
    }
    return self;
}

+ (instancetype)searchObject {
    MapsSearchObject *searchObject = [[MapsSearchObject alloc] init];
    return searchObject;
}

@end
