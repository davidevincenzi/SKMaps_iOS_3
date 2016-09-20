//
//  SKTUnzipOperation.m
//  
//
//

#import "SKTUnzipOperation.h"
#import "ZipArchive.h"
#import "SKTDownloadManager+Additions.h"

#import "SKTDownloadObjectHelper.h"

@interface SKTUnzipOperation () <ZipArchiveDelegate>

@end

@implementation SKTUnzipOperation

+ (instancetype)unzipOperationWithDelegate:(id<SKTUnzipOperationDelegate>)delegate withDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper withType:(SKTDownloadFileType)downloadFileType {
    return [[SKTUnzipOperation alloc] initWithDelegate:delegate withDownloadHelper:downloadHelper withType:downloadFileType];
}

- (instancetype)initWithDelegate:(id<SKTUnzipOperationDelegate>)delegate withDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper withType:(SKTDownloadFileType)downloadFileType {
    self = [super init];
    if (self) {
        _downloadHelper = downloadHelper;
        _unzipDelegate = delegate;
        _downloadType = downloadFileType;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }
        
        NSString *mapCode = [self.downloadHelper getCode];
        
        if ((!mapCode) || (!self.downloadHelper)) {
            return;
        }
        
        NSString *path = nil;
        path = [[SKTDownloadManager libraryDirectory] stringByAppendingPathComponent:mapCode];
        
        NSString *zipFileName = nil;
        
        zipFileName = [path stringByAppendingPathComponent:[[self.downloadHelper.details.downloadURLNB componentsSeparatedByString:@"/"] lastObject]];
        
        _totalSize = [SKTDownloadManager fileSizeForPath:zipFileName];
        
        [self unzipFile:zipFileName];
    }
}

- (void)unzipFile:(NSString *)file {
    ZipArchive *unzipper = [[ZipArchive alloc] init];
    ZipArchive *__weak weakUnzipper = unzipper;
    unzipper.delegate = self;
    unzipper.progressBlock = ^(int percentage, int filesProcessed, int numFiles){
        if (![self isCancelled]) {
            //inform delegate of our progress
            self.unzipPercentage = percentage;
            if ([self.unzipDelegate respondsToSelector:@selector(unzipOperation:updatedProgressPercentage:)]) {
                [self.unzipDelegate unzipOperation:self updatedProgressPercentage:(float)percentage];
            }
        } else {
            //is canceled, cancel zip archive
            [weakUnzipper cancelUnzip];
        }
    };
    
    if (!self.isCancelled) {
        
        BOOL success = NO;
        if ([unzipper UnzipOpenFile:file]) {
            [unzipper UnzipFileTo:[file stringByDeletingLastPathComponent] overWrite:TRUE];
            [unzipper CloseZipFile2];
            
            NSFileManager *fman = [NSFileManager new];
            
            [fman removeItemAtPath:file error:nil];
            
            [self updateDownloadHelperDownloadState];
            success = YES;
        }
        
        if ([self.unzipDelegate respondsToSelector:@selector(unzipOperation:finishedForFile:withSuccess:)]) {
            [self.unzipDelegate unzipOperation:self finishedForFile:file withSuccess:success];
        }
    }
    
    unzipper.progressBlock = nil;
}

#pragma mark - ZipArchive delegate

- (void)zipArchive:(ZipArchive *)zipArchive DidCancelFileAtPath:(NSString *)path {
}

- (void)ErrorMessage:(NSString *)msg {
    NSLog(@"%@", msg);
}

- (void)updateDownloadHelperDownloadState {
    switch (self.downloadType) {
        case SKTDownloadFileTypeNBFile:
        {
            self.downloadHelper.details.downloadState.bNBUnzipped = YES;
            break;
        }
        case SKTDownloadFileTypeVoice:
        {
            break;
        }
        default:
            break;
    }
}

@end
