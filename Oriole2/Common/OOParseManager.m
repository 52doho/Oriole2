//
//  OOParseManager.m
//  CamCool
//
//  Created by Gary Wong on 6/14/14.
//  Copyright (c) 2014 Oriole2 Ltd. All rights reserved.
//

#import <Parse/Parse.h>

#import "OOParseManager.h"
#import "GTMObjectSingleton.h"
#import "OOCommon.h"

@interface OOParseManager()

@property (nonatomic, strong, readonly) PFObject *parseObjectOfShareText;

@end


@implementation OOParseManager

GTMOBJECT_SINGLETON_BOILERPLATE(OOParseManager, instance)

- (void)_getShareTextWithLanguage:(NSString *)language appId:(NSUInteger)appId errorBlock:(OOBlockError)errorBlock
{
    NSParameterAssert(language);
    
    NSString *format = [NSString stringWithFormat:@"language = '%@' AND appId = '%i'", language, appId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    PFQuery *query = [PFQuery queryWithClassName:@"ShareText" predicate:predicate];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            _parseObjectOfShareText = object;
            [_parseObjectOfShareText saveEventually];
        }
        else
        {
            OOLogError(@"get Parse data error:%@", error);
            if (errorBlock) {
                errorBlock(error);
            }
        }
    }];
}

- (void)setupWithParseAppId:(NSString *)appid clientKey:(NSString *)clientKey appId:(NSUInteger)appId
{
    NSParameterAssert(appid);
    NSParameterAssert(clientKey);
    
    [Parse setApplicationId:appid clientKey:clientKey];
    
    [self _getShareTextWithLanguage:[OOCommon getCurrentLanguage] appId:appId errorBlock:^(NSError *error) {
        [self _getShareTextWithLanguage:@"en" appId:appId errorBlock:NULL];
    }];
    
    NSString *format = [NSString stringWithFormat:@"appId = '%i'", appId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    PFQuery *query = [PFQuery queryWithClassName:@"OOMoreApps" predicate:predicate];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            _moreAppsEntity = [[OOMoreAppsEntity alloc] initWithPFObject:object];
        }
        else
        {
            OOLogError(@"get Parse data error:%@", error);
        }
    }];
}

- (NSString *)_getObjectForKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
    NSString *text = _parseObjectOfShareText[key];
    if(text)
        return text;
    else
        return defaultValue;
}

- (NSString *)shareImage
{
    return [self _getObjectForKey:@"shareImage" defaultValue:@""];
}

- (NSString *)shareImageInstagram
{
    return [self _getObjectForKey:@"shareImageInstagram" defaultValue:@""];
}

- (NSString *)shareVideo
{
    return [self _getObjectForKey:@"shareVideo" defaultValue:@""];
}

- (NSString *)shareText
{
    return [self _getObjectForKey:@"shareText" defaultValue:@""];
}

- (NSString *)shareApp
{
    return [self _getObjectForKey:@"shareApp" defaultValue:@""];
}

- (NSString *)shareTitle
{
    return [self _getObjectForKey:@"shareTitle" defaultValue:@""];
}

- (NSString *)instagramUid
{
    return [self _getObjectForKey:@"instagramUid" defaultValue:@"Oriole2"];
}

- (NSString *)moregameText
{
    return [self _getObjectForKey:@"moregameText" defaultValue:@""];
}

@end
