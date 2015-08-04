//
//  OOParseManager.h
//  Oriole2
//
//  Created by Gary Wong on 6/14/14.
//  Copyright (c) 2014 Oriole2 Ltd. All rights reserved.
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

#import "OOMoreAppsEntity.h"

@interface OOParseManager : NSObject

@property (nonatomic, strong, readonly) NSString         *shareImage, *shareImageInstagram, *shareVideo, *shareText, *shareApp, *shareTitle, *instagramUid, *moregameText;
@property (nonatomic, strong, readonly) OOMoreAppsEntity *moreAppsEntity;

@property (nonatomic, assign, readonly) BOOL       interstitial_showAtLaunch;
@property (nonatomic, assign, readonly) NSUInteger interstitial_maxShowPerHour;

+ (instancetype)instance;

- (void)setupWithParseAppId:(NSString *)appid clientKey:(NSString *)clientKey appId:(NSUInteger)appId;

@end
