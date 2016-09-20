//
//  SKOBaseSearchObject.h
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKODefinitions.h"

/**Base class for objects returned by SKOSearchLib search services.
 */
@interface SKOBaseSearchObject : NSObject


/** Api key to be used by the service.
 */
@property (nonatomic, strong) NSString *apiKey;

/** Api secret to be used by the service.
 */
@property (nonatomic, strong) NSString *apiSecret;

/** The connectivity mode of the search. The default value is SKSearchOnline.
 */
@property(nonatomic, assign) SKOSearchMode searchMode;

/** Search language
 */
@property(nonatomic, strong) NSString *searchLanguage;

@end
