//
//  SKTMapDownloadState.m
//  
//

//

#import "SKTMapDownloadState.h"

@implementation SKTMapDownloadState

-(id)initInstalled:(BOOL)installed
{
    self = [super init];
    if (self)
    {
        self.bSkmDownloaded = installed;
        self.bNBDownloaded = installed;
        self.bTexturesDownloaded = installed;
        self.bNBUnzipped = installed;
    }
    return self;
}


-(void)setInstalled:(BOOL) installed
{
    self.bSkmDownloaded = installed;
    self.bNBDownloaded = installed;
    self.bTexturesDownloaded = installed;
    self.bNBUnzipped = installed;
}

-(BOOL)isFullyDownloaded
{
    return (self.bSkmDownloaded && self.bNBDownloaded && self.bTexturesDownloaded && self.bNBUnzipped);
}

-(BOOL) isFullyUnzipped
{
    return (self.bNBUnzipped);
}


-(BOOL)finishedDownloading
{
    return (self.bSkmDownloaded && self.bNBDownloaded && self.bTexturesDownloaded);
}

@end
