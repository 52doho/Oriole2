#import "OOAdSDKCompatibility.h"

#if !OO_AD_LEGACY_INTERSTITIAL
@implementation OOAdLegacyInterstitial {
    GADInterstitialAd *_ad;
    BOOL _loading;
    BOOL _used;
}

- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
    self = [super init];
    if (self) _adUnitID = [adUnitID copy];
    return self;
}
- (BOOL)isReady { return _ad != nil && !_used; }
- (BOOL)hasBeenUsed { return _used; }
- (NSString *)adNetworkClassName {
    return _ad.responseInfo.loadedAdNetworkResponseInfo.adNetworkClassName;
}
- (void)loadRequest:(GADRequest *)request {
    if (_loading || _ad || _used) return;
    _loading = YES;
    __weak typeof(self) weakSelf = self;
    [GADInterstitialAd loadWithAdUnitID:self.adUnitID request:request completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        OOAdLegacyInterstitial *strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf->_loading = NO;
        strongSelf->_ad = ad;
        ad.fullScreenContentDelegate = strongSelf;
        ad.paidEventHandler = ^(GADAdValue *value) {
            OOAdLegacyInterstitial *owner = weakSelf;
            if (owner.revenueHandler) owner.revenueHandler(value.value, value.currencyCode, value.precision, owner.adNetworkClassName ?: @"");
        };
        id<GADInterstitialDelegate> delegate = strongSelf.delegate;
        if (error || !ad) {
            if ([delegate respondsToSelector:@selector(interstitial:didFailToReceiveAdWithError:)]) {
                [delegate interstitial:strongSelf didFailToReceiveAdWithError:error ?: [NSError errorWithDomain:@"Oriole2.AdLoad" code:1 userInfo:nil]];
            }
        } else if ([delegate respondsToSelector:@selector(interstitialDidReceiveAd:)]) {
            [delegate interstitialDidReceiveAd:strongSelf];
        }
    }];
}
- (void)reportPresentationFailure:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(interstitial:didFailToPresentScreenWithError:)]) {
        [self.delegate interstitial:self didFailToPresentScreenWithError:error];
    }
}
- (void)presentFromRootViewController:(UIViewController *)controller {
    NSError *error;
    if (!self.isReady || ![_ad canPresentFromRootViewController:controller error:&error]) {
        [self reportPresentationFailure:error ?: [NSError errorWithDomain:@"Oriole2.AdPresentation" code:2 userInfo:nil]];
        return;
    }
    _used = YES;
    [_ad presentFromRootViewController:controller];
}
- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    if ([self.delegate respondsToSelector:@selector(interstitialWillPresentScreen:)]) {
        [self.delegate interstitialWillPresentScreen:self];
    }
}
- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    if ([self.delegate respondsToSelector:@selector(interstitialDidDismissScreen:)]) {
        [self.delegate interstitialDidDismissScreen:self];
    }
    _ad.fullScreenContentDelegate = nil;
    _ad = nil;
}
- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
    if ([self.delegate respondsToSelector:@selector(interstitialDidRecordImpression:)]) {
        [self.delegate interstitialDidRecordImpression:self];
    }
}
- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    [self reportPresentationFailure:error];
    _ad.fullScreenContentDelegate = nil;
    _ad = nil;
}
@end
#endif
