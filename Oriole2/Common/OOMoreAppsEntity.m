//
//  OOMoreAppsEntity.m
//  Oriole2
//
//  Created by Gary Wong on 6/15/14.
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
        
        PFRelation *appEntities = object[@"appUnions"];
        PFQuery *query = appEntities.query;
        [query includeKey:@"appEntity"];
        [query whereKey:@"order" greaterThanOrEqualTo:@(0)];
        [query orderByAscending:@"order"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error)
            {
                OOLogError(@"get Parse data error:%@", error);
            }
            else
            {
                NSMutableArray *ary = [NSMutableArray array];
                for (PFObject *appUnion in objects) {
                    PFObject *appEntity = appUnion[@"appEntity"];
                    [ary addObject:[[OOAppEntity alloc] initWithPFObject:appEntity]];
                }
                _aryAppEntities = [NSArray arrayWithArray:ary];
                [[NSNotificationCenter defaultCenter] postNotificationName:kOOMoreAppsDidUpdateNotification object:nil];
                
                OOLog(@"get more apps from Parse Success!");
            }
        }];
    }
    return self;
}

@end
