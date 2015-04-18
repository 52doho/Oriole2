//
//  NSDate+Random.m
//  ZEPP
//
//  Created by Guichao Huang (Gary) on 9/21/14.
//  Copyright (c) 2014 Zepp US Inc. All rights reserved.
//

#import "NSDate+Random.h"
#import "NSNumber+Random.h"

@implementation NSDate (Random)

+ (NSDate *)randomDate {
	NSTimeInterval secs = [NSNumber randomFloat];

	return [NSDate dateWithTimeIntervalSince1970:secs];
}

+ (NSDate *)randomDateBefore:(NSDate *)date {
	NSTimeInterval secs = [date timeIntervalSince1970] - [NSNumber randomFloat];

	return [NSDate dateWithTimeIntervalSince1970:secs];
}

+ (NSDate *)randomDateAfter:(NSDate *)date {
	NSTimeInterval secs = [date timeIntervalSince1970] + [NSNumber randomFloat];

	return [NSDate dateWithTimeIntervalSince1970:secs];
}

+ (NSDate *)randomDateFrom:(NSDate *)start to:(NSDate *)end {
	NSTimeInterval secs = [NSNumber randomFloatFrom:[start timeIntervalSince1970] to:[end timeIntervalSince1970]];

	return [NSDate dateWithTimeIntervalSince1970:secs];
}

@end
