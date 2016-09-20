//
//  SKOneBoxDropdownControllerTests.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SkOneBoxDropdownController.h"
#import "SKOneBoxDropdownItem.h"

@interface SKOneBoxDropdownControllerTests : XCTestCase

@end

@implementation SKOneBoxDropdownControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testAddDropdownItem {
    SKOneBoxDropdownItem *item = [SKOneBoxDropdownItem dropdownItem];
    SKOneBoxDropdownController *controller = [[SKOneBoxDropdownController alloc] init];
    
    [controller addDropdownItem:item];
    
    XCTAssert([controller.items containsObject:item], @"Pass");
}

-(void)testRemoveDropdownItem {
    SKOneBoxDropdownItem *item = [SKOneBoxDropdownItem dropdownItem];
    SKOneBoxDropdownController *controller = [[SKOneBoxDropdownController alloc] init];
    
    [controller addDropdownItem:item];
    [controller removeDropdownItem:item];
    
    XCTAssert(![controller.items containsObject:item], @"Pass");
}

-(void)testInsertDropdownItemAtIndex {
    SKOneBoxDropdownItem *item0 = [SKOneBoxDropdownItem dropdownItem];
    SKOneBoxDropdownItem *item1 = [SKOneBoxDropdownItem dropdownItem];
    SKOneBoxDropdownItem *item2 = [SKOneBoxDropdownItem dropdownItem];
    SKOneBoxDropdownItem *insertedItem = [SKOneBoxDropdownItem dropdownItem];
    SKOneBoxDropdownController *controller = [[SKOneBoxDropdownController alloc] init];
    
    [controller addDropdownItem:item0];
    [controller addDropdownItem:item1];
    [controller addDropdownItem:item2];
    [controller insertDropdownItem:insertedItem atIndex:1];
    
    XCTAssertEqual(insertedItem, [controller.items objectAtIndex:1],@"Pass");
}

-(void)testRemoveDropdownItemAtIndex {
    SKOneBoxDropdownItem *item0 = [SKOneBoxDropdownItem dropdownItem];
    SKOneBoxDropdownItem *itemToRemove = [SKOneBoxDropdownItem dropdownItem];
    SKOneBoxDropdownItem *item2 = [SKOneBoxDropdownItem dropdownItem];
    
    SKOneBoxDropdownController *controller = [[SKOneBoxDropdownController alloc] init];
    
    [controller addDropdownItem:item0];
    [controller addDropdownItem:itemToRemove];
    [controller addDropdownItem:item2];
    
    NSUInteger index = [controller.items indexOfObject:itemToRemove];
    [controller removeDropdownItemAtIndex:index];
    
    XCTAssert(![controller.items containsObject:itemToRemove],@"Pass");
}

@end
