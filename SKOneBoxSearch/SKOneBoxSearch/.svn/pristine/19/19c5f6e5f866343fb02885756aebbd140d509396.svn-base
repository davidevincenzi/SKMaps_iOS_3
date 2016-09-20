//
//  SKOneBoxHeaderButtonTests.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SKOneBoxHeaderButton.h"

@interface SKOneBoxHeaderButtonTests : XCTestCase

@end

@implementation SKOneBoxHeaderButtonTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testInit {
    NSString *title = @"Title";
    UIImage *activeImage = [[UIImage alloc] init];
    UIImage *selectedImage = [[UIImage alloc] init];
    UIImage *inactiveImage = [[UIImage alloc] init];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    void (^mySelectionBlock)(void) = ^void() {
        [expectation fulfill];
    };
    SKOneBoxHeaderButton *header = [[SKOneBoxHeaderButton alloc] initWithTitle:title activeImage:activeImage selectedImage:selectedImage inactiveImage:inactiveImage andSelectionBlock:mySelectionBlock];
    
    XCTAssert([header.textLabel.text isEqualToString:title], @"Pass");
    XCTAssert([header.activeStateImage isEqual:activeImage], @"Pass");
    XCTAssert([header.selectedStateImage isEqual:selectedImage], @"Pass");
    XCTAssert([header.inactiveStateImage isEqual:inactiveImage], @"Pass");
    XCTAssert(header.selectionBlock, @"Pass");
    
    header.selectionBlock();
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        XCTAssert(!error, @"Pass");
    }];
}

@end
