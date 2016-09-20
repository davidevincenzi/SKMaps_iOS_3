//
//  AppleSearchObject.h
//

#import <SKOSearchLib/SKOSearchLib.h>

/** AppleSearchObject - stores the information for a apple address search.
 */
@interface AppleSearchObject : SKOBaseSearchObject

/** The code of the country.
 */
@property(nonatomic, strong) NSString *country;

/** The name of the state.
 */
@property(nonatomic, strong) NSString *state;

/** The name of the city or zip code
 */
@property(nonatomic, strong) NSString *city;

/** The name of the street.
 */
@property(nonatomic, strong) NSString *street;

/** The house number.
 */
@property(nonatomic, strong) NSString *houseNumber;

/** Creates an empty AppleSearchObject
 @return - an empty autoreleased object
 */
+ (instancetype)appleSearchObject;

@end
