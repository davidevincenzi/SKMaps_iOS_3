//
//  SKTDownloadTypes.h
//  

//

#ifndef _SKDownloadTypes_h
#define _SKDownloadTypes_h

typedef NS_ENUM(NSUInteger, SKTDownloadFileType) {
    SKTDownloadFileTypeTexture = 0,  //Texture zip
    SKTDownloadFileTypeNBFile,       //Namebrowser zip
    SKTDownloadFileTypeMapFile,      //Map file.
    SKTDownloadFileTypeWikiTravel,
    SKTDownloadFileTypeVoice
} ;

typedef NS_ENUM(NSInteger, SKTMapDownloadItemStatus) {
    SKTMapDownloadItemStatusInvalidState = -1,
    SKTMapDownloadItemStatusQueued,
    SKTMapDownloadItemStatusPaused,
    SKTMapDownloadItemStatusDownloading,
    SKTMapDownloadItemStatusInstalling,
    SKTMapDownloadItemStatusProcessing,
    SKTMapDownloadItemStatusFinished
};

#endif
