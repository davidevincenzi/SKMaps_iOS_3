//
//  SKOneBoxTableHeaderViewTests.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SKOneBoxTableHeaderView.h"

@interface SKOneBoxTableHeaderViewTests : XCTestCase

@end

@implementation SKOneBoxTableHeaderViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testInitWithFrameAndButtonsArray {
    UIButton *button1 = [[UIButton alloc] init];
    UIButton *button2 = [[UIButton alloc] init];
    
    NSArray *myButtons = [[NSArray alloc] initWithObjects:button1, button2, nil];
    CGRect frame = CGRectMake(0, 0, 0, 0);
    
    SKOneBoxTableHeaderView *headerView = [[SKOneBoxTableHeaderView alloc] initWithFrame:frame andButtonsArray:myButtons];
    
    XCTAssert([myButtons isEqualToArray:headerView.buttons], @"Pass");
    XCTAssert(CGRectEqualToRect(frame, headerView.frame), @"Pass");
}
@end
