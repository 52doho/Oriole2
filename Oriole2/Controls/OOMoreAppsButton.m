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
#import <Crashlytics/Crashlytics.h>

@interface OOMoreAppsButton ()<GADInterstitialDelegate>
{
    NSDictionary *_config;
    BOOL _is_show_interstitial;
    NSArray *_apps;
    NSUInteger _appCurrentIndex;
    NSString *_app_callback_url;
    NSString *_interstitial_id;
    LKBadgeView *badgeView;
}

@end

@implementation OOMoreAppsButton

- (void)_setBadge:(NSString *)badge {
    if([badge isEqual: @"0"]) {
        badgeView.hidden = YES;
    } else {
        badgeView.hidden = NO;
        badgeView.text = badge ?: [@((int)OORANDOM(2, 10)) stringValue];
    }
}

- (void)_gotoNextApp {
    NSString *title;
    NSString *badge_text;
    UIColor *badge_color = [UIColor redColor];
    if (_appCurrentIndex >= ((int)_apps.count - 1)) {
        _appCurrentIndex = 0;
        if (_interstitial_id.length > 0) {
            _is_show_interstitial = true;
            return;// 所有 app 已显示，显示 admob 广告
        }
    }
    
    for (NSUInteger i = _appCurrentIndex; i < _apps.count; i++) {
        BOOL disabled = [_apps[i][@"disabled"] boolValue];
        if (disabled) {
            continue;
        }
        
        NSString *scheme = _apps[i][@"scheme"];
        if (scheme.length > 0) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]]) {
                continue;// has been installed
            }
        }
        title = _apps[i][@"title"];
        badge_text = _apps[i][@"badge_text"];
        UIColor *color = [UIColor colorFromHexString:_apps[i][@"badge_color"]];
        if (color) {
            badge_color = color;
        }
        
        _appCurrentIndex = i;
        break;
    }
    [self setTitle:title forState:UIControlStateNormal];
    [self _setBadge:badge_text];
    badgeView.badgeColor = badge_color;
}

- (void)_setDefault
{
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    badgeView = [[LKBadgeView alloc] init];
    badgeView.textColor = [UIColor whiteColor];
    badgeView.badgeColor = [UIColor clearColor];
    badgeView.font = [UIFont boldSystemFontOfSize:14];
    badgeView.horizontalAlignment = LKBadgeViewHorizontalAlignmentRight;
    badgeView.outlineWidth = 0;
    [self _setBadge:@""];
    [self addSubview:badgeView];
    [self addTarget:self action:@selector(_moreAppsViewTapped) forControlEvents:UIControlEventTouchDown];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didDownloadOOAdConfig:) name:@"kDidDownloadOOAdConfig" object:nil];
}

- (void)_didDownloadOOAdConfig:(NSNotification *)notification {
    NSDictionary *appConfig = notification.object;
    if ([appConfig isKindOfClass:[NSDictionary class]]) {
        BOOL disabled = [appConfig[@"download_button"][@"disabled"] boolValue];
        self.hidden = disabled;
        
        _app_callback_url = appConfig[@"download_button"][@"app_callback_url"];
        _is_show_interstitial = [appConfig[@"download_button"][@"is_show_interstitial"] boolValue];
        if (_is_show_interstitial) {
            NSString *title = appConfig[@"download_button"][@"interstitial"][@"title"];
            NSString *badge_text = appConfig[@"download_button"][@"interstitial"][@"badge_text"];
            UIColor *badge_color = [UIColor colorFromHexString:appConfig[@"download_button"][@"interstitial"][@"badge_color"]];
            if (!badge_color) {
                badge_color = [UIColor redColor];
            }
            [self setTitle:title forState:UIControlStateNormal];
            [self _setBadge:badge_text];
            badgeView.badgeColor = badge_color;
            _interstitial_id = appConfig[@"download_button"][@"interstitial"][@"id"];
        } else {
            _apps = appConfig[@"download_button"][@"apps"];
            [self _gotoNextApp];
        }
    }
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
    if (_is_show_interstitial) {
        [[OOAd instance] showInterstitialOfMoreAppsWithMediationID:_interstitial_id delegate:self];
    } else {
        NSDictionary *appConfig = _apps[_appCurrentIndex];
        
        UIViewController *topmostViewController = [OOCommon getTopmostViewController];
        NSUInteger appId = [appConfig[@"app_id"] integerValue];
        
        if (appId > 0 && topmostViewController) {
            [OOCommon openInAppStoreWithID:appId viewController:topmostViewController];
        } else {
            NSString *url = appConfig[@"url"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url ?:@"itms-apps://itunes.apple.com/us/artist/oriole2-co.-ltd./id506665225?mt=8"]];
        }
        
        _appCurrentIndex++;
        [self performSelector:@selector(_gotoNextApp) withObject:nil afterDelay:2];
        
        if ([self _isWebUrl:_app_callback_url]) {
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
            NSString *app_name = _config[@"app_name"];
            NSDictionary *params = @{
                                     @"channel":[NSString stringWithFormat:@"Oriole2_%@", app_name],
                                     @"timestamp":[@(timestamp) stringValue],
                                     @"device_id":[OOCommon deviceId],
                                     @"ios_idfa":[OOCommon idfa],
                                     @"ios_idfa_md5":[OOCommon idfa_md5],
                                     @"device_model":[OOCommon deviceModel],
                                     @"device_brand":[OOCommon deviceBrand],
                                     @"device_name":[OOCommon deviceName],
                                     @"country":[OOCommon deviceCountry],
                                     @"locale":[OOCommon deviceLocale],
                                     @"system_version":[OOCommon systemVersion],
                                     @"system_name":[OOCommon systemName],
                                     @"app_version":[OOCommon appVersion],
                                     @"timezone":[OOCommon timezone],
                                     };
            NSURL *url = [OOCommon buildQueryUrl:_app_callback_url params:params];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                OOLog(@"点击记录结果：%@", connectionError);
            }];
        }
    }
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [self _setBadge:[@(OORANDOM(1, 5)) stringValue]];
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
    [self addTarget:self action:@selector(_moreAppsViewTapped) forControlEvents:UIControlEventTouchDown];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didDownloadOOAdConfig:) name:@"kDidDownloadOOAdConfig" object:nil];
}

- (void)_didDownloadOOAdConfig:(NSNotification *)notification {
    NSDictionary *appConfig = notification.object;
    if ([appConfig isKindOfClass:[NSDictionary class]]) {
        _instagramId = appConfig[@"instagram"][@"id"];
        _instagramName = appConfig[@"instagram"][@"name"];
        if (_instagramId.length == 0) {
            _instagramId = @"o2apps";
        }
        if (self.showText) {
            [self setTitle:_instagramName forState:UIControlStateNormal];
        }
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

- (void)_moreAppsViewTapped
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", _instagramId]]];
    
    [Answers logCustomEventWithName:@"Instagram button" customAttributes:@{@"account":_instagramId}];
}

@end
