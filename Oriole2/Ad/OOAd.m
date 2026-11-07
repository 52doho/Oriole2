//  OOAd.m
//  AdCatalog
//
//  Created by Gary Wong on 10/15/13.
//
//

#import "OOAd.h"
#import "iRate.h"
//#import <Chartboost/Chartboost.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "OOMoreAppsView.h"

@interface OOAdRequestParams : NSObject <GADAdNetworkExtras>
@property (nonatomic, copy) NSString *placement;
@property (nonatomic, assign) BOOL isMoreGame;
@end

@implementation OOAdRequestParams

@end

@implementation OOInterstitial

@end

@interface OOAd () <GADInterstitialDelegate> {
    NSMutableDictionary *dicMediations;
    NSMutableArray      *aryInterstitialPresenting;
}
@end

@implementation OOAd

+ (OOAd *)instance{
    static OOAd *sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [(OOAd *)[self alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        dicMediations = [NSMutableDictionary dictionary];
        aryInterstitialPresenting = [NSMutableArray array];
        _allowsDeferredPresentation = YES;
    }
    
    return self;
}

- (NSInteger)_getIntegerValueWithKeys:(NSArray *)keys defaultValue:(NSInteger)defaultValue {
    NSDictionary *dic = _config;
    for (NSString *key in keys) {
        dic = dic[key];
    }
    if ([dic isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)dic integerValue];
    } else {
        return defaultValue;
    }
}

- (void)_didDownloadOOAdConfig {
    [iRate sharedInstance].promptAtLaunch = NO;//[_config[@"iRate"][@"promptAtLaunch"] boolValue];
    [iRate sharedInstance].daysUntilPrompt = [self _getIntegerValueWithKeys:@[@"iRate", @"daysUntilPrompt"] defaultValue:2];
    [iRate sharedInstance].eventsUntilPrompt = [self _getIntegerValueWithKeys:@[@"iRate", @"eventsUntilPrompt"] defaultValue:5];
    [iRate sharedInstance].usesUntilPrompt = [self _getIntegerValueWithKeys:@[@"iRate", @"usesUntilPrompt"] defaultValue:2];
    [iRate sharedInstance].remindPeriod = [self _getIntegerValueWithKeys:@[@"iRate", @"remindPeriod"] defaultValue:4];
}

#define OOAdLog(log, ...) OOLog(@"<OOAd> %@", [NSString stringWithFormat:(log), ## __VA_ARGS__])

#define kAdRequestParams @"kAdRequestParams"
+ (GADRequest *)adRequestWithPlacement:(NSString *)placement isMoreGame:(BOOL)isMoreGame {
    GADRequest        *request = [GADRequest request];
    OOAdRequestParams *params = [[OOAdRequestParams alloc] init];
    
    params.placement = placement;
    params.isMoreGame = isMoreGame;
    
    GADCustomEventExtras *extras = [[GADCustomEventExtras alloc] init];
    NSDictionary         *dic = @{kAdRequestParams:params};
    [extras setExtras:dic forLabel:@"Chartboost"];
    [extras setExtras:dic forLabel:@"Playhaven"];
    [extras setExtras:dic forLabel:@"AdMob Network"];
    [extras setExtras:dic forLabel:@"Flurry"];
    [extras setExtras:dic forLabel:@"iAd"];
    [extras setExtras:dic forLabel:@"Millennial Media"];
    [request registerAdNetworkExtras:extras];
    
    ZPInvokeBlock([OOAd instance].didCreateGADRequest, request);
    if ([OOAd instance].didCreateGADRequestForPlacement) {
        [OOAd instance].didCreateGADRequestForPlacement(request, placement);
    }
#ifdef DEBUG
//    request.testDevices = @[ kGADSimulatorID, @"5331e99c6444bf981c5847d8ed5a2166" ];
#endif
    
    return request;
}

+ (GADRequest *)adRequestWithPlacement:(NSString *)placement {
    return [self adRequestWithPlacement:placement isMoreGame:NO];
}

+ (GADRequest *)adRequestWithDefaultPlacement {
    return [self adRequestWithPlacement:@"default"];
}

- (void)_notifyEvent:(NSString *)event ad:(OOInterstitial *)ad error:(NSError *)error {
    if (self.eventHandler) self.eventHandler(event, ad.adUnitID ?: @"", ad.placement ?: @"", error);
}

- (OOInterstitial *)_newInterstitialWithAdUnitID:(NSString *)adUnitID {
    return [[OOInterstitial alloc] initWithAdUnitID:adUnitID];
}

- (NSTimeInterval)_currentUptime { return [NSProcessInfo processInfo].systemUptime; }

- (BOOL)isInterstitialReadyWithMediationID:(NSString *)mediationID placement:(NSString *)placement {
    OOInterstitial *ad = dicMediations[mediationID][placement];
    return ad.isReady && !ad.hasBeenUsed && ad.loadedUptime > 0 && [self _currentUptime] - ad.loadedUptime < 3300;
}

- (void)discardCachedInterstitials {
    for (NSDictionary *placements in dicMediations.allValues) {
        for (OOInterstitial *ad in placements.allValues) {
            ad.needToShowAfterReceiveAd = NO;
            [self _clearDelegate:ad];
        }
    }
    [dicMediations removeAllObjects];
}

- (BOOL)_presentInterstitial:(OOInterstitial *)interstitial fromViewController:(UIViewController *)fromViewController {
    if (!interstitial || !fromViewController || (self.presentationValidator && !self.presentationValidator(interstitial.adUnitID, interstitial.placement))) {
        interstitial.needToShowAfterReceiveAd = NO;
        [self _notifyEvent:@"presentation_blocked" ad:interstitial error:nil];
        return NO;
    }

    if (self.presentationValidator && ([UIApplication sharedApplication].applicationState != UIApplicationStateActive || fromViewController.isBeingPresented || fromViewController.presentedViewController || !fromViewController.view.window)) {
        interstitial.needToShowAfterReceiveAd = NO;
        [self _notifyEvent:@"presentation_blocked" ad:interstitial error:nil];
        return NO;
    }
    if ([fromViewController isBeingPresented] && self.allowsDeferredPresentation) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _presentInterstitial:interstitial fromViewController:fromViewController];
        });
        return YES;
    }
    [self _notifyEvent:@"presentation_requested" ad:interstitial error:nil];
    @try {
        [interstitial presentFromRootViewController:fromViewController];
    } @catch (NSException *exception) {
        NSError *error = [NSError errorWithDomain:@"Oriole2.AdPresentation" code:1 userInfo:@{NSLocalizedDescriptionKey: exception.reason ?: @"Unable to present ad"}];
        [self _notifyEvent:@"presentation_failed" ad:interstitial error:error];
        return NO;
    }
    return YES;
}

- (void)_presentInterstitialAndCacheMore:(OOInterstitial *)interstitialOld delegate:(id <GADInterstitialDelegate> )delegate {
    if (interstitialOld) {
        if (!interstitialOld.hasBeenUsed) {
            [aryInterstitialPresenting addObject:interstitialOld];
            if (![self _presentInterstitial:interstitialOld fromViewController:[OOCommon getTopmostViewController]]) {
                [aryInterstitialPresenting removeObject:interstitialOld];
                return;
            }
        } else {
            OOAdLog(@"interstitialOld has been used, will not present again");
        }
        
        [self _removeInterstitialFromCache:interstitialOld];
        
        // cache more
        OOAdLog(@"cache more interstitial");
        [self _showInterstitialWithMediationId:interstitialOld.adUnitID placement:interstitialOld.placement isMoreGame:interstitialOld.isMoreGame isCache:YES delegate:delegate];
    } else {
        OOAdLog(@"logic error: interstitial hasBeenUsed");
    }
}

- (void)_removeInterstitialFromCache:(OOInterstitial *)interstitial {
    NSMutableDictionary *dicPlacements = dicMediations[interstitial.adUnitID];
    
    if (dicPlacements[interstitial.placement]) {
    if (dicPlacements[interstitial.placement] == interstitial) [dicPlacements removeObjectForKey:interstitial.placement];
    } else {
        OOAdLog(@"can't find interstitial:%@ from cache", interstitial.placement);
    }
}

- (OOInterstitialState)_showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement isMoreGame:(BOOL)isMoreGame isCache:(BOOL)isCache delegate:(id <GADInterstitialDelegate> )delegate {
    if (![mediationID isKindOfClass:[NSString class]] || ![placement isKindOfClass:[NSString class]] || mediationID.length == 0 || placement.length == 0) {
        OOAdLog(@"mediationID and placement can't be empty");
        return OOInterstitialState_Nothing;
    }
    if (self.requestValidator && !self.requestValidator(mediationID, placement)) return OOInterstitialState_Nothing;
    if (!isCache && self.presentationValidator && !self.presentationValidator(mediationID, placement)) return OOInterstitialState_Nothing;
    
    NSMutableDictionary *dicPlacements = dicMediations[mediationID];
    
    if (dicPlacements == nil) {
        dicPlacements = [NSMutableDictionary dictionary];
        dicMediations[mediationID] = dicPlacements;
    }
    
    OOInterstitial *interstitial = dicPlacements[placement];
    if (interstitial && interstitial.loadedUptime > 0 && ![self isInterstitialReadyWithMediationID:mediationID placement:placement]) {
        [self _notifyEvent:@"expired" ad:interstitial error:nil];
        [self _clearDelegate:interstitial];
        [dicPlacements removeObjectForKey:placement];
        interstitial = nil;
    }
    
    if (interstitial) {
        if (!isCache) {
            if (interstitial.isReady) {
                [self _presentInterstitialAndCacheMore:interstitial delegate:delegate];
                
                return OOInterstitialState_Present;
            } else {
                // wait
                OOAdLog(@"waiting interstitial to complete");
                interstitial.needToShowAfterReceiveAd = self.allowsDeferredPresentation;
                
                return OOInterstitialState_Loading;
            }
        } else {
            [self _notifyEvent:@"cache_reused" ad:interstitial error:nil];
            return OOInterstitialState_Nothing;// for cache
        }
    } else {
        // create new
        interstitial = [self _newInterstitialWithAdUnitID:mediationID];
        interstitial.placement = placement;
        interstitial.delegateBackup = delegate;
        interstitial.isMoreGame = isMoreGame;
        
        if (isCache) {
            interstitial.needToShowAfterReceiveAd = NO;
        } else {
            interstitial.needToShowAfterReceiveAd = self.allowsDeferredPresentation;
        }
        
        interstitial.delegate = self;
#if !OO_AD_LEGACY_INTERSTITIAL
        __weak typeof(self) weakSelf = self;
        interstitial.revenueHandler = ^(NSDecimalNumber *value, NSString *currency, NSInteger precision, NSString *network) {
            OOAd *owner = weakSelf;
            if (owner.revenueHandler) owner.revenueHandler(mediationID, placement, value, currency, precision, network);
        };
#endif
        GADRequest *request = [OOAd adRequestWithPlacement:placement isMoreGame:isMoreGame];
#ifdef DEBUG
#if OO_AD_LEGACY_INTERSTITIAL
        request.testDevices = @[ @"5331e99c6444bf981c5847d8ed5a2166" ];
#else
        [GADMobileAds sharedInstance].requestConfiguration.testDeviceIdentifiers = @[ @"5331e99c6444bf981c5847d8ed5a2166" ];
#endif
#endif
        dicPlacements[placement] = interstitial;
        [self _notifyEvent:@"request" ad:interstitial error:nil];
        [interstitial loadRequest:request];
        
        return OOInterstitialState_CreateNew;
    }
}

- (OOInterstitialState)showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement delegate:(id <GADInterstitialDelegate> )delegate {
    return [self _showInterstitialWithMediationId:mediationID placement:placement isMoreGame:NO isCache:NO delegate:delegate];
}

- (OOInterstitialState)showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement {
    return [self showInterstitialWithMediationId:mediationID placement:placement delegate:nil];
}

- (void)cacheInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement {
    [self _showInterstitialWithMediationId:mediationID placement:placement isMoreGame:NO isCache:YES delegate:nil];
}

- (NSString *)_getInterstitialLastShowDateKeyWithPlacement:(NSString *)placement {
    if (!placement) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"OOInterstitialLastShowDate_%@", placement];
}

- (NSString *)_getInterstitialLastShowCountKeyWithPlacement:(NSString *)placement {
    if (!placement) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"OOInterstitialLastShowCount_%@", placement];
}

- (OOInterstitialState)showInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID delegate:(id <GADInterstitialDelegate> )delegate {
    static NSString *PLACEMENT = @"app_become_active";
    static BOOL isFirstLaunch = YES;
    
    if (isFirstLaunch) {
        isFirstLaunch = NO;
        
//        if ([OOParseManager instance].interstitial_showAtLaunch) {
            return [self showInterstitialWithMediationId:mediationID placement:PLACEMENT delegate:delegate];
//        }
    } else {
        NSDate *lastShowDate = [DEFAULTS objectForKey:[self _getInterstitialLastShowDateKeyWithPlacement:PLACEMENT]];
        
        if (!lastShowDate) {
            return [self showInterstitialWithMediationId:mediationID placement:PLACEMENT delegate:delegate];
        }
        
        NSString       *kCount = [self _getInterstitialLastShowCountKeyWithPlacement:PLACEMENT];
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastShowDate];
        
        if ((0 < interval) && (interval < 3600)) {
            NSUInteger count = [DEFAULTS integerForKey:kCount];
            
//            if (count < [OOParseManager instance].interstitial_maxShowPerHour) {
                return [self showInterstitialWithMediationId:mediationID placement:PLACEMENT delegate:delegate];
//            }
        } else {
            [DEFAULTS setObject:@(0) forKey:kCount];
            return [self showInterstitialWithMediationId:mediationID placement:PLACEMENT delegate:delegate];
        }
    }
    
    return OOInterstitialState_Nothing;
}

- (OOInterstitialState)showInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID {
    return [self showInterstitialOfAppBecomeActiveWithMediationID:mediationID delegate:nil];
}

- (void)cacheInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID {
    [self _showInterstitialWithMediationId:mediationID placement:@"app_become_active" isMoreGame:NO isCache:YES delegate:nil];
}

- (OOInterstitialState)showInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID delegate:(id <GADInterstitialDelegate> )delegate {
    return [self _showInterstitialWithMediationId:mediationID placement:@"more_games" isMoreGame:YES isCache:NO delegate:delegate];
}

- (OOInterstitialState)showInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID {
    return [self showInterstitialOfMoreAppsWithMediationID:mediationID delegate:nil];
}

- (void)cacheInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID delegate:(id <GADInterstitialDelegate> )delegate {
    [self _showInterstitialWithMediationId:mediationID placement:@"more_games" isMoreGame:YES isCache:YES delegate:delegate];
}

// GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    if (![ad isKindOfClass:[OOInterstitial class]]) {
        return;// avoid crash
    }
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    if (dicMediations[interstitial.adUnitID][interstitial.placement] != interstitial) {
        [self _clearDelegate:interstitial];
        return;
    }
    interstitial.loadedUptime = [self _currentUptime];
    [self _notifyEvent:@"loaded" ad:interstitial error:nil];
    
    if ([interstitial.delegateBackup respondsToSelector:@selector(interstitialDidReceiveAd:)]) {
        [interstitial.delegateBackup interstitialDidReceiveAd:ad];
    }
    
    OOAdLog(@"interstitialDidReceiveAd:%@, adNetworkClassName:%@", interstitial.placement, interstitial.adNetworkClassName);
    
    if (interstitial.needToShowAfterReceiveAd) {
        [self _presentInterstitialAndCacheMore:interstitial delegate:interstitial.delegateBackup];
    }
}

// NOTE: clear delegate to avoid crash of admob.
// -[GADDelegateManager didFailToReceiveAdWithError:] (GADDelegateManager.m:97)
- (void)_clearDelegate:(OOInterstitial *)interstitial {
    interstitial.delegate = interstitial.delegateBackup = nil;
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    if (![ad isKindOfClass:[OOInterstitial class]]) {
        return;// avoid crash
    }
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    
    if ([interstitial.delegateBackup respondsToSelector:@selector(interstitial:didFailToReceiveAdWithError:)]) {
        [interstitial.delegateBackup interstitial:ad didFailToReceiveAdWithError:error];
    }
    
    OOAdLog(@"interstitial:%@, didFailToReceiveAdWithError:%@", interstitial.placement, error);
    [self _notifyEvent:@"load_failed" ad:interstitial error:error];
    [self _removeInterstitialFromCache:interstitial];
    [self _clearDelegate:interstitial];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    if (![ad isKindOfClass:[OOInterstitial class]]) {
        return;// avoid crash
    }
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    [DEFAULTS setObject:[NSDate date] forKey:[self _getInterstitialLastShowDateKeyWithPlacement:interstitial.placement]];
    NSString *countKey = [self _getInterstitialLastShowCountKeyWithPlacement:interstitial.placement];
    [DEFAULTS setInteger:[DEFAULTS integerForKey:countKey] + 1 forKey:countKey];
    [self _notifyEvent:@"presented" ad:interstitial error:nil];
    
    if ([interstitial.delegateBackup respondsToSelector:@selector(interstitialWillPresentScreen:)]) {
        [interstitial.delegateBackup interstitialWillPresentScreen:ad];
    }
    
    OOAdLog(@"interstitialWillPresentScreen:%@", interstitial.placement);
}

- (void)interstitialDidRecordImpression:(GADInterstitial *)ad {
    if ([ad isKindOfClass:[OOInterstitial class]]) [self _notifyEvent:@"impression" ad:(OOInterstitial *)ad error:nil];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    if (![ad isKindOfClass:[OOInterstitial class]]) {
        return;// avoid crash
    }
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    [self _notifyEvent:@"dismissed" ad:interstitial error:nil];
    
    if ([interstitial.delegateBackup respondsToSelector:@selector(interstitialDidDismissScreen:)]) {
        [interstitial.delegateBackup interstitialDidDismissScreen:ad];
    }
    
    [aryInterstitialPresenting removeObject:ad];
    [self _clearDelegate:interstitial];
    
    OOAdLog(@"interstitialDidDismissScreen:%@", interstitial.placement);
}

- (void)interstitial:(GADInterstitial *)ad didFailToPresentScreenWithError:(NSError *)error {
    if (![ad isKindOfClass:[OOInterstitial class]]) return;
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    [self _notifyEvent:@"presentation_failed" ad:interstitial error:error];
    [aryInterstitialPresenting removeObject:interstitial];
    [self _removeInterstitialFromCache:interstitial];
    [self _clearDelegate:interstitial];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    if (![ad isKindOfClass:[OOInterstitial class]]) {
        return;// avoid crash
    }
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    
    if ([interstitial.delegateBackup respondsToSelector:@selector(interstitialWillLeaveApplication:)]) {
        [interstitial.delegateBackup interstitialWillLeaveApplication:ad];
    }
    
    // A click can open Safari/App Store while the ad is still on screen. Keep
    // receiving its final dismissal so the app's presentation lock is released.
    [self _notifyEvent:@"left_application" ad:interstitial error:nil];
    
    OOAdLog(@"interstitialWillLeaveApplication:%@", interstitial.placement);
}

@end

#pragma mark - OOAdBase -
@interface OOAdBase (extend) {
}
- (OOAdRequestParams *)getExtrasForRequest:(GADCustomEventRequest *)request delegate:(NSObject *)delegate;
@end

@implementation OOAdBase
- (OOAdRequestParams *)getExtrasForRequest:(GADCustomEventRequest *)request delegate:(NSObject *)delegate {
    NSDictionary      *dic = [request additionalParameters];
    OOAdRequestParams *params = dic[kAdRequestParams];
    
    if (!params) {
        OOLog(@"Internal error of OOAdBase");
    }
    
    return params;
}

- (NSDictionary *)convertToDic:(NSString *)serverParam {
    if (serverParam == nil) {
        return nil;
    }
    
    NSError      *error = nil;
    NSDictionary *dicJsonValue = [NSJSONSerialization JSONObjectWithData:[serverParam dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        OOAdLog(@"serverParam error:%@", error);
    }
    
    if (dicJsonValue == nil) {
        OOAdLog(@"Admob site config error: %@", serverParam);
    }
    
    return dicJsonValue;
}

- (NSString *)getPlacementIdInDic:(NSDictionary *)dic placementName:(NSString *)placementName {
    if (dic == nil) {
        return nil;
    }
    
    NSDictionary *dicPlacements = dic[@"placements"];
    NSString     *placementId = dicPlacements[placementName];
    
    if (placementId == nil) {
        OOAdLog(@"Can't find placementName: %@ in dic:%@, class:%@", placementName, dic, NSStringFromClass([self class]));
    }
    
    return placementId;
}

@end

#pragma mark - OOAdBanner_Oriole2 -
@interface OOAdBanner_Oriole2 () <GADCustomEventBanner, GADBannerViewDelegate, SKStoreProductViewControllerDelegate> {
    OOMoreAppsView *_moreAppsView;
    NSArray        *_aryApps;
    NSString       *_url;
    NSUInteger _appId;
    BOOL _hasRecordTap;
}
@property(nonatomic, strong) SKStoreProductViewController *storeController;
@end

@implementation OOAdBanner_Oriole2

@synthesize delegate;

- (void)dealloc {
    [_moreAppsView stopAnimate];
    _moreAppsView = nil;
    _storeController.delegate = nil;
}

- (SKStoreProductViewController *)storeController {
    if (_storeController == nil) {
        _storeController = [[SKStoreProductViewController alloc] init];
        _storeController.delegate = self;
    }
    
    return _storeController;
}

- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
    NSDictionary *dic = [self convertToDic:serverParam];
    if (!_moreAppsView) {
        _moreAppsView = [[OOMoreAppsView alloc] init];
        _moreAppsView.randomTimeFrom = 10;
        _moreAppsView.randomTimeTo = 12;
        _url = @"itms-apps://itunes.apple.com/us/artist/oriole2-co.-ltd./id506665225?mt=8";
        _moreAppsView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
        [_moreAppsView addTarget:self action:@selector(_moreAppsViewTapped) forControlEvents:UIControlEventTouchDown];
        
        [self.delegate customEventBanner:self didReceiveAd:_moreAppsView];
    }
    
    if (dic) {
        NSString *randomTimeFrom = dic[@"secondsFrom"];
        NSString *randomTimeTo = dic[@"secondsTo"];
        _moreAppsView.randomTimeFrom = [randomTimeFrom integerValue];
        _moreAppsView.randomTimeTo = [randomTimeTo integerValue];
        [_moreAppsView setBannerImageUrls:dic[@"images"]];
        NSString *urlFromServer = dic[@"url"];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlFromServer]]) {
            _url = urlFromServer;
        }
        
        _aryApps = dic[@"apps"];
        _appId = NSUIntegerMax;
        
        for (NSDictionary *dic in _aryApps) {
            uint _id = [dic[@"id"] intValue];
            NSString *scheme = dic[@"scheme"];
            if ([scheme rangeOfString:@"://"].location == NSNotFound) {
                scheme = [NSString stringWithFormat:@"%@://", scheme];
            }
            
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]]) {
                continue;// has been installed
            } else {
                _appId = _id;
                
                static NSMutableArray *aryAppIdDidLoad;
                
                if (aryAppIdDidLoad == nil) {
                    aryAppIdDidLoad = [NSMutableArray array];
                }
                
                if (![aryAppIdDidLoad containsObject:@(_appId)]) {
                    [self.storeController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: @(_appId)} completionBlock:^(BOOL result, NSError *error) {
                        if (result && !error) {
                            [aryAppIdDidLoad addObject:@(_appId)];
                        }
                        
                        OOLog(@"preload store controller, result:%i, error:%@", result, error);
                    }];
                }
                
                break;
            }
        }
    }
    
    [_moreAppsView startAnimate];
}

- (void)_showModalViewController:(UIViewController *)modalVC {
    if (modalVC) {
        UIViewController *topmostViewController = [OOCommon getTopmostViewController];
        
        if (topmostViewController.presentedViewController) {
            [topmostViewController dismissViewControllerAnimated:NO completion:^{
                [topmostViewController presentViewController:modalVC animated:YES completion:nil];
            }];
        } else {
            [topmostViewController presentViewController:modalVC animated:YES completion:nil];
        }
    }
}

- (void)_moreAppsViewTapped {
    if (!_hasRecordTap) {
        _hasRecordTap = YES;
        
        [self.delegate customEventBannerWasClicked:self];
    }
    
    UIViewController *topmostViewController = [OOCommon getTopmostViewController];
    
    if ((_appId != NSUIntegerMax) && topmostViewController) {
        [self.storeController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:@(_appId)} completionBlock:^(BOOL result, NSError *error) {
        }];
        [self _showModalViewController:self.storeController];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)productVC {
    productVC.delegate = nil;
    [productVC dismissViewControllerAnimated:YES completion:^{
    }];
    self.storeController = nil;
}

@end
/*
#pragma mark - OOAdInterstitial_Chartboost -
@interface OOAdInterstitial_Chartboost () <GADCustomEventInterstitial, ChartboostDelegate> {
    NSString *_placement;
    BOOL _isMoreGame;
}
@end

@implementation OOAdInterstitial_Chartboost

@synthesize delegate;

- (void)dealloc {
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
    NSDictionary *dicParam = [self convertToDic:serverParam];
    
    if (dicParam) {
        NSString *token = dicParam[@"id"];
        NSString *secret = dicParam[@"signature"];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [Chartboost startWithAppId:token appSignature:secret delegate:self];
            [Chartboost setAutoCacheAds:YES];
        });
        
        _placement = CBLocationMainMenu;
        OOAdRequestParams *extras = [self getExtrasForRequest:request delegate:self.delegate];
        _isMoreGame = extras.isMoreGame;
        
        if (_isMoreGame) {
            [Chartboost cacheMoreApps:_placement];
        } else {
            [Chartboost cacheInterstitial:_placement];
        }
    }
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (_isMoreGame) {
        [Chartboost showMoreApps:_placement];
    } else {
        [Chartboost showInterstitial:_placement];
    }
}

- (BOOL)shouldDisplayInterstitial:(CBLocation)location {
    [self.delegate customEventInterstitialWillPresent:self];
    // cache
    [Chartboost cacheInterstitial:location];
    
    return YES;
}

- (BOOL)shouldDisplayMoreApps {
    [self.delegate customEventInterstitialWillPresent:self];
    // cache
    [Chartboost cacheMoreApps:_placement];
    
    return YES;
}

- (void)didCacheInterstitial:(CBLocation)location {
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)didFailToLoadInterstitial:(CBLocation)location {
    [self.delegate customEventInterstitial:self didFailAd:nil];
}

- (void)didDismissInterstitial:(CBLocation)location {
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)didCloseInterstitial:(CBLocation)location {
    [self didDismissInterstitial:location];
}

- (void)didClickInterstitial:(CBLocation)location {
    [self didDismissInterstitial:location];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

@end
*/
