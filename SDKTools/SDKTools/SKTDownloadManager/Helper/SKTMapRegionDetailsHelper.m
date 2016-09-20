//
//  SKTMapRegionDetailsHelper.m

//

#import "SKTMapRegionDetailsHelper.h"
#import "SKTDownloadObjectHelper.h"
#import "SKTTexture.h"

@implementation SKTMapRegionDetailsHelper

+(id)mapRegionDetailsHelperWithSKTPackage:(SKTPackage*)package
{
    SKTMapRegionDetailsHelper *mapDetails = [[SKTMapRegionDetailsHelper alloc] init];
    
    //map file Path.
    if (package.file) {
        mapDetails.downloadURLMap = package.file;
    }
    
    //Downlaod url NB.
    if (package.nbzip) {
        mapDetails.downloadURLNB = package.nbzip;
    }
    
    long long totalSize = 0;
    if (package.size) {
        totalSize = package.size;
    }
    
    long long nbSize = totalSize;
    if (package.skmsize) {
        mapDetails.sizeMap = [NSNumber numberWithLongLong:package.skmsize];
        nbSize -= package.skmsize;
    }
    
    mapDetails.sizeNB = [NSNumber numberWithLongLong:nbSize];
    
    //Textures
    if (package.texture) {
        //link to file
        if (package.texture.file) {
            mapDetails.downloadURLTexture = package.texture.file;
        }
        
        //size of zip
        NSNumber *zipSizeNumberTexture = [NSNumber numberWithLongLong:package.texture.sizebigfile];
        mapDetails.sizeTexture = zipSizeNumberTexture;
        
        //unzipped size
        
        NSNumber *unzipSizeNumberTexture = [NSNumber numberWithLongLong:package.texture.unzipsize];
        mapDetails.unzipSizeTexture = unzipSizeNumberTexture;
        
    }

    [mapDetails setCode:package.packageCode];
    [mapDetails setParentCode:package.parentCode];
    
    return mapDetails;
}

@end
