//
//  MapsSearchService.h
//

#import <Foundation/Foundation.h>
#import "MapsSearchServiceDelegate.h"
#import "MapsSearchObject.h"

/** MapsSearchService class provides services for searching POIs and addresses using ScoutSDK oneline search.
 */
@interface MapsSearchService : NSObject

/** Returns the singleton search service.
 */
+ (instancetype)sharedInstance;

/** The caller objects should adopt the MapsSearchServiceDelegate to receive callbacks.
 */
@property (atomic, weak) id<MapsSearchServiceDelegate> searchServiceDelegate;

/** Supports local search.
 @param searchObject - stores the input parameters for the ScoutSDK oneline search.
 */
- (void)search:(MapsSearchObject *)searchObject;

/** Cancels an ongoing search request.
 */
- (void)cancelSearch;

@end
