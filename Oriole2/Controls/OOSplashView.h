//
//  OOSplashView.h
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

#import <UIKit/UIKit.h>

typedef enum {
    OOSplashViewAnimation_FadeOut,
    OOSplashViewAnimation_ScaleAndFadeOut,
} OOSplashViewAnimation;

@interface OOSplashView : UIView
{
    UIImageView           *ooImageView;
    UIImageView           *appImageView;
    BOOL                  isMainVCLoaded, isVSImageHide;
    NSTimer               *theTimer;
    OOSplashViewAnimation appImageAnimation;
    float                 appImageAnimationDuration, appImagePauseDuration;
}
@property(nonatomic, assign) OOSplashViewAnimation appImageAnimation;
@property(nonatomic, assign) float                 appImageAnimationDuration, appImagePauseDuration;
@property(nonatomic, assign) BOOL                  isMainVCLoaded;

- (id)initWithFrame:(CGRect)frame appImageName:(NSString *)appImageName;
- (id)initWithFrame:(CGRect)frame ooImageName:(NSString *)ooImageName appImageName:(NSString *)appImageName;
- (id)initWithFrame:(CGRect)frame ooImageName:(NSString *)ooImageName appImageName:(NSString *)appImageName appImageAnimation:(OOSplashViewAnimation)animation appImageAnimationDuration:(float)animationDuration appImagePauseDuration:(float)pauseDuration;

@end
