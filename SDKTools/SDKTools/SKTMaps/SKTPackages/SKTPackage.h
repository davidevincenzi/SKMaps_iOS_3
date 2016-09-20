//
//  SKTPackage.h
//  ProtobufParsing
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SKTPackageType) {
	SKTPackageTypeCountry = 0,
	SKTPackageTypeCity,
	SKTPackageTypeContinent,
	SKTPackageTypeRegion,
	SKTPackageTypeState
} ;

@class SKTLanguage;
@class SKTTexture;
@class SKTElevation;
@class SKTBBox;
@class SKTMapsObject;

@interface SKTPackage : NSObject

@property (nonatomic, strong) NSString *packageCode;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, assign) SKTPackageType type;

@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) long long skmsize;
@property (nonatomic, assign) long long size;
@property (nonatomic, assign) long long unzipsize;
@property (nonatomic, strong) NSString *nbzip;

@property (nonatomic, strong) SKTTexture *texture;
@property (nonatomic, strong) SKTElevation *elevation;
@property (nonatomic, strong) SKTBBox *bbox;

@property (nonatomic, assign) SKTMapsObject *mapsObject;

@property (nonatomic, strong) NSString *parentCode;
@property (nonatomic, strong) NSArray *childCodes;

- (NSString *)nameForLanguageCode:(NSString *)languageCode;

- (NSArray *)childObjects;
- (instancetype)parentObject;

-(void)addChildCode:(NSString*)code;

@end
