//
//  OOCommon.m
//  Oriole2
//
//  Created by Gary Wong on 8/9/11.
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

#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonCryptor.h>
#import <AdSupport/AdSupport.h>
#import "OOCommon.h"
#import "DeviceUID.h"
#import "MBProgressHUD.h"
#import "NSString+TKCategory.h"
#import "iVersion.h"

#import <mach/task.h>
#import <mach/mach.h>
#import <sys/utsname.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <execinfo.h>

@interface OOBridgeObject : NSObject <SKStoreProductViewControllerDelegate>
{
    __strong OOBridgeObject *self_strong;
}
// @property(nonatomic, assign) UIViewController *viewController;
- (void)increaseRetainCount;
@end

@implementation OOBridgeObject
- (void)dealloc
{
    //    NSLog(@"OOBridgeObject dealloc");
}

- (void)increaseRetainCount
{
    if (!self_strong) {
        self_strong = self;
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)productVC
{
    productVC.delegate = nil;
    [productVC dismissViewControllerAnimated:YES completion:^{
        //        NSLog(@"OOBridgeObject productViewControllerDidFinish");
        self_strong = nil;
    }];
}

@end



@interface OOCommon()<iVersionDelegate> {
    OOBlockBool _iVersionStateChangedCallback;
}

@end

@implementation OOCommon

#define kHightlightDuration 0.15
#define kFadeDuration       0.15
static NSBundle * wlBundle;

+ (OOCommon *)instance{
    static OOCommon *sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [(OOCommon *)[self alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [iVersion sharedInstance].delegate = self;
    }
    
    return self;
}

+ (NSString *)idfa {
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    }
    else{
        
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        }
        else{
            
            //for no arc
            //ASIdentifierManager *asIM = [[[asIdentifierMClass alloc] init] autorelease];
            //for arc
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            }
            else{
                
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                }
                else{
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

+ (NSString *)idfa_md5 {
    return [[[OOCommon idfa] md5sum] uppercaseString];
}

+ (NSString *)deviceId {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *)deviceName {
    return [UIDevice currentDevice].name;
}

+ (NSString *)deviceLocale {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return language;
}

+ (NSString *)deviceCountry {
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return country;
}

+ (NSString *)deviceModel {
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"x86_64"    :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",      // (Original)
                              @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                              @"iPod5,1"   :@"iPod Touch",      // (Fifth Generation)
                              @"iPod7,1"   :@"iPod Touch",      // (Sixth Generation)
                              @"iPhone1,1" :@"iPhone",          // (Original)
                              @"iPhone1,2" :@"iPhone 3G",       // (3G)
                              @"iPhone2,1" :@"iPhone 3GS",      // (3GS)
                              @"iPad1,1"   :@"iPad",            // (Original)
                              @"iPad2,1"   :@"iPad 2",          //
                              @"iPad2,2"   :@"iPad 2",          //
                              @"iPad2,3"   :@"iPad 2",          //
                              @"iPad2,4"   :@"iPad 2",          //
                              @"iPad3,1"   :@"iPad",            // (3rd Generation)
                              @"iPad3,2"   :@"iPad",            // (3rd Generation)
                              @"iPad3,3"   :@"iPad",            // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",        // (GSM)
                              @"iPhone3,2" :@"iPhone 4",        // iPhone 4
                              @"iPhone3,3" :@"iPhone 4",        // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",       //
                              @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",            // (4th Generation)
                              @"iPad3,5"   :@"iPad",            // (4th Generation)
                              @"iPad3,6"   :@"iPad",            // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",       // (Original)
                              @"iPad2,6"   :@"iPad Mini",       // (Original)
                              @"iPad2,7"   :@"iPad Mini",       // (Original)
                              @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",   //
                              @"iPhone7,2" :@"iPhone 6",        //
                              @"iPhone8,1" :@"iPhone 6s",       //
                              @"iPhone8,2" :@"iPhone 6s Plus",  //
                              @"iPhone8,4" :@"iPhone SE",       //
                              @"iPhone9,1" :@"iPhone 7",        // (model A1660 | CDMA)
                              @"iPhone9,3" :@"iPhone 7",        // (model A1778 | Global)
                              @"iPhone9,2" :@"iPhone 7 Plus",   // (model A1661 | CDMA)
                              @"iPhone9,4" :@"iPhone 7 Plus",   // (model A1784 | Global)
                              @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,3"   :@"iPad Air",        // 5th Generation iPad (iPad Air)
                              @"iPad4,4"   :@"iPad Mini 2",     // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini 2",     // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,6"   :@"iPad Mini 2",     // (2nd Generation iPad Mini)
                              @"iPad4,7"   :@"iPad Mini 3",     // (3rd Generation iPad Mini)
                              @"iPad4,8"   :@"iPad Mini 3",     // (3rd Generation iPad Mini)
                              @"iPad4,9"   :@"iPad Mini 3",     // (3rd Generation iPad Mini)
                              @"iPad5,1"   :@"iPad Mini 4",     // (4th Generation iPad Mini)
                              @"iPad5,2"   :@"iPad Mini 4",     // (4th Generation iPad Mini)
                              @"iPad5,3"   :@"iPad Air 2",      // 6th Generation iPad (iPad Air 2)
                              @"iPad5,4"   :@"iPad Air 2",      // 6th Generation iPad (iPad Air 2)
                              @"iPad6,3"   :@"iPad Pro 9.7-inch",// iPad Pro 9.7-inch
                              @"iPad6,4"   :@"iPad Pro 9.7-inch",// iPad Pro 9.7-inch
                              @"iPad6,7"   :@"iPad Pro 12.9-inch",// iPad Pro 12.9-inch
                              @"iPad6,8"   :@"iPad Pro 12.9-inch",// iPad Pro 12.9-inch
                              @"AppleTV2,1":@"Apple TV",        // Apple TV (2nd Generation)
                              @"AppleTV3,1":@"Apple TV",        // Apple TV (3rd Generation)
                              @"AppleTV3,2":@"Apple TV",        // Apple TV (3rd Generation - Rev A)
                              @"AppleTV5,3":@"Apple TV",        // Apple TV (4th Generation)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:self.deviceId];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([self.deviceId rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([self.deviceId rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([self.deviceId rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
    }
    
    return deviceName;
}

+ (NSString *)deviceBrand {
    return @"Apple";
}

+ (NSString *)systemManufacturer {
    return @"Apple";
}

+ (NSString *)timezone {
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    return currentTimeZone.name;
}

+ (NSString *)macAddress {
    
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macString;
}

+ (NSString *)systemName {
    return [UIDevice currentDevice].systemName;
}

+ (NSString *)systemVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)uniqueId {
    return [DeviceUID uid];
}

+ (NSString *)bundleId {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)buildNumber {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)userAgent {
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    return [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}

+ (NSString *)getCurrentLanguage
{
    NSArray *ary = [NSLocale preferredLanguages];

    if (ary.count > 0) {
        return [ary objectAtIndex:0];
    }

    return nil;
}

+ (NSString *)getLocalizedAppName
{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

    if ([appName length] == 0) {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    }

    return appName;
}

+ (NSString *)getAppVersion
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    return appVersion;
}

+ (NSBundle *)getOOBundle
{
    if (wlBundle) {
        return wlBundle;
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Oriole2" ofType:@"bundle"];
    wlBundle = [NSBundle bundleWithPath:path];
    return wlBundle;
}

+ (NSString *)getFeedbackHeader
{
    NSString *header = [NSString stringWithFormat:@"%@ %@", [self getLocalizedAppName], OOLocalizedStringInOOBundle(@"Feedback")];

    return header;
}

+ (NSString *)getFeedbackDeviceInfo
{
    NSString *info = [NSString stringWithFormat:@"%@:\t%@<br>%@:\t%@<br>%@:\t%@<br>%@:\t%@ %@", OOLocalizedStringInOOBundle(@"AppName"), [self getLocalizedAppName], OOLocalizedStringInOOBundle(@"AppVersion"), [OOCommon getAppVersion], OOLocalizedStringInOOBundle(@"Model"), [UIDevice currentDevice].model, OOLocalizedStringInOOBundle(@"System"), [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];

    return info;
}

+ (NSString *)getFeedbackDeviceInfoWithNewLine:(BOOL)newLine
{
    if (newLine) {
        return [NSString stringWithFormat:@"<br><br><br><br>%@", [OOCommon getFeedbackDeviceInfo]];
    } else {
        return [OOCommon getFeedbackDeviceInfo];
    }
}

+ (NSString *)hashString:(NSString *)str
{
    int length = str.length;
    // chaos params
    CGFloat alpha = 3.864088472;

    int sum = 0;

    for (int i = 0; i < length; i++) {
        unichar c = [str characterAtIndex:i];
        sum += (int)c;
    }

    CGFloat x0 = (CGFloat)sum / length / 256;

    NSMutableString *udidHashed = [NSMutableString string];
    [udidHashed appendFormat:@"%c", (int)(x0 * 256)];

    for (int i = 1; i < length; i++) {
        x0 = alpha * x0 * (1 - x0);
        [udidHashed appendFormat:@"%c", (int)(x0 * 256)];
    }

    return udidHashed;
}

+ (UIImage *)getScreenShot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;

    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    } else {
        UIGraphicsBeginImageContext(imageSize);
    }

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || ([window screen] == [UIScreen mainScreen])) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                -[window bounds].size.width * [[window layer] anchorPoint].x,
                -[window bounds].size.height * [[window layer] anchorPoint].y);

            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];

            // Restore the context
            CGContextRestoreGState(context);
        }
    }

    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

+ (UIWindow *)getOriginalWindow
{
    CGRect bounds = [[UIScreen mainScreen] bounds];

    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        CGRect boundsWin = window.bounds;

        if (CGRectEqualToRect(bounds, boundsWin)) {
            return window;
        }
    }

    return nil;
}

+ (UIViewController *)getRootViewController
{
    UIViewController *rootViewController = nil;
    id               appDelegate = [[UIApplication sharedApplication] delegate];

    if ([appDelegate respondsToSelector:@selector(viewController)]) {
        rootViewController = [appDelegate valueForKey:@"viewController"];
    }

    if (!rootViewController) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        rootViewController = window.rootViewController;
    }

    return rootViewController;
}

+ (UIViewController *)getTopmostViewController
{
    UIViewController *rootViewController = [self getRootViewController];

    while (rootViewController.presentedViewController)
        rootViewController = rootViewController.presentedViewController;

    return rootViewController;
}

+ (void)_presentViewController:(UIViewController *)viewControllerToPresent fromViewController:(UIViewController *)fromViewController animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (!viewControllerToPresent || !fromViewController) {
        return;
    }

    if ([fromViewController isBeingPresented]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self _presentViewController:viewControllerToPresent fromViewController:fromViewController animated:flag completion:completion];
            });
    } else {
        [fromViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

+ (void)presentOnTopmostVCWithVC:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    [self _presentViewController:viewControllerToPresent fromViewController:[self getTopmostViewController] animated:flag completion:completion];
}

+ (void)dialPhone:(NSString *)phoneNumber
{
    if (phoneNumber.length > 0) {
        NSString *temp = [@"tel://" stringByAppendingString : phoneNumber];
        NSString *urlString = [temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL    *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)exchangeUint:(uint *)v1 with:(uint *)v2
{
    uint tmp = *v1;

    *v1 = *v2;
    *v2 = tmp;
}

+ (void)exchangeObject:(NSObject **)obj1 with:(NSObject **)obj2
{
    NSObject *tmp = *obj1;

    *obj1 = *obj2;
    *obj2 = tmp;
}

+ (BOOL)isLocalizedMetric
{
    // England, US., Canada, India, Australia
    BOOL     isMetric = YES;
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];

    if ([localeIdentifier isEqualToString:@"en_GB"] || [localeIdentifier isEqualToString:@"en_US"] ||
        [localeIdentifier isEqualToString:@"en_CA"] || [localeIdentifier isEqualToString:@"en_IN"] || [localeIdentifier isEqualToString:@"en_AU"]) {
        isMetric = NO;
    }

    return isMetric;
}

+ (void)_hightlightViewShow2:(UIView *)view
{
    [UIView animateWithDuration:kHightlightDuration animations:^(void) {
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

+ (void)_hightlightViewHide1:(UIView *)view
{
    [UIView animateWithDuration:kHightlightDuration animations:^(void) {
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [OOCommon _hightlightViewShow2:view];
    }];
}

+ (void)_hightlightViewShow1:(UIView *)view
{
    [UIView animateWithDuration:kHightlightDuration animations:^(void) {
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [OOCommon _hightlightViewHide1:view];
    }];
}

+ (void)hightlightView:(UIView *)view
{
    [UIView animateWithDuration:kHightlightDuration animations:^(void) {
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [OOCommon _hightlightViewShow1:view];
    }];
}

+ (void)fadeInForView:(UIView *)view
{
    view.alpha = 0.0;
    [UIView animateWithDuration:kFadeDuration animations:^(void) {
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

+ (void)fadeOutForView:(UIView *)view
{
    view.alpha = 1.0;
    [UIView animateWithDuration:kFadeDuration animations:^(void) {
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
}

+ (NSString *)getFrequencyTextByUnit:(NSUInteger)calendarUnit
{
    switch (calendarUnit) {
    default:
    case 0:
        {
            return OOLocalizedString(@"NoRepeat");

            break;
        }

    case NSHourCalendarUnit:
        {
            return OOLocalizedString(@"Hourly");

            break;
        }

    case NSDayCalendarUnit:
        {
            return OOLocalizedString(@"Daily");

            break;
        }

    case NSWeekCalendarUnit:
        {
            return OOLocalizedString(@"Weekly");

            break;
        }

    case NSMonthCalendarUnit:
        {
            return OOLocalizedString(@"Monthly");

            break;
        }
    }
}

+ (NSUInteger)getCalendarUnitByFrequencyText:(NSString *)text
{
    if ([text isEqualToString:OOLocalizedString(@"NoRepeat")]) {
        return 0;
    } else if ([text isEqualToString:OOLocalizedString(@"Hourly")]) {
        return NSHourCalendarUnit;
    } else if ([text isEqualToString:OOLocalizedString(@"Daily")]) {
        return NSDayCalendarUnit;
    } else if ([text isEqualToString:OOLocalizedString(@"Weekly")]) {
        return NSWeekCalendarUnit;
    } else if ([text isEqualToString:OOLocalizedString(@"Monthly")]) {
        return NSMonthCalendarUnit;
    } else {
        return 0;
    }
}

+ (void)openInAppStoreWithID:(NSUInteger)appID viewController:(UIViewController *)viewController
{
    [self openInAppStoreWithID:appID viewController:viewController showHudInView:nil];
}

+ (MBProgressHUD *)openInAppStoreWithID:(NSUInteger)appID viewController:(UIViewController *)viewController showHudInView:(UIView *)view
{
    MBProgressHUD *hud = nil;

    if (NSClassFromString(@"SKStoreProductViewController") && viewController) {
        OOBridgeObject *bridge = [[OOBridgeObject alloc] init];
        //        bridge.viewController = viewController;

        NSDictionary                 *productParameters = @{SKStoreProductParameterITunesItemIdentifier :@(appID)};
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = bridge;

        if (view) {
            // show waiting
            hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
            hud.minShowTime = 1;
            hud.labelText = OOLocalizedStringInOOBundle(@"Waiting");
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.removeFromSuperViewOnHide = YES;
            hud.userInteractionEnabled = NO;

            [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
                if (result) {
                    [hud hide:YES];
                    [self presentOnTopmostVCWithVC:storeController animated:YES completion:NULL];

                    [bridge increaseRetainCount];
                } else {
                    hud.labelText = [error localizedDescription];
                    [hud hide:YES afterDelay:1.];
                    OOLog(@"There was a problem displaying app store view");
                }
            }];
        } else {
            [storeController loadProductWithParameters:productParameters completionBlock:nil];
            [self presentOnTopmostVCWithVC:storeController animated:YES completion:NULL];

            [bridge increaseRetainCount];
        }
    } else {
        // Before iOS 6, we can only open the URL
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/app/id%i?mt=8", appID]];
        [[UIApplication sharedApplication] openURL:url];
    }
    return nil;
//    return hud;
}

// Memory
BOOL ProcessGetMemUsageForTask(task_t task, unsigned int *resident, unsigned int *_virtual)
{
    task_basic_info_data_t t_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;

    if (task_info(task, TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count) == KERN_SUCCESS) {
        *resident = t_info.resident_size;
        *_virtual = t_info.virtual_size;
        return YES;
    }

    return NO;
}

BOOL ProcessGetMemUsage(unsigned int *resident, unsigned int *_virtual)
{
    return ProcessGetMemUsageForTask(mach_task_self(), resident, _virtual);
}

+ (void)logMemory
{
#ifdef DEBUG
        unsigned int resident, _virtual;

        if (ProcessGetMemUsage(&resident, &_virtual)) {
            OOLog(@"Resident: %fmb, Virtual: %fmb", (CGFloat)resident / 1024.0 / 1024.0,
                (CGFloat)_virtual / 1024.0 / 1024.0);
        } else {
            OOLog(@"Couldn't get task info");
        }
#endif
}

+ (BOOL)isJailbroken
{
    BOOL     jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";

    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }

    return jailbroken;
}

typedef void (^ OOBlockAssetsGroup)(ALAssetsGroup *group);
+ (ALAssetsLibrary *)_findAssetsGroupCompleteBlock:(OOBlockAssetsGroup)completeBlock
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if ([[assetsGroup valueForProperty:ALAssetsGroupPropertyName] isEqualToString:[OOCommon getLocalizedAppName]]) {
            OOLog(@"found album %@", [OOCommon getLocalizedAppName]);
            completeBlock(assetsGroup);
            *stop = YES;
        } else if ((assetsGroup == nil) && (*stop == NO)) {
            [library addAssetsGroupAlbumWithName:[OOCommon getLocalizedAppName]
                                     resultBlock:^(ALAssetsGroup *assetsGroup) {
                completeBlock(assetsGroup);
            }

                                    failureBlock:^(NSError *error) {
                OOLog(@"error adding album");
                completeBlock(nil);
            }];
            *stop = YES;
        }
    }

                         failureBlock:^(NSError *error) {
        OOLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
        [library addAssetsGroupAlbumWithName:[OOCommon getLocalizedAppName]
                                 resultBlock:^(ALAssetsGroup *assetsGroup) {
            completeBlock(assetsGroup);
        }

                                failureBlock:^(NSError *error) {
            OOLog(@"error adding album");
            completeBlock(nil);
        }];
    }];
    return library;
}

+ (void)writeImageToSavedPhotosAlbum:(UIImage *)image metadata:(NSDictionary *)metadata completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
{
    __block ALAssetsLibrary *library = nil;

    library = [self _findAssetsGroupCompleteBlock:^(ALAssetsGroup *assetsGroup) {
            [library writeImageToSavedPhotosAlbum:image.CGImage
                                         metadata:metadata
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error.code == 0) {
                    if (assetsGroup) {
                        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                            // assign the photo to the album
                            [assetsGroup addAsset:asset];
                        } failureBlock:^(NSError *error) {
                            OOLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                        }];
                    }
                }

                if (completionBlock) {
                    completionBlock(assetURL, error);
                }
            }];
        }];
}


+ (NSURL *)buildQueryUrl:(NSString *)url params:(NSDictionary *)params {
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in [params allKeys]) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:params[key]]];
    }
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    components.queryItems = queryItems;
    return components.URL;
}

+ (void)logAppOpenWithAppName:(NSString *)appName {
    if (appName.length > 0) {
        NSDictionary *params = @{
                                 @"app_name":appName,
                                 @"device_id":[OOCommon deviceId],
                                 @"ios_idfa":[OOCommon idfa],
                                 @"ios_idfa_md5":[OOCommon idfa_md5],
                                 @"device_model":[OOCommon deviceModel],
                                 @"device_brand":[OOCommon deviceBrand],
                                 @"device_name":[OOCommon deviceName],
                                 @"country":[OOCommon deviceCountry],
                                 @"locale":[OOCommon deviceLocale],
                                 @"system_version":[OOCommon systemVersion],
                                 @"system_name":[OOCommon systemName],
                                 @"app_version":[OOCommon appVersion],
                                 @"timezone":[OOCommon timezone],
                                 };
        NSURL *url = [OOCommon buildQueryUrl:@"https://www.taobangzhu.net/mobileapi/ad/oriole2AppOpenLog" params:params];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            OOLog(@"logAppOpen 记录结果：%@", connectionError);
        }];
    }
}

- (void)iVersionStateChanged:(OOBlockBool)callback {
    _iVersionStateChangedCallback = callback;
    
    NSString *lastNewVersion = [self _iVersionLastNewVersion];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    BOOL hasNew = lastNewVersion.length > 0 && [lastNewVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending;
    ZPInvokeBlock(_iVersionStateChangedCallback, hasNew);
}

#define kiVersionLastNewVersion @"OOLastNewVersion"
- (NSString *)_iVersionLastNewVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kiVersionLastNewVersion];
}

- (void)_setiVersionLastNewVersion:(NSString *)version
{
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:kiVersionLastNewVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -iVersionDelegate
- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails {
    [self _setiVersionLastNewVersion:version];
    ZPInvokeBlock(_iVersionStateChangedCallback, YES);
}

@end

