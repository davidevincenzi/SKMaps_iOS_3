//
//  SKOneBoxTestCase.m
//  SKOneBoxSearch
//
//  Created by Dragos Dobrean on 15/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxTestCase.h"

#define kOneBoxTestCaseSearchLanguageKey    @"searchLanguage"
#define kOneBoxTestCaseResultsKey           @"results"
#define kOneBoxTestCaseProviderIDKey        @"providerId"
#define kOneBoxTestCaseProviderNameKey      @"providerName"
#define kOneBoxTestCaseSearchTermKey        @"searchTerm"
#define kOneBoxTestCaseLongitudeKey         @"longitude"
#define kOneBoxTestCaseLatitudeKey          @"latitude"
#define kOneBoxTestCaseRadiusKey            @"radius"

@interface SKOneBoxTestCase()

// Contains NSArrays of SKOneBoxSearchResult for NSNumbers providers keys
@property (strong, nonatomic) NSMutableDictionary *results;

// The search term of the search
@property (strong, nonatomic) NSString *searchTerm;

// Names of the providers
@property (strong, nonatomic) NSMutableDictionary *providerNames;

// The language of the search
@property (strong, nonatomic) NSString *searchLanguage;

// Radius used for search
@property (strong, nonatomic) NSNumber *radius;

// The coordinate of the search object
@property (assign, nonatomic) CLLocationCoordinate2D coordinateOfSearch;

@end

@implementation SKOneBoxTestCase

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // Do additional setup
        self.results = [NSMutableDictionary new];
        self.providerNames = [NSMutableDictionary new];
        self.coordinateOfSearch = CLLocationCoordinate2DMake(0.0, 0.0);
        self.searchTerm = @"";
        self.radius = @(0);
    }
    
    return self;
}

- (instancetype)initFromJSONDictionary:(NSDictionary *)dictionary {
    self = [self init];
    
    NSString *searchLanguage = [dictionary objectForKey:kOneBoxTestCaseSearchLanguageKey];
    if (searchLanguage) {
        self.searchLanguage = searchLanguage;
    }
    
    NSString *searchTerm = [dictionary objectForKey:kOneBoxTestCaseSearchTermKey];
    if (searchTerm) {
        self.searchTerm = searchTerm;
    }
    
    NSNumber *latitude = [dictionary objectForKey:kOneBoxTestCaseLatitudeKey];
    NSNumber *longitude = [dictionary objectForKey:kOneBoxTestCaseLongitudeKey];
    
    if (latitude && longitude) {
        self.coordinateOfSearch = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
    }
    
    NSNumber *radius = [dictionary objectForKey:kOneBoxTestCaseRadiusKey];
    if (radius) {
        self.radius = radius;
    }
    
    // Fetch all results dictionary
    NSArray *results = [dictionary objectForKey:kOneBoxTestCaseResultsKey];
    
    for (NSDictionary *result in results) {
        // Result dictionary contains all the results from a provider
        NSString *providerName = [result objectForKey:kOneBoxTestCaseProviderNameKey];
        NSNumber *providerID = [result objectForKey:kOneBoxTestCaseProviderIDKey];
        
        if (providerID && providerName) {
            [self.providerNames setObject:providerName forKey:providerID];
        }
        
        // Fetch all the results from the current provider
        NSArray *searchResultsFromCurrentProvider = [result objectForKey:kOneBoxTestCaseResultsKey];
        
        if (searchResultsFromCurrentProvider) {
            // New array of search results for the provider will contain objects of kind SKOneBoxSearchResult
            NSMutableArray *searchResultsForProvider = [NSMutableArray new];
            
            for (NSDictionary *searchResultDictionary in searchResultsFromCurrentProvider) {
                // Init an object from the dictionary and save it to the current results array
                SKOneBoxSearchResult *resultForProvider = [[SKOneBoxSearchResult alloc] initFromJSONDictionary:searchResultDictionary];
                
                [searchResultsForProvider addObject:resultForProvider];
            }
            
            // put the results in the global dictionary
            [self.results setObject:searchResultsForProvider forKey:providerID];
        }
    }
    
    return self;
}

- (instancetype)initWithSearchResults:(NSDictionary *)results searchObject:(SKOneBoxSearchObject *)searchObject andProvidersNames:(NSDictionary *)providersNames {
    self = [self init];
    
    self.results = [NSMutableDictionary dictionaryWithDictionary:results];
    self.providerNames = [NSMutableDictionary dictionaryWithDictionary:providersNames];
    self.searchTerm = searchObject.searchTerm;
    self.searchLanguage = searchObject.searchLanguage;
    self.radius = searchObject.radius;
    self.coordinateOfSearch = searchObject.coordinate;
    
    return self;
}

#pragma mark - Public methods

- (NSDictionary *)toJSONDictionary {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    [json setObject:self.searchLanguage forKey:kOneBoxTestCaseSearchLanguageKey];
    [json setObject:self.searchTerm forKey:kOneBoxTestCaseSearchTermKey];
    [json setObject:self.radius forKey:kOneBoxTestCaseRadiusKey];
    [json setObject:@(self.coordinateOfSearch.latitude) forKey:kOneBoxTestCaseLatitudeKey];
    [json setObject:@(self.coordinateOfSearch.longitude) forKey:kOneBoxTestCaseLongitudeKey];
   
    NSMutableArray *allResults = [NSMutableArray new];
    
    for (NSNumber *providerID in self.providerNames) {
        // New json dictionary for current provider
        NSMutableDictionary *provider = [NSMutableDictionary new];
        
        // Set the provider name and id
        NSString *providerName = self.providerNames[providerID];
        
        [provider setObject:providerName forKey:kOneBoxTestCaseProviderNameKey];
        [provider setObject:providerID forKey:kOneBoxTestCaseProviderIDKey];
        
        NSMutableArray *resultsForProvider = [NSMutableArray new];
        
        // Set the results for each provider
        for (SKOneBoxSearchResult *result in self.results[providerID]) {
            NSDictionary *jsonResult = [result toJSONDictionary];
            
            [resultsForProvider addObject:jsonResult];
        }
        
        // Set the results as an array got the current provider
        [provider setObject:resultsForProvider forKey:kOneBoxTestCaseResultsKey];
        
        // Add the current provider to all results list
        [allResults addObject:provider];
    }
    
    // Set all the results to the initial json
    [json setObject:allResults forKey:kOneBoxTestCaseResultsKey];
    
    return json;
}

- (SKOneBoxSearchObject *)searchObject {
    SKOneBoxSearchObject *result = [SKOneBoxSearchObject oneBoxSearchObject];
    result.searchTerm = self.searchTerm;
    result.searchLanguage = self.searchLanguage;
    result.coordinate = self.coordinateOfSearch;
    result.radius = self.radius;
    
    return result;
}

- (NSDictionary *)allResults {
    return self.results;
}

- (NSDictionary *)allProviderNames {
    return self.providerNames;
}

@end
