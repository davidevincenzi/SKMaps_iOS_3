//
//  SKTMaps.m
//  ProtobufParsing
//
//

#import "SKTMapsObject.h"

@implementation SKTMapsObject

#pragma mark - Parsing

+ (SKTMapsObject *)convertFromJSON:(NSString *)jsonString {
	NSError *e = nil;
	NSDictionary *JSON = [NSJSONSerialization
	                      JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                          options:NSJSONReadingMutableContainers
                          error:&e];
    
	SKTMapsObject *maps = [[SKTMapsObject alloc] init];
	NSMutableArray *packagesArray = [NSMutableArray array];
    
	//common attributed
	maps.version = JSON[@"version"];
	maps.xmlVersion = JSON[@"xmlVersion"];
    
	//packages
	for (NSDictionary *packageChild in JSON[@"packages"]) {
		//go through each package
        
		SKTPackage *package = [[SKTPackage alloc] init];
        
		[package setMapsObject:maps];
        
		[package setPackageCode:packageChild[@"packageCode"]];
        
		//type
		[package setType:[packageChild[@"type"] intValue]];
        
		//languages
		NSMutableArray *languagesArray = [NSMutableArray array];
        
		for (NSDictionary *languageChild in packageChild[@"languages"]) {
			SKTLanguage *language = [[SKTLanguage alloc] init];
            
			[language setLngCode:languageChild[@"lngCode"]];
			[language setTlName:languageChild[@"tlName"]];
            
			[languagesArray addObject:language];
		}
		[package setLanguages:languagesArray];
        
		//file
		[package setFile:packageChild[@"file"]];
        
		//skmsize
		[package setSkmsize:[packageChild[@"skmsize"] longLongValue]];
        
		//size
		[package setSize:[packageChild[@"size"] longLongValue]];
        
		//unzipsize
		[package setUnzipsize:[packageChild[@"unzipsize"] longLongValue]];
        
		//nbzip
		[package setNbzip:packageChild[@"nbzip"]];
        
        
		//texture
		if (packageChild[@"texture"]) {
			NSDictionary *textureChild = packageChild[@"texture"];
			SKTTexture *texture = [[SKTTexture alloc] init];
            
			[texture setFile:textureChild[@"file"]];
			[texture setSize:[textureChild[@"size"] longLongValue]];
			[texture setUnzipsize:[textureChild[@"unzipsize"] longLongValue]];
			[texture setTexturesbigfile:textureChild[@"texturesbigfile"]];
			[texture setSizebigfile:[textureChild[@"sizebigfile"] longLongValue]];
            
			[package setTexture:texture];
		}
        
		if (packageChild[@"elevation"]) {
			SKTElevation *elevation = [[SKTElevation alloc] init];
            
			NSDictionary *elevationChild = packageChild[@"elevation"];
            
			[elevation setFile:elevationChild[@"file"]];
			[elevation setSize:[elevationChild[@"size"] longLongValue]];
			[elevation setUnzipsize:[elevationChild[@"unzipsize"] longLongValue]];
            
			[package setElevation:elevation];
		}
        
        
		//bbox
        
		/*
         @property (nonatomic, assign) double longMin;
         @property (nonatomic, assign) double longMax;
         @property (nonatomic, assign) double latMin;
         @property (nonatomic, assign) double latMax;
		 */
        
		if (packageChild[@"bbox"]) {
			SKTBBox *bbox = [[SKTBBox alloc] init];
            
			NSDictionary *bboxChild = packageChild[@"bbox"];
            
			[bbox setLongMin:[bboxChild[@"longMin"] doubleValue]];
			[bbox setLongMax:[bboxChild[@"longMax"] doubleValue]];
			[bbox setLatMin:[bboxChild[@"latMin"] doubleValue]];
			[bbox setLatMax:[bboxChild[@"latMax"] doubleValue]];
            
			[package setBbox:bbox];
		}
        
		[packagesArray addObject:package];
	}
	[maps setPackages:packagesArray];
    
	//world
	NSDictionary *worldChild = JSON[@"world"];

	for (NSDictionary *continentChild in worldChild[@"continents"]) {
		//go through each package
        
        NSString *contientCode = continentChild[@"continentCode"];
        SKTPackage *continentPackage = [maps packageForCode:contientCode];
        
		for (NSDictionary *countryChild in continentChild[@"countries"]) {
            
            NSString *countryCode = countryChild[@"countryCode"];
            [continentPackage addChildCode:countryCode];
            
            SKTPackage *countryPackage = [maps packageForCode:countryCode];
			[countryPackage setParentCode:contientCode];

            //try to get cityCodes
			for (NSDictionary *cityChild in countryChild[@"cityCodes"]) {
                
                NSString *cityCode = cityChild[@"cityCode"];
                
				SKTPackage *cityPackage = [maps packageForCode:cityCode];
                
                [countryPackage addChildCode:cityCode];
				[cityPackage setParentCode:countryCode];
			}
            //try to get stateCodes
            for (NSDictionary *stateChild in countryChild[@"stateCodes"]) {
                
                NSString *stateCode = stateChild[@"stateCode"];
                
				SKTPackage *statePackage = [maps packageForCode:stateCode];
                [countryPackage addChildCode:statePackage.packageCode];
				[statePackage setParentCode:countryCode];
                
                for (NSDictionary *stateCityChild in stateChild[@"cityCodes"]) {
                    
                    NSString *stateCityCode = stateCityChild[@"cityCode"];
                    
                    SKTPackage *stateCityPackage = [maps packageForCode:stateCityCode];
                    
                    [statePackage addChildCode:stateCityCode];
                    [stateCityPackage setParentCode:stateCode];
                }

			}
            
		}
	}
    
	return maps;
}

- (NSArray *)packagesForType:(SKTPackageType)packageType {
	NSMutableArray *packages = [NSMutableArray array];
	for (SKTPackage *package in self.packages) {
		if (package.type == packageType) {
			[packages addObject:package];
		}
	}
	return packages;
}

- (SKTPackage *)packageForCode:(NSString *)packageCode {
	for (SKTPackage *package in self.packages) {
		if ([package.packageCode isEqualToString:packageCode]) {
			return package;
		}
	}
	return nil;
}

@end
