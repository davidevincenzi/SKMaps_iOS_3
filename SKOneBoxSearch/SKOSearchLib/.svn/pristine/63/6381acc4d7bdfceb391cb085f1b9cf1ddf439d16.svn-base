//
//  SKOneBoxSearchResult.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchResult.h"
#import "NSString+SKOneBoxStringAdditions.h"
#import "SKOSearchLibUtils.h"
#import "SKOneBoxSearchResult+TableViewCellHelper.h"

NSString *const kSearchResultAdditionalInformationAPIRanking = @"resultRanking";

@implementation SKOneBoxSearchResult

- (id)init {
    self = [super init];
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake(0, 0);
        self.name = @"";
        self.type = SKOneBoxSearchResultStreet;
        
        self.relevancyType = SKOneBoxSearchResultHighRelevancy;
        self.topResult = NO;
        self.expected = YES;
    }
    return self;
}

- (instancetype)initFromJSONDictionary:(NSDictionary *)dictionary {
    self = [self init];
    
    NSString *uid = [dictionary valueForKey:@"uid"];
    if (uid) {
        self.uid = uid;
    }
    
    NSNumber *latitude = [dictionary valueForKey:@"latitude"];
    NSNumber *longitude = [dictionary valueForKey:@"longitude"];
    if (latitude && longitude) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        self.coordinate = coordinate;
    }
    
    NSNumber *type = [dictionary valueForKey:@"type"];
    if (type) {
        self.type = type.intValue;
    }
    
    NSNumber *relevancyType = [dictionary valueForKey:@"relevancyType"];
    if (relevancyType) {
        self.relevancyType = relevancyType.intValue;
    }
    
    NSNumber *topResult = [dictionary valueForKey:@"topResult"];
    if (topResult) {
        self.topResult = [topResult boolValue];
    }
    
    NSString *name = [dictionary valueForKey:@"name"];
    if (name) {
        self.name = name;
    }
    
    NSString *street = [dictionary valueForKey:@"street"];
    if (street) {
        self.street = street;
    }
    
    NSString *locality = [dictionary valueForKey:@"locality"];
    if (locality) {
        self.locality = locality;
    }
    
    NSString *subLocality = [dictionary valueForKey:@"subLocality"];
    if (subLocality) {
        self.subLocality = subLocality;
    }
    
    NSString *administrativeArea = [dictionary valueForKey:@"administrativeArea"];
    if (administrativeArea) {
        self.administrativeArea = administrativeArea;
    }
    
    NSString *administrativeAreaCode = [dictionary valueForKey:@"administrativeAreaCode"];
    if (administrativeAreaCode) {
        self.administrativeAreaCode = administrativeAreaCode;
    }
    
    NSString *subAdministrativeArea = [dictionary valueForKey:@"subAdministrativeArea"];
    if (subAdministrativeArea) {
        self.subAdministrativeArea = subAdministrativeArea;
    }
    
    NSString *postalCode = [dictionary valueForKey:@"postalCode"];
    if (postalCode) {
        self.postalCode = postalCode;
    }
    
    NSString *ISOcountryCode = [dictionary valueForKey:@"ISOcountryCode"];
    if (ISOcountryCode) {
        self.ISOcountryCode = ISOcountryCode;
    }
    
    NSString *country = [dictionary valueForKey:@"country"];
    if (country) {
        self.country = country;
    }
    
    NSDictionary *additionalInformation = [dictionary valueForKey:@"additionalInformation"];
    if (additionalInformation) {
        self.additionalInformation = additionalInformation;
    }
    
    NSNumber *expected = [dictionary valueForKey:@"expected"];
    if (expected) {
        self.expected = expected.boolValue;
    }
        
    return self;
}

+ (instancetype)oneBoxSearchResult {
    SKOneBoxSearchResult *oneBoxSearchResult = [[SKOneBoxSearchResult alloc] init];
    return oneBoxSearchResult;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToSearchResult:object];
}

//TODO expand
-(BOOL)isEqualToSearchResult:(SKOneBoxSearchResult*)object {
//    if ([self.name isEqualToString:@"Apple Inc."] && [object.locality isEqualToString:@"Cupertino"]) {
//        int x = 0;
//    }
    
    if ([[self postalCode] isEqualToString:[object postalCode]] && [self.houseNumber isEqualToString:[object houseNumber]]) {
        return YES;
    }
    if ([SKOneBoxSearchResult isSameLocation:self.coordinate asLocation:object.coordinate] &&
        ([[self name] isEqualToString:[object name]] ||
         ([self.houseNumber isEqualToString:[object houseNumber]] && [[self street] isEqualToString:[object street]]))) {
        return YES;
    }
    return NO;
}

+ (BOOL)isSameLocation:(CLLocationCoordinate2D)firstLocation asLocation:(CLLocationCoordinate2D)secondLocation {
    double epsilon = 0.001;//up to 110m
    double latitudeDifference = fabs(firstLocation.latitude - secondLocation.latitude);
    double longitudeDifference = fabs(firstLocation.longitude - secondLocation.longitude);
    
    BOOL returnVal = latitudeDifference <= epsilon && longitudeDifference <= epsilon;
    return returnVal;
}

- (double)rankingWeightTitleForSearchTerm:(NSString *)searchTerm {
    double titleDistance = 0;
    
    [self.title matchesTerm:searchTerm distance:&titleDistance];
    
    return titleDistance;
}

- (BOOL)matchesSearchTerm:(NSString *)searchTerm rankingWeight:(double*)rankingWeight {
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *editedTerm = [[searchTerm lowercaseString] stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:usLocale];
    NSString *editedTitle = [[self.title lowercaseString] stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:usLocale];
    
    NSUInteger totalMatchTitle = [SKOSearchLibUtils levenshteinDistanceFirstString:editedTitle secondString:editedTerm];
    
    double titleDistance = 0;
    double subtitleDistance = 0;
    
    BOOL returnValue = [[self title] matchesTerm:searchTerm distance:&titleDistance] || [self.subtitle matchesTerm:searchTerm distance:&subtitleDistance];
    
    if (titleDistance > 0.000001 && fabs(titleDistance - 1) < 0.000001) {
        //is 1
        titleDistance = titleDistance - (totalMatchTitle/1000.0f);
    }
    
    titleDistance *= 70;
    subtitleDistance *= 30;
    
    *rankingWeight = (titleDistance + subtitleDistance) / 100;
    
    return returnValue;
}

- (BOOL)hasLocationData {
    if (self.locality) {
        return YES;
    }
    if (self.subLocality) {
        return YES;
    }
    
    if ([[self additionalInformation] valueForKey:@"onelineAddress"]) {
        NSArray *componentsOneline = [[[self additionalInformation] valueForKey:@"onelineAddress"] componentsSeparatedByString:@","];
        if ([componentsOneline count]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)localityComponentsString {
    NSMutableArray *values = [NSMutableArray new];
    if (self.locality) {
        [values addObject:self.locality];
    }
    
    if (self.subLocality) {
        [values addObject:self.subLocality];
    }
    
    if (self.subAdministrativeArea) {
        [values addObject:self.subAdministrativeArea];
    }
    
    NSString *localitiesString = [values componentsJoinedByString:@" "];
    
    return localitiesString;
}

- (NSDictionary *)toJSONDictionary {
    
    NSMutableDictionary *additionalInformation = [NSMutableDictionary dictionaryWithDictionary:self.additionalInformation];
    for (id key in [additionalInformation allKeys]) {
        if (![[additionalInformation valueForKey:key] isKindOfClass:[NSString class]] && ![[additionalInformation valueForKey:key] isKindOfClass:[NSNumber class]]) {
            [additionalInformation removeObjectForKey:key];
        }
    }

    NSDictionary *dictionary =  @{
      @"uid": self.uid ? self.uid : @"",
      @"latitude":[NSNumber numberWithDouble:self.coordinate.latitude],
      @"longitude": [NSNumber numberWithDouble:self.coordinate.longitude],
      @"type": [NSNumber numberWithInt:self.type],
      @"relevancyType": [NSNumber numberWithInt:self.relevancyType],
      @"topResult": [NSNumber numberWithInt:self.topResult],
      @"name": self.name ? self.name : @"",
      @"street": self.street ? self.street : @"",
      @"locality": self.locality ? self.locality : @"",
      @"subLocality": self.subLocality ? self.subLocality : @"",
      @"administrativeArea": self.administrativeArea ? self.administrativeArea : @"",
      @"administrativeAreaCode": self.administrativeAreaCode ? self.administrativeAreaCode : @"",
      @"subAdministrativeArea": self.subAdministrativeArea ? self.subAdministrativeArea : @"",
      @"postalCode": self.postalCode ? self.postalCode : @"",
      @"houseNumber": self.houseNumber ? self.houseNumber : @"",
      @"ISOcountryCode": self.ISOcountryCode ? self.ISOcountryCode : @"",
      @"country": self.country ? self.country : @"",
      @"additionalInformation" :additionalInformation,
      @"expected" : [NSNumber numberWithBool:self.expected]
      };
    
    return dictionary;
}

- (BOOL)isValid {
    return self.coordinate.latitude != 0.0f && self.coordinate.longitude != 0.0f;
}

- (NSString *)description {
    NSString *string = [NSString stringWithFormat:@"(%f,%f), %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
                        self.coordinate.latitude,
                        self.coordinate.longitude,
                        self.name,
                        self.street,
                        self.locality,
                        self.subLocality,
                        self.administrativeArea,
                        self.administrativeAreaCode,
                        self.subAdministrativeArea,
                        self.postalCode,
                        self.houseNumber,
                        self.ISOcountryCode,
                        self.country];

    return string;
}

- (void)setNewRanking:(double)ranking {
    if (self.additionalInformation) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.additionalInformation];
        [dict setValue:[NSNumber numberWithDouble:ranking] forKey:@"ranking"];
        self.additionalInformation = dict;
    }
    else {
        self.additionalInformation = @{@"ranking":[NSNumber numberWithDouble:ranking]};
    }
}

- (BOOL)isMajorCity {
    return self.type == SKOneBoxSearchResultLocality || self.type == SKOneBoxSearchResultSubLocality;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    SKOneBoxSearchResult *copy = [[SKOneBoxSearchResult alloc] init];
    
    if (copy) {
        copy.uid = self.uid;
        copy.coordinate = self.coordinate;
        copy.type = self.type;
        copy.relevancyType = self.relevancyType;
        copy.topResult = self.topResult;
        copy.name = self.name; // eg. Apple Inc.
        copy.street = self.street;
        copy.locality = self.locality;
        copy.subLocality = self.subLocality;
        copy.administrativeArea = self.administrativeArea;
        copy.administrativeAreaCode = self.administrativeAreaCode;
        copy.subAdministrativeArea = self.subAdministrativeArea;
        copy.postalCode = self.postalCode;
        copy.houseNumber = self.houseNumber;
        copy.ISOcountryCode = self.ISOcountryCode;
        copy.country = self.country;
        copy.additionalInformation = self.additionalInformation;
    }
    
    return copy;
}

@end
