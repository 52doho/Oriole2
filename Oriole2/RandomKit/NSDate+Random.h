//
//  NSDate+Random.h
//  ZEPP
//
//  Created by Guichao Huang (Gary) on 9/21/14.
//  Copyright (c) 2014 Zepp US Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Random)

+ (NSDate *)randomDate;
+ (NSDate *)randomDateBefore:(NSDate *)date;
+ (NSDate *)randomDateAfter:(NSDate *)date;
+ (NSDate *)randomDateFrom:(NSDate *)start to:(NSDate *)end;

@end
