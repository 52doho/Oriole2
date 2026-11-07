//
//  OOAd.h
//  AdCatalog
//
//  Created by Gary Wong on 10/15/13.
//
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "OOAdSDKCompatibility.h"
#import "OOCommon.h"

@interface OOInterstitial : GADInterstitial
@property (nonatomic, copy) NSString                             *placement;
@property (nonatomic, weak) NSObject <GADInterstitialDelegate> *delegateBackup;
@property (nonatomic, assign) BOOL needToShowAfterReceiveAd, isMoreGame;
@property (nonatomic, assign) NSTimeInterval loadedUptime;
@end

typedef enum {
    OOInterstitialState_Nothing,
    OOInterstitialState_Present,
    OOInterstitialState_Loading,
    OOInterstitialState_CreateNew
} OOInterstitialState;

typedef void (^ OOBlockGADRequest)(GADRequest *request);

@interface OOAd : NSObject {
}
@property (nonatomic, strong, readonly) NSDictionary *config;
@property (nonatomic, strong) OOBlockGADRequest didCreateGADRequest;
@property (nonatomic, copy) void (^didCreateGADRequestForPlacement)(GADRequest *request, NSString *placement);
// Optional hooks: existing client apps retain their behavior unless they opt in.
@property (nonatomic, copy) BOOL (^requestValidator)(NSString *adUnitID, NSString *placement);
@property (nonatomic, copy) BOOL (^presentationValidator)(NSString *adUnitID, NSString *placement);
@property (nonatomic, copy) void (^eventHandler)(NSString *event, NSString *adUnitID, NSString *placement, NSError *error);
// Optional diagnostics for modern SDK clients. No change to legacy SDK behavior.
@property (nonatomic, copy) void (^revenueHandler)(NSString *adUnitID, NSString *placement, NSDecimalNumber *value, NSString *currency, NSInteger precision, NSString *network);
@property (nonatomic, assign) BOOL allowsDeferredPresentation;
- (BOOL)isInterstitialReadyWithMediationID:(NSString *)mediationID placement:(NSString *)placement;
- (void)discardCachedInterstitials;

+ (OOAd *)instance;

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
- (void)cacheInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID delegate:(id <GADInterstitialDelegate> )delegate;

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
