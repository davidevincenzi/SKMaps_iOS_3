//
//  SKTDownloadManager+DatabaseManager.h
//  
//

#import "SKTDownloadManager.h"

@interface SKTDownloadManager (DatabaseManager)

/** Delete all files from disk related to a download
 @param downloadHelper The SKTDownloadObjectHelper object containing information regarding the download.
 */
+ (void)cleanupDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

@end
