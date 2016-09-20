//
//  SKOneBoxCoreDataManager+SKOneBoxSearchObject.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxCoreDataManager+SKOneBoxSearchObject.h"
#import "SKOneBoxRecentSearch.h"

@implementation SKOneBoxCoreDataManager (SKOneBoxSearchObject)

-(void)saveSearchObject:(SKOneBoxSearchObject*)searchObject {
    if (searchObject && [searchObject.searchTerm length]) {
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@", ."];
        
        NSString *searchTerm = [searchObject.searchTerm stringByTrimmingCharactersInSet:
                                   set];
        
        NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"searchText LIKE[cd] %@",
                                    searchTerm];
        NSArray *results = [self searchListUsingPredicate:predicate];
        
        SKOneBoxRecentSearch *search = nil;
        if ([results count]) {
            search = [results objectAtIndex:0];
            //increase frequency count
            search.frequency = [NSNumber numberWithInteger:search.frequency.integerValue+1];
        }
        else {
            SKOneBoxRecentSearch *search = [self createEmptySearch];
            search.searchText = searchTerm;
            search.frequency = @1;
        }
        search.date = [NSDate date];
        [self save];
    }
}

-(void)saveSearchResultObject:(SKOneBoxSearchResult*)searchResultObject {
    SKOneBoxSearchObject *searchObject = [SKOneBoxSearchObject oneBoxSearchObject];
    searchObject.searchTerm = searchResultObject.name;
    [self saveSearchObject:searchObject];
}

-(NSArray*)searchesForObject:(SKOneBoxSearchObject*)searchObject {
    if (searchObject && [searchObject.searchTerm length]) {
        NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"searchText CONTAINS[cd] %@ && NOT (searchText LIKE[cd] %@)",
                                    searchObject.searchTerm, searchObject.searchTerm];
        return [self searchListUsingPredicate:predicate];
    }
    return [self searchList];
}

@end
