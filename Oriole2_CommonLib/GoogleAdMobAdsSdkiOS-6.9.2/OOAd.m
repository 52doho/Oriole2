
//  OOAd.m
//  AdCatalog
//
//  Created by Gary Wong on 10/15/13.
//
//

#import "OOAd.h"
//#import <RevMobAds/RevMobAds.h>
#import "Chartboost.h"
//#import "DMAdView.h"
//#import "DMInterstitialAdController.h"
//#import "PunchBoxAd.h"
//#import "PunchBoxAdDelegate.h"

#import "OOMoreAppsView.h"

#import "GADCustomEventBanner.h"
#import "GADCustomEventBannerDelegate.h"
#import "GADCustomEventInterstitial.h"
#import "GADCustomEventInterstitialDelegate.h"
#import "GADCustomEventInterstitial.h"
#import "GADCustomEventExtras.h"
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import "GADInterstitial.h"

@interface OOAdRequestParams : NSObject <GADAdNetworkExtras>
@property (nonatomic, copy) NSString *placement;
@property (nonatomic, assign) BOOL isMoreGame;
@end

@implementation OOAdRequestParams

@end

@implementation OOInterstitial


@end

@interface OOAd()<GADInterstitialDelegate>
{
    NSMutableDictionary *dicMediations;
    NSMutableArray *aryInterstitialPresenting;
}
@end

@implementation OOAd

- (id)init
{
    self = [super init];
    if(self)
    {
        dicMediations = [NSMutableDictionary dictionary];
        aryInterstitialPresenting = [NSMutableArray array];
    }
    return self;
}

#define OOAdLog(log, ...) OOLog(@"<OOAd> %@", [NSString stringWithFormat:(log), ##__VA_ARGS__])

GTMOBJECT_SINGLETON_BOILERPLATE(OOAd, instance);

#define kAdRequestParams @"kAdRequestParams"
+ (GADRequest *)adRequestWithPlacement:(NSString *)placement isMoreGame:(BOOL)isMoreGame
{
    GADRequest *request = [GADRequest request];
    OOAdRequestParams *params = [[OOAdRequestParams alloc] init];
    params.placement = placement;
    params.isMoreGame = isMoreGame;
    
    GADCustomEventExtras *extras = [[GADCustomEventExtras alloc] init];
    NSDictionary *dic = @{kAdRequestParams:params};
    [extras setExtras:dic forLabel:@"Chartboost"];
    [extras setExtras:dic forLabel:@"Playhaven"];
    [extras setExtras:dic forLabel:@"AdMob Network"];
    [extras setExtras:dic forLabel:@"RevMob"];
    [extras setExtras:dic forLabel:@"DoMob"];
    [extras setExtras:dic forLabel:@"PunchBox"];
    [extras setExtras:dic forLabel:@"Flurry"];
    [extras setExtras:dic forLabel:@"iAd"];
    [extras setExtras:dic forLabel:@"Millennial Media"];
    [request registerAdNetworkExtras:extras];
    
    return request;
}

+ (GADRequest *)adRequestWithPlacement:(NSString *)placement
{
    return [self adRequestWithPlacement:placement isMoreGame:NO];
}

+ (GADRequest *)adRequestWithDefaultPlacement
{
    return [self adRequestWithPlacement:@"default"];
}
/*
- (void)appOpenNotifyForPlayhavenWithToken:(NSString *)token secret:(NSString *)secret
{
    [(PHAPIRequest *)[PHPublisherOpenRequest requestForApp:token secret:secret] send];
}
*/
- (void)_presentInterstitialAndCacheMore:(OOInterstitial *)interstitialOld delegate:(id<GADInterstitialDelegate>)delegate
{
    if(interstitialOld)
    {
        if(!interstitialOld.hasBeenUsed)
        {
            UIViewController *vc = [OOCommon getRootViewController];
            if(vc.presentedViewController)
                vc = vc.presentedViewController;
            [interstitialOld presentFromRootViewController:vc];
            
            [aryInterstitialPresenting addObject:interstitialOld];
        }
        else
        {
            OOAdLog(@"interstitialOld has been used, will not present again");
        }
        
        NSMutableDictionary *dicPlacements = dicMediations[interstitialOld.adUnitID];
        
        [self _removeInterstitialFromCache:interstitialOld];
        
        //cache more
        OOAdLog(@"cache more interstitial");
        OOInterstitial *interstitial = [[OOInterstitial alloc] init];
        interstitial.placement = interstitialOld.placement;
        interstitial.delegateBackup = delegate;
        interstitial.isMoreGame = interstitialOld.isMoreGame;
        interstitial.needToShowAfterReceiveAd = NO;
        
        interstitial.adUnitID = interstitialOld.adUnitID;
        interstitial.delegate = self;
        GADRequest *request = [OOAd adRequestWithPlacement:interstitialOld.placement isMoreGame:interstitialOld.isMoreGame];
        [interstitial loadRequest:request];
        
        [dicPlacements setObject:interstitial forKey:interstitialOld.placement];
    }
    else
    {
        OOAdLog(@"logic error: interstitial hasBeenUsed");
    }
}

- (void)_removeInterstitialFromCache:(OOInterstitial *)interstitial
{
    NSMutableDictionary *dicPlacements = dicMediations[interstitial.adUnitID];
    if(dicPlacements[interstitial.placement])
        [dicPlacements removeObjectForKey:interstitial.placement];
    else
    {
        OOAdLog(@"can't find interstitial:%@ from cache", interstitial.placement);
    }
}

- (OOInterstitialState)_showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement isMoreGame:(BOOL)isMoreGame isCache:(BOOL)isCache delegate:(id<GADInterstitialDelegate>)delegate
{
    if(mediationID == nil || placement == nil)
    {
        OOAdLog(@"mediationID and placement can't be empty");
        return OOInterstitialState_Nothing;
    }
    
    NSMutableDictionary *dicPlacements = dicMediations[mediationID];
    if(dicPlacements == nil)
    {
        dicPlacements = [NSMutableDictionary dictionary];
        [dicMediations setObject:dicPlacements forKey:mediationID];
    }
    OOInterstitial *interstitial = dicPlacements[placement];
    if(interstitial)
    {
        if(!isCache)
        {
            if(interstitial.isReady)
            {
                [self _presentInterstitialAndCacheMore:interstitial delegate:delegate];
                
                return OOInterstitialState_Present;
            }
            else
            {
                //wait
                OOAdLog(@"waiting interstitial to complete");
                interstitial.needToShowAfterReceiveAd = YES;
                
                return OOInterstitialState_Loading;
            }
        }
        else
            return OOInterstitialState_Nothing;//for cache
    }
    else
    {
        //create new
        interstitial = [[OOInterstitial alloc] init];
        interstitial.placement = placement;
        interstitial.delegateBackup = delegate;
        interstitial.isMoreGame = isMoreGame;
        if(isCache)
            interstitial.needToShowAfterReceiveAd = NO;
        else
            interstitial.needToShowAfterReceiveAd = YES;
        
        interstitial.adUnitID = mediationID;
        interstitial.delegate = self;
        GADRequest *request = [OOAd adRequestWithPlacement:placement isMoreGame:isMoreGame];
        [interstitial loadRequest:request];
        
        [dicPlacements setObject:interstitial forKey:placement];
        
        return OOInterstitialState_CreateNew;
    }
}

- (OOInterstitialState)showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement delegate:(id<GADInterstitialDelegate>)delegate
{
    return [self _showInterstitialWithMediationId:mediationID placement:placement isMoreGame:NO isCache:NO delegate:delegate];
}

- (OOInterstitialState)showInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement
{
    return [self showInterstitialWithMediationId:mediationID placement:placement delegate:nil];
}

- (void)cacheInterstitialWithMediationId:(NSString *)mediationID placement:(NSString *)placement
{
    [self _showInterstitialWithMediationId:mediationID placement:placement isMoreGame:NO isCache:YES delegate:nil];
}

- (OOInterstitialState)showInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID delegate:(id<GADInterstitialDelegate>)delegate
{
    return [self showInterstitialWithMediationId:mediationID placement:@"app_become_active" delegate:delegate];
}

- (OOInterstitialState)showInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID
{
    return [self showInterstitialOfAppBecomeActiveWithMediationID:mediationID delegate:nil];
}

- (void)cacheInterstitialOfAppBecomeActiveWithMediationID:(NSString *)mediationID
{
    [self _showInterstitialWithMediationId:mediationID placement:@"app_become_active" isMoreGame:NO isCache:YES delegate:nil];
}

- (OOInterstitialState)showInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID delegate:(id<GADInterstitialDelegate>)delegate
{
    return [self _showInterstitialWithMediationId:mediationID placement:@"more_games" isMoreGame:YES isCache:NO delegate:delegate];
}

- (OOInterstitialState)showInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID
{
    return [self showInterstitialOfMoreAppsWithMediationID:mediationID delegate:nil];
}

- (void)cacheInterstitialOfMoreAppsWithMediationID:(NSString *)mediationID
{
    [self _showInterstitialWithMediationId:mediationID placement:@"more_games" isMoreGame:YES isCache:YES delegate:nil];
}

//GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if(![ad isKindOfClass:[OOInterstitial class]])
        return;//avoid crash
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    if([interstitial.delegateBackup respondsToSelector:@selector(interstitialDidReceiveAd:)])
        [interstitial.delegateBackup interstitialDidReceiveAd:ad];
    
    OOAdLog(@"interstitialDidReceiveAd:%@", interstitial.placement);
    if(interstitial.needToShowAfterReceiveAd)
        [self _presentInterstitialAndCacheMore:interstitial delegate:interstitial.delegateBackup];
}

//NOTE: clear delegate to avoid crash of admob.
//-[GADDelegateManager didFailToReceiveAdWithError:] (GADDelegateManager.m:97)
- (void)_clearDelegate:(OOInterstitial *)interstitial
{
    interstitial.delegate = interstitial.delegateBackup = nil;
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    if(![ad isKindOfClass:[OOInterstitial class]])
        return;//avoid crash
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    if([interstitial.delegateBackup respondsToSelector:@selector(interstitial:didFailToReceiveAdWithError:)])
        [interstitial.delegateBackup interstitial:ad didFailToReceiveAdWithError:error];
    
    OOAdLog(@"interstitial:%@, didFailToReceiveAdWithError:%@", interstitial.placement, error);
    [self _removeInterstitialFromCache:interstitial];
    [self _clearDelegate:interstitial];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    if(![ad isKindOfClass:[OOInterstitial class]])
        return;//avoid crash
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    if([interstitial.delegateBackup respondsToSelector:@selector(interstitialWillPresentScreen:)])
        [interstitial.delegateBackup interstitialWillPresentScreen:ad];
    
    OOAdLog(@"interstitialWillPresentScreen:%@", interstitial.placement);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    if(![ad isKindOfClass:[OOInterstitial class]])
        return;//avoid crash
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    if([interstitial.delegateBackup respondsToSelector:@selector(interstitialDidDismissScreen:)])
        [interstitial.delegateBackup interstitialDidDismissScreen:ad];
    
    [aryInterstitialPresenting removeObject:ad];
    [self _clearDelegate:interstitial];
    
    OOAdLog(@"interstitialDidDismissScreen:%@", interstitial.placement);
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    if(![ad isKindOfClass:[OOInterstitial class]])
        return;//avoid crash
    
    OOInterstitial *interstitial = (OOInterstitial *)ad;
    if([interstitial.delegateBackup respondsToSelector:@selector(interstitialWillLeaveApplication:)])
        [interstitial.delegateBackup interstitialWillLeaveApplication:ad];
    
    [aryInterstitialPresenting removeObject:ad];
    [self _clearDelegate:interstitial];
    
    OOAdLog(@"interstitialWillLeaveApplication:%@", interstitial.placement);
}

@end


#pragma mark - OOAdBase -
@interface OOAdBase(extend)
{
}
- (OOAdRequestParams *)getExtrasForRequest:(GADCustomEventRequest *)request delegate:(NSObject *)delegate;
@end

@implementation OOAdBase
- (OOAdRequestParams *)getExtrasForRequest:(GADCustomEventRequest *)request delegate:(NSObject *)delegate
{
    NSDictionary *dic = [request additionalParameters];
    OOAdRequestParams *params = dic[kAdRequestParams];
    if(!params)
    {
        OOLog(@"Internal error of OOAdBase");
    }
    
    return params;
}

- (NSDictionary *)convertToDic:(NSString *)serverParam
{
    if(serverParam == nil)
        return nil;
    
    NSError *error = nil;
    NSDictionary *dicJsonValue = [NSJSONSerialization JSONObjectWithData:[serverParam dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if(error)
    {
        OOAdLog(@"serverParam error:%@", error);
    }
    if(dicJsonValue == nil)
    {
        OOAdLog(@"Admob site config error: %@", serverParam);
    }
    
    return dicJsonValue;
}

- (NSString *)getPlacementIdInDic:(NSDictionary *)dic placementName:(NSString *)placementName
{
    if(dic == nil)
        return nil;
    
    NSDictionary *dicPlacements = dic[@"placements"];
    NSString *placementId = dicPlacements[placementName];
    if(placementId == nil)
    {
        OOAdLog(@"Can't find placementName: %@ in dic:%@, class:%@", placementName, dic, NSStringFromClass([self class]));
    }
    return placementId;
}

@end


#pragma mark - OOAdBanner_Oriole2 -
@interface OOAdBanner_Oriole2()<GADCustomEventBanner, GADBannerViewDelegate, SKStoreProductViewControllerDelegate>
{
    OOMoreAppsView *moreAppsView;
    NSArray *aryApps;
    NSString *artistUrl;
    NSString *url;
    uint appId;
    BOOL hasRecordTap;
}
@property(nonatomic, strong) SKStoreProductViewController *storeController;
@end

@implementation OOAdBanner_Oriole2

@synthesize delegate;

- (void)dealloc
{
    [moreAppsView stopAnimate];
    moreAppsView = nil;
    _storeController.delegate = nil;
}

- (SKStoreProductViewController *)storeController
{
    if (_storeController == nil)
    {
        _storeController = [[SKStoreProductViewController alloc] init];
        _storeController.delegate = self;
    }
    return _storeController;
}

- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    if (!moreAppsView)
    {
        moreAppsView = [[OOMoreAppsView alloc] init];
        moreAppsView.randomTimeFrom = 4;
        moreAppsView.randomTimeTo = 6;
        url = @"itms-apps://itunes.apple.com/us/artist/oriole2-co.-ltd./id506665225?mt=8";
        moreAppsView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
        [moreAppsView addTarget:self action:@selector(_moreAppsViewTapped) forControlEvents:UIControlEventTouchDown];
        
        [self.delegate customEventBanner:self didReceiveAd:moreAppsView];
    }
    
    NSDictionary *dic = [self convertToDic:serverParam];
    if(dic)
    {
        NSString *randomTimeFrom = dic[@"secondsFrom"];
        NSString *randomTimeTo = dic[@"secondsTo"];
        moreAppsView.randomTimeFrom = [randomTimeFrom integerValue];
        moreAppsView.randomTimeTo = [randomTimeTo integerValue];
        NSString *urlFromServer = dic[@"url"];
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlFromServer]])
            url = urlFromServer;
        
        aryApps = dic[@"apps"];
        artistUrl = dic[@"artist"][@"url"];
        appId = NSUIntegerMax;
        for (NSDictionary *dic in aryApps)
        {
            uint _id = [dic[@"id"] intValue];
            NSString *scheme = dic[@"scheme"];
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]])
                continue;//has been installed
            else
            {
                appId = _id;
                
                static NSMutableArray *aryAppIdDidLoad;
                if (aryAppIdDidLoad == nil)
                {
                    aryAppIdDidLoad = [NSMutableArray array];
                }
                if (![aryAppIdDidLoad containsObject:@(appId)])
                {
                    [self.storeController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : @(appId)} completionBlock:^(BOOL result, NSError *error) {
                        if(result && !error)
                            [aryAppIdDidLoad addObject:@(appId)];
                        OOLog(@"preload store controller, result:%i, error:%@", result, error);
                    }];
                }
                break;
            }
        }
    }
    [moreAppsView startAnimate];
}

- (void)_showModalViewController:(UIViewController *)modalVC
{
    if(modalVC)
    {
        UIViewController *topmostViewController = [OOCommon getTopmostViewController];
        if(topmostViewController.presentedViewController)
        {
            [topmostViewController dismissViewControllerAnimated:NO completion:^{
                [topmostViewController presentViewController:modalVC animated:YES completion:nil];
            }];
        }
        else
            [topmostViewController presentViewController:modalVC animated:YES completion:nil];
    }
}

- (void)_moreAppsViewTapped
{
    if(!hasRecordTap)
    {
        hasRecordTap = YES;
        
        [self.delegate customEventBanner:self clickDidOccurInAd:moreAppsView];
    }
    
    UIViewController *topmostViewController = [OOCommon getTopmostViewController];
    if(appId != NSUIntegerMax && topmostViewController)
    {
        //show waiting
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:moreAppsView animated:YES];
        hud.minShowTime = 1;
        hud.opacity = 0;
        hud.labelText = nil;
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.removeFromSuperViewOnHide = YES;
        
        [self.storeController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : @(appId)} completionBlock:^(BOOL result, NSError *error) {
            if (result)
            {
                [hud hide:YES];
                [self _showModalViewController:self.storeController];
            }
            else
            {
                hud.labelText = OOLocalizedStringInOOBundle(@"Failed");
                [hud hide:YES afterDelay:1.];
                OOLog(@"There was a problem displaying app store view");
            }
        }];
    }
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)productVC
{
    [productVC dismissViewControllerAnimated:YES completion:^{
    }];
}

@end

/*
#pragma mark - OOAdBanner_RevMob -
@interface OOAdBanner_RevMob()<GADCustomEventBanner, GADBannerViewDelegate, RevMobAdsDelegate>
{
    RevMobBannerView *revMobBannerView;
}
@end


@implementation OOAdBanner_RevMob

@synthesize delegate;

- (void)dealloc
{
    revMobBannerView.delegate = nil;
    revMobBannerView = nil;
}

- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    if (!revMobBannerView)
    {
        NSDictionary *dicParam = [self convertToDic:serverParam];
        if([RevMobAds session] == nil)
        {
            [RevMobAds startSessionWithAppID:dicParam[@"id"]];
        }
        
        OOAdRequestParams *extras = [self getExtrasForRequest:request delegate:self.delegate];
        NSString *placementId = [self getPlacementIdInDic:dicParam placementName:extras.placement];
        
        if(placementId)
            revMobBannerView = [[RevMobAds session] bannerViewWithPlacementId:placementId];
        else
            revMobBannerView = [[RevMobAds session] bannerView];
        revMobBannerView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
        [revMobBannerView setDelegate:self];
    }
    [revMobBannerView loadAd];
}

- (void)revmobAdDidReceive
{
    [self.delegate customEventBanner:self didReceiveAd:revMobBannerView];
}

- (void)revmobAdDidFailWithError:(NSError *)error
{
    [self.delegate customEventBanner:self didFailAd:error];
}

- (void)revmobAdDisplayed
{
    [self.delegate customEventBannerWillPresentModal:self];
}

- (void)revmobUserClosedTheAd
{
    [self.delegate customEventBannerWillDismissModal:self];
}

- (void)revmobUserClickedInTheAd
{
    [self.delegate customEventBanner:self clickDidOccurInAd:revMobBannerView];
}

@end



#pragma mark - OOAdInterstitial_RevMob -
@interface OOAdInterstitial_RevMob()<GADCustomEventInterstitial, RevMobAdsDelegate>
{
    RevMobFullscreen *fullscreen;
}
@end

@implementation OOAdInterstitial_RevMob

@synthesize delegate;
- (void)dealloc
{
    [fullscreen hideAd];
    fullscreen.delegate = nil;
    fullscreen = nil;
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    if (!fullscreen)
    {
        NSDictionary *dicParam = [self convertToDic:serverParam];
        if([RevMobAds session] == nil)
        {
            [RevMobAds startSessionWithAppID:dicParam[@"id"]];
        }
        
        OOAdRequestParams *extras = [self getExtrasForRequest:request delegate:self.delegate];
        NSString *placementId = [self getPlacementIdInDic:dicParam placementName:extras.placement];
        
        if(placementId)
            fullscreen = [[RevMobAds session] fullscreenWithPlacementId:placementId];
        else
            fullscreen = [[RevMobAds session] fullscreen];
        [fullscreen setDelegate:self];
    }
    [fullscreen loadAd];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
    [fullscreen showAd];
}

- (void)revmobAdDidReceive
{
    [self.delegate customEventInterstitial:self didReceiveAd:nil];
}

- (void)revmobAdDidFailWithError:(NSError *)error
{
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)revmobAdDisplayed
{
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)revmobUserClosedTheAd
{
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)revmobUserClickedInTheAd
{
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

@end



#pragma mark - OOAdInterstitial_Playhaven -
@interface OOAdInterstitial_Playhaven()<GADCustomEventInterstitial, PHPublisherContentRequestDelegate>
{
    PHPublisherContentRequest *contentRequest;
}
@end

@implementation OOAdInterstitial_Playhaven

@synthesize delegate;
- (void)dealloc
{
    contentRequest.delegate = nil;
    contentRequest = nil;
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    NSDictionary *dicParam = [self convertToDic:serverParam];
    if(dicParam)
    {
        NSString *token = dicParam[@"token"];
        NSString *secret = dicParam[@"secret"];
        
        static BOOL hasNotifyOpen = NO;
        if(!hasNotifyOpen)
        {
            hasNotifyOpen = YES;
            
            [(PHAPIRequest *)[PHPublisherOpenRequest requestForApp:token secret:secret] send];
        }
        
        OOAdRequestParams *extras = [self getExtrasForRequest:request delegate:self.delegate];
        
        contentRequest.delegate = nil;
        contentRequest = nil;
        
        contentRequest = [PHPublisherContentRequest requestForApp:token secret:secret placement:extras.placement delegate:self];
        [contentRequest setShowsOverlayImmediately:NO];
        [contentRequest setAnimated:YES];
        [contentRequest preload];
    }
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
    [contentRequest send];
}

- (void)requestDidGetContent:(PHPublisherContentRequest *)request
{
    [self.delegate customEventInterstitial:self didReceiveAd:nil];
}

- (void)request:(PHAPIRequest *)request didFailWithError:(NSError *)error
{
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)request:(PHPublisherContentRequest *)request contentWillDisplay:(PHContent *)content
{
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)request:(PHPublisherContentRequest *)request contentDidDismissWithType:(PHPublisherContentDismissType *)type
{
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
    
    if(type == PHPublisherApplicationBackgroundTriggeredDismiss)
    {
        [self.delegate customEventInterstitialWillLeaveApplication:self];
    }
}

@end
*/


#pragma mark - OOAdInterstitial_Chartboost -
@interface OOAdInterstitial_Chartboost()<GADCustomEventInterstitial, ChartboostDelegate>
{
    NSString *_placement;
    BOOL _isMoreGame;
}
@end

@implementation OOAdInterstitial_Chartboost

@synthesize delegate;
- (void)dealloc
{
    [Chartboost sharedChartboost].delegate = nil;
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    NSDictionary *dicParam = [self convertToDic:serverParam];
    if(dicParam)
    {
        NSString *token = dicParam[@"id"];
        NSString *secret = dicParam[@"signature"];
        
        Chartboost *cb = [Chartboost sharedChartboost];
        cb.appId = token;
        cb.appSignature = secret;
        cb.autoCacheAds = YES;
        cb.delegate = self;
        
        _placement = CBLocationMainMenu;
        OOAdRequestParams *extras = [self getExtrasForRequest:request delegate:self.delegate];
        _isMoreGame = extras.isMoreGame;
        if (_isMoreGame)
            [cb cacheMoreApps:_placement];
        else
            [cb cacheInterstitial:_placement];
    }
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
    if (_isMoreGame)
        [[Chartboost sharedChartboost] showMoreApps:_placement];
    else
        [[Chartboost sharedChartboost] showInterstitial:_placement];
}

- (BOOL)shouldDisplayInterstitial:(CBLocation)location
{
    [self.delegate customEventInterstitialWillPresent:self];
    //cache
    [[Chartboost sharedChartboost] cacheInterstitial:location];
    
    return YES;
}

- (BOOL)shouldDisplayMoreApps
{
    [self.delegate customEventInterstitialWillPresent:self];
    //cache
    [[Chartboost sharedChartboost] cacheMoreApps:_placement];
    
    return YES;
}

- (void)didCacheInterstitial:(CBLocation)location
{
    [self.delegate customEventInterstitial:self didReceiveAd:nil];
}

- (void)didFailToLoadInterstitial:(CBLocation)location
{
    [self.delegate customEventInterstitial:self didFailAd:nil];
}

- (void)didDismissInterstitial:(CBLocation)location
{
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)didCloseInterstitial:(CBLocation)location
{
    [self didDismissInterstitial:location];
}

- (void)didClickInterstitial:(CBLocation)location
{
    [self didDismissInterstitial:location];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

@end

/*
#pragma mark - OOAdBanner_DoMob -
@interface OOAdBanner_DoMob()<GADCustomEventBanner, GADBannerViewDelegate, DMAdViewDelegate>
{
    DMAdView *adView;
}
@end


@implementation OOAdBanner_DoMob

@synthesize delegate;

- (void)dealloc
{
    adView.delegate = nil;
    adView = nil;
}

- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    if (!adView)
    {
        OOAdRequestParams *extras = [self getExtrasForRequest:request delegate:self.delegate];
        
        NSDictionary *dicParam = [self convertToDic:serverParam];
        NSString *placementId = [self getPlacementIdInDic:dicParam placementName:extras.placement];
        NSString *publisherId = dicParam[@"id"];
        if(!placementId)
            OOAdLog(@"placementId not found");
        
        adView = [[DMAdView alloc] initWithPublisherId:publisherId placementId:placementId size:adSize.size];
        adView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
        [adView setDelegate:self];
        adView.rootViewController = self.delegate.viewControllerForPresentingModalView;
    }
    [adView loadAd];
}

- (void)dmAdViewSuccessToLoadAd:(DMAdView *)view
{
    [self.delegate customEventBanner:self didReceiveAd:adView];
}

- (void)dmAdViewFailToLoadAd:(DMAdView *)adView withError:(NSError *)error
{
    [self.delegate customEventBanner:self didFailAd:error];
}

- (void)dmWillPresentModalViewFromAd:(DMAdView *)view
{
    [self.delegate customEventBannerWillPresentModal:self];
}

- (void)dmDidDismissModalViewFromAd:(DMAdView *)view
{
    [self.delegate customEventBannerWillDismissModal:self];
}

- (void)dmAdViewDidClicked:(DMAdView *)view
{
    [self.delegate customEventBanner:self clickDidOccurInAd:adView];
}

@end



#pragma mark - OOAdInterstitial_DoMob -
@interface OOAdInterstitial_DoMob()<GADCustomEventInterstitial, DMInterstitialAdControllerDelegate>
{
    DMInterstitialAdController *adController;
}
@end

@implementation OOAdInterstitial_DoMob

@synthesize delegate;
- (void)dealloc
{
    [adController.view removeFromSuperview];
    adController.delegate = nil;
    adController = nil;
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    if (!adController)
    {
        OOAdRequestParams *extras = [self getExtrasForRequest:request delegate:self.delegate];
        
        NSDictionary *dicParam = [self convertToDic:serverParam];
        NSString *placementId = [self getPlacementIdInDic:dicParam placementName:extras.placement];
        NSString *publisherId = dicParam[@"id"];
        
        CGSize adSize;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            adSize = DOMOB_AD_SIZE_300x250;
        else
            adSize = DOMOB_AD_SIZE_600x500;
        UIViewController *rootViewController = [OOCommon getRootViewController];
        adController = [[DMInterstitialAdController alloc] initWithPublisherId:publisherId placementId:placementId rootViewController:rootViewController size:adSize];
        adController.shouldHiddenStatusBar = NO;
        [adController setDelegate:self];
    }
    [adController loadAd];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
    [adController present];
}

- (void)dmInterstitialSuccessToLoadAd:(DMInterstitialAdController *)dmInterstitial
{
    [self.delegate customEventInterstitial:self didReceiveAd:nil];
}

- (void)dmInterstitialFailToLoadAd:(DMInterstitialAdController *)dmInterstitial withError:(NSError *)error
{
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)dmInterstitialWillPresentScreen:(DMInterstitialAdController *)dmInterstitial
{
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)dmInterstitialDidDismissScreen:(DMInterstitialAdController *)dmInterstitial
{
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)dmInterstitialWillPresentModalView:(DMInterstitialAdController *)dmInterstitial
{
}

- (void)dmInterstitialDidDismissModalView:(DMInterstitialAdController *)dmInterstitial
{
}

- (void)dmInterstitialDidClicked:(DMInterstitialAdController *)dmInterstitial
{
    [self.delegate customEventInterstitialWillLeaveApplication:self];
    //NOTE:Don't call this. It will lead to adController delloc and access a zombie object.
//    [self.delegate customEventInterstitialWillLeaveApplication:self];
    //hide interstitial
//    [dmInterstitial performSelector:@selector(dmDimmingViewShouldClose) withObject:nil];
}

@end

 

#pragma mark - OOAdBanner_PunchBox -
@interface OOAdBanner_PunchBox()<GADCustomEventBanner, GADBannerViewDelegate, PunchBoxAdDelegate>
{
    
}
@end


@implementation OOAdBanner_PunchBox

@synthesize delegate;

- (void)dealloc
{
    [PunchBoxAd setBannerDelegate:nil];
}

- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
//    static BOOL hasStartSession = NO;
//    if(!hasStartSession)
//    {
//        hasStartSession = YES;
//        
//        NSDictionary *dic = [self convertToDic:serverParam];
//        if(dic)
//        {
//            NSString *key = dic[@"id"];
//            NSString *isGame = dic[@"isGame"];
//            [PunchBoxAd startSession:key forGame:[isGame boolValue]];
//        }
//    }
    
    [PunchBoxAd setBannerDelegate:self];
    [PunchBoxAd isTest:NO];
    
    OOAdExtras *extras = [self getExtrasForRequest:request delegate:self.delegate];
    if(extras.placement)
        [PunchBoxAd requestEventAd:extras.placement withPosition:CGPointMake(0, 0)];
    else
        [PunchBoxAd requestFixedAdWithDelay:0 withPosition:CGPointMake(0, 0)];
}

- (void)punchBoxAdUpdateTheStatus
{
    
}

- (void)didReceived:(UIView *)adView withParameters:(NSDictionary *)parameters
{
    [self.delegate customEventBanner:self didReceiveAd:adView];
}

- (void)didFailWithMessage:(PBADErrorCode )errorCode withParameters:(NSDictionary *)parameters
{
    [self.delegate customEventBanner:self didFailAd:[NSError errorWithDomain:@"PunchBox" code:errorCode userInfo:parameters]];
}

- (void)willDismiss:(UIView *)adView withParameters:(NSDictionary *)parameters
{
    [self.delegate customEventBannerWillDismissModal:self];
}

- (void)adViewWillPresentScreen:(UIView *)adView
{
    [self.delegate customEventBannerWillPresentModal:self];
}

- (void)adViewWillDismissScreen:(UIView *)adView
{
    [self.delegate customEventBannerWillDismissModal:self];
}

- (void)adViewDidDismissScreen:(UIView *)adView
{
    [self.delegate customEventBannerDidDismissModal:self];
}

- (void)adViewWillLeaveApplication:(UIView *)adView
{
    [self.delegate customEventBanner:self clickDidOccurInAd:adView];
}

@end


#pragma mark - OOAdInterstitial_PunchBox -
@interface OOAdInterstitial_PunchBox()<GADCustomEventInterstitial, PunchBoxAdDelegate>
{
    BOOL isMoreGame;
}
@end

@implementation OOAdInterstitial_PunchBox

@synthesize delegate;
- (void)dealloc
{
    [PunchBoxAd setMoreGameDelegate:nil];
}

- (void)_requestInterstitial:(GADCustomEventRequest *)request
{
    OOAdLog(@"moreGameEnabled: %@", [PunchBoxAd moreGameEnabled] ? @"YES" : @"NO");
    OOAdLog(@"moreGameisNew: %@", [PunchBoxAd moreGameisNew] ? @"YES" : @"NO");
    [PunchBoxAd setMoreGameDelegate:self];
    [PunchBoxAd isTest:NO];
    
    UIViewController *rootViewController = [OOCommon getRootViewController];
    OOAdExtras *extras = [self getExtrasForRequest:request delegate:self.delegate];
    isMoreGame = extras.isMoreGame;
    if(isMoreGame)
    {
        [PunchBoxAd showMoreGameViewOnRootView:rootViewController.view animated:YES];
    }
    else
    {
        [PunchBoxAd showFullScreenAdWithRootView:rootViewController.view];
    }
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParam label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    //NOTE: 这个版本只能在 application didFinishLaunchingWithOptions 调用 startSession
//    static BOOL hasStartSession = NO;
//    if(!hasStartSession)
//    {
//        hasStartSession = YES;
//        
//        NSDictionary *dic = [self convertToDic:serverParam];
//        if(dic)
//        {
//            NSString *key = dic[@"id"];
//            NSString *isGame = dic[@"isGame"];
//            [PunchBoxAd startSession:key forGame:[isGame boolValue]];
//            
//            //NOTE:调用 startSession 之后才能调用 showMoreGameViewOnRootView，这个版本存在界面问题
//            return;
////            [self performSelector:@selector(_requestInterstitial:) withObject:request afterDelay:1];
//        }
//    }
//    else
//    {
        [self _requestInterstitial:request];
//    }
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
    
}

//ad banner
- (void)didReceived:(UIView *)adView withParameters:(NSDictionary *)parameters
{
}

- (void)didFailWithMessage:(PBADErrorCode )errorCode withParameters:(NSDictionary *)parameters
{
}

- (void)willDismiss:(UIView *)adView withParameters:(NSDictionary *)parameters
{
}

- (void)adViewWillPresentScreen:(UIView *)adView
{
}

- (void)adViewWillDismissScreen:(UIView *)adView
{
}

- (void)adViewDidDismissScreen:(UIView *)adView
{
}

- (void)adViewWillLeaveApplication:(UIView *)adView
{
}

//MoreGame
- (void)punchBoxAdReceiveMoreGameData
{
    [self.delegate customEventInterstitial:self didReceiveAd:nil];
}

- (void)punchBoxAdMoreGameDataError:(NSError *)error
{
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)punchBoxAdWillShowMoreGameAdView:(UIView *)moreGameView
{
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)punchBoxAdWillCloseMoreGameAdView:(UIView *)moreGameView
{
    [self.delegate customEventInterstitialWillDismiss:self];
}

- (void)punchBoxAdCloseMoreGameAdViewFinished:(UIView *)moreGameView
{
    [self.delegate customEventInterstitialDidDismiss:self];
}

//Interstitial
- (void)punchBoxAdReceiveFullScreenData
{
    [self.delegate customEventInterstitial:self didReceiveAd:nil];
}

- (void)punchBoxAdFullScreenDataError:(NSError *)error
{
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)punchBoxAdWillShowFullScreenAdView:(UIView *)fullScreenView
{
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)punchBoxAdWillCloseFullScreenAdView:(UIView *)fullScreenView
{
    [self.delegate customEventInterstitialWillDismiss:self];
}

- (void)punchBoxAdCloseFullScreenAdViewFinished:(UIView *)fullScreenView
{
    [self.delegate customEventInterstitialDidDismiss:self];
    
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

@end
*/