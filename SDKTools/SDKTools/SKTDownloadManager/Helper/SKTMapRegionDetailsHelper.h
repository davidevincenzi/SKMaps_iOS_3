//
//  SKTMapRegionDetailsHelper.h
//  

//

#import <Foundation/Foundation.h>
#import "SKTMapDownloadState.h"
#import "KVCBaseObject.h"
#import "SKTPackage.h"

@class SKTDownloadObjectHelper;

/**
 SKTMapRegionDetailsHelper holds additional information regarding a download, such as download sizes and download urls.
 */
@interface SKTMapRegionDetailsHelper : KVCBaseObject

/**
 code for the download object.
 */
@property (nonatomic, strong) NSString *code;

/**
 parent code for the download object.
 */
@property (nonatomic, strong) NSString *parentCode;

/**
 NSNumber representing the size of the SKM file.
 */
@property (nonatomic, strong) NSNumber *sizeMap;

/**
 NSNumber representing the size of the name browser file.
 */
@property (nonatomic, strong) NSNumber *sizeNB;

/**
 NSNumber representing the size of the texture file.
 */
@property (nonatomic, strong) NSNumber *sizeTexture;

/**
 NSNumber representing the size of the unzip texture file.
 */
@property (nonatomic, strong) NSNumber *unzipSizeTexture;

/**
 NSString representing the url of the skm file.
 */
@property (nonatomic, strong) NSString *downloadURLMap;

/**
 NSString representing the url of the name browser file.
 */
@property (nonatomic, strong) NSString *downloadURLNB;

/**
 NSString representing the url of the texture file.
 */
@property (nonatomic, strong) NSString *downloadURLTexture;

/**
 SKTMapDownloadState representing the download state.
 */
@property (nonatomic, strong) SKTMapDownloadState *downloadState;

/**
 Class factory method for creating a SKTMapRegionDetailsHelper using a SKTPackage object.
 @param package object resulted from Map JSON parsing.
 @return SKTMapRegionDetailsHelper with required download information.
 */
+(id)mapRegionDetailsHelperWithSKTPackage:(SKTPackage*)package;

@end
