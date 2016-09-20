//
//  SKOneBoxSearchResult+TableViewCellHelper.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchResult+TableViewCellHelper.h"
#import "SKOSearchLibUtils.h"

typedef NS_ENUM(NSInteger, SKOneBoxSearchResultDataTypes) {
    SKOneBoxSearchResultDataTypeName = 0, // eg. Apple Inc.
    SKOneBoxSearchResultDataTypeStreet,//eg. 1 Infinite Loop.
    SKOneBoxSearchResultDataTypeLocality,// City, eg. Cupertino.
    SKOneBoxSearchResultDataTypeSubLocality, //Neighborhood, common name, eg. Mission District.
    SKOneBoxSearchResultDataTypeAdministrativeArea, //State, eg. California.
    SKOneBoxSearchResultDataTypeSubAdministrativeArea, //County, eg. Santa Clara.
    SKOneBoxSearchResultDataTypePostalCode, //Zip code, eg. 95014.
    SKOneBoxSearchResultDataTypeHouseNumber, //House number, eg. 1.
    SKOneBoxSearchResultDataTypeCountry, //Country for the search result eg. United States.
    SKOneBoxSearchResultDataTypeOnelineAddress //Full address in one line, additionaInformation['oneline']
};

#define kSKOneBoxSearchResultSeparator @", "
#define kSKOneBoxSearchResultEmptySeparator @" "

@implementation SKOneBoxSearchResult (TableViewCellHelper)

- (NSString *)title {
    if (self.type == SKOneBoxSearchResultPOI && [self.name length]) {
        // POI
        return [self concatenatedStringFor:[self POITitleOrder] withSeparator:kSKOneBoxSearchResultSeparator];
    } else {
        // Address
        NSString *returnValue;
        if ([SKOSearchLibUtils isCoordinateInUS:self.coordinate]) {
            // Result is in US
            if ([self isMajorCity]) {
                returnValue = [self concatenatedStringFor:[self cityTitleOrderUS] withSeparator:kSKOneBoxSearchResultEmptySeparator];
            }
            else {
                returnValue = [self concatenatedStringFor:[self addressTitleOrderUS] withSeparator:kSKOneBoxSearchResultEmptySeparator];
            }

        } else {
            // Rest of the world
            if ([self isMajorCity]) {
                returnValue = [self concatenatedStringFor:[self cityTitleOrderNonUS] withSeparator:kSKOneBoxSearchResultEmptySeparator];
            }
            else {
                returnValue = [self concatenatedStringFor:[self addressTitleOrderNonUS] withSeparator:kSKOneBoxSearchResultEmptySeparator];
            }
        }
        
        if (returnValue.length) {
            return returnValue;
        } else {
            if ([self.name length] > 0) {
                return self.name;
            }
        }
    }

    return @"";
}

- (NSString *)subtitle {
    if ([self.additionalInformation objectForKey:@"onelineAddress"]) {
        return [self.additionalInformation objectForKey:@"onelineAddress"];
    }
    
    NSString *returnValue;
    if ([SKOSearchLibUtils isCoordinateInUS:self.coordinate]) {
        // Result is in US
        if (self.type == SKOneBoxSearchResultPOI && [self.name length]) {
            // POI
            return [self concatenatedStringFor:[self POISubtitleOrderUS] withSeparator:kSKOneBoxSearchResultSeparator];
        }
        else {
            if ([self isMajorCity]) {
                returnValue = [self concatenatedStringFor:[self citySubtitleOrderUS] withSeparator:kSKOneBoxSearchResultEmptySeparator];
            }
            else {
                returnValue = [self concatenatedStringFor:[self addressSubtitleOrderUS] withSeparator:kSKOneBoxSearchResultEmptySeparator];
            }
        }
        
    } else {
        // Rest of the world
        if (self.type == SKOneBoxSearchResultPOI && [self.name length]) {
            // POI
            return [self concatenatedStringFor:[self POISubtitleOrderNonUS] withSeparator:kSKOneBoxSearchResultSeparator];
        }
        else {
            if ([self isMajorCity]) {
                returnValue = [self concatenatedStringFor:[self citySubtitleOrderNonUS] withSeparator:kSKOneBoxSearchResultEmptySeparator];
            }
            else {
                returnValue = [self concatenatedStringFor:[self addressSubtitleOrderNonUS] withSeparator:kSKOneBoxSearchResultEmptySeparator];
            }
        }
    }
    return returnValue;
}


#pragma mark - Private methods

/** Returns the mapped value for a data tyepe
 */
- (NSString *)valueForDataType:(SKOneBoxSearchResultDataTypes)dataType {
    switch (dataType) {
        case SKOneBoxSearchResultDataTypeName:
            return self.name;
        case SKOneBoxSearchResultDataTypeStreet:
            return self.street;
        case SKOneBoxSearchResultDataTypeLocality:
            if (self.locality.length) {
                return self.locality;
            }
            else if (self.subLocality.length) {
                return self.subLocality;
            }
            return @"";
        case SKOneBoxSearchResultDataTypeSubLocality:
            return self.subLocality;
        case SKOneBoxSearchResultDataTypeAdministrativeArea:
            if(self.administrativeArea.length) {
                return self.administrativeArea;
            }
            else if (self.administrativeAreaCode.length) {
                return self.administrativeAreaCode;
            }
            else if(self.subAdministrativeArea.length) {
                return self.subAdministrativeArea;
            }
            return @"";
        case SKOneBoxSearchResultDataTypeSubAdministrativeArea:
            return self.subAdministrativeArea;
        case SKOneBoxSearchResultDataTypePostalCode:
            return self.postalCode;
        case SKOneBoxSearchResultDataTypeHouseNumber:
            return self.houseNumber;
        case SKOneBoxSearchResultDataTypeCountry:
            if (self.country.length) {
                return self.country;
            }
            else if(self.ISOcountryCode.length) {
                return self.ISOcountryCode;
            }
            return @"";
        case SKOneBoxSearchResultDataTypeOnelineAddress:
            if (self.additionalInformation && self.additionalInformation[@"oneline"]) {
                return self.additionalInformation[@"oneline"];
            }
            return @"";
        default:
            return @"";
    }
}

/** Creates a string with the elements from the order array separated
 by the provided separator
 */
- (NSString *)concatenatedStringFor:(NSArray *)order withSeparator:(NSString *)separator {
    NSString *returnValue = @"";
    
    // Iterate every valu from the provided order and return the concatenated string
    for (NSNumber *value in order) {
        NSString *stringValue = [self valueForDataType:value.intValue];
        
        if (!stringValue.length) {
            continue;
        }
        
        if (!returnValue.length) {
            returnValue = stringValue;
        } else {
            returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%@%@", separator, stringValue]];
        }
    }
    
    return returnValue;
}

#pragma mark - Oder Definition

// US City
- (NSArray *)cityTitleOrderUS {
    NSArray *order = @[@(SKOneBoxSearchResultLocality)];
    
    return order;
}

- (NSArray *)citySubtitleOrderUS {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypePostalCode),@(SKOneBoxSearchResultDataTypeAdministrativeArea),@(SKOneBoxSearchResultDataTypeCountry)];
    
    return order;
}

// Non-US City
- (NSArray *)cityTitleOrderNonUS {
    NSArray *order = @[@(SKOneBoxSearchResultLocality)];
    
    return order;
}

- (NSArray *)citySubtitleOrderNonUS {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypePostalCode),@(SKOneBoxSearchResultDataTypeCountry)];
    
    return order;
}

// Defines the order for the POI Title
- (NSArray *)POITitleOrder {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypeName)];
    
    return order;
}

//Street name, zip code, city name, state code, country name
- (NSArray *)POISubtitleOrderUS {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypeStreet),@(SKOneBoxSearchResultDataTypePostalCode),@(SKOneBoxSearchResultDataTypeLocality),@(SKOneBoxSearchResultDataTypeAdministrativeArea),@(SKOneBoxSearchResultDataTypeCountry)];
    
    return order;
}

//Street name, zip code, city name, county, country name
- (NSArray *)POISubtitleOrderNonUS {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypeStreet),@(SKOneBoxSearchResultDataTypePostalCode),@(SKOneBoxSearchResultDataTypeLocality),@(SKOneBoxSearchResultDataTypeSubLocality),@(SKOneBoxSearchResultDataTypeCountry)];
    
    return order;
}

// Non-US Addresses
- (NSArray *)addressTitleOrderNonUS {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypeStreet), @(SKOneBoxSearchResultDataTypeHouseNumber)];
    
    return order;
}

//City name, zip code, country name
- (NSArray *)addressSubtitleOrderNonUS {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypeLocality), @(SKOneBoxSearchResultDataTypePostalCode),@(SKOneBoxSearchResultDataTypeCountry)];
    
    return order;
}

// US Addresses
- (NSArray *)addressTitleOrderUS {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypeHouseNumber), @(SKOneBoxSearchResultDataTypeStreet)];
    
    return order;
}

//City name, zip code, state code, country name
- (NSArray *)addressSubtitleOrderUS {
    NSArray *order = @[@(SKOneBoxSearchResultDataTypeLocality), @(SKOneBoxSearchResultDataTypePostalCode), @(SKOneBoxSearchResultDataTypeAdministrativeArea),@(SKOneBoxSearchResultDataTypeCountry)];
    
    return order;
}

@end
