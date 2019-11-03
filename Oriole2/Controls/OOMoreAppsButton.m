//
//  OOMoreAppsButton.m
//  BeehiveWeather
//
//  Created by Gary Wong on 6/13/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
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

#import "OOMoreAppsButton.h"
#import "OOCommon.h"
#import "OOAd.h"
#import "UIColor+Extend.h"
#import "LKBadgeView.h"

#import <Firebase/Firebase.h>

@interface OOMoreAppsButton ()<GADInterstitialDelegate>
{
    NSDictionary *_config;
    BOOL _is_show_interstitial;
    NSArray *_apps;
    int _appCurrentIndex;
    NSString *_interstitial_id;
    LKBadgeView *badgeView;
}

@end

@implementation OOMoreAppsButton

- (void)_setBadge:(NSString *)badge {
    if (![badge isKindOfClass:[NSString class]]) {
        badge = [NSString stringWithFormat:@"%@", badge];
    }
    if([badge isEqual: @"0"] || !badge) {
        badgeView.hidden = YES;
    } else {
        badgeView.hidden = NO;
        badgeView.text = badge ?: [@((int)OORANDOM(2, 10)) stringValue];
    }
}

- (void)_gotoInterstitial {
    _is_show_interstitial = true;
    [self _showSelf:NO];
    
    NSString *title = _config[@"interstitial"][@"title"];
    NSString *badge_text = _config[@"interstitial"][@"badge_text"];
    UIColor *badge_color = [UIColor colorFromHexString:_config[@"interstitial"][@"badge_color"]];
    if (!badge_color) {
        badge_color = [UIColor redColor];
    }
    [self setTitle:title forState:UIControlStateNormal];
    [self _setBadge:badge_text];
    badgeView.badgeColor = badge_color;
    [[OOAd instance] cacheInterstitialOfMoreAppsWithMediationID:_interstitial_id delegate:self];
}

- (void)_gotoNextApp {
    NSString *title;
    NSString *badge_text;
    UIColor *badge_color = [UIColor redColor];
    _appCurrentIndex++;
    if (_appCurrentIndex > ((int)_apps.count - 1)) {
        [self _gotoInterstitial];
        return;// 所有 app 已显示，显示 admob 广告
    }
    
    for (; _appCurrentIndex < _apps.count; _appCurrentIndex++) {
        id appConfig = _apps[_appCurrentIndex];
        BOOL disabled = [appConfig[@"disabled"] boolValue];
        if (disabled) {
            continue;
        }
        
        NSString *scheme = appConfig[@"scheme"];
        if (scheme.length > 0) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]]) {
                continue;// has been installed
            }
        }
        title = appConfig[@"title"];
        badge_text = appConfig[@"badge_text"];
        UIColor *color = [UIColor colorFromHexString:appConfig[@"badge_color"]];
        if (color) {
            badge_color = color;
        }
        break;
    }
    [self setTitle:title forState:UIControlStateNormal];
    [self _setBadge:badge_text];
    badgeView.badgeColor = badge_color;
    if (!title) {
        [self _gotoInterstitial];
    }
}

- (void)_setDefault
{
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    _appCurrentIndex = -1;
    badgeView = [[LKBadgeView alloc] init];
    badgeView.textColor = [UIColor whiteColor];
    badgeView.badgeColor = [UIColor clearColor];
    badgeView.font = [UIFont boldSystemFontOfSize:12];
    badgeView.horizontalAlignment = LKBadgeViewHorizontalAlignmentRight;
    badgeView.outlineWidth = 0;
    [self _setBadge:@""];
    [self addSubview:badgeView];
    [self addTarget:self action:@selector(_moreAppsViewTapped) forControlEvents:UIControlEventTouchDown];
}

- (void)setConfig:(NSDictionary *)config {
    _config = config;
    BOOL disabled = [config[@"disabled"] boolValue];
    self.hidden = disabled;
    
    _is_show_interstitial = [config[@"is_show_interstitial"] boolValue];
    _interstitial_id = _config[@"interstitial"][@"id"];
    _apps = config[@"apps"];
    [self _gotoNextApp];
}

+ (id)button {
    return [[OOMoreAppsButton alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        [self _setDefault];
    }

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _setDefault];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UILabel *label = nil;
    for (UIView *subView in [self subviews]) {
        if ([subView isKindOfClass:[UILabel class]]) {
            label = (UILabel *)subView;
        }
    }
    CGSize size = self.frame.size;
    CGFloat height = 22;
    badgeView.frame = CGRectMake(0, label.frame.origin.y - height, size.width, height);
    label.frame = CGRectMake(size.width - label.frame.size.width, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
    
    // set again to SHOW badge
    badgeView.text = badgeView.text;
}

- (BOOL)_isWebUrl:(NSString *)str {
    return str.length > 0 && [str rangeOfString:@"http"].location == 0;
}

- (void)_moreAppsViewTapped
{
    if (_appCurrentIndex < _apps.count) {
        NSDictionary *config = _apps[_appCurrentIndex];
        
        UIViewController *topmostViewController = [OOCommon getTopmostViewController];
        NSUInteger appId = [config[@"app_id"] integerValue];
        if (appId > 0 && topmostViewController) {
            [OOCommon openInAppStoreWithID:appId viewController:topmostViewController];
        } else {
            NSString *url = config[@"url"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url ?:@"itms-apps://itunes.apple.com/us/artist/oriole2-co.-ltd./id506665225?mt=8"]];
        }
        
        [self performSelector:@selector(_gotoNextApp) withObject:nil afterDelay:2];
                
        NSString *scheme = config[@"scheme"] ?: @"";
        [FIRAnalytics logEventWithName:@"MoreApps_Oriole2" parameters:@{@"scheme": scheme}];
    } else {
        [self _showSelf:NO];
        [[OOAd instance] showInterstitialOfMoreAppsWithMediationID:_interstitial_id delegate:self];
        [FIRAnalytics logEventWithName:@"MoreApps_Interstitial" parameters:@{}];
    }
}

#pragma mark - GADInterstitialDelegate
- (void)_showSelf:(BOOL)show {
    [UIView animateWithDuration:kDefaultAnimateDuration animations:^{
        self.alpha = show ? 1 : 0;
    }];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [self _setBadge:[@((int)OORANDOM(1, 5)) stringValue]];
    [self _showSelf:YES];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [self _showSelf:NO];
}

@end



#pragma mark - OOInstagramButton
@interface OOInstagramButton ()
{
    NSString *_instagramId, *_instagramName;
}

@end

@implementation OOInstagramButton

- (void)_setDefault
{
    _showText = YES;
    self.hidden = ![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]];
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self setImage:[UIImage imageNamed:@"instagram.png"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(_instagramButtonTapped) forControlEvents:UIControlEventTouchDown];
    
    [self _didDownloadOOAdConfig];
}

- (void)_didDownloadOOAdConfig {
    _instagramId = @"o2apps";
    _instagramName = @"O2 Games";
    if (self.showText) {
        [self setTitle:_instagramName forState:UIControlStateNormal];
    }
}

+ (id)button {
    return [[OOInstagramButton alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _setDefault];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _setDefault];
}

- (void)setShowText:(BOOL)showText {
    _showText = showText;
    if (!showText) {
        CGFloat length = kIsiPad ? 55 : 33;
        [self setTitle:nil forState:UIControlStateNormal];
        self.bounds = CGRectMake(0, 0, length, length);
    }
}

- (void)_instagramButtonTapped
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", _instagramId]]];
    
    [FIRAnalytics logEventWithName:@"Instagram_button" parameters:@{@"account":_instagramId}];
}

@end
