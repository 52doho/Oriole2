//
//  UIColor+Extend.m
//  Oriole2
//
//  Created by Gary Wong on 3/8/11.
//  Copyright 2011 Oriole2 Ltd. All rights reserved.
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

#import "UIColor+Extend.h"
#import "OOCommon.h"

@implementation UIColor (Extend)

+ (UIColor *)randomColor
{
    CGFloat red = OORANDOM_0_1();
    CGFloat green = OORANDOM_0_1();
    CGFloat blue = OORANDOM_0_1();
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];

    return color;
}

@end
