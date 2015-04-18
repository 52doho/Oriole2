//
//  NSString+Random.m
//  ZEPP
//
//  Created by Guichao Huang (Gary) on 9/21/14.
//  Copyright (c) 2014 Zepp US Inc. All rights reserved.
//

#import "NSString+Random.h"

@implementation NSString (Random)

+ (NSString *)defaultAlphabet {
	return @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
}

+ (NSString *)randomString {
	return [self randomStringWithAlphabet:[self defaultAlphabet]];
}

+ (NSString *)randomStringWithLength:(NSUInteger)length {
	return [self randomStringWithAlphabet:[self defaultAlphabet] length:length];
}

+ (NSString *)randomStringWithAlphabet:(NSString *)alphabet {
	return [self randomStringWithAlphabet:alphabet length:DEFAULT_LENGTH];
}

+ (NSString *)randomStringWithAlphabet:(NSString *)alphabet length:(NSUInteger)length {
	return [[self alloc] initWithAlphabet:alphabet length:length];
}

- (id)initWithDefaultAlphabet {
	return [self initWithAlphabet:[NSString defaultAlphabet]];
}

- (id)initWithAlphabet:(NSString *)alphabet {
	return [self initWithAlphabet:alphabet length:DEFAULT_LENGTH];
}

- (id)initWithAlphabet:(NSString *)alphabet length:(NSUInteger)length {
	NSMutableString *string = [NSMutableString stringWithCapacity:length];

	for (NSUInteger i = 0; i < length; i++) {
		u_int32_t r = arc4random() % [alphabet length];
		unichar c = [alphabet characterAtIndex:r];
		[string appendFormat:@"%C", c];
	}

	self = [[NSString alloc] initWithString:string];
	return self;
}

+ (NSString *)randomEmail {
	return [self randomEmailWithDomain:[self randomStringWithLength:DEFAULT_LENGTH] length:DEFAULT_LENGTH];
}

+ (NSString *)randomEmailWithDomain:(NSString *)domain {
	return [self randomEmailWithDomain:domain length:DEFAULT_LENGTH];
}

+ (NSString *)randomEmailWithDomain:(NSString *)domain length:(NSUInteger)length {
	NSString *email = [NSString stringWithFormat:@"%@@%@.com", [self randomStringWithLength:length], domain];

	return email;
}

@end
