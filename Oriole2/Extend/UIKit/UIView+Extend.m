//
//  UIView+Extend.m
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

#import "UIView+Extend.h"

@implementation UIView (KalAdditions)

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;

    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;

    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y
{
    CGRect frame = self.frame;

    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;

    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;

    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;

    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint c = self.center;

    c.x = centerX;
    self.center = c;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint c = self.center;

    c.y = centerY;
    self.center = c;
}

- (void)_printView:(UIView *)view withLevel:(uint)level
{
    // TODO:how to print level?
    NSLog(@"{%i}\t top:%.0f\t left:%.0f\t bottom:%.0f\t right:%.0f", level, view.top, view.left, view.bottom, view.right);

    for (UIView *subView in [view subviews]) {
        [self _printView:subView withLevel:0];
    }
}

- (void)printViewHierarchy
{
#ifdef DEBUG
        for (UIView *subView in [self subviews]) {
            [self _printView:subView withLevel:0];
        }
#endif
}

- (void)printViewBounds
{
    //	OOLog(@"left:%f, top:%f, width:%f, height:%f", self.left, self.top, self.width, self.height);
}

- (UIView *)_hitTestUnlimitedBound:(CGPoint)point withEvent:(UIEvent *)event withView:(UIView *)view
{
    for (UIView *subView in view.subviews) {
        if ((subView.alpha > .01f) && !subView.hidden) {
            CGPoint p1 = CGPointMake(point.x - subView.frame.origin.x, point.y - subView.frame.origin.y);

            if ([subView pointInside:p1 withEvent:event]) {
                return [self _hitTestUnlimitedBound:p1 withEvent:event withView:subView];
            }
        }
    }

    if ([view pointInside:point withEvent:event]) {
        return view;
    } else {
        return nil;
    }
}

- (UIView *)hitTestUnlimitedBound:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self _hitTestUnlimitedBound:point withEvent:event withView:self];
}

@end
