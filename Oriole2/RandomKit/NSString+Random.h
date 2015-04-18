//
//  NSString+Random.h
//  ZEPP
//
//  Created by Guichao Huang (Gary) on 9/21/14.
//  Copyright (c) 2014 Zepp US Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSUInteger DEFAULT_LENGTH = 6;

@interface NSString (Random)

+ (NSString *)defaultAlphabet;
+ (NSString *)randomString;
+ (NSString *)randomStringWithLength:(NSUInteger)length;
+ (NSString *)randomStringWithAlphabet:(NSString *)alphabet;
+ (NSString *)randomStringWithAlphabet:(NSString *)alphabet length:(NSUInteger)length;

+ (NSString *)randomEmail;
+ (NSString *)randomEmailWithDomain:(NSString *)domain;
+ (NSString *)randomEmailWithDomain:(NSString *)domain length:(NSUInteger)length;

@end
