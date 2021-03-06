//
//  OOAppDelegate.m
//  Oriole2
//
//  Created by Gary Wong on 12/11/11.
//  Copyright 2010 Oriole2 Ltd. All rights reserved.
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

#import "OOAppDelegate.h"

#import "iRate.h"
#import "iVersion.h"
#import "OOCommon.h"

// private methods
@interface OOAppDelegate (hidden)

@end

@implementation OOAppDelegate

+ (void)load
{
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    [iRate sharedInstance].promptAtLaunch = NO;
    [iRate sharedInstance].daysUntilPrompt = 0;
    [iRate sharedInstance].eventsUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 2;
    [iRate sharedInstance].remindPeriod = 4;
    [iRate sharedInstance].messageTitle = OOLocalizedStringInOOBundle(@"iRateMessageTitle");
    [iRate sharedInstance].message = OOLocalizedStringInOOBundle(@"iRateAppMessage");

    [iRate sharedInstance].cancelButtonLabel = @"";
    [iRate sharedInstance].remindButtonLabel = OOLocalizedStringInOOBundle(@"iRateRemindButton"); // exchange
    [iRate sharedInstance].rateButtonLabel = OOLocalizedStringInOOBundle(@"iRateRateButton");
    
    [iVersion sharedInstance].checkPeriod = 1;
    [iVersion sharedInstance].ignoreButtonLabel = @"";
}

- (id)init
{
    self = [super init];

    if (self) {
    }

    return self;
}

- (void)dealloc
{
}

#pragma mark -
#pragma mark Memory management
// overload me to get a memory tracing support
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [OOCommon logMemory];
}

@end
