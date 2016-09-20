//
//  SKOneBoxDropDownItemTests.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SKOneBoxDropdownItem.h"


@interface SKOneBoxDropDownItemTests : XCTestCase

@end

@implementation SKOneBoxDropDownItemTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testDropDownItem {
    SKOneBoxDropdownItem *item = [SKOneBoxDropdownItem dropdownItem];
    
    XCTAssert(item, @"Pass");
}

-(void)testDropDownItemWithTitle {
    NSString *title = @"Title";
    SKOneBoxDropdownItem *item = [SKOneBoxDropdownItem dropdownItemWithTitle:title];

    XCTAssert([item.title isEqualToString:title], @"Pass");
}

@end
