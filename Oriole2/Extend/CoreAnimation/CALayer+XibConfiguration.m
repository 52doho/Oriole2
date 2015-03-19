//
//  CALayer+XibConfiguration.m
//  Oriole2
//
//  Created by Gary Wong on 12/1/14.
//  Copyright 2014 Oriole2 Ltd. All rights reserved.
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

#import "CALayer+XibConfiguration.h"
#import "OOGeometry+Extend.h"
#import <objc/runtime.h>

@implementation CALayer (XibConfiguration)

- (void)setBorderUIColor:(UIColor *)color {
	self.borderColor = color.CGColor;
}

- (UIColor *)borderUIColor {
	return [UIColor colorWithCGColor:self.borderColor];
}

@end


@implementation UIView (XibConfiguration)

static char kRotateAngle;

- (void)setBackgroundUIColor:(UIColor *)backgroundUIColor {
    self.backgroundColor = backgroundUIColor;
}

- (UIColor *)backgroundUIColor {
    return self.backgroundColor;
}

- (void)setRotateAngle:(CGFloat)rotateAngle {
    [self willChangeValueForKey:@"rotateAngle"];
    
    objc_setAssociatedObject(self, &kRotateAngle, @(rotateAngle), OBJC_ASSOCIATION_ASSIGN);
    self.transform = CGAffineTransformRotate(self.transform, degrees2Radian(rotateAngle));
    
    [self didChangeValueForKey:@"rotateAngle"];
}

- (CGFloat)rotateAngle {
    return [objc_getAssociatedObject(self, &kRotateAngle) floatValue];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    self.layer.anchorPoint = anchorPoint;
    
    CGFloat tx = (anchorPoint.x - 0.5) * self.bounds.size.width;
    CGFloat ty = (0.5 - anchorPoint.y) * self.bounds.size.height;
    self.transform = CGAffineTransformTranslate(self.transform, tx, ty);
}

- (CGPoint)anchorPoint {
    return self.layer.anchorPoint;
}

@end
