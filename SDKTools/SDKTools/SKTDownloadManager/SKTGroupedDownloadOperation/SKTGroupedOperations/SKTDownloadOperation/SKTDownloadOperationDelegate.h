//
//  SKTDownloadOperationDelegate.h
//  
//

//

#import <Foundation/Foundation.h>

@class SKTDownloadOperation;

/**
 SKTDownloadOperationDelegate delegate of SKTDownloadOperation.
 */
@protocol SKTDownloadOperationDelegate <NSObject>

@required

/**
 Delegate method called when the download operation finished.
 @param operation the download operation.
 @param success A boolean indicating if the download finished with success.
 */
- (void)downloadOperation:(SKTDownloadOperation *)operation finishedSuccessfully:(BOOL)success;

/**
 Delegate method called when the download operation will retry to download.
 @param operation the download operation.
 @param newOperations NSArray containing a copy of the download operations. The new operations will replace the old one.
 */
- (void)downloadOperation:(SKTDownloadOperation *)operation willRetryWithDownloadOperation:(NSArray *)newOperations;

/**
 Delegate method called when the download operation received timeout.
 @param operation the download operation.
 */
- (void)didReceiveTimeOut:(SKTDownloadOperation *)operation;

/**
 Delegate method called when the download operation was cancelled by the operating system (background task cancelled after a certain period).
 @param operation the download operation.
 */
- (void)operationCanceledByOS:(SKTDownloadOperation *)operation;

@optional

/**
 Delegate method called when the download operation received bytes.
 @param operation the download operation.
 @param bytesRead NSInteger representing incoming read bytes of the download operation.
 @param totalBytesRead long long representing total read bytes of the download operation.
 @param totalBytesExpected long long representing total remaining expected bytes of the download operation.
 @param totalBytesExpectedToReadForFile long long representing total expected bytes of the download operation (expectedContentLenght).
 */
- (void)downloadOperation:(SKTDownloadOperation *)operation bytesRead:(NSInteger)bytesRead totalBytesRead:(long long)totalBytesRead totalBytesExpected:(long long)totalBytesExpected totalBytesExpectedToReadForFile:(long long)totalBytesExpectedToReadForFile;

@end
