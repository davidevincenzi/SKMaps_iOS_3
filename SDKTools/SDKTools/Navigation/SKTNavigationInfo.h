//
//  SKTNavigationInfo.h
//  SDKTools
//

//

#import <Foundation/Foundation.h>
#import <SKMaps/SKDefinitions.h>
#import <SKMaps/SKRouteAdvice.h>

/** Aggregates different values regarding the navigation state.
 */
@interface SKTNavigationInfo : NSObject

/** Current navigation speed in m/s. Used by the UI category to update the UI accordingly.
 */
@property (nonatomic, assign) double currentSpeed;

/** Current speed limit in m/s. Used by the UI category to update the UI accordingly.
 */
@property (nonatomic, assign) double currentSpeedLimit;

/** Current estimated time to arrival in seconds. Used by the UI category to update the UI accordingly.
 */
@property (nonatomic, assign) int currentETA;

/** Current distance to arrival in meters. Used by the UI category to update the UI accordingly.
 */
@property (nonatomic, assign) int currentDTA;

/** Current country code. Used to load the appropriate color dictionary.
 */
@property (nonatomic, assign) NSString *currentCountryCode;

/** Current street type. Used to update the colors of the current street label colors in free drive.
 */
@property (nonatomic, assign) SKStreetType currentStreetType;

/** Next street type. Used to update the colors of the visual advice in navigation.
 */
@property (nonatomic, assign) SKStreetType nextStreetType;

/** Second next street type. Used to update the colors of the short visual advice in navigation.
 */
@property (nonatomic, assign) SKStreetType secondNextStreetType;

/** Tells whether the current advice is the last one.
 */
@property (nonatomic, assign) BOOL isLastAdvice;

/** Tells whether the next advice is the last one.
 */
@property (nonatomic, assign) BOOL nextAdviceIsLast;

/** Latest received audio advice list.
 */
@property (nonatomic, strong) NSArray *lastAudioAdvices;

/** Latest received visual route advice.
 */
@property (nonatomic, strong) SKRouteAdvice *firstAdvice;

/** Is the visual route advice the last one?
 */
@property (nonatomic, assign) BOOL firstAdviceIsLast;

/** Latest received short visual advice.
 */
@property (nonatomic, strong) SKRouteAdvice *secondaryAdvice;

/** Is the short visual route advice the last one?
 */
@property (nonatomic, assign) BOOL secondaryAdviceIsLast;

/** Resets the properties to some default values.
 */
- (void)reset;

@end
