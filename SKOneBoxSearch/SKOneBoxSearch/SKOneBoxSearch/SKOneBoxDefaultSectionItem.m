//
//  SKOneBoxDefaultSectionItem.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxDefaultSectionItem.h"

@interface SKOneBoxDefaultSectionItem ()

@end

@implementation SKOneBoxDefaultSectionItem

-(id)init {
    self = [super init];
    
    if (self) {
        self.headerSectionHeight = 24.0f;
        self.footerSectionHeight = 24.0f;
    }
    
    return self;
}

-(id)initSectionItems:(NSArray*)items {
    self = [super init];
    
    if (self) {
        self.sectionTableItems = items;
        self.headerSectionHeight = 24.0f;
        self.footerSectionHeight = 24.0f;
    }
    
    return self;
}

@end
