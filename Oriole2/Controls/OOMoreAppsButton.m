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
#import "NSString+TKCategory.h"
#import "LKBadgeView.h"

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

- (void)_downloadConfig
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL *url = [NSURL URLWithString:@"http://120.27.195.105/magento/Oriole2/Oriole2.json"];
//        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *err = nil;
        NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (!err && json) {
            dispatch_main_async_safe(^{
                [self _didLoadConfig:json];
            });
        } else {
            OOLogError(@"下载广告配置错误：%@", err);
        }
    });
}

- (void)_didLoadConfig:(NSDictionary *)json {
    _config = json;
    NSDictionary *appConfig = json[self.configName];
    if (appConfig) {
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
    } else {
        OOLogError(@"%@ name not found", self.configName);
    }
}

- (void)_gotoNextApp {
    NSString *title;
    NSString *badge_text;
    UIColor *badge_color = [UIColor redColor];
    if (_appCurrentIndex >= ((int)_apps.count - 1)) {
        _appCurrentIndex = 0;
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

    badgeView = [[LKBadgeView alloc] init];
    badgeView.textColor = [UIColor whiteColor];
    badgeView.font = [UIFont boldSystemFontOfSize:14];
    badgeView.horizontalAlignment = LKBadgeViewHorizontalAlignmentRight;
    badgeView.outlineWidth = 0;
    [self addSubview:badgeView];
    [self addTarget:self action:@selector(_moreAppsViewTapped) forControlEvents:UIControlEventTouchDown];
    
    [self _downloadConfig];
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

    CGSize size = self.frame.size;
    badgeView.frame = CGRectMake(0, -size.height * 0.6, size.width, size.height);
    
    // set again to SHOW badge
    [self _setBadge:badgeView.text];
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
            NSString *ios_idfa_md5 = [[[OOCommon idfa] md5sum] uppercaseString];
            NSURLComponents *components = [NSURLComponents componentsWithString:_app_callback_url];
            components.queryItems =
            @[
              [NSURLQueryItem queryItemWithName:@"channel" value:[NSString stringWithFormat:@"Oriole2_%@", self.configName]],
              [NSURLQueryItem queryItemWithName:@"os" value:@"iOS"],
              [NSURLQueryItem queryItemWithName:@"ios_idfa_md5" value:ios_idfa_md5],
              [NSURLQueryItem queryItemWithName:@"timestamp" value:[@(timestamp) stringValue]],
              ];
            NSURL *url = components.URL;
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                OOLog(@"点击记录结果：%@", connectionError);
            }];
        }
    }
}

- (void)dealloc
{
    OOLog(@"OOMoreAppsButton dealloc");
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [self _setBadge:[@(OORANDOM(1, 5)) stringValue]];
}

@end
