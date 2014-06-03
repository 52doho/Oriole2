//
//  OOAnimation.m
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


#import "OOAnimation.h"


@implementation OOAnimation

#define kHightlightDuration 0.15
#define kFadeDuration 0.15
+ (void)fadeInView:(UIView *)view duration:(double)duration
{
	[UIView animateWithDuration:duration animations:^(void) {
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)fadeInView:(UIView *)view
{
    [self fadeInView:view duration:kFadeDuration];
}

+ (void)fadeOutForView:(UIView *)view duration:(double)duration
{
    [UIView animateWithDuration:duration animations:^(void) {
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)fadeOutForView:(UIView *)view
{
    [self fadeOutForView:view duration:kFadeDuration];
}

static CGFloat kTransitionDuration = 0.3;

+ (void)bounceShowView:(UIView *)subView toScale:(float)scale completion:(void (^)(BOOL finished))completion
{
    subView.transform = CGAffineTransformMakeScale(.0001, .0001);
    
    [UIView animateWithDuration:kTransitionDuration/1.5 animations:^{
        subView.transform = CGAffineTransformMakeScale(scale + 0.1, scale + 0.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kTransitionDuration/1.5 animations:^{
            subView.transform = CGAffineTransformMakeScale(scale - 0.1, scale - 0.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kTransitionDuration/1.5 animations:^{
                subView.transform = CGAffineTransformMakeScale(scale, scale);
            } completion:^(BOOL finished) {
                completion(finished);
            }];
        }];
    }];
}

+ (void)bounceShowView:(UIView *)subView completion:(void (^)(BOOL finished))completion
{
	[OOAnimation bounceShowView:subView toScale:1. completion:completion];
}

+ (void)bounceShowView:(UIView *)subView
{
    [OOAnimation bounceShowView:subView completion:^(BOOL finished) {
        
    }];
}

+ (void)bounceHideView:(UIView *)subView fromScale:(float)scale completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:kTransitionDuration/1.5 animations:^{
        subView.transform = CGAffineTransformMakeScale(scale, scale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kTransitionDuration/2 animations:^{
            subView.transform = CGAffineTransformMakeScale(.0001, .0001);
        } completion:^(BOOL finished) {
            completion(finished);
        }];
    }];
}

+ (void)bounceHideView:(UIView *)subView completion:(void (^)(BOOL finished))completion
{
    [OOAnimation bounceHideView:subView fromScale:1.1 completion:completion];
}

+ (void)bounceHideView:(UIView *)subView
{
    [OOAnimation bounceHideView:subView completion:^(BOOL finished) {
        
    }];
}

+ (void)_hightlightViewShow2:(UIView *)view
{
    [UIView animateWithDuration:kHightlightDuration animations:^(void) {
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)_hightlightViewHide1:(UIView *)view
{
    [UIView animateWithDuration:kHightlightDuration animations:^(void) {
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self _hightlightViewShow2:view];
    }];
}

+ (void)_hightlightViewShow1:(UIView *)view
{
    [UIView animateWithDuration:kHightlightDuration animations:^(void) {
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self _hightlightViewHide1:view];
    }];
}

+ (void)hightlightView:(UIView *)view
{
    [UIView animateWithDuration:kHightlightDuration animations:^(void) {
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self _hightlightViewShow1:view];
    }];
}

+ (void)popUpAnimationForView:(UIView *)view
{
    if(!view)
        return;
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [view.layer addAnimation:animation forKey:@"popup"];
}

@end
