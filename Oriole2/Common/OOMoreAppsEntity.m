//
//  OOMoreAppsEntity.m
//  CamCool
//
//  Created by Gary Wong on 6/15/14.
//  Copyright (c) 2014 Oriole2 Ltd. All rights reserved.
//

#import "OOMoreAppsEntity.h"
#import "OOCommon.h"

@implementation OOAppEntity

- (id)initWithPFObject:(PFObject *)object
{
    self = [super init];
    if (self)
    {
        _appId = [(NSString *)object[@"appId"] integerValue];
        _scheme = object[@"scheme"];
    }
    return self;
}

@end

@implementation OOMoreAppsEntity

- (id)initWithPFObject:(PFObject *)object
{
    self = [super init];
    if (self)
    {
        _secondsFrom = [object[@"secondsFrom"] unsignedIntegerValue];
        _secondsTo = [object[@"secondsTo"] unsignedIntegerValue];
        _artistUrl = object[@"artistUrl"];
        
        PFRelation *appEntities = object[@"appEntities"];
        PFQuery *query = appEntities.query;
        [query whereKey:@"orderIndex" greaterThanOrEqualTo:@(0)];
        [query orderByAscending:@"orderIndex"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error)
            {
                OOLogError(@"get Parse data error:%@", error);
            }
            else
            {
                NSMutableArray *ary = [NSMutableArray array];
                for (PFObject *app in objects) {
                    [ary addObject:[[OOAppEntity alloc] initWithPFObject:app]];
                }
                _aryAppEntities = [NSArray arrayWithArray:ary];
                
                OOLog(@"get more apps from Parse Success!");
            }
        }];
    }
    return self;
}

@end
