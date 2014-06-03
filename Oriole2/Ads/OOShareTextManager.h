//
//  OOShareTextManager.h
//  FloatingGallery
//
//  Created by Gary Wong on 1/30/13.
//  Copyright (c) 2013 Oriole2 Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOOShareTextManager_DidUpdateNotification @"kOOShareTextManager_DidUpdateNotification"
@interface OOShareTextManager : NSObject
{
    
}

@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong, readonly) NSString *shareImage, *shareImageInstagram, *shareVideo, *shareText, *shareApp, *title;
@property (nonatomic, strong, readonly) NSDictionary *dicConfig, *dicMoreApps;
@property (nonatomic, assign, readonly) BOOL isRefreshing;
@property(nonatomic, assign) BOOL forceReloadInDebug;

+ (OOShareTextManager *)instance;

- (void)refreshData;
@end
