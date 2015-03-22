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
#import "OOCommon.h"
#import "MBProgressHUD.h"

#import <mach/task.h>
#import <mach/mach.h>
#import <sys/sysctl.h>
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

@implementation OOCommon

#define kHightlightDuration 0.15
#define kFadeDuration       0.15
static NSBundle * wlBundle;

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

+ (void)openInAppStoreWithID:(int)appID viewController:(UIViewController *)viewController
{
    [self openInAppStoreWithID:appID viewController:viewController showHudInView:viewController.view];
}

+ (MBProgressHUD *)openInAppStoreWithID:(int)appID viewController:(UIViewController *)viewController showHudInView:(UIView *)view
{
    MBProgressHUD *hud = nil;

    if (NSClassFromString(@"SKStoreProductViewController") && viewController) {
        OOBridgeObject *bridge = [[OOBridgeObject alloc] init];
        //        bridge.viewController = viewController;

        NSDictionary                 *productParameters = @{SKStoreProductParameterITunesItemIdentifier : [NSNumber numberWithInt:appID]};
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

    return hud;
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

@end
