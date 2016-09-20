//
//  SKTDownloadObjectHelper.m
//  

//

#import "SKTDownloadObjectHelper.h"
#import <AFNetworking.h>
#import <SKMaps/SKMapPackageDownloadInfo.h>
#import <SKMaps/SKMapsService.h>
#import "SKTLanguage.h"

NSString * const kSKTSkobblerMapsURLString = @"http://maps.skobbler.com";

@implementation SKTDownloadObjectHelper

#pragma mark - Creation

+(id)downloadObjectHelperWithSKTPackage:(SKTPackage*)package
{
    SKTDownloadObjectHelper *mapRegionHelper = [[SKTDownloadObjectHelper alloc] init];
    
    NSArray *components = [package.file componentsSeparatedByString:@"/"];
    mapRegionHelper.custom = ([[components objectAtIndex:0] isEqualToString:@"custom-packages"]) ? YES : NO;
    
    for (SKTLanguage *language in package.languages) {
        [mapRegionHelper setValue:[language tlName] forKey:[NSString stringWithFormat:@"name_%@",[language lngCode]]];
    }
    
    [mapRegionHelper setIsInstalled:[NSNumber numberWithBool:NO]];
    [mapRegionHelper setIsPurchased:[NSNumber numberWithBool:NO]];
    [mapRegionHelper setType:[NSNumber numberWithInt:package.type]];
    [mapRegionHelper setDetails:[SKTMapRegionDetailsHelper mapRegionDetailsHelperWithSKTPackage:package]];
    [mapRegionHelper setDownloadType:SKTDownloadObjectMap];
    
    //init download state with default values
    [mapRegionHelper initDownloadState];
    
    if([[mapRegionHelper isInstalled] boolValue])
    {
        [mapRegionHelper.details setDownloadState:[[SKTMapDownloadState alloc] initInstalled:YES]];
    }
    
    mapRegionHelper.package = package;
    
    return mapRegionHelper;
}

-(void)initDownloadState
{
    self.details.downloadState = [[SKTMapDownloadState alloc] init];
    
    //set yes if not avaialble
    self.details.downloadState.bSkmDownloaded = ![SKTDownloadObjectHelper linkAvailableForDownloadHelper:self withType:SKTDownloadFileTypeMapFile];
    self.details.downloadState.bNBDownloaded = ![SKTDownloadObjectHelper linkAvailableForDownloadHelper:self withType:SKTDownloadFileTypeNBFile];
    self.details.downloadState.bNBUnzipped = ![SKTDownloadObjectHelper linkAvailableForDownloadHelper:self withType:SKTDownloadFileTypeNBFile];
    self.details.downloadState.bTexturesDownloaded = ![SKTDownloadObjectHelper linkAvailableForDownloadHelper:self withType:SKTDownloadFileTypeTexture];
}

#pragma mark - Overriden

-(NSString*)description
{
    return [NSString stringWithFormat:@"\n Code: %@\n Name EN: %@\n Name DE: %@\n Name FR: %@\n Name Es: %@\n Name IT: %@\n ParentCode:%@\n URL:%@\n Installed:%d\n Bought:%d\n MapSize:%@\n NBSize:%@\n TextureSize:%@\n TextureURL:%@\n \n",[self getCode], self.name_en, self.name_de, self.name_fr, self.name_es, self.name_it, self.details.parentCode, self.details.downloadURLMap , [self.isInstalled  boolValue], [self.isPurchased boolValue] , self.details.sizeMap , self.details.sizeNB, self.details.sizeTexture, self.details.downloadURLTexture ];
}

-(NSComparisonResult)compare:(SKTDownloadObjectHelper*)otherObject
{
    return [[otherObject getCode] compare:[self getCode]];
}

#pragma mark - Helpers

-(NSString*)mapRegionHelperNameForCurrentLanguage
{
    NSString * currentLanguage = @"en";
    if([currentLanguage isEqualToString:@"en_us"])
    {
        currentLanguage=@"en";
    }

    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"name_%@",currentLanguage]);
    NSString* localizedName = nil;
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        localizedName = [self performSelector:selector withObject:nil];
#pragma clang diagnostic pop
    }
    
    if(!localizedName) {
        localizedName = [self name_en];
    }
    
    return localizedName;
}

-(NSString*)getCode
{
    return self.details.code;
}

-(long long)getTotalSize
{
    if (self.downloadType == SKTDownloadObjectMap)
    {
#ifdef TOM_TOM_MAPS
        return [self.details.sizeMap longLongValue];
#else
        return [self.details.sizeTexture longLongValue] + [self.details.sizeNB longLongValue] + [self.details.sizeMap longLongValue];
#endif
    }
    else
    {
        return 0;
    }
}

- (BOOL)isFullyDownloaded {
    if (self.downloadType == SKTDownloadObjectMap) {
        return (self.details.downloadState.bSkmDownloaded && self.details.downloadState.bNBDownloaded && self.details.downloadState.bTexturesDownloaded && self.details.downloadState.bNBUnzipped);
    }
    
    return NO;
}

- (BOOL)isFullyUnzipped {
    if (self.downloadType == SKTDownloadObjectMap) {
        return (self.details.downloadState.bNBUnzipped);
    }
    else if (self.downloadType == SKTDownloadObjectWiki) {
        return YES;
    }
    return NO;
}

- (BOOL)finishedDownloading {
    if (self.downloadType == SKTDownloadObjectMap) {
        return (self.details.downloadState.bSkmDownloaded && self.details.downloadState.bNBDownloaded && self.details.downloadState.bTexturesDownloaded);
    }

    return FALSE;
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters withEncoding:(NSStringEncoding)encoding {
    //build a serialzier to makde a url and get serialized query
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    [serializer setStringEncoding:encoding];
    NSURLRequest *request = [serializer requestBySerializingRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSKTSkobblerMapsURLString]] withParameters:parameters error:nil];
    NSString *requestParameter = request.URL.query;
    return requestParameter;
}

+ (NSDictionary *)urlAuthenticationHeaders {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    // osName, osVer, appName, appVer
    headers[@"osName"] = [[[UIDevice currentDevice] systemName] stringByReplacingOccurrencesOfString:@" " withString:@""];
    headers[@"osVer"] = [[UIDevice currentDevice] systemVersion];
    headers[@"appName"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    headers[@"appVer"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    headers[@"uid"] = [[UIDevice currentDevice] identifierForVendor];
    
    return headers;
}

+ (NSString *)urlParameters
{
    NSDictionary *dictionary = [self urlAuthenticationHeaders];
    return [self queryStringFromParameters:dictionary withEncoding:NSUTF8StringEncoding];
}

+ (SKMapPackageDownloadInfo *)formattedMapPackageDownloadInfoForCountryCode:(NSString *)countryCode downloadHelper:(SKTDownloadObjectHelper *)currentDownloadHelper {
    SKMapPackageDownloadInfo *packageDownloadInfo = [[SKMapsService sharedInstance].packagesManager downloadInfoForPackageWithCode:countryCode forMapVersion:nil];
    packageDownloadInfo.mapURL = (currentDownloadHelper.isCustom) ? [packageDownloadInfo.mapURL stringByReplacingOccurrencesOfString:@"package" withString:@"custom-packages"] : packageDownloadInfo.mapURL;
    packageDownloadInfo.textureURL = (currentDownloadHelper.isCustom) ? [packageDownloadInfo.textureURL stringByReplacingOccurrencesOfString:@"package" withString:@"custom-packages"] : packageDownloadInfo.textureURL;
    packageDownloadInfo.namebrowserFilesURL = (currentDownloadHelper.isCustom) ? [packageDownloadInfo.namebrowserFilesURL stringByReplacingOccurrencesOfString:@"package" withString:@"custom-packages"] : packageDownloadInfo.namebrowserFilesURL;
    
    return packageDownloadInfo;
}

//Form the URL for each type of file for the assigned map object

+ (NSURL *)downloadHelper:(SKTDownloadObjectHelper *)currentDownloadHelper downloadURLForType:(SKTDownloadFileType)downloadFileType {
    SKMapPackageDownloadInfo *packageDownloadInfo = [SKTDownloadObjectHelper formattedMapPackageDownloadInfoForCountryCode:currentDownloadHelper.details.code downloadHelper:currentDownloadHelper];
    
    NSURL *itemURL = nil;
    switch (downloadFileType) {
        case SKTDownloadFileTypeTexture:
        {
            itemURL = [NSURL URLWithString:packageDownloadInfo.textureURL];
            break;
        }
        case SKTDownloadFileTypeMapFile:
        {
            itemURL = [NSURL URLWithString:packageDownloadInfo.mapURL];
            break;
        }
        case SKTDownloadFileTypeNBFile:
        {
            itemURL = [NSURL URLWithString:packageDownloadInfo.namebrowserFilesURL];
            break;
        }
        default:
            break;
    }
    
    return itemURL;
}

+ (BOOL)linkAvailableForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper withType:(SKTDownloadFileType)downloadFileType {
    switch (downloadFileType) {
        case SKTDownloadFileTypeTexture:
        {
            return (downloadHelper.details.downloadURLTexture != nil);
            break;
        }
        case SKTDownloadFileTypeMapFile:
        {
            return (downloadHelper.details.downloadURLMap != nil);
            break;
        }
        case SKTDownloadFileTypeNBFile:
        {
            return (downloadHelper.details.downloadURLNB != nil);
            break;
        }
        default:
            return NO;
            break;
    }
}

@end
