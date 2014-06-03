//
//  OOString+Extend.m
//  Oriole2
//
//  Created by Gary Wong on 11-8-22.
//  Copyright 2011 OO. All rights reserved.
//

#import "OOString+Extend.h"

@implementation NSString(Extend)

- (BOOL)isNotEmpty
{
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0;
}

- (BOOL)isNumberValue
{
    return [self intValue] != 0 || [self isEqualToString:@"0"];
}

- (NSString *)urlEncodedString
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8));
	return result;
}

- (NSString *)urlDecodedString
{
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8));
	return result;	
}

@end
