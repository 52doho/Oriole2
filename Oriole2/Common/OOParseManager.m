//
//  OOParseManager.m
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

#import <Parse/Parse.h>

#import "OOParseManager.h"
#import "GTMObjectSingleton.h"
#import "OOCommon.h"
#import "StandardPaths.h"

@interface PFObject (extensions)
-(void) encodeWithCoder:(NSCoder *) encoder;
-(id) initWithCoder:(NSCoder *) aDecoder;
@end
@interface PFACL (extensions)
-(void) encodeWithCoder:(NSCoder *) encoder;
-(id) initWithCoder:(NSCoder *) aDecoder;
@end


@implementation PFObject (extension)
#pragma mark - NSCoding compliance
#define kPFObjectAllKeys @"___PFObjectAllKeys"
#define kPFObjectClassName @"___PFObjectClassName"
#define kPFObjectObjectId @"___PFObjectId"
#define kPFACLPermissions @"permissionsById"
- (void)encodeWithCoder:(NSCoder *) encoder{
    
    [encoder encodeObject:[self parseClassName] forKey:kPFObjectClassName];
    [encoder encodeObject:[self objectId] forKey:kPFObjectObjectId];
    [encoder encodeObject:[self allKeys] forKey:kPFObjectAllKeys];
    for (NSString * key in [self allKeys]) {
        [encoder  encodeObject:self[key] forKey:key];
    }
}

- (id)initWithCoder:(NSCoder *) aDecoder{
    NSString * aClassName  = [aDecoder decodeObjectForKey:kPFObjectClassName];
    NSString * anObjectId = [aDecoder decodeObjectForKey:kPFObjectObjectId];
    
    self = [PFObject objectWithoutDataWithClassName:aClassName objectId:anObjectId];
    
    if (self) {
        NSArray * allKeys = [aDecoder decodeObjectForKey:kPFObjectAllKeys];
        for (NSString * key in allKeys) {
            id obj = [aDecoder decodeObjectForKey:key];
            if (obj) {
                self[key] = obj;
            }
        }
    }
    return self;
}
@end

@implementation PFACL (extension)
- (void)encodeWithCoder:(NSCoder *) encoder{
    [encoder encodeObject:[self valueForKey:kPFACLPermissions] forKey:kPFACLPermissions];
}

- (id)initWithCoder:(NSCoder *) aDecoder{
    self = [super init];
    if (self) {
        [self setValue:[aDecoder decodeObjectForKey:kPFACLPermissions] forKey:kPFACLPermissions];
    }
    return self;
}
@end




@interface OOParseManager()
{
    BOOL _interstitial_showAtLaunch;
    NSUInteger _interstitial_maxShowPerHour;
}
@property (nonatomic, strong, readonly) PFObject *parseObjectOfShareText;

@end


@implementation OOParseManager

GTMOBJECT_SINGLETON_BOILERPLATE(OOParseManager, instance)

- (id)init
{
    self = [super init];
    if (self) {
        _interstitial_showAtLaunch = NO;
        _interstitial_maxShowPerHour = 2;
        
        NSString *path = [self _getLocalPersistancePath];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            NSData *data = [[NSMutableData alloc] initWithContentsOfFile:path];
            _parseObjectOfShareText = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return self;
}

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
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_parseObjectOfShareText];
            [data writeToFile:[self _getLocalPersistancePath] atomically:YES];
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
    
    [_parseObjectOfShareText fetchIfNeeded];
    
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

- (NSString *)_getLocalPersistancePath
{
    return [[[NSFileManager defaultManager] offlineDataPath] stringByAppendingPathComponent:@"parseObjectOfShareText"];
}

- (NSString *)_getObjectForKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
    if ([_parseObjectOfShareText isDataAvailable]) {
        NSString *text = _parseObjectOfShareText[key];
        if(text)
            return text;
        else
            return defaultValue;
    } else {
        [_parseObjectOfShareText fetchIfNeeded];
        return defaultValue;
    }
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
    return [self _getObjectForKey:@"moregameText" defaultValue:@"Games"];
}

- (BOOL)interstitial_showAtLaunch
{
    NSNumber *num = _parseObjectOfShareText[@"interstitial_showAtLaunch"];
    if (num)
        return [num boolValue];
    else
        return _interstitial_showAtLaunch;
}

- (NSUInteger)interstitial_maxShowPerHour
{
    NSNumber *num = _parseObjectOfShareText[@"interstitial_maxShowPerHour"];
    if (num)
        return [num unsignedIntegerValue];
    else
        return _interstitial_maxShowPerHour;
}

@end
