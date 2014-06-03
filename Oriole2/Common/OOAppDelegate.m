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
#import "BWQuincyManager.h"

//#import "GTMStackTrace.h"
/*
#include <exception>*/

//private methods
@interface OOAppDelegate (hidden)

@end

@implementation OOAppDelegate

+ (void)initialize
{
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    [iRate sharedInstance].promptAtLaunch = NO;
    [iRate sharedInstance].daysUntilPrompt = 0;
    [iRate sharedInstance].eventsUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 2;
    [iRate sharedInstance].remindPeriod = 4;
    [[iRate sharedInstance] downloadConfig];
    [iVersion sharedInstance];
}

/**
 @see http://chaosinmotion.com/blog/?p=423
 http://www.iphonedevsdk.com/forum/iphone-sdk-development-advanced-discussion/18633-flurry-uncaughtexception-handler.html
 */
/*
void _uncaughtExceptionHandler(NSException *exception)
{
    //[Flurry logError:@"uncaughtException" message:[exception name] exception:exception];
    
#ifndef DEBUG
	NSString *trace = GTMStackTraceFromException(exception);
    [Flurry logError:@"uncaughtException" message:trace exception:exception];
#else
    OOLog(@"Stack Trace: %@", [exception callStackSymbols]);
#endif
}*/

//http://pastebin.com/HS6jLQs0
//void _uncaughtExceptionHandler(NSException *exception)
//{
//    if ([exception respondsToSelector:@selector(callStackSymbols)])
//    {
//        OOLog(@"Exception %@ with callStack %@", exception, [exception callStackSymbols]);
//        
//#ifndef DEBUG
//        NSMutableString *summarizedCallStackSymbols = [NSMutableString string];
//        for (NSString *callStackSymbol in [exception callStackSymbols])
//        {
//            /* Remove the framework prefix */
//            if (callStackSymbol.length > 51)
//                callStackSymbol = [callStackSymbol substringFromIndex:51];
//            
//            /* Flurry's message space is very limited; remove the offset to further save space */
//            NSRange plusRange = [callStackSymbol rangeOfString:@" + "];
//            if (plusRange.location != NSNotFound)
//                callStackSymbol = [callStackSymbol substringToIndex:plusRange.location];
//            
//            /* Skip useless top-of-stack entries */
//            if (([callStackSymbol rangeOfString:@"__exceptionPreprocess"].location != NSNotFound) ||
//                ([callStackSymbol rangeOfString:@"objc_exception_throw"].location != NSNotFound))
//                continue;
//            
//            /* We could add a character between each symbol, but that just loses us precious space */
//            [summarizedCallStackSymbols appendFormat:@"%@", callStackSymbol];                      
//        }
//        
//        [Flurry logError:[exception name]
//                          message:summarizedCallStackSymbols
//                        exception:exception];
//#endif
//    }
//    else
//    {
//#ifndef DEBUG
//        [Flurry logError:[exception name]
//                          message:[exception reason]
//                        exception:exception];
//#endif
//    }
//}

- (id)init
{
	self = [super init];
	if (self)
	{
//        NSSetUncaughtExceptionHandler(&_uncaughtExceptionHandler);
        [[BWQuincyManager sharedQuincyManager] setSubmissionURL:@"http://oriole2.com/CrashReporter/crash_v300.php"];
        [[BWQuincyManager sharedQuincyManager] setDelegate:(id<BWQuincyManagerDelegate>)self];
//        [[BWQuincyManager sharedQuincyManager] startManager];
	}
	return self;
}

- (void)dealloc 
{
}

#pragma mark -
#pragma mark Memory management
//overload me to get a memory tracing support
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [OOCommon logMemory];
}

@end
