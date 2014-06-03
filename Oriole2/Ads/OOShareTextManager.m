//
//  OOShareTextManager.m
//  FloatingGallery
//
//  Created by Gary Wong on 1/30/13.
//  Copyright (c) 2013 Oriole2 Ltd. All rights reserved.
//

#import "OOShareTextManager.h"
#import "StandardPaths.h"
#import "GTMObjectSingleton.h"
#import "OOCommon.h"

@implementation OOShareTextManager
@synthesize isRefreshing;

GTMOBJECT_SINGLETON_BOILERPLATE(OOShareTextManager, instance)

#define kShareTextLastRequestDate @"kShareTextLastRequestDate"

#define kAPIVersion @"0.1"
#define kUrlShareText @"http://oriole2.com/Ads/SNSShareTextConfig.php"

#define kUserDefaults_shareImage @"OOSNS_shareImageText"
#define kUserDefaults_shareVideo @"OOSNS_shareVideoText"
#define kUserDefaults_shareText @"OOSNS_shareTextText"
#define kUserDefaults_shareApp @"OOSNS_shareAppText"
#define kUserDefaults_title @"OOSNS_shareTitleText"
#define kUserDefaults_ooMoreApps @"OOSNS_ooMoreApps"
#define kUserDefaults_dicConfig @"OOSNS_dicConfig"

- (id)init
{
    self = [super init];
    if (self)
    {
        _shareApp = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_shareApp];
        if(_shareApp == nil)
            _shareApp = @"";
        _shareImage = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_shareImage];
        if(_shareImage == nil)
            _shareImage = @"";
        _shareVideo = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_shareVideo];
        if(_shareVideo == nil)
            _shareVideo = @"";
        _shareText = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_shareText];
        if(_shareText == nil)
            _shareText = @"";
        _title = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_title];
        if(_title == nil)
            _title = @"";
        _dicMoreApps = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_ooMoreApps];
        _dicConfig = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaults_dicConfig];
    }
    return self;
}

- (void)_log:(NSString *)msg
{
    OOLog(@"OOShareTextManager: %@", msg);
}

- (NSString *)shareImageInstagram
{
    NSString *text = [_dicConfig objectForKey:@"shareImageInstagram"];
    if(text)
        return text;
    else
        return @"";
}

- (void)refreshData
{
    if(self.appid == nil || [self.appid isEqual:@""])
    {
        [self _log:@"appid must be setted."];
        return;
    }
    
    if(isRefreshing)
        return;
    
    if(!_forceReloadInDebug)
    {
        NSDate *date = [DEFAULTS objectForKey:kShareTextLastRequestDate];
        if(date == nil)
        {
            date = [NSDate date];
        }
        else
        {
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [now timeIntervalSinceDate:date];
            interval = fabsf(interval);
            if(interval < 60 * 60 * 12)// 12 hours
                return;
        }
        [DEFAULTS setObject:date forKey:kShareTextLastRequestDate];
        [DEFAULTS synchronize];
    }
    
    //download data in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        isRefreshing = YES;
        [self _downloadData];
    });
}

- (void)_downloadData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?language=%@&appid=%@&version=%@", kUrlShareText , [OOCommon getCurrentLanguage], self.appid, kAPIVersion]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data)
        {
            [self _log:@"_downloadFinished"];
            NSError *error = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if(!error)
            {
                int statusCode = [[dic objectForKey:@"statusCode"] intValue];
                if(statusCode == 200)
                {
                    //update value
                    _shareApp = [dic objectForKey:@"shareApp"];
                    _shareImage = [dic objectForKey:@"shareImage"];
                    _shareVideo = [dic objectForKey:@"shareVideo"];
                    _title = [dic objectForKey:@"title"];
                    _dicMoreApps = [dic objectForKey:@"ooMoreApps"];
                    _dicConfig = dic;
                    
                    //persistence
                    [[NSUserDefaults standardUserDefaults] setValue:_shareApp forKey:kUserDefaults_shareApp];
                    [[NSUserDefaults standardUserDefaults] setValue:_shareImage forKey:kUserDefaults_shareImage];
                    [[NSUserDefaults standardUserDefaults] setValue:_shareVideo forKey:kUserDefaults_shareVideo];
                    [[NSUserDefaults standardUserDefaults] setValue:_shareText forKey:kUserDefaults_shareText];
                    [[NSUserDefaults standardUserDefaults] setValue:_title forKey:kUserDefaults_title];
                    [[NSUserDefaults standardUserDefaults] setValue:_dicMoreApps forKey:kUserDefaults_ooMoreApps];
                    [[NSUserDefaults standardUserDefaults] setValue:_dicConfig forKey:kUserDefaults_dicConfig];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOOShareTextManager_DidUpdateNotification object:self];
                }
            }
            else
            {
                [self _log:[NSString stringWithFormat:@"responseString is not a valid json format, error:%@", error]];
            }
            isRefreshing = NO;
        }
        else
        {
            [self _log:@"_downloadFailed"];
            isRefreshing = NO;
        }
    });
}

@end
