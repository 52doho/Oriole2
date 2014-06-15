//
//  OOMoreAppsEntity.h
//  CamCool
//
//  Created by Gary Wong on 6/15/14.
//  Copyright (c) 2014 Oriole2 Ltd. All rights reserved.
//

#import <Parse/Parse.h>

#define kOOMoreAppsDidUpdateNotification @"kOOMoreAppsDidUpdateNotification"
#define kOOCommonParseAppId @"AmPG4AQ5dLDFPydmdM8KkY7uM7KCWe4JRX9FzDpt"
#define kOOCommonParseClientKey @"U3g1oOPmYZuQRnZtE766BJc3Aaia4B7X1INnMbzx"

@interface OOAppEntity : NSObject

@property (nonatomic, assign, readonly) NSUInteger appId;
@property (nonatomic, strong, readonly) NSString *scheme;

- (id)initWithPFObject:(PFObject *)object;

@end

@interface OOMoreAppsEntity : NSObject

@property (nonatomic, assign, readonly) NSUInteger secondsFrom, secondsTo;
@property (nonatomic, strong, readonly) NSString *artistUrl;
@property (nonatomic, strong, readonly) NSArray *aryAppEntities;

- (id)initWithPFObject:(PFObject *)object;

@end
