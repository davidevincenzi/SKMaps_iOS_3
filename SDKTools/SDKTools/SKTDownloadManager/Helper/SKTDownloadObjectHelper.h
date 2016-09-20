//
//  SKTDownloadObjectHelper.h
//  
//

//

#import <Foundation/Foundation.h>
#import "KVCBaseObject.h"
#import "SKTDownloadTypes.h"

#import "SKTMapDownloadState.h"
#import "SKTMapRegionDetailsHelper.h"
#import "SKTPackage.h"

typedef NS_ENUM(NSUInteger, SKTDownloadObjectType)
{
    SKTDownloadObjectMap = 0,
    SKTDownloadObjectWiki, 
    SKTDownloadObjectVoice
};

/**
 SKTDownloadObjectHelper holds additional information regarding a download.
 */
@interface SKTDownloadObjectHelper : KVCBaseObject

/**
 English translation for download.
 */
@property (nonatomic, strong) NSString *name_en;

/**
 German translation for download.
 */
@property (nonatomic, strong) NSString *name_de;

/**
 Spanish translation for download.
 */
@property (nonatomic, strong) NSString *name_es;

/**
 French translation for download.
 */
@property (nonatomic, strong) NSString *name_fr;

/**
 Italian translation for download.
 */
@property (nonatomic, strong) NSString *name_it;

/**
 Romanian translation for download.
 */
@property (nonatomic, strong) NSString *name_ro;

/**
 Russian translation for download.
 */
@property (nonatomic, strong) NSString *name_ru;

/**
 Hungarian translation for download.
 */
@property (nonatomic, strong) NSString *name_hu;

/**
 Dutch translation for download.
 */
@property (nonatomic, strong) NSString *name_nl;

/**
 Turkish translation for download.
 */
@property (nonatomic, strong) NSString *name_tr;

/**
 Portuguese translation for download.
 */
@property (nonatomic, strong) NSString *name_pt;

/**
 Swedish translation for download.
 */
@property (nonatomic, strong) NSString *name_sv;

/**
 Dansk translation for download.
 */
@property (nonatomic, strong) NSString *name_da;

/**
 Polish translation for download.
 */
@property (nonatomic, strong) NSString *name_pl;

/**
 Value indicating if a map is purchased.
 */
@property (nonatomic, strong) NSNumber *isPurchased;

/**
 Value indicating if a map is installed.
 */
@property (nonatomic, strong) NSNumber *isInstalled;

/**
 Value indicating the type of the map, continent, country, state etc.
 */
@property (nonatomic, strong) NSNumber *type;

/**
 SKTDownloadObjectType indicates the type of the download.
 */
@property (nonatomic, assign) SKTDownloadObjectType downloadType;

/**
 SKTMapRegionDetailsHelper contains additional download details.
 */
@property (nonatomic, strong) SKTMapRegionDetailsHelper *details;

/**
 package holds informations from map json file regarding the download.
 */
@property (nonatomic, strong) SKTPackage *package;

/**
 Defines if the package is custom or not.
 */
@property (nonatomic, assign, getter=isCustom) BOOL custom;

/**
 Class factory method for creating a SKTDownloadObjectHelper using a SKTPackage object.
 @param package object resulted from Map JSON parsing.
 @return SKTDownloadObjectHelper with required download information.
 */
+(id)downloadObjectHelperWithSKTPackage:(SKTPackage*)package;

/**
 Returns language for map download.
 @return NSString representing the current language translation.
 */
-(NSString*)mapRegionHelperNameForCurrentLanguage;

/**
 Returns map download code.
 @return NSString representing the map download core (eg.: RO, US, DE).
 */
-(NSString*)getCode;

/**
 Returns the total size of the download.
 @return long long indicating the total size of the download.
 */
-(long long)getTotalSize;

/**
 Returns a boolean indicating wether the download has finished, unzipping included.
 @return boolean indicating wether the download has finished, unzipping included.
 */
-(BOOL)isFullyDownloaded;

/**
 Returns a boolean indicating wether the download has finished unzipping.
 @return boolean indicating wether the download has finished unzipping.
 */
-(BOOL)isFullyUnzipped;

/**
 Returns a boolean indicating wether download has finished.
 @return boolean indicating wether download has finished.
 */
-(BOOL)finishedDownloading;

/**
 Compare method for download objects, compares object codes.
 @param otherObject The object to which we compare.
 @return NSComparisonResult indicating the compare result.
 */
-(NSComparisonResult)compare:(id)otherObject;

/**
 Returns the URL for the downloadFileType.
 @param currentDownloadHelper the download helper object
 @param downloadFileType download file type
 @return URL for the downloadFileType.
 */
+(NSURL*)downloadHelper:(SKTDownloadObjectHelper*)currentDownloadHelper downloadURLForType:(SKTDownloadFileType)downloadFileType;

/**
 Returns a boolean indicating the a url exists for the downloadFileType.
 @param downloadHelper the download helper object
 @param downloadFileType download file type
 @return a boolean indicating the a url exists for the downloadFileType.
 */
+(BOOL)linkAvailableForDownloadHelper:(SKTDownloadObjectHelper*)downloadHelper withType:(SKTDownloadFileType)downloadFileType;

@end
