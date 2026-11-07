#import <GoogleMobileAds/GoogleMobileAds.h>

// Retain the shared library's existing source API for older clients. The legacy
// SDK keeps its own implementation; current SDKs use a namespaced adapter below.
#if __has_include(<GoogleMobileAds/GADInterstitial.h>)
#define OO_AD_LEGACY_INTERSTITIAL 1
#else
#define OO_AD_LEGACY_INTERSTITIAL 0

@class OOAdLegacyInterstitial;
@protocol GADInterstitialDelegate <NSObject>
@optional
- (void)interstitialDidReceiveAd:(OOAdLegacyInterstitial *)ad;
- (void)interstitial:(OOAdLegacyInterstitial *)ad didFailToReceiveAdWithError:(NSError *)error;
- (void)interstitialWillPresentScreen:(OOAdLegacyInterstitial *)ad;
- (void)interstitialDidDismissScreen:(OOAdLegacyInterstitial *)ad;
- (void)interstitialWillLeaveApplication:(OOAdLegacyInterstitial *)ad;
- (void)interstitialDidRecordImpression:(OOAdLegacyInterstitial *)ad;
- (void)interstitial:(OOAdLegacyInterstitial *)ad didFailToPresentScreenWithError:(NSError *)error;
@end

@interface OOAdLegacyInterstitial : NSObject <GADFullScreenContentDelegate>
@property (nonatomic, copy, readonly) NSString *adUnitID;
@property (nonatomic, weak) id<GADInterstitialDelegate> delegate;
@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic, readonly) BOOL hasBeenUsed;
@property (nonatomic, copy, readonly) NSString *adNetworkClassName;
@property (nonatomic, copy) void (^revenueHandler)(NSDecimalNumber *value, NSString *currency, NSInteger precision, NSString *network);
- (instancetype)initWithAdUnitID:(NSString *)adUnitID;
- (void)loadRequest:(GADRequest *)request;
- (void)presentFromRootViewController:(UIViewController *)controller;
@end

// Compiler aliases only: never define classes in Google's runtime namespace.
@compatibility_alias GADInterstitial OOAdLegacyInterstitial;
@compatibility_alias GADRequestError NSError;
#endif
