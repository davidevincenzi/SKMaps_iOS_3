//
//  SKOneBoxTopHit.h
//  SKOSearchLib
//
//  Created by Dragos Dobrean on 02/02/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SKOneBoxTopHitNumberOfVisibleResults 2

@interface SKOneBoxTopHit : NSObject

/** Marks the top hit results from the provided dictionary of
 results
  It only looks at the first **two (defined above) results as they the ony ones shown
 in th initial UI
  Uses the search providers list if provided to obtain the order of the results (how will be
 presented in the UI)
 */
- (void)markTopHitsFromResults:(NSDictionary *)results withSearchProviders:(NSArray *)searchProviders andCompletitionBlock:(void(^)(NSDictionary *markedResults))block;

@end
