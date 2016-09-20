//
//  SKTMapDownloadState.h
//  
//

//

#import <Foundation/Foundation.h>
#import "KVCBaseObject.h"

/**
 SKTMapDownloadState keeps tracks of the state of the download.
 */
@interface SKTMapDownloadState : KVCBaseObject

/**
 Boolean indicating if the map file has been downloaded.
 */
@property(nonatomic,assign) BOOL bSkmDownloaded;

/**
 Boolean indicating if the name browser file has been downloaded.
 */
@property(nonatomic,assign) BOOL bNBDownloaded;

/**
 Boolean indicating if the texture file has been downloaded.
 */
@property(nonatomic,assign) BOOL bTexturesDownloaded;

/**
 Boolean indicating if the name browser file has been unzipped.
 */
@property(nonatomic,assign) BOOL bNBUnzipped;

/**
 Init method for SKTMapDownloadState
 @param installed boolean indicating if the map is installed or not.
 @return SKTMapDownloadState object initialized based on installed parameter.
 */
-(id)initInstalled:(BOOL)installed;

/**
  Method for checking if map has finished downloading, this means download and unzip included.
 @return A boolean indicating if map is fully downloaded, unzipping included.
 */
-(BOOL)isFullyDownloaded;

/**
 Method for checking if map is fully unzipped.
 @return A boolean indicating if map is fully unzipped.
 */
-(BOOL)isFullyUnzipped;

/**
 Method for checking if map has finished downloading.
 @return A boolean indicating if map is finished downloading.
 */
-(BOOL)finishedDownloading;

/**
 Method for specifing if a map is installed or not. Should be used after the download has completed.
 @param installed boolean indicating if the map is installed or not.
 */
-(void)setInstalled:(BOOL)installed;

@end
