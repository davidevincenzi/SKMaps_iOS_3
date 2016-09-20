//
//  SKOneBoxTopHit.m
//  SKOSearchLib
//
//  Created by Dragos Dobrean on 02/02/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxTopHit.h"
#import "SKOneBoxSearchResult+TableViewCellHelper.h"
#import "SKOSearchLibUtils.h"
#import "SKSearchProviderProtocol.h"

@implementation SKOneBoxTopHit

#pragma mark - Public Methods

- (void)markTopHitsFromResults:(NSDictionary *)results withSearchProviders:(NSArray *)searchProviders andCompletitionBlock:(void(^)(NSDictionary *markedResults))block {
    // Look among all the results an compare them
    NSArray *allKeys = results.allKeys;
    
    // If we have search providers use those keys for order
    if (searchProviders && searchProviders.count > 0) {
        NSMutableArray *keys = [NSMutableArray new];
        for (id<SKSearchProviderProtocol> value in searchProviders) {
            [keys addObject:[value providerID]];
        }
        
        allKeys = keys;
    }
    
    // Unmark all the results
    for (NSNumber *key in allKeys) {
        for (SKOneBoxSearchResult *result in results[key]) {
            result.topResult = NO;
        }
    }
    
    NSMutableArray *marked = [NSMutableArray new];
    NSMutableDictionary *markedDictionary = [NSMutableDictionary new];
    
    // Consturct the results dictionary
    for (NSNumber *key in allKeys) {
        NSMutableArray *array = [NSMutableArray new];
        [markedDictionary setObject:array forKey:key];
    }
    
    // Iterate all keys
    for (int i = 0; i < allKeys.count; i++) {
        NSNumber *firstKey = [allKeys objectAtIndex:i];
        NSArray *resultForFirstKey = [results objectForKey:firstKey];
        
        resultForFirstKey = [resultForFirstKey sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            SKOneBoxSearchResult *first = (SKOneBoxSearchResult *)obj1;
            SKOneBoxSearchResult *second = (SKOneBoxSearchResult *)obj2;
            
            NSNumber *firstRank = first.additionalInformation[@"ranking"];
            NSNumber *secondRank = second.additionalInformation[@"ranking"];
            
            return [secondRank compare:firstRank];
        }];
        
        // For every result for the current key
        for (int j = 0; j < resultForFirstKey.count && j < SKOneBoxTopHitNumberOfVisibleResults; j++) {
            SKOneBoxSearchResult *result = resultForFirstKey[j];
            // If the result exists in the next results, mark it as top hit,
            // and was not marked before
            if ([self existsResult:result inResults:results keys:allKeys andProvidersFromIndex:i] && ![self existsResult:result inArray:marked]) {
                result.topResult = YES;
                [marked addObject:result];
            }
        }
    }

    if (block) {
        block(results);
    }
}

#pragma mark - Private Methods

/** Check if a results exists in the other providers
 @param result - the result for which we check
 @param results - all the results for which we do the search
 @param index - the index of the provider for the result we search
 
 @return YES if exists, NO otherwise
 */
- (BOOL)existsResult:(SKOneBoxSearchResult *)result inResults:(NSDictionary *)results keys:(NSArray *)allKeys andProvidersFromIndex:(int)index {
    
    for (int i = index + 1; i < allKeys.count; i++) {
        NSArray *values = [results objectForKey:allKeys[i]];
        
        values = [values sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            SKOneBoxSearchResult *first = (SKOneBoxSearchResult *)obj1;
            SKOneBoxSearchResult *second = (SKOneBoxSearchResult *)obj2;
            
            NSNumber *firstRank = first.additionalInformation[@"ranking"];
            NSNumber *secondRank = second.additionalInformation[@"ranking"];
            
            return [secondRank compare:firstRank];
        }];
        
        for (int j = 0; j < values.count && j < SKOneBoxTopHitNumberOfVisibleResults; j++) {
            SKOneBoxSearchResult *otherResult = values[j];
            
            // Compare the results
            if ([self is:result equalWithOtherResult:otherResult]) {
                return YES;
            }
        }
    }
    
    return NO;
}


/** Checks if a result exist in a provided array, using the local comparator
 function
 */
- (BOOL)existsResult:(SKOneBoxSearchResult *)result inArray:(NSArray *)results {
    for (SKOneBoxSearchResult *value in results) {
        if ([self is:result equalWithOtherResult:value]) {
            return YES;
        }
    }
    
    return NO;
}

/** Checks if two results are equal
 */
- (BOOL)is:(SKOneBoxSearchResult *)result equalWithOtherResult:(SKOneBoxSearchResult *)otherResult {
    if (result.type != otherResult.type) {
        return NO;
    }
    
    if (result.type == SKOneBoxSearchResultPOI) {
        if ([result.name isEqual:otherResult.name]) {
            return YES;
        }
    } else {
        if ([SKOSearchLibUtils isSameLocation:result.coordinate asLocation:otherResult.coordinate withDistance:2000]) {
            
            switch (result.type) {
                case SKOneBoxSearchResultStreet:
                    return [result.street isEqual:otherResult.street];
                    break;
                case SKOneBoxSearchResultLocality:
                    return [result.locality isEqualToString:otherResult.locality];
                case SKOneBoxSearchResultAdministrativeArea:
                    return [result.administrativeArea isEqualToString:otherResult.administrativeArea];
                case SKOneBoxSearchResultPostalCode:
                    return [result.postalCode isEqualToString:otherResult.postalCode];
                case SKOneBoxSearchResultCountry:
                    return [result.country isEqualToString:otherResult.country];
                case SKOneBoxSearchResultSubLocality:
                    return [result.subLocality isEqualToString:otherResult.subLocality];
                default:
                    return [result.name isEqualToString:otherResult.name];
            }
        }
    }
    
    return NO;
}

@end
