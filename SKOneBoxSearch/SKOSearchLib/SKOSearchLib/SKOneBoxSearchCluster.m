//
//  SKOneBoxSearchCluster.m
//  SKOSearchLib
//
//  Created by Dragos Dobrean on 06/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchCluster.h"

#define kOneBoxSearchProviderWeight 100
#define kOneBoxSearchResultWeight   1

@interface SKOneBoxSearchCluster()

// The bounding box of the cluster
@property (strong, nonatomic) SKOBBox *boundingBox;

// Results contains objects of SKOneBoxSearchResult for providers keys
@property (strong, atomic) NSMutableDictionary* resultsFromProviders;

// The number of the results from cluster
@property (assign, atomic) int numberOfResults;

@end

@implementation SKOneBoxSearchCluster

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.resultsFromProviders = [NSMutableDictionary new];
        self.numberOfResults = 0;
    }
    
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andRadius:(int)radius {
    self = [self init];
    self.boundingBox = [SKOBBox boundingBoxForCoordinate:coordinate radius:radius];
    
    return self;
}

- (instancetype)initWithTopLeftCoordinate:(CLLocationCoordinate2D)topCoordinate andBottomRightCoordinate:(CLLocationCoordinate2D)bootomCoordinate {
    self = [self init];
    self.boundingBox = [SKOBBox boundingBoxWithTopLeftCoordinate:topCoordinate bottomRightCoordinate:bootomCoordinate];
    
    return self;
}

#pragma mark - Public methods

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate {
    return [self.boundingBox containsLocation:coordinate];
}

- (void)addResult:(SKOneBoxSearchResult *)result fromProviderID:(NSNumber *)providerID {
    
    if ([[self.resultsFromProviders allKeys] containsObject:providerID]) {
        // Add the result in the dictonary keys
        NSMutableArray *resultsForProvider = self.resultsFromProviders[providerID];
        [resultsForProvider addObject:result];
        
    } else {
        // The key does not exist, create a new one
        NSMutableArray *resultsForProvider = [NSMutableArray new];
        [resultsForProvider addObject:result];
        
        [self.resultsFromProviders setObject:resultsForProvider forKey:providerID];
    }
    
    // Increase the number of results
    self.numberOfResults++;
}

- (long)numberOfProviders {
    return [self.resultsFromProviders allKeys].count;
}

- (NSDictionary *)allResultsAndProvidersFromCluster {
    return self.resultsFromProviders;
}

- (NSArray *)allResults {
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSNumber *providerID in self.resultsFromProviders.allKeys) {
        NSArray *providerResults = self.resultsFromProviders[providerID];
        [results addObjectsFromArray:providerResults];
    }
    
    return results;
}

- (long)weight {
    return (self.numberOfProviders * kOneBoxSearchProviderWeight) + (self.numberOfResults * kOneBoxSearchResultWeight);
}

- (NSArray *)resultsForProvider:(NSNumber *)providerID {
    if ([[self.resultsFromProviders allKeys] containsObject:providerID]) {
        return self.resultsFromProviders[providerID];
    }
    
    return [NSArray new];
}

@end
