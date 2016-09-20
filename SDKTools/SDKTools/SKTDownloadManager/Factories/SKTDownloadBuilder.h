//
//  SKTDownloadBuilder.h
//  

//

#import <Foundation/Foundation.h>

@class SKTGroupedDownloadOperation;
@class SKTDownloadObjectHelper;

/**
 * Factory class which takes in SKTDownloadObjectHelper and generates SKTGroupedDownloadOperation objects.
 */
@interface SKTDownloadBuilder : NSObject

/** Creates a SKTGroupedDownloadOperation object from a SKTDownloadObjectHelper.
 SKTGroupedDownloadOperation contains multiple SKTGroupedOperations.
 For example a map download will contain 3 SKTGroupedOperations (Map, Name browser zip, texture file).
 @param downloadHelper The SKTDownloadObjectHelper object containing information regarding the download.
 @return SKTGroupedDownloadOperation containing SKTGroupedOperations.
 */
+ (SKTGroupedDownloadOperation *)groupedDownloadOperationForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

@end
