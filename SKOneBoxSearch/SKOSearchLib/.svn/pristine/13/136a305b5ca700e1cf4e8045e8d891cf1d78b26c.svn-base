//
//  SKOneBoxSearchCluster.h
//  SKOSearchLib
//
//  Created by Dragos Dobrean on 06/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOBBox.h"
#import "SKOneBoxSearchResult.h"
#import "SKSearchBaseProvider.h"

@interface SKOneBoxSearchCluster : NSObject

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andRadius:(int)radius;
- (instancetype)initWithTopLeftCoordinate:(CLLocationCoordinate2D)topCoordinate andBottomRightCoordinate:(CLLocationCoordinate2D)bootomCoordinate;

// Checks if the coordinate provider is in the bounding box of the cluster
- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

/** Adds a new result to the cluster for the specified provider ID
 @param result - the search result
 @param provideID - the id for the search result provider
 */
- (void)addResult:(SKOneBoxSearchResult *)result fromProviderID:(NSNumber *)providerID;

// Returns the total number of providers from the cluster
- (long)numberOfProviders;

// Returns all the results as values to the providers from the cluster
- (NSDictionary *)allResultsAndProvidersFromCluster;

// Returns all the results from the cluster
- (NSArray *)allResults;

// Returns the weight of the cluster
- (long)weight;

// Returns all the results from the cluster for the provided providerID
- (NSArray *)resultsForProvider:(NSNumber *)providerID;

@end
