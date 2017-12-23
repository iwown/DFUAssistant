//
//  FirmwareUpdateTests.m
//  FirmwareUpdateTests
//
//  Created by west on 16/9/19.
//  Copyright © 2016年 west. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FileManager.h"

@interface FirmwareUpdateTests : XCTestCase

@end

@implementation FirmwareUpdateTests

- (void)setUp {
    
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testApp {
    NSInteger file = [FileManager addFunction:1 andB:2];
    NSCAssert(file == 3, @"exist");
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
