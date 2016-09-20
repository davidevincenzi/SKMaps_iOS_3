//
//  SKTDownloadBuilder.m
//  

//

#import "SKTDownloadBuilder.h"
#import "SKTDownloadOperation.h"
#import "SKTGroupedOperations.h"
#import "SKTGroupedDownloadOperation.h"
#import "SKTDownloadTypes.h"
#import "SKTDownloadManager.h"
#import "SKTDownloadObjectHelper.h"
#import "SKTDownloadManager+Additions.h"

@implementation SKTDownloadBuilder

#pragma mark - Public

+ (SKTGroupedDownloadOperation *)groupedDownloadOperationForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    NSAssert([downloadHelper isKindOfClass:[SKTDownloadObjectHelper class]], @"Not a SKTDownloadObjectHelper class!");
    
    SKTGroupedDownloadOperation *groupedDownloadOperation = [SKTDownloadBuilder groupedDownloadOperationForObject:downloadHelper];
    [groupedDownloadOperation setDownloadHelper:downloadHelper];
    
    return groupedDownloadOperation;
}

#pragma mark - Private methods

+ (SKTGroupedDownloadOperation *)groupedDownloadOperationForObject:(SKTDownloadObjectHelper *)downloadHelper {
    NSString *downloadPath = [SKTDownloadBuilder downloadPathForDownloadHelper:downloadHelper];
    
    if ([downloadHelper downloadType] == SKTDownloadObjectMap) {
        return [SKTDownloadBuilder createGroupedDownloadOperationsForDownloadHelper:downloadHelper atPath:downloadPath];
    } else if ([downloadHelper downloadType] == SKTDownloadObjectWiki) {
        return [SKTDownloadBuilder createGroupedDownloadOperationsForWikiTravel:downloadHelper atPath:downloadPath];
    } else if ([downloadHelper downloadType] == SKTDownloadObjectVoice) {
        return [SKTDownloadBuilder createGroupedDownloadOperationsForVoice:downloadHelper atPath:downloadPath];
    }
    return nil;
}

+ (SKTGroupedDownloadOperation *)createGroupedDownloadOperationsForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper atPath:(NSString *)path {
    SKTGroupedDownloadOperation *groupedDownloadOperation = [SKTGroupedDownloadOperation downloadGroupedOperation];
    
    //Texture
    NSURL *downloadURLTexture = [SKTDownloadObjectHelper downloadHelper:downloadHelper downloadURLForType:SKTDownloadFileTypeTexture];
    if ([SKTDownloadObjectHelper linkAvailableForDownloadHelper:downloadHelper withType:SKTDownloadFileTypeTexture]) {
        SKTGroupedOperations *groupedOperation = [SKTGroupedOperations groupedOperation];
        SKTDownloadOperation *downloadOperation = [SKTDownloadOperation downloadOperationWithDelegate:groupedOperation URL:downloadURLTexture downloadFilePath:path withType:SKTDownloadFileTypeTexture withDownloadHelper:downloadHelper];
        [groupedOperation setupWithDownloadOperation:downloadOperation andUnzipOperation:nil];
        
        [groupedOperation setDelegate:groupedDownloadOperation];
        [groupedDownloadOperation addSKGroupedOperation:groupedOperation];
    }
    
    //MAP SKM
    NSURL *downloadURLMap = [SKTDownloadObjectHelper downloadHelper:downloadHelper downloadURLForType:SKTDownloadFileTypeMapFile];
    if ([SKTDownloadObjectHelper linkAvailableForDownloadHelper:downloadHelper withType:SKTDownloadFileTypeMapFile]) {
        SKTGroupedOperations *groupedOperation = [SKTGroupedOperations groupedOperation];
        SKTDownloadOperation *downloadOperation = [SKTDownloadOperation downloadOperationWithDelegate:groupedOperation URL:downloadURLMap downloadFilePath:path withType:SKTDownloadFileTypeMapFile withDownloadHelper:downloadHelper];
        [groupedOperation setupWithDownloadOperation:downloadOperation andUnzipOperation:nil];
        [groupedOperation setDelegate:groupedDownloadOperation];
        
        [groupedDownloadOperation addSKGroupedOperation:groupedOperation];
    }
    
    //NB zip
    NSURL *downloadURLNB = [SKTDownloadObjectHelper downloadHelper:downloadHelper downloadURLForType:SKTDownloadFileTypeNBFile];
    if ([SKTDownloadObjectHelper linkAvailableForDownloadHelper:downloadHelper withType:SKTDownloadFileTypeNBFile]) {
        SKTGroupedOperations *groupedOperation = [SKTGroupedOperations groupedOperation];
        SKTDownloadOperation *downloadOperation = [SKTDownloadOperation downloadOperationWithDelegate:groupedOperation URL:downloadURLNB downloadFilePath:path withType:SKTDownloadFileTypeNBFile withDownloadHelper:downloadHelper];
        [groupedOperation setupWithDownloadOperation:downloadOperation andUnzipOperation:[SKTDownloadOperation unzipOperationForDownloadOperation:downloadOperation withUnzipDelegate:groupedOperation]];
        [groupedOperation setDelegate:groupedDownloadOperation];
        
        [groupedDownloadOperation addSKGroupedOperation:groupedOperation];
    }
    
    return groupedDownloadOperation;
}

+ (SKTGroupedDownloadOperation *)createGroupedDownloadOperationsForWikiTravel:(SKTDownloadObjectHelper *)downloadHelper atPath:(NSString *)path {
    SKTGroupedDownloadOperation *groupedDownloadOperation = [SKTGroupedDownloadOperation downloadGroupedOperation];
    
    NSURL *downloadURLWikiTravel = [SKTDownloadObjectHelper downloadHelper:downloadHelper downloadURLForType:SKTDownloadFileTypeWikiTravel];
    if ([SKTDownloadObjectHelper linkAvailableForDownloadHelper:downloadHelper withType:SKTDownloadFileTypeWikiTravel]) {
        SKTGroupedOperations *groupedOperation = [SKTGroupedOperations groupedOperation];
        SKTDownloadOperation *downloadOperation = [SKTDownloadOperation downloadOperationWithDelegate:groupedOperation URL:downloadURLWikiTravel downloadFilePath:path withType:SKTDownloadFileTypeWikiTravel withDownloadHelper:downloadHelper];
        [groupedOperation setupWithDownloadOperation:downloadOperation andUnzipOperation:nil];
        [groupedOperation setDelegate:groupedDownloadOperation];
        
        [groupedDownloadOperation addSKGroupedOperation:groupedOperation];
    }
    return groupedDownloadOperation;
}

+ (SKTGroupedDownloadOperation *)createGroupedDownloadOperationsForVoice:(SKTDownloadObjectHelper *)voice atPath:(NSString *)path {
    SKTGroupedDownloadOperation *groupedDownloadOperation = [SKTGroupedDownloadOperation downloadGroupedOperation];
    
    NSURL *downloadURLVoice = [SKTDownloadObjectHelper downloadHelper:voice downloadURLForType:SKTDownloadFileTypeVoice];
    if ([SKTDownloadObjectHelper linkAvailableForDownloadHelper:voice withType:SKTDownloadFileTypeVoice]) {
        SKTGroupedOperations *groupedOperation = [SKTGroupedOperations groupedOperation];
        SKTDownloadOperation *downloadOperation = [SKTDownloadOperation downloadOperationWithDelegate:groupedOperation URL:downloadURLVoice downloadFilePath:path withType:SKTDownloadFileTypeVoice withDownloadHelper:voice];
        [groupedOperation setupWithDownloadOperation:downloadOperation andUnzipOperation:[SKTDownloadOperation unzipOperationForDownloadOperation:downloadOperation withUnzipDelegate:groupedOperation]];
        [groupedOperation setDelegate:groupedDownloadOperation];
        
        [groupedDownloadOperation addSKGroupedOperation:groupedOperation];
    }
    return groupedDownloadOperation;
}

+ (NSString *)downloadPathForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    NSString *path = nil;
    
    path = [[SKTDownloadManager libraryDirectory] stringByAppendingPathComponent:[downloadHelper getCode]];
    
    NSError *error;
    NSFileManager *fman = [NSFileManager new];
    if (![fman fileExistsAtPath:path]) {
        [fman createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return path;
}

@end
