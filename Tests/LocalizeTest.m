//
//  LocalizeTest.m
//  Oriole2
//
//  Created by Gary Wong on 1/10/11.
//  Copyright 2011 Oriole2 Ltd. All rights reserved.
//
// Permission is hereby granted to staffs of Oriole2 Ltd.
// Any person obtaining a copy of this software and associated documentation 
// files (the "Software") should not use, copy, modify, merge, publish, distribute, 
// sublicense, and/or sell copies of the Software without permission granted by 
// Oriole2 Ltd.
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 


#import "LocalizeTest.h"
#import "OOLocalize.h"


@implementation LocalizeTest

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void) testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}

- (void) testCurrentLanguage
{
	NSString *lan = [OOLocalize getCurrentLanguage];
	STAssertTrue([lan isEqualToString:@"en-us"], @"get language error");
}

#endif


@end
