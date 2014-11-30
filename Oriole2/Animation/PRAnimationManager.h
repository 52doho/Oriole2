//
//  PRAnimationManager.h
//  OOPromotion
//
//  Created by ZhangChenglong on 13-6-4.
//  Copyright (c) 2013年 Oriole2 Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OOCommon.h"

typedef enum
{
    PRAnimationDirection_Top,
    PRAnimationDirection_Left,
    PRAnimationDirection_Bottom,
    PRAnimationDirection_Right
}PRAnimationDirection;

@interface PRAnimationManager : NSObject

+ (PRAnimationManager *)instance;

- (void)dropAnimationForView:(UIView *)view from:(float)from to:(float)to farestDestance:(float)farestDestance duration:(float)duration delay:(float)delay completeBlock:(OOBlockBasic)completeBlock;
- (void)flyAndBounceInAnimationForView:(UIView *)view isX:(BOOL)isX from:(float)from to:(float)to farestDestance:(float)farestDestance duration:(float)duration delay:(float)delay completeBlock:(OOBlockBasic)completeBlock;
- (void)bounceInAnimationForView:(UIView *)view fromScale:(float)fromScale toScale:(float)toScale farestScale:(float)farestScale duration:(float)duration delay:(float)delay completeBlock:(OOBlockBasic)completeBlock;
- (void)stretchAnimationForView:(UIView *)view deltaScaleX:(float)deltaScaleX deltaScaleY:(float)deltaScaleY duration:(float)duration delay:(float)delay repeatCount:(int)repeatCount completeBlock:(OOBlockBasic)completeBlock;

- (void)flipForView:(UIView *)view mirrorView:(UIView *)mirrorView direction:(PRAnimationDirection)direction duration:(float)duration count:(uint)count completeBlock:(OOBlockBasic)completeBlock;

- (void)dropDownAndFadeInView:(UIView *)view fromScale:(float)fromScale delay:(NSTimeInterval)delay duration:(float)duration completeBlock:(OOBlockBasic)completeBlock;

@end
