//
//  SKTDownloadManager+ResumeManager.h
//  

//

#import "SKTDownloadManager.h"

@interface SKTDownloadManager (ResumeManager)

/**
 Write to disk the download in progress, keep track of running download in case we need to restart the download.
 @param objectsToDownload NSArray of SKTDownloadObjectHelper objects
 */
+ (void)storeDownloadObjects:(NSArray *)objectsToDownload;

/**
 Remove a download from disk, there's no need to restart it in the future.
 @param objectsToDownload NSArray of SKTDownloadObjectHelper objects
 */
+ (void)removeDownloadObjects:(NSArray *)objectsToDownload;

/**
 Retrive an array of download objects that were stored on disk.
 @return NSArray of SKTDownloadObjectHelper objects that we can restore.
 */
+ (NSArray *)storedDownloadObjects;

/**
 Clear download objects that were stored on disk.
 */
+ (void)clearStoredDownloadObjects;

@end
