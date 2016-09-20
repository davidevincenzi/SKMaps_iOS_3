//
//  SKOneBoxFilterOperation.h
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOneBoxSearchResult.h"
#import "SKOneBoxSearchObject.h"

@interface SKOneBoxFilterOperation : NSOperation

@property (nonatomic, copy) void (^foundProbableLocationBlock)(SKOneBoxSearchResult *mostProbableLocation);

-(id)initWithMinimumRelevancyType:(SKOneBoxSearchResultRelevancyType)minimumRelevancyType minimumProviders:(int)minimumProviders searchObject:(SKOneBoxSearchObject*)searchObject dictionaryToFilter:(NSMutableDictionary*)dictionaryToFilter completionBlock:(void (^)(SKOneBoxFilterOperation *filterOperation,NSDictionary *filteredDictionary))completionBlock;

@end
