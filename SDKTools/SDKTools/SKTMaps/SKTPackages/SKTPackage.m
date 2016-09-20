//
//  SKTPackage.m
//  ProtobufParsing

//

#import "SKTPackage.h"
#import "SKTLanguage.h"
#import "SKTTexture.h"
#import "SKTElevation.h"
#import "SKTBBox.h"
#import "SKTMapsObject.h"

@implementation SKTPackage

- (SKTPackageType)packageTypeForString:(NSString *)packageType {
	if ([packageType isEqualToString:@"country"]) {
		return SKTPackageTypeCountry;
	}
	else if ([packageType isEqualToString:@"city"]) {
		return SKTPackageTypeCity;
	}
	else if ([packageType isEqualToString:@"continent"]) {
		return SKTPackageTypeContinent;
	}
	else if ([packageType isEqualToString:@"region"]) {
		return SKTPackageTypeRegion;
	}
	else if ([packageType isEqualToString:@"state"]) {
		return SKTPackageTypeState;
	}
	return SKTPackageTypeCountry;
}

- (NSString *)nameForLanguageCode:(NSString *)languageCode {
	for (SKTLanguage *language in self.languages) {
		if ([language.lngCode isEqualToString:languageCode]) {
			return language.tlName;
		}
	}
	return nil;
}

- (NSArray *)childObjects
{
    NSMutableArray *childObjs = [NSMutableArray array];
    for (NSString *childCode in self.childCodes) {
        SKTPackage *package = [self.mapsObject packageForCode:childCode];
        [childObjs addObject:package];
    }
    return childObjs;
}

- (instancetype)parentObject
{
    if (self.parentCode) {
        SKTPackage *package = [self.mapsObject packageForCode:self.parentCode];
        return package;
    }
    return nil;
}

-(void)addChildCode:(NSString*)code
{
    if (!self.childCodes) {
        self.childCodes = [NSArray arrayWithObject:code];
    }
    else
    {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.childCodes];
        [tempArray addObject:code];
        self.childCodes = tempArray;
    }
}

@end
