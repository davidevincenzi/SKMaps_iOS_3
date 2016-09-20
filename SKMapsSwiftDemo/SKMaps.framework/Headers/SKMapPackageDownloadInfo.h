//
//  SKMapPackageDownloadInfo.h
//  SKMaps
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Model class for offline package download URLs.
 */
@interface SKMapPackageDownloadInfo : NSObject

/** URL for the map file (.skm).
 */
@property(nonatomic, strong) NSString *mapURL;

/** URL for texture file (.txg).
 */
@property(nonatomic, strong) NSString *textureURL;

/** The URL for the namebrowser files (.zip).
 */
@property(nonatomic, strong) NSString *namebrowserFilesURL;

/** An array containing the URLs for the unarchived namebrowser files. This is an alternative to downloading the namebrowser zip, without having to unarchive it.
 */
@property(nonatomic, strong) NSArray *unarchivedNamebrowserFileURLs;

/** The URL for the elevation files (.zip).
 */
@property(nonatomic, strong) NSString *elevationPackageURL;

@end
