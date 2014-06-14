//
//  OOParseManager.h
//  CamCool
//
//  Created by Gary Wong on 6/14/14.
//  Copyright (c) 2014 Oriole2 Ltd. All rights reserved.
//

#import "OOMoreAppsEntity.h"

@interface OOParseManager : NSObject

@property (nonatomic, strong, readonly) NSString *shareImage, *shareImageInstagram, *shareVideo, *shareText, *shareApp, *shareTitle, *instagramUid, *moregameText;
@property (nonatomic, strong, readonly) OOMoreAppsEntity *moreAppsEntity;

+ (OOParseManager *)instance;

- (void)setupWithParseAppId:(NSString *)appid clientKey:(NSString *)clientKey appId:(NSUInteger)appId;

@end
