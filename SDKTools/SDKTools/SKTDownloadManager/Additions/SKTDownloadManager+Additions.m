//
//  SKTDownloadManager+Additions.m
//  

//

#import "SKTDownloadManager+Additions.h"
#import "SKTGroupedDownloadOperation.h"

#import "SKTDownloadObjectHelper.h"

#import <objc/runtime.h>

#import <SKMaps/SKMapsService.h>

NSString *const kSKTDownloadOverallProgressString = @"overallProgressString";
NSString *const kSKTDownloadOverallPercentage = @"overallPercentage";
NSString *const kSKTDownloadTotalDownloadSize = @"totalDownloadSize";
NSString *const kSKTDownloadTotalBytesDownloaded = @"totalBytesDownloaded";

const int kUnitSizeCount = 1024;

@implementation SKTDownloadManager (Additions)

+ (NSString *)libraryDirectory {
    static NSString *libraryDirectory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    });
    return libraryDirectory;
}

+ (long long)totalSizeForItems:(NSArray *)items {
    long long totalBytes = 0;
    for (SKTDownloadObjectHelper *downloadHelper in items) {
        if ([downloadHelper downloadType] == SKTDownloadObjectMap) {
            totalBytes += [downloadHelper.details.sizeMap longLongValue];
            totalBytes += [downloadHelper.details.sizeNB longLongValue]*2.5;
            totalBytes += [downloadHelper.details.sizeTexture longLongValue]*2.5;
            
        } else if ([downloadHelper downloadType] == SKTDownloadObjectWiki) {
            totalBytes += [downloadHelper getTotalSize];
        }
    }
    return totalBytes;
}

+ (BOOL)deviceHasEnoughSpaceForItems:(NSArray *)items {
    long long totalBytes = [SKTDownloadManager totalSizeForItems:items];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDictionary *attributesDict = [fileManager attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
    long long freespace = [[attributesDict objectForKey:NSFileSystemFreeSize] longLongValue];
    
    if (freespace > totalBytes) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)mapPackageHasCorrectSize:(SKTDownloadObjectHelper *)downloadHelper {
    NSAssert([downloadHelper isKindOfClass:[SKTDownloadObjectHelper class]], @"Not a SKTDownloadObjectHelper class!");
    
    //only check map downloads
    if ([downloadHelper downloadType] == SKTDownloadObjectMap) {
        NSString *folderPath = [[SKTDownloadManager libraryDirectory] stringByAppendingPathComponent:[downloadHelper getCode]];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@.skm", folderPath, [downloadHelper getCode]];
        BOOL isValidPackage = [[SKMapsService sharedInstance].packagesManager validateMapFileAtPath:fullPath];
        
        return isValidPackage;
    }
    return YES;
}

+ (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

+ (long long)expectedDownloadSizeForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper withFileType:(SKTDownloadFileType)downloadFileType {
    NSAssert([downloadHelper isKindOfClass:[SKTDownloadObjectHelper class]], @"Not a SKTDownloadObjectHelper class!");
    
    long long bytes = 0;
    
    switch (downloadFileType) {
        case SKTDownloadFileTypeTexture:
        {
            bytes = [downloadHelper.details.sizeTexture longLongValue];
        }
            break;
            
        case SKTDownloadFileTypeNBFile:
        {
            bytes = [downloadHelper.details.sizeNB longLongValue];
        }
            break;
            
        case SKTDownloadFileTypeMapFile:
        {
            bytes = [downloadHelper.details.sizeMap longLongValue];
        }
            break;
            
        case SKTDownloadFileTypeWikiTravel:
        {
            bytes = [downloadHelper getTotalSize];
        }
            break;
            
        case SKTDownloadFileTypeVoice:
        {
            bytes = [downloadHelper getTotalSize];
        }
            break;
            
        default:
            break;
    }
    return bytes;
}

+ (NSDictionary *)downloadProgressDataForGroupedDownloadOperations:(NSArray *)array {
    NSString *overallProgressString = nil;
    float overallPercentage = 0.;
    
    long long totalDownloadSize = 0;
    long long totalBytesDownloaded = 0;
    
    NSArray *tempOperations = [NSArray arrayWithArray:array];
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        NSAssert([operation isKindOfClass:[SKTGroupedDownloadOperation class]], @"Not a SKTGroupedDownloadOperation class!");
        totalBytesDownloaded += operation.totalBytesDownloaded;
        totalDownloadSize += operation.totalDownloadSize;
    }
    
    overallPercentage = totalBytesDownloaded/(float)(totalDownloadSize)*100;
    if (isnan(overallPercentage)) {
        overallPercentage = 0;
    }
    
    overallProgressString = [NSString stringWithFormat:@"%@ / %@", [SKTDownloadManager stringForSize:totalBytesDownloaded], [SKTDownloadManager stringForSize:totalDownloadSize]];
    
    return @{kSKTDownloadOverallProgressString:overallProgressString,
             kSKTDownloadOverallPercentage:[NSNumber numberWithFloat:overallPercentage],
             kSKTDownloadTotalDownloadSize:[NSNumber numberWithLongLong:totalDownloadSize],
             kSKTDownloadTotalBytesDownloaded:[NSNumber numberWithLongLong:totalBytesDownloaded]};
}

+ (NSString *)stringForSize:(long long)size {
    NSString *unitString = @"";
    float finalSize = 0.0;
    if (size/kUnitSizeCount < 100.0) {
        unitString = @"KB";
        finalSize = (float)size / kUnitSizeCount;
        
    } else if (size / (kUnitSizeCount * kUnitSizeCount) < 1000.0) {
        unitString = @"MB";
        finalSize = (float)size/(kUnitSizeCount * kUnitSizeCount);
        
    } else if (size / (kUnitSizeCount * kUnitSizeCount * kUnitSizeCount) < 100.0) {
        finalSize = (float)size / (kUnitSizeCount * kUnitSizeCount * kUnitSizeCount);
        unitString = @"GB";
    }
    
    if (finalSize == 0.0) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%.1f %@", finalSize, unitString];
}

#pragma mark - Private

- (void)setUserDidAcceptCellularDownload:(BOOL)userDidAcceptCellularDownload
{
    objc_setAssociatedObject(self, @selector(userDidAcceptCellularDownload), [NSNumber numberWithBool:userDidAcceptCellularDownload], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)userDidAcceptCellularDownload
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(userDidAcceptCellularDownload));
    return [number boolValue];
}


@end
