//
//  SKTDownloadManager+ResumeManager.m
//  

//

#import "SKTDownloadManager+ResumeManager.h"
#import "SKTDownloadManager+Additions.h"
#import "SKTDownloadObjectHelper.h"
#import "AFDownloadRequestOperation.h"
#import "SKTDownloadManager+DatabaseManager.h"

NSString *const resumeFileName = @"SKDownloadResumeFiles";

@implementation SKTDownloadManager (ResumeManager)

#pragma mark - Public

+ (void)storeDownloadObjects:(NSArray *)objectsToDownload {
    
    @synchronized(self) {
        NSFileManager *fman = [NSFileManager new];
        NSData *fileData = [fman contentsAtPath:[SKTDownloadManager resumeFilePath]];
        if (fileData) {
            //we have file on disk, unarchive
            NSMutableArray *downloadObjects = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
            
            for (SKTDownloadObjectHelper *downloadHelper in objectsToDownload) {
                NSAssert([downloadHelper isKindOfClass:[SKTDownloadObjectHelper class]], @"Not a SKTDownloadObjectHelper class!");
                BOOL foundObject = NO;
                for (NSString *string in downloadObjects) {
                    SKTDownloadObjectHelper *object = (SKTDownloadObjectHelper *)[SKTDownloadObjectHelper objectForJSON:string];
                    if ([object compare:downloadHelper] == NSOrderedSame) {
                        foundObject = YES;
                    }
                }
                
                if (!foundObject) {     //make sure we dont have duplicates
                    NSString *objectJson = [downloadHelper objectToJson];
                    [downloadObjects addObject:objectJson];
                }
            }
            
            fileData = [NSKeyedArchiver archivedDataWithRootObject:downloadObjects];
        } else {
            
            NSMutableArray *downloadObjects = [NSMutableArray array];
            
            for (SKTDownloadObjectHelper *downloadHelper in objectsToDownload) {
                NSAssert([downloadHelper isKindOfClass:[SKTDownloadObjectHelper class]], @"Not a SKTDownloadObjectHelper class!");
                NSString *objectJson = [downloadHelper objectToJson];
                [downloadObjects addObject:objectJson];
                
            }
            fileData = [NSKeyedArchiver archivedDataWithRootObject:downloadObjects];
        }
        
        //write back to disk
        [fileData writeToFile:[SKTDownloadManager resumeFilePath] atomically:YES];
    }
    
}

+ (void)removeDownloadObjects:(NSArray *)objectsToDownload {
    
    @synchronized(self) {
        NSFileManager *fman = [NSFileManager new];
        NSData *fileData = [fman contentsAtPath:[SKTDownloadManager resumeFilePath]];
        if (fileData) {
            //we have file on disk, unarchive
            NSMutableArray *downloadObjects = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
            NSMutableArray *tempDownloadObjects = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
            
            for (NSString *string in downloadObjects) {
                SKTDownloadObjectHelper *object = (SKTDownloadObjectHelper *)[SKTDownloadObjectHelper objectForJSON:string];
                
                for (SKTDownloadObjectHelper *downloadHelper in objectsToDownload) {
                    NSAssert([downloadHelper isKindOfClass:[SKTDownloadObjectHelper class]], @"Not a SKTDownloadObjectHelper class!");
                    if ([object compare:downloadHelper] == NSOrderedSame) {
                        [tempDownloadObjects removeObject:string];
                        break;
                    }
                }
            }
            
            fileData = [NSKeyedArchiver archivedDataWithRootObject:tempDownloadObjects];
        }
        
        //write back to disk
        [fileData writeToFile:[SKTDownloadManager resumeFilePath] atomically:YES];
    }
    
}

+ (NSArray *)storedDownloadObjects {
    NSFileManager *fman = [NSFileManager new];
    NSData *fileData = [fman contentsAtPath:[SKTDownloadManager resumeFilePath]];
    if (fileData) {
        NSMutableArray *downloadObjects = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
        NSMutableArray *SKTDownloadObjects = [NSMutableArray array];
        for (NSString *string in downloadObjects) {
            SKTDownloadObjectHelper *object = (SKTDownloadObjectHelper *)[SKTDownloadObjectHelper objectForJSON:string];
            [SKTDownloadObjects addObject:object];
        }
        
        return SKTDownloadObjects;
    } else {
        return nil;
    }
}

+ (void)clearStoredDownloadObjects {
    @synchronized(self) {
        NSFileManager *manager = [[NSFileManager alloc] init];
        
        //clean download helpers
        NSArray *downloadHelpers = [SKTDownloadManager storedDownloadObjects];
        for (SKTDownloadObjectHelper *helper in downloadHelpers) {
            NSAssert([helper isKindOfClass:[SKTDownloadObjectHelper class]], @"Not a SKTDownloadObjectHelper class!");
            [SKTDownloadManager cleanupDownloadHelper:helper];
        }
        
        //remove resume file
        [manager removeItemAtPath:[SKTDownloadManager resumeFilePath] error:nil];
        
        //remove cache folder
        NSString *cacheDir = NSTemporaryDirectory();
        NSString *cacheFolder = [cacheDir stringByAppendingPathComponent:kAFNetworkingIncompleteDownloadFolderName];
        [manager removeItemAtPath:cacheFolder error:nil];
    }
}

#pragma mark - Private

+ (NSString *)resumeFilePath {
    return [[SKTDownloadManager libraryDirectory] stringByAppendingPathComponent:resumeFileName];
}

@end
