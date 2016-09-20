//
//  SKTMaps.h
//  ProtobufParsing
//

#import <Foundation/Foundation.h>

#import "SKTPackage.h"
#import "SKTLanguage.h"
#import "SKTTexture.h"
#import "SKTElevation.h"
#import "SKTBBox.h"

/** Contains information regarding maps json
 */
@interface SKTMapsObject : NSObject

/** The version of the SKTMapsObject from the json.
 */
@property (nonatomic, strong) NSString *xmlVersion;

/** The xml version of the SKTMapsObject from the json.
 */
@property (nonatomic, strong) NSString *version;

/** An array with all the packages of the SKTMapsObject.
 */
@property (nonatomic, strong) NSArray *packages;

/** Returns a SKTMapsObject for the given json.
 @param jsonString The string for the json.
 @return An SKTMapsObject object from the json string given.
 */
+ (SKTMapsObject *)convertFromJSON:(NSString *)jsonString;

/** Returns all the packages for a specified type.
 @param packageType The type of the packages to be returned.
 @return An array of SKTPackage objects.
 */
- (NSArray *)packagesForType:(SKTPackageType)packageType;

/** Returns a SKTPackage object for a specified package code.
 @param packageCode The code of the package to be returned.
 @return An SKTPackage object corresponding to the given package code.
 */
- (SKTPackage *)packageForCode:(NSString *)packageCode;

@end
