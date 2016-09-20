//
//  SKOneBoxSearchResultMetaData.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/**SKOneBoxSearchResultMetaData - stores the meta data information from a one box search
 */

@interface SKOneBoxSearchResultMetaData : NSObject

/** The current page number.
 */
@property(nonatomic, assign) NSInteger page;

/** The total number of search results per page.
 */
@property(nonatomic, assign) NSInteger items;

/** The total number of search results.
 */
@property(nonatomic, assign) NSInteger total;

/** Boolean indicating if there are more results available.
 */
@property(nonatomic, assign) BOOL hasMore;

/** URL pointing to the next page of results.
 */
@property(nonatomic, strong) NSString *nextPage;

/** URL pointing to the previous page of results.
 */
@property(nonatomic, strong) NSString *previousPage;

/** A newly initialized SKGLSSearchMetaData.
 */
+ (instancetype)oneBoxSearchMetaData;

/** Method for checking if service has any more results to retrieve
 @return Boolean indicating wether service can retrieve more results through pagination
 */
- (BOOL)hasMoreResults;

@end
