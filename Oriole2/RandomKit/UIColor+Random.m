//
//  UIColor+Random.m
//  ZEPP
//
//  Created by Guichao Huang (Gary) on 9/21/14.
//  Copyright (c) 2014 Zepp US Inc. All rights reserved.
//

#import "UIColor+Random.h"
#import "NSNumber+Random.h"

@implementation UIColor (Random)

+ (UIColor *)randomColor {
	return [self randomColorWithAlpha:1];
}

+ (UIColor *)randomColorWithAlpha:(CGFloat)alpha {
	CGFloat red = [NSNumber randomFloatFrom:0 to:1];
	CGFloat green = [NSNumber randomFloatFrom:0 to:1];
	CGFloat blue = [NSNumber randomFloatFrom:0 to:1];
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];

	return color;
}

@end
