//
//  OOAd.h
//  AdCatalog
//
//  Created by Gary Wong on 10/15/13.
//
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "OOCommon.h"

@interface OOInterstitial : GADInterstitial
@property (nonatomic, copy) NSString                             *placement;
@property (nonatomic, assign) NSObject <GADInterstitialDelegate> *delegateBackup;
@property (nonatomic, assign) BOOL needToShowAfterReceiveAd, isMoreGame;
@end

typedef enum {
    OOInterstitialState_Nothing,
    OOInterstitialState_Present,
    OOInterstitialState_Loading,
    OOInterstitialState_CreateNew
} OOInterstitialState;

@interface OOAd : NSObject {
}
@property (nonatomic, strong, readonly) NSDictionary *config;
@property (nonatomic, assign) BOOL interstitial_aba_enabled;

+ (OOAd *)instance;
+ (NSURL *)buildQueryUrl:(NSString *)url params:(NSDictionary *)params;
- (void)downloadConfigWithAppName:(NSString *)appname;

+ (GADRequest *)adRequestWithPlacement:(NSString *)placement isMoreGame:(BOOL)isMoreGame;
+ (GADRequest *)adRequestWithPlacement:(NSString *)placement;
+ (GADRequest *)adRequestWithDefaultPlacement;

- (OOInterstitialState)showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement delegate:(id <GADInterstitialDelegate> )delegate;
- (OOInterstitialState)showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement;
- (void)cacheInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement;

- (OOInterstitialState)showInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID delegate:(id <GADInterstitialDelegate> )delegate;
- (OOInterstitialState)showInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID;
- (void)cacheInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID;

- (OOInterstitialState)showInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID delegate:(id <GADInterstitialDelegate> )delegate;
- (OOInterstitialState)showInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID;
- (void)cacheInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID;

@end

@interface OOAdBase : NSObject {
}
- (NSDictionary *)convertToDic:(NSString *)serverParameter;
- (NSString *)getPlacementIdInDic:(NSDictionary *)dic placementName:(NSString *)placementName;

@end

@interface OOAdBanner_Oriole2 : OOAdBase {
}
@end
/*
@interface OOAdInterstitial_Chartboost : OOAdBase {
}
@end
*/
