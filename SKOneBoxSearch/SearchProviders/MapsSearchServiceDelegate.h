//
//  MapsSearchServiceDelegate.h
//

#import <Foundation/Foundation.h>

@class MapsSearchService;

@protocol MapsSearchServiceDelegate <NSObject>

- (void)searchService:(MapsSearchService *)searchService didRetrieveSearchResults:(NSArray *)searchResults;
- (void)searchServiceDidFailToRetrieveSearchResults:(MapsSearchService *)searchService;

@end
