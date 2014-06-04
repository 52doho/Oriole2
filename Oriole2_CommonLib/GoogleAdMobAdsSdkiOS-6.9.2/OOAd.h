//
//  OOAd.h
//  AdCatalog
//
//  Created by Gary Wong on 10/15/13.
//
//

#import <Foundation/Foundation.h>
#import "GADAdNetworkExtras.h"
#import "GADRequest.h"
#import "GADInterstitialDelegate.h"
#import "GADInterstitial.h"
#import "GADAdMobExtras.h"
#import "GADCustomEventExtras.h"


@interface OOInterstitial : GADInterstitial
@property (nonatomic, copy) NSString *placement;
@property (nonatomic, assign) NSObject<GADInterstitialDelegate> *delegateBackup;
@property (nonatomic, assign) BOOL needToShowAfterReceiveAd, isMoreGame;
@end

//#define kOOAdPlacementName @"placementName"
//#define kOOAdIsMoreGame @"isMoreGame"

typedef enum
{
    OOInterstitialState_Nothing,
    OOInterstitialState_Present,
    OOInterstitialState_Loading,
    OOInterstitialState_CreateNew
}OOInterstitialState;

@interface OOAd : NSObject
{
    
}

+ (OOAd *)instance;

//+ (GADRequest *)adRequestWithAdditionalParameters:(NSDictionary *)dic;
+ (GADRequest *)adRequestWithPlacement:(NSString *)placement isMoreGame:(BOOL)isMoreGame;
+ (GADRequest *)adRequestWithPlacement:(NSString *)placement;
+ (GADRequest *)adRequestWithDefaultPlacement;

//- (void)appOpenNotifyForPlayhavenWithToken:(NSString *)token secret:(NSString *)secret;

- (OOInterstitialState)showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement delegate:(id<GADInterstitialDelegate>)delegate;
- (OOInterstitialState)showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement;
- (void)cacheInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement;

- (OOInterstitialState)showInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID delegate:(id<GADInterstitialDelegate>)delegate;
- (OOInterstitialState)showInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID;
- (void)cacheInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID;

- (OOInterstitialState)showInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID delegate:(id<GADInterstitialDelegate>)delegate;
- (OOInterstitialState)showInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID;
- (void)cacheInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID;

@end


@interface OOAdBase : NSObject
{
    
}
//- (UIViewController *)getRootViewController;
- (NSDictionary *)convertToDic:(NSString *)serverParameter;
- (NSString *)getPlacementIdInDic:(NSDictionary *)dic placementName:(NSString *)placementName;

@end

@interface OOAdBanner_Oriole2 : OOAdBase
{
    
}
@end
/*
@interface OOAdBanner_RevMob : OOAdBase
{
    
}
@end

@interface OOAdInterstitial_RevMob : OOAdBase
{
    
}
@end


@interface OOAdInterstitial_Playhaven : OOAdBase
{
    //区分 more game 和 普通全屏广告
}
@end*/


@interface OOAdInterstitial_Chartboost : OOAdBase
{
    //区分 more game 和 普通全屏广告
}
@end

/*
@interface OOAdBanner_DoMob : OOAdBase
{
    
}
@end

@interface OOAdInterstitial_DoMob : OOAdBase
{
    
}
@end


@interface OOAdBanner_PunchBox : OOAdBase
{
    
}
@end

@interface OOAdInterstitial_PunchBox : OOAdBase
{
    //区分 more game 和 普通全屏广告
}
@end*/

