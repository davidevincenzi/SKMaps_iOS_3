//
//  SKTDownloadManager+DatabaseManager.m
//  

//

#import "SKTDownloadManager+DatabaseManager.h"
#import "SKTDownloadManager+Additions.h"

#import "SKTDownloadObjectHelper.h"

@implementation SKTDownloadManager (DatabaseManager)

+ (void)cleanupDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    NSAssert([downloadHelper isKindOfClass:[SKTDownloadObjectHelper class]], @"Not a SKTDownloadObjectHelper class!");
    
    NSString *path = [[SKTDownloadManager libraryDirectory] stringByAppendingPathComponent:[downloadHelper getCode]];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @synchronized(self) {
            NSFileManager *fman = [NSFileManager new];
            if ([fman fileExistsAtPath:path]) {
                
                [fman removeItemAtPath:path error:nil];
            }
        }
    });
}

@end
