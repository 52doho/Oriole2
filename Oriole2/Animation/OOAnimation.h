//
//  OOAnimation.h
//  Oriole2
//
//  Created by Gary Wong on 8/10/11.
//  Copyright 2010 Oriole2 Ltd. All rights reserved.
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
#import <QuartzCore/QuartzCore.h>


@interface OOAnimation : NSObject
{

}

+ (void)fadeInView:(UIView *)view;
+ (void)fadeInView:(UIView *)view duration:(double)duration;
+ (void)fadeOutForView:(UIView *)view;

+ (void)bounceShowView:(UIView *)subView;
+ (void)bounceShowView:(UIView *)subView completion:(void (^)(BOOL finished))completion;
+ (void)bounceShowView:(UIView *)subView toScale:(float)scale completion:(void (^)(BOOL finished))completion;

+ (void)bounceHideView:(UIView *)subView;
+ (void)bounceHideView:(UIView *)subView completion:(void (^)(BOOL finished))completion;
+ (void)bounceHideView:(UIView *)subView fromScale:(float)scale completion:(void (^)(BOOL finished))completion;

+ (void)hightlightView:(UIView *)view;

+ (void)popUpAnimationForView:(UIView *)view;

@end
