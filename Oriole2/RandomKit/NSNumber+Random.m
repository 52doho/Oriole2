//
//  NSNumber+Random.m
//  ZEPP
//
//  Created by Guichao Huang (Gary) on 9/21/14.
//  Copyright (c) 2014 Zepp US Inc. All rights reserved.
//

#import "NSNumber+Random.h"

@implementation NSNumber (Random)

+ (CGFloat)randomFloat {
	CGFloat ret = arc4random() % RAND_MAX;

	return ret;
}

+ (CGFloat)randomFloatFrom:(CGFloat)start to:(CGFloat)end {
	CGFloat min = MIN(start, end);
	CGFloat max = MAX(start, end);
	float ret = (arc4random() % RAND_MAX) / (RAND_MAX * 1.0) * (max - min) + min;

	return ret;
}

+ (NSInteger)randomInteger {
	return [self randomFloat];
}

+ (NSInteger)randomIntegerWithLength:(NSInteger)length {
	length = abs(length);
	NSInteger maxLength;
#if __LP64__
	maxLength = 11;
#else
	maxLength = 9;
#endif
	if (length > maxLength)
		length = maxLength;
	return [self randomIntegerFrom:-powf(10, length) to:powf(10, length)];
}

+ (NSInteger)randomIntegerFrom:(NSInteger)start to:(NSInteger)end {
	return [self randomFloatFrom:start to:end];
}

+ (NSUInteger)randomUInteger {
	return abs([self randomFloat]);
}

+ (NSUInteger)randomUIntegerWithLength:(NSUInteger)length {
	if (length > 11)
		length = 11;
	return [self randomUIntegerFrom:0 to:powf(10, length)];
}

+ (NSUInteger)randomUIntegerFrom:(NSUInteger)start to:(NSUInteger)end {
	return [self randomFloatFrom:start to:end];
}

+ (BOOL)randomBOOL {
	return (arc4random() % 2 - 1) > 0 ? YES : NO;
}

@end
