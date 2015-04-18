//
//  NSNumber+Random.h
//  ZEPP
//
//  Created by Guichao Huang (Gary) on 9/21/14.
//  Copyright (c) 2014 Zepp US Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSNumber (Random)

+ (CGFloat)randomFloat;
+ (CGFloat)randomFloatFrom:(CGFloat)start to:(CGFloat)end;

+ (NSInteger)randomInteger;
+ (NSInteger)randomIntegerFrom:(NSInteger)start to:(NSInteger)end;
// length is [0 ~ 9] for 32bit, [0 ~ 11] for 64bit
+ (NSInteger)randomIntegerWithLength:(NSInteger)length;

+ (NSUInteger)randomUInteger;
+ (NSUInteger)randomUIntegerWithLength:(NSUInteger)length;
+ (NSUInteger)randomUIntegerFrom:(NSUInteger)start to:(NSUInteger)end;

+ (BOOL)randomBOOL;

@end
