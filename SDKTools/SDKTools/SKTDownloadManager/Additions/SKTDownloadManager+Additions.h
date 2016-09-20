//
//  SKTDownloadManager+Additions.h
//  

//

#import "SKTDownloadManager.h"
#import "SKTDownloadTypes.h"

/**
 Constans used to read valued returned by downloadProgressDataForGroupedDownloadOperations: function.
 - kSKTDownloadOverallProgressString - overall progress string for all SKTGroupedDownloadOperations sent to downloadProgressDataForGroupedDownloadOperations:
 - kSKTDownloadOverallPercentage - overall percentage as a `float` value for all SKTGroupedDownloadOperations sent to downloadProgressDataForGroupedDownloadOperations:
 - kSKTDownloadTotalDownloadSize - total download size as `long long` for all SKTGroupedDownloadOperations sent to downloadProgressDataForGroupedDownloadOperations:
 - kSKTDownloadTotalBytesDownloaded - total downloaded bytes as `long long` for all SKTGroupedDownloadOperations sent to downloadProgressDataForGroupedDownloadOperations:
 */
extern NSString *const kSKTDownloadOverallProgressString;
extern NSString *const kSKTDownloadOverallPercentage;
extern NSString *const kSKTDownloadTotalDownloadSize;
extern NSString *const kSKTDownloadTotalBytesDownloaded;

@interface SKTDownloadManager (Additions)

/**
 Whether or not the user has accepted download over cellular networks.
 */
@property(nonatomic, assign) BOOL userDidAcceptCellularDownload;

/** 
 Helper function to return Library directory
 @return Library directory path
 */
+ (NSString *)libraryDirectory;

/**
 Total expected download size for an array of SKTDownloadObjectHelper objects
 @param items NSArray of SKTDownloadObjectHelper objects
 @return Total size for all SKTDownloadObjectHelper objects as long long
 */
+ (long long)totalSizeForItems:(NSArray *)items;

/**
 Whether or not there is enough disk space for a set of SKTDownloadObjectHelper. Used to see if a download can be started or not.
 @param items NSArray of SKTDownloadObjectHelper objects
 @return A boolean indicating is the device has enough disk space for required downloads
 */
+ (BOOL)deviceHasEnoughSpaceForItems:(NSArray *)items;

/**
 Whether or not a map package has been correctly downloaded and has the right size.
 @param downloadHelper SKTDownloadObjectHelper with the download details
 @return A boolean indicating if the map package was downloaded correctly
 */
+ (BOOL)mapPackageHasCorrectSize:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Get the byte size of a file at a given path
 @param path Path to a file/resource
 @return Unsigned long long representing the bytes of the file at a given path
 */
+ (unsigned long long)fileSizeForPath:(NSString *)path;

/**
 Expected download size for a SKTDownloadObjectHelper object
 @param downloadHelper SKTDownloadObjectHelper with the download details
 @param downloadFileType SKTDownloadFileType representing the type of the download
 @return long long representing the expected download size for a download object
 */
+ (long long)expectedDownloadSizeForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper withFileType:(SKTDownloadFileType)downloadFileType;

/**
 Returns progress data for a set of SKTGroupedDownloadOperation objects.
 @param array NSArray of SKTGroupedDownloadOperation objects
 @return The dictionary contains following keys/values:
 - an `NSString` object under the `kSKTDownloadOverallProgressString` key, representing overall progress string for all SKTGroupedDownloadOperations.
 - an `NSNumber` object under the `kSKTDownloadOverallPercentage` key, representing overall percentage as a `float` value for all SKTGroupedDownloadOperations.
 - an `NSNumber` object under the `kSKTDownloadTotalDownloadSize` key, total download size as `long long` for all SKTGroupedDownloadOperations.
 - an `NSNumber` object under the `kSKTDownloadTotalBytesDownloaded` key, total downloaded bytes as `long long` for all SKTGroupedDownloadOperations.
 */
+ (NSDictionary *)downloadProgressDataForGroupedDownloadOperations:(NSArray *)array;

/**
 Converts a long long value to a string
 @param size long long value representing the size
 @return The string representing the size.
 */
+ (NSString *)stringForSize:(long long)size;

@end
