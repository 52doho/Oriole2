//
//  OOApp_AppDelegate.m
//  Oriole2_App
//
//  Created by Gary Huang on 12-2-22.
//  Copyright (c) 2012年 Oriole2 Ltd. All rights reserved.
//

#import "OOApp_AppDelegate.h"

#import "OOViewController.h"
#import "GTMNSString+HTML.h"
//#import "CCShareKitConfigurator.h"
//#import "SHKConfiguration.h"

@implementation OOApp_AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

+ (void)initialize
{
//	//configure iRate
//	[iRate sharedInstance].appStoreID = 512796815;
//    [iRate sharedInstance].promptAtLaunch = YES;
//    [iRate sharedInstance].daysUntilPrompt = 0;
//    [iRate sharedInstance].eventsUntilPrompt = 0;
//    [iRate sharedInstance].usesUntilPrompt = 2;
//    
//	//configure iVersion
//	[iVersion sharedInstance].appStoreID = 512796815;
//    [iVersion sharedInstance].checkPeriod = 0;
	//[iVersion sharedInstance].remoteVersionsPlistURL = @"http://charcoaldesign.co.uk/iVersion/versions.plist";
	//[iVersion sharedInstance].localVersionsPlistPath = @"versions.plist";
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    CCShareKitConfigurator *configurator;
//    if(kIsiPad)
//        configurator = [[CCShareKitConfiguratorHD alloc] init];
//    else
//        configurator = [[CCShareKitConfigurator alloc] init];
//    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
//    [configurator release];
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[OOViewController alloc] initWithNibName:@"OOViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
//    [[SHK currentHelper] setRootViewController:self.window.rootViewController];
    
    //[NSException raise:@"测试异常" format:@"ss"];
    /*
    //push
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airhship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    [[UAPush shared] resetBadge];//zero badge on startup
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];*/
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    UALOG(@"Application did become active.");
//    [[UAPush shared] resetBadge]; //zero badge when resuming from background (iOS 4+)
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    UALOG(@"APN device token: %@", deviceToken);
//    // Updates the device token and registers the token with UA
//    [[UAPush shared] registerDeviceToken:deviceToken];
    /*
    //Do something when notifications are disabled altogther
    if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone)
    {
        UALOG(@"iOS Registered a device token, but nothing is enabled!");
        
        //only alert if this is the first registration, or if push has just been
        //re-enabled
        if ([UAirship shared].deviceToken != nil) { //already been set this session
            NSString* okStr = @"OK";
            NSString* errorMessage =
            @"Unable to turn on notifications. Use the \"Settings\" app to enable notifications.";
            NSString *errorTitle = @"Error";
            UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:okStr
                                                      otherButtonTitles:nil];
            
            [someError show];
            [someError release];
        }
        
        //Do something when some notification types are disabled
    }
    else if ([application enabledRemoteNotificationTypes] != [UAPush shared].notificationTypes)
    {
        UALOG(@"Failed to register a device token with the requested services. Your notifications may be turned off.");
        
        //only alert if this is the first registration, or if push has just been
        //re-enabled
        if ([UAirship shared].deviceToken != nil) { //already been set this session
            
            UIRemoteNotificationType disabledTypes = [application enabledRemoteNotificationTypes] ^ [UAPush shared].notificationTypes;
            
            
            
            NSString* okStr = @"OK";
            NSString* errorMessage = [NSString stringWithFormat:@"Unable to turn on %@. Use the \"Settings\" app to enable these notifications.", [UAPush pushTypeString:disabledTypes]];
            NSString *errorTitle = @"Error";
            UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:okStr
                                                      otherButtonTitles:nil];
            
            [someError show];
            [someError release];
        }
    }
    */
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
//    UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - iRate iVersion -
- (iRateVC *)iRateViewControllerForRating
{
    iRateVC *rateVC = [[iRateVC alloc] initWithNibName:@"iRateVC" bundle:nil];
    return rateVC;
}

- (iVersionVC *)iVersionViewControllerForDisplay
{
    iVersionVC *versionVC = [[iVersionVC alloc] initWithNibName:@"iVersionVC" bundle:nil];
    return versionVC;
}

- (iCrashVC *)iCrashViewControllerForSending
{
    iCrashVC *crashVC = [[iCrashVC alloc] initWithNibName:@"iCrashVC" bundle:nil];
    return crashVC;
}

@end
