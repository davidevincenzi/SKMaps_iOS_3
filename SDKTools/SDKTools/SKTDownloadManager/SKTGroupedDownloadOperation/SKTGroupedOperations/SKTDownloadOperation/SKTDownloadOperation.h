//
//  SKTDownloadOperation.h
//  

//

#import <Foundation/Foundation.h>
#import "SKTDownloadTypes.h"
#import "AFDownloadRequestOperation.h"
#import "SKTDownloadOperationDelegate.h"

@class SKTDownloadObjectHelper;
@class SKTUnzipOperation;

@protocol SKTUnzipOperationDelegate;

/**
 Download operation
 */
@interface SKTDownloadOperation : AFDownloadRequestOperation

/**
 Download helper object used for keeping track of download sizes and download states.
 */
@property (nonatomic, strong) SKTDownloadObjectHelper *downloadHelper;

/**
 Download delegate.
 */
@property (nonatomic, weak) id<SKTDownloadOperationDelegate> downloadDelegate;

/**
 Download file type (Texture,Map,NB,Voice,Wiki).
 */
@property (nonatomic, assign) SKTDownloadFileType downloadType;

/**
 Total bytes read for file.
 */
@property (nonatomic, assign) long long totalBytesReadForFile;

/**
 Total bytes expected to read for file.
 */
@property (nonatomic, assign) long long totalBytesExpectedToReadForFile;

/**
 Ammount of data downloaded by the connection, measured in bytes.
 */
@property (nonatomic, assign) long long totalBytesRead;

/**
 Previous ammount of data downloaded by the connection, measured in bytes.
 */
@property (nonatomic, assign) long long totalBytesPreviouslyRead;

/**
 Factory class for creating an download operation.
 @param delegate Download delegate.
 @param url Download URL.
 @param filePath Download path.
 @param downloadFileType Download file type (Texture,Map,NB,Voice,Wiki).
 @param downloadHelper Download helper object used for keeping track of download sizes and download states.
 @return Newly created download operation.
 */
+ (instancetype)downloadOperationWithDelegate:(id<SKTDownloadOperationDelegate>)delegate URL:(NSURL *)url downloadFilePath:(NSString *)filePath withType:(SKTDownloadFileType)downloadFileType withDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Factory class for creating a fresh copy of the input download operation. Used for retry mechanism.
 @param downloadOperation A SKTDownloadOperation operation.
 @return Returns a fresh copy of the input download operation.
 */
+ (instancetype)downloadOperationWithDownloadOperation:(SKTDownloadOperation *)downloadOperation;

/**
 Factory class for creating a unzip operation for a download operation.
 @param downloadOperation A SKTDownloadOperation operation.
 @param delegate Unzip delegate.
 @return Returns a fresh unzip operation.
 */
+ (SKTUnzipOperation *)unzipOperationForDownloadOperation:(SKTDownloadOperation *)downloadOperation withUnzipDelegate:(id<SKTUnzipOperationDelegate>)delegate;

/**
 Method for retrieving download sample size for measuring download speed.
 @return 'long long' representing size in bytes between bytes read (totalBytesRead - totalBytesPreviouslyRead).
 */
- (long long)sampleSize;

@end
