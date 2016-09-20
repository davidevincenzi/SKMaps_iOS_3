//
//  SKTUnzipOperationDelegate.h
//  

//

#import <Foundation/Foundation.h>

@class SKTUnzipOperation;

/**
 SKTUnzipOperationDelegate delegate of SKTUnzipOperation.
 */
@protocol SKTUnzipOperationDelegate <NSObject>

@required

/**
 Delegate method for returning unzip progress percentage.
 @param unzipOperation the unzip operation.
 @param percentage float representing the unzip percentage.
 */
- (void)unzipOperation:(SKTUnzipOperation *)unzipOperation updatedProgressPercentage:(float)percentage;

/**
 Delegate method for finished unzipping.
 @param unzipOperation the unzip operation.
 @param file the path of the file beeing unzipped.
 @param success a boolean indicating if the unzip was succesfull.
 */
- (void)unzipOperation:(SKTUnzipOperation *)unzipOperation finishedForFile:(NSString *)file withSuccess:(BOOL)success;

@end
