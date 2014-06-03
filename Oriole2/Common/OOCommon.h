//
//  OOCommon.h
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


// Safe releases
#define OO_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define OO_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
// Release a CoreFoundation object safely.
#define OO_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

#define kIsPadUI (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kIsiPad (kIsPadUI)
#define kIsPhoneUI (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kIsiPhone ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])
#define kIsiPhone_5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define kIsiPod ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])
#define kIsRetina ([[UIScreen mainScreen] scale] == 2)
#define kIsiOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

#define kUniversalImage(image) ([UIImage imageNamed:[NSString stringWithFormat:@"%@%@.%@", [image stringByDeletingPathExtension], (kIsiPad ? @"~ipad" : @"~iphone"), [image pathExtension]]])
#define iPhone568ImageNamed(image) (kIsiPhone_5 ? [NSString stringWithFormat:@"%@-568h.%@", [image stringByDeletingPathExtension], [image pathExtension]] : image)
#define iPhone568Image(image) ([UIImage imageNamed:iPhone568ImageNamed(image)])

#define kKeyboardHeight(landscape) (kIsiPad ? (landscape ? 352 : 264) : (landscape ? 162 : 216))
#define kIsUILandscape UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
#define kIsStatusBarHidden [[UIApplication sharedApplication] isStatusBarHidden]

#define INVALID_INDEX -9999
#define kDefaultAnimateDuration .3

#define kOriole2_AppStoreUrl @"itms-apps://itunes.apple.com/us/artist/oriole2-co.-ltd./id506665225?mt=8"

#if !defined(EXCHANGE)
#define EXCHANGE(A,B)	({ __typeof__(A) __tmp = (A); A = B; B = __tmp; })
#endif

//tab bar
#define kTabbarItemImageSelected @"TabbarItemImageSelected"
#define kTabbarItemImageUnSelected @"TabbarItemImageUnSelected"
#define kTabbarItemControllerClass @"TabbarItemControllerClass"
#define kTabbarItemIsUsedNavigationController @"TabbarItemIsUsedNavigationController"

//Debug logs
#ifdef DEBUG  
#define OOLog(log, ...) NSLog(log, ## __VA_ARGS__)  
#define OOLogError(log, ...) NSLog( @"\n-------ERROR------- <%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(log), ##__VA_ARGS__] )
#define OOLogWithFileLine(log, ...) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(log), ##__VA_ARGS__] )
#define OOLogWithClassMethod(log, ...) NSLog(@"<%@ %@> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [NSString stringWithFormat:(log), ##__VA_ARGS__])
#define OOLogWithInterval(log, ...) NSLog(@"<interval:%f> %@", [[NSDate date] timeIntervalSinceReferenceDate], [NSString stringWithFormat:(log), ##__VA_ARGS__])
#else  
#define OOLog(log, ...)
#define OOLogError(log, ...)
#define OOLogWithFileLine(log, ...)
#define OOLogWithClassMethod()
#define OOLogWithInterval(log, ...)
#endif  

// Block
#if NS_BLOCKS_AVAILABLE
typedef void (^OOBlockBasic)(void);
typedef void (^OOBlockData)(NSData *data);
typedef void (^OOBlockNumber)(NSNumber *number);
typedef void (^OOBlockError)(NSError *error);
typedef void (^OOBlockImage)(UIImage *image);
typedef void (^OOBlockDictionary)(NSDictionary *dic);
typedef void (^OOBlockArray)(NSArray *ary);
#endif

/**
 Returns a random float between from and to, from <= random < to
 */
#define OORANDOM(from, to) ((arc4random() % RAND_MAX) / (RAND_MAX * 1.0) * (to - from) + from)
#define OORANDOM_MINUS1_1() (OORANDOM(-1, 1))
#define OORANDOM_0_1() (OORANDOM(0, 1))

#define OOLocalizedString(str) NSLocalizedString(str, str)
#define OOLocalizedStringInOOBundle(str) NSLocalizedStringFromTableInBundle(str, @"Localizable", [OOCommon getOOBundle], nil)

//day changed
#define kDateChangedNotification @"DateChangedNotification"
#define kDateChangedWithDaySpan @"DateChangedWithDaySpan"
#define kDateChangedWithWeekSpan @"DateChangedWithWeekSpan"
#define kDateChangedWithMonthSpan @"DateChangedWithMonthSpan"
#define kDateChangedWithYearSpan @"DateChangedWithYearSpan"

#define kDateChangedFromDate @"DateChangedFromDate"
#define kDateChangedToDate @"DateChangedToDate"

//splash screen notifications
#define kWillShowMainVCNotification @"WillShowMainVCNotification"
#define kDidShowMainVCNotification @"DidShowMainVCNotification"

//UIKit
#define UIViewAutoresizingFlexibleAll (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin)

// NSUserDefaults
#define DEFAULTS [NSUserDefaults standardUserDefaults]

// More apps
#define kMoreAppsDidUpdateNotification @"kMoreAppsDidUpdateNotification"

// SNS
// Oriole
#define kSNSTwitterID_Oriole2 @"514404683"
#define kSNSTwitterName_Oriole2 @"Oriole_2"
#define kSNSFacebookID_Oriole2 @"100002661420968"
#define kSNSFacebookName_Oriole2 @"Oriole2"
// CamCool & CamCool HD
#define kSNSTwitterID_CamCool @"631647131"
#define kSNSTwitterName_CamCool @"CamCoolApp"
#define kSNSFacebookID_CamCool @"496784377013644"
#define kSNSFacebookName_CamCool @"CamCoolApp"
// PhotoCool
#define kSNSTwitterID_PhotoCool @"636043086"
#define kSNSTwitterName_PhotoCool @"PhotoCoolApp"
#define kSNSFacebookID_PhotoCool @"321554981268896"
#define kSNSFacebookName_PhotoCool @"PhotoCoolApp"
// Brace Booth
#define kSNSTwitterID_BraceBooth @"714270373"
#define kSNSTwitterName_BraceBooth @"BraceBoothApp"
#define kSNSFacebookID_BraceBooth @"259868917459226"
#define kSNSFacebookName_BraceBooth @"BraceBoothApp"
// BoothCool
#define kSNSTwitterID_BoothCool @"761162335"
#define kSNSTwitterName_BoothCool @"BoothCoolApp"
#define kSNSFacebookID_BoothCool @"337409763014434"
#define kSNSFacebookName_BoothCool @"BoothCoolApp"
// EmojiCool
#define kSNSTwitterID_EmojiCool @"751497572"
#define kSNSTwitterName_EmojiCool @"EmojiCoolApp"
#define kSNSFacebookID_EmojiCool @"286382031469542"
#define kSNSFacebookName_EmojiCool @"EmojiCoolApp"
// WuShaMao
#define kSNSTwitterID_WuShaMao @"775146570"
#define kSNSTwitterName_WuShaMao @"WuShaMao"
#define kSNSFacebookID_WuShaMao @"456347697730881"
#define kSNSFacebookName_WuShaMao @"WuShaMao"
// Freezic
#define kSNSTwitterID_Freezic @"899546546"
#define kSNSTwitterName_Freezic @"Freezic"
#define kSNSFacebookID_Freezic @"483574658343118"
#define kSNSFacebookName_Freezic @"Freezic"


////Chartboost
//#define kChartboostDidCacheMoreAppsNotification @"kChartboostDidCacheMoreAppsNotification"

#import <StoreKit/StoreKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class MBProgressHUD;
@interface OOCommon : NSObject
{
	
}

+ (NSString *)getCurrentLanguage;
+ (NSString *)hashString:(NSString *)str;
+ (NSString *)getLocalizedAppName;
+ (NSString *)getFeedbackHeader;
+ (NSString *)getFeedbackDeviceInfo;
+ (NSString *)getFeedbackDeviceInfoWithNewLine:(BOOL)newLine;
+ (NSString *)getAppVersion;
+ (NSBundle *)getOOBundle;
+ (UIImage *)getScreenShot;
+ (UIWindow *)getOriginalWindow;
+ (UIViewController *)getRootViewController;
+ (UIViewController *)getTopmostViewController;

+ (void)dialPhone:(NSString *)phoneNumber;
+ (void)exchangeUint:(uint *)v1 with:(uint *)v2;
+ (void)exchangeObject:(NSObject **)obj1 with:(NSObject **)obj2;

+ (BOOL)isLocalizedMetric;
+ (void)hightlightView:(UIView *)view;
+ (void)fadeInForView:(UIView *)view;
+ (void)fadeOutForView:(UIView *)view;
+ (NSString *)getFrequencyTextByUnit:(NSUInteger)calendarUnit;
+ (NSUInteger)getCalendarUnitByFrequencyText:(NSString *)text;

// Use [[iRate sharedInstance] openRatingsPageInAppStore] instead.
//+ (void)openRatingsPageInAppStoreWithID:(int)appID;
+ (void)openInAppStoreWithID:(int)appID viewController:(UIViewController *)viewController;
+ (MBProgressHUD *)openInAppStoreWithID:(int)appID viewController:(UIViewController *)viewController showHudInView:(UIView *)view;

//security
//+ (NSString *)TripleDES:(NSString*)plainText isDecrypt:(BOOL)isDecrypt key:(NSString*)key;

//Memory
+ (void)logMemory;

//Jailbrake
+ (BOOL)isJailbroken;

// write image to the album of app. if the album doesn't exist, then creat one.
+ (void)writeImageToSavedPhotosAlbum:(UIImage *)image metadata:(NSDictionary *)metadata completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock;

@end
