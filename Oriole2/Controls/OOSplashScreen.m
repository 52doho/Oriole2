//
//  OOSplashScreen.m
//  Oriole2
//
//  Created by Gary Wong on 11-7-15.
//  Copyright 2011 Oriole2 Ltd. All rights reserved.
//
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

#import "OOSplashScreen.h"
#import "OOCommon.h"

@interface OOSplashScreen(hidden)
- (void)_checkCanFinish;
@end

@implementation OOSplashScreen
@synthesize appImageAnimation, appImageAnimationDuration, appImagePauseDuration, isMainVCLoaded;

- (id)initWithFrame:(CGRect)frame ooImageName:(NSString*)ooImageName appImageName:(NSString*)appImageName appImageAnimation:(OOSplashScreenAnimation)animation appImageAnimationDuration:(float)animationDuration appImagePauseDuration:(float)pauseDuration
{
    self = [super initWithFrame:frame];
    if (self)
    {
        appImageAnimation = animation;
        appImageAnimationDuration = animationDuration;
        appImagePauseDuration = pauseDuration;
        UIImage *appImage = [UIImage imageNamed:appImageName];
        if (appImage)
        {
            appImageView = [[UIImageView alloc] initWithFrame:frame];
            appImageView.image = appImage;
            [self addSubview:appImageView];
        }
        else
            isVSImageHide = YES;
        
        ooImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ooImageName]];
        ooImageView.frame = frame;
        [self addSubview:ooImageView];
        
        if (appImage)
        {
            [UIView animateWithDuration:appImageAnimationDuration animations:^(void) {
                ooImageView.alpha = 0;
            } completion:^(BOOL finished) {
                isVSImageHide = YES;
            }];
        }
        theTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(_checkCanFinish) userInfo:nil repeats:YES];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame appImageName:(NSString*)appImageName
{
    return [self initWithFrame:frame ooImageName:@"Default.png" appImageName:appImageName];
}

- (id)initWithFrame:(CGRect)frame ooImageName:(NSString*)ooImageName appImageName:(NSString*)appImageName
{
    return [self initWithFrame:frame ooImageName:ooImageName appImageName:appImageName appImageAnimation:OOSplashScreenAnimation_FadeOut appImageAnimationDuration:1.5 appImagePauseDuration:0];
}

- (void)_hideAppImageView
{
    [UIView animateWithDuration:appImageAnimationDuration animations:^(void) {
        if (appImageAnimation == OOSplashScreenAnimation_FadeOut)
        {
            self.alpha = 0.0;
        }
        else
        {
            CGRect frame = appImageView.frame;
            appImageView.frame = CGRectMake(frame.origin.x - frame.size.width / 2, frame.origin.y - frame.size.height / 2, frame.size.width * 2, frame.size.height * 2);
            self.alpha = 0.0;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kWillShowMainVCNotification object:nil];
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidShowMainVCNotification object:nil];
        [self removeFromSuperview];
    }];
}

- (void)_hideImageViewAndRemoveSelf:(UIImageView *)imgView
{
    if (imgView == ooImageView)
    {
        [UIView animateWithDuration:appImageAnimationDuration animations:^(void) {
            imgView.alpha = 0.0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kWillShowMainVCNotification object:nil];
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidShowMainVCNotification object:nil];
            [self removeFromSuperview];
        }];
    }
    else
    {
        [self performSelector:@selector(_hideAppImageView) withObject:nil afterDelay:appImagePauseDuration];
    }
    
}
 
- (void)_checkCanFinish
{
    if(isMainVCLoaded && isVSImageHide)
    {
        if (appImageView)
            [self _hideImageViewAndRemoveSelf:appImageView];
        else
            [self _hideImageViewAndRemoveSelf:ooImageView];
        
        [theTimer invalidate];
        theTimer = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    OOLog(@"OOSplashScreen dealloc");
}

@end
