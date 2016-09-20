//
//  SKOneBoxDefaultTableItem.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 21/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxDefaultTableItem.h"
#import "UIColor+SKOneBoxColors.h"
#import "SKOneBoxSearchConstants.h"

@implementation SKOneBoxDefaultTableItem

-(id)init {
    self = [super init];
    
    if (self) {
        self.itemHeight = kRowHeightOneLineResult;
        
        self.titleColor = [UIColor hex3A3A3A];
        self.titleFont = [UIFont fontWithName:@"Avenir-Roman" size:16];
    }
    
    return self;
}

@end
