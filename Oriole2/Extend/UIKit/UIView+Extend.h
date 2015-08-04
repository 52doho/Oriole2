//
//  UIView+Extend.h
//  Oriole2
//
//  Created by Gary Wong on 2/12/11.
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

#import <Foundation/Foundation.h>

@interface UIView (Extend)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;

- (void)printViewHierarchy;
- (void)printViewBounds;
- (UIView *)hitTestUnlimitedBound:(CGPoint)point withEvent:(UIEvent *)event;

@end
