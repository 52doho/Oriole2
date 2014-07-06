//
//  PRAnimationManager.m
//  OOPromotion
//
//  Created by ZhangChenglong on 13-6-4.
//  Copyright (c) 2013年 Oriole2 Co., Ltd. All rights reserved.
//

#import "PRAnimationManager.h"

@interface PRAnimationManager()
@end

@implementation PRAnimationManager

+ (PRAnimationManager *)instance
{
    return [[PRAnimationManager alloc] init];
}

#define kAnimationType @"AnimationType"
#define kAnimationType_Drop @"kAnimationType_Drop"
#define kAnimationType_FlyAndBounceIn @"kAnimationType_FlyAndBounceIn"
#define kAnimationType_BounceIn @"kAnimationType_BounceIn"
#define kAnimationType_Stretch @"kAnimationType_Stretch"
#define kAnimationType_Flip @"kAnimationType_Flip"
#define kAnimationCompleteBlock @"kAnimationCompleteBlock"
#define kView @"View"
#define kKeyPathKey @"KeyPathKey"
#define kKeyPathValue @"KeyPathValue"

- (void)dropAnimationForView:(UIView *)view from:(float)from to:(float)to farestDestance:(float)farestDestance duration:(float)duration delay:(float)delay completeBlock:(OOBlockBasic)completeBlock
{
    if(!view || !view.superview)
        return;
    
    [view.layer removeAllAnimations];
    
    NSString *keyPath = @"position.y";
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    
    NSNumber *position0 = @(from);
    NSNumber *position1 = @(to + farestDestance);
    NSNumber *position2 = @(to - farestDestance * 4/5);
    NSNumber *position3 = @(to + farestDestance * 3/5);
    NSNumber *position4 = @(to - farestDestance * 2/5);
    NSNumber *position5 = @(to + farestDestance * 1/5);
    NSNumber *position6 = @(to);
    
    NSArray *frameValues = @[position0,position1,position2,position3,position4,position5,position6];
    [animation setValues:frameValues];
    
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.removedOnCompletion = NO;
    CFTimeInterval beginTime = CACurrentMediaTime();
    animation.beginTime = beginTime + delay;
    animation.duration = duration;
    
    animation.delegate = self;
    [animation setValue:kAnimationType_Drop forKey:kAnimationType];
    [animation setValue:view forKey:kView];
    [animation setValue:completeBlock forKey:kAnimationCompleteBlock];
    [animation setValue:@"center" forKey:kKeyPathKey];
    [animation setValue:[NSValue valueWithCGPoint:CGPointMake(view.centerX, to)] forKey:kKeyPathValue];
    
    [view.layer addAnimation:animation forKey:kAnimationType_Drop];
}

- (void)flyAndBounceInAnimationForView:(UIView *)view isX:(BOOL)isX from:(float)from to:(float)to farestDestance:(float)farestDestance duration:(float)duration delay:(float)delay completeBlock:(OOBlockBasic)completeBlock
{
    if(!view)
        return;
    
    [view.layer removeAllAnimations];
    
    float sign = 1;
    CAKeyframeAnimation *animation;
    if(isX)
    {
        animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        sign = -1;
    }
    else
        animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    
    NSNumber *position0 = @(from);
    NSNumber *position1 = @(to + farestDestance * sign);
    NSNumber *position2 = @(to - farestDestance * 4/5 * sign);
    NSNumber *position3 = @(to + farestDestance * 3/5 * sign);
    NSNumber *position4 = @(to - farestDestance * 2/5 * sign);
    NSNumber *position5 = @(to + farestDestance * 1/5 * sign);
    NSNumber *position6 = @(to);
    
    NSArray *frameValues = @[position0,position1,position2,position3,position4,position5,position6];
    [animation setValues:frameValues];
    
    CFTimeInterval beginTime = CACurrentMediaTime();
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.beginTime = beginTime + delay;
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    animation.delegate = self;
    [animation setValue:kAnimationType_FlyAndBounceIn forKey:kAnimationType];
    [animation setValue:view forKey:kView];
    [animation setValue:completeBlock forKey:kAnimationCompleteBlock];
    [animation setValue:@"center" forKey:kKeyPathKey];
    CGPoint center = isX ? CGPointMake(to, view.centerY) : CGPointMake(view.centerX, to);
    [animation setValue:[NSValue valueWithCGPoint:center] forKey:kKeyPathValue];
    
    [view.layer addAnimation:animation forKey:kAnimationType_FlyAndBounceIn];
}

- (void)bounceInAnimationForView:(UIView *)view fromScale:(float)fromScale toScale:(float)toScale farestScale:(float)farestScale duration:(float)duration delay:(float)delay completeBlock:(OOBlockBasic)completeBlock
{
    if(!view)
        return;
    
    [view.layer removeAllAnimations];
    
    NSString *keyPath = @"transform";
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    
    CATransform3D startingScale = CATransform3DMakeScale(fromScale, fromScale, 1);
    CATransform3D overshootScale = CATransform3DMakeScale(toScale + farestScale, toScale + farestScale, 1);
    CATransform3D undershootScale = CATransform3DMakeScale(toScale - farestScale / 2, toScale - farestScale / 2, 1.0);
    CATransform3D endingScale = CATransform3DMakeScale(toScale, toScale, 1);
    
    NSArray *boundsValues = @[[NSValue valueWithCATransform3D:startingScale],
                             [NSValue valueWithCATransform3D:overshootScale],
                             [NSValue valueWithCATransform3D:undershootScale],
                             [NSValue valueWithCATransform3D:endingScale]];
    [animation setValues:boundsValues];
    
    NSArray *times = @[@0.0f,
                      @0.5f,
                      @0.9f,
                      @1.0f];
    [animation setKeyTimes:times];
    
    NSArray *timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setTimingFunctions:timingFunctions];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    CFTimeInterval beginTime = CACurrentMediaTime();
    animation.beginTime = beginTime + delay;
    animation.duration = duration;
    
    animation.delegate = self;
    [animation setValue:kAnimationType_Drop forKey:kAnimationType];
    [animation setValue:completeBlock forKey:kAnimationCompleteBlock];
    [animation setValue:view forKey:kView];
    [animation setValue:keyPath forKey:kKeyPathKey];
    [animation setValue:[NSValue valueWithCGAffineTransform:CGAffineTransformIdentity] forKey:kKeyPathValue];
    
    [view.layer addAnimation:animation forKey:kAnimationType_BounceIn];
}

- (void)stretchAnimationForView:(UIView *)view deltaScaleX:(float)deltaScaleX deltaScaleY:(float)deltaScaleY duration:(float)duration delay:(float)delay repeatCount:(int)repeatCount completeBlock:(OOBlockBasic)completeBlock
{
    if(!view)
        return;
    
    [view.layer removeAllAnimations];
    
    NSString *keyPath = @"transform";
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    
    CATransform3D startingScale = CATransform3DMakeScale(1 + deltaScaleX, 1 + deltaScaleY, 1);
    CATransform3D endingScale = CATransform3DMakeScale(1 - deltaScaleX, 1 - deltaScaleY, 1);
    
    NSArray *boundsValues = @[[NSValue valueWithCATransform3D:startingScale],
                             [NSValue valueWithCATransform3D:endingScale], [NSValue valueWithCATransform3D:startingScale]];
    [animation setValues:boundsValues];
    
    if(repeatCount < 0)
        animation.repeatCount = HUGE_VALF;//infinite
    else
        animation.repeatCount = repeatCount;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    
    CFTimeInterval beginTime = CACurrentMediaTime();
    animation.beginTime = beginTime + delay;
    animation.duration = duration;
    
    [view.layer addAnimation:animation forKey:kAnimationType_Stretch];
}

// Scales center points by the difference in their anchor points scaled to their frame size.
// Lets you move anchor points around without dealing with CA's implicit frame math.
- (CGPoint)_center:(CGPoint)oldCenter movedFromAnchorPoint:(CGPoint)oldAnchorPoint toAnchorPoint:(CGPoint)newAnchorPoint withFrame:(CGRect)frame
{
    //	OOLog(@"moving center (%.2f, %.2f) from oldAnchor (%.2f, %.2f) to newAnchor (%.2f, %.2f)", oldCenter.x, oldCenter.y, oldAnchorPoint.x, oldAnchorPoint.y, newAnchorPoint.x, newAnchorPoint.y);
	CGPoint anchorPointDiff = CGPointMake(newAnchorPoint.x - oldAnchorPoint.x, newAnchorPoint.y - oldAnchorPoint.y);
	CGPoint newCenter = CGPointMake(oldCenter.x + (anchorPointDiff.x * frame.size.width),
									oldCenter.y + (anchorPointDiff.y * frame.size.height));
    //	OOLog(@"new center is (%.2f, %.2f) (frame size: (%.2f, %.2f))", newCenter.x, newCenter.y, frame.size.width, frame.size.height);
    
	return newCenter;
}

- (void)_setAnchorPoint:(CGPoint *)anchorPoint xRotate:(float *)xRotate yRotate:(float *)yRotate withDirection:(PRAnimationDirection)direction
{
    if(direction == PRAnimationDirection_Top)
    {
        *anchorPoint = CGPointMake(.5, 0);
        *xRotate = 1;
        *yRotate = 0;
    }
    else if(direction == PRAnimationDirection_Left)
    {
        *anchorPoint = CGPointMake(0, .5);
        *xRotate = 0;
        *yRotate = 1;
    }
    else if(direction == PRAnimationDirection_Bottom)
    {
        *anchorPoint = CGPointMake(.5, 1);
        *xRotate = 1;
        *yRotate = 0;
    }
    else
    {
        *anchorPoint = CGPointMake(1, .5);
        *xRotate = 0;
        *yRotate = 1;
    }
}

- (PRAnimationDirection)_reverseDirection:(PRAnimationDirection)direction
{
    if(direction == PRAnimationDirection_Top)
    {
        return PRAnimationDirection_Bottom;
    }
    else if(direction == PRAnimationDirection_Left)
    {
        return PRAnimationDirection_Right;
    }
    else if(direction == PRAnimationDirection_Bottom)
    {
        return PRAnimationDirection_Top;
    }
    else
    {
        return PRAnimationDirection_Left;
    }
}

#define kFlipAnimationStep @"kFlipAnimationStep"
#define kFlipAnimationStepFirst @"kFlipAnimationStepFirst"
#define kFlipAnimationStepSecond @"kFlipAnimationStepSecond"
#define kFlipAnimationView @"kFlipAnimationView"
#define kFlipAnimationMirrorView @"kFlipAnimationMirrorView"
#define kFlipAnimationDirection @"kFlipAnimationDirection"
#define kFlipAnimationDuration @"kFlipAnimationDuration"
#define kFlipAnimationCount @"kFlipAnimationCount"
- (void)flipForView:(UIView *)view mirrorView:(UIView *)mirrorView direction:(PRAnimationDirection)direction duration:(float)duration count:(uint)count completeBlock:(OOBlockBasic)completeBlock
{
    if(!view || !mirrorView)
        return;
    
    if(count == 0)
    {
        if(completeBlock)
            completeBlock();
        return;
    }
    
    [view.layer removeAllAnimations];
    [mirrorView.layer removeAllAnimations];
    
    [view.superview insertSubview:mirrorView belowSubview:view];
    mirrorView.frame = view.frame;
    if(direction == PRAnimationDirection_Top)
    {
        mirrorView.top -= mirrorView.height;
    }
    else if(direction == PRAnimationDirection_Left)
    {
        mirrorView.left -= mirrorView.width;
    }
    else if(direction == PRAnimationDirection_Bottom)
    {
        mirrorView.top += mirrorView.height;
    }
    else
    {
        mirrorView.left += mirrorView.width;
    }
    
    mirrorView.hidden = YES;
    view.hidden = NO;
    float durationStep = duration / count / 2;
    CFTimeInterval beginTime = CACurrentMediaTime();
    
    // Skewed identity for camera perspective:
    CATransform3D skewedIdentityTransform = CATransform3DIdentity;
//    skewedIdentityTransform.m34 = 1.0 / -(MAX(view.width, view.height) * 2);
    
    CGPoint anchorPointView;
    float xRotate, yRotate;
    [self _setAnchorPoint:&anchorPointView xRotate:&xRotate yRotate:&yRotate withDirection:direction];
    
    CGPoint newTopViewCenter = [self _center:view.center movedFromAnchorPoint:view.layer.anchorPoint toAnchorPoint:anchorPointView withFrame:view.frame];
    view.layer.anchorPoint = anchorPointView;
    view.center = newTopViewCenter;
    
    // Add an animation to swing from top to bottom.
    CABasicAnimation *animationFirst = [CABasicAnimation animationWithKeyPath:@"transform"];
    NSValue *value1 = [NSValue valueWithCATransform3D:skewedIdentityTransform];
    NSValue *value2 = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, xRotate, yRotate, 0.f)];
    //first animate
    animationFirst.beginTime = beginTime;
    animationFirst.duration = durationStep;
    animationFirst.fromValue = value1;
    animationFirst.toValue = value2;
    animationFirst.removedOnCompletion = NO;
    animationFirst.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [animationFirst setValue:kFlipAnimationStepFirst forKey:kFlipAnimationStep];
    [animationFirst setValue:view forKey:kFlipAnimationView];
    [animationFirst setValue:mirrorView forKey:kFlipAnimationMirrorView];
    [animationFirst setValue:kAnimationType_Flip forKey:kAnimationType];
    animationFirst.delegate = self;
    animationFirst.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:animationFirst forKey:kAnimationType_Flip];
    
    // Bottom tile:
    // Change its anchor point:
    CGPoint anchorPointMirrorView;
    [self _setAnchorPoint:&anchorPointMirrorView xRotate:&xRotate yRotate:&yRotate withDirection:[self _reverseDirection:direction]];
    CGPoint newBottomHalfCenter = [self _center:mirrorView.center movedFromAnchorPoint:mirrorView.layer.anchorPoint toAnchorPoint:anchorPointMirrorView withFrame:mirrorView.frame];
    mirrorView.layer.anchorPoint = anchorPointMirrorView;
    mirrorView.center = newBottomHalfCenter;
    
    // Add an animation to swing from top to bottom.
    CABasicAnimation *animationSecond = [CABasicAnimation animationWithKeyPath:@"transform"];
    value1 = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, xRotate, yRotate, 0.f)];
    value2 = [NSValue valueWithCATransform3D:skewedIdentityTransform];
    //second animate
    animationSecond.beginTime = beginTime + durationStep;
    animationSecond.duration = durationStep;
    animationSecond.fromValue = value1;
    animationSecond.toValue = value2;
    animationSecond.removedOnCompletion = YES;
    animationSecond.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [animationSecond setValue:kFlipAnimationStepSecond forKey:kFlipAnimationStep];
    [animationSecond setValue:view forKey:kFlipAnimationView];
    [animationSecond setValue:mirrorView forKey:kFlipAnimationMirrorView];
    [animationSecond setValue:@(direction) forKey:kFlipAnimationDirection];
    [animationSecond setValue:@(duration - durationStep * 2) forKey:kFlipAnimationDuration];
    [animationSecond setValue:@((int)count - 1) forKey:kFlipAnimationCount];
    [animationSecond setValue:completeBlock forKey:kAnimationCompleteBlock];
    [animationSecond setValue:kAnimationType_Flip forKey:kAnimationType];
    animationSecond.delegate = self;
    animationSecond.fillMode = kCAFillModeBoth;
    [mirrorView.layer addAnimation:animationSecond forKey:kAnimationType_Flip];
}

- (void)dropDownAndFadeInView:(UIView *)view fromScale:(float)fromScale delay:(NSTimeInterval)delay duration:(float)duration completeBlock:(OOBlockBasic)completeBlock
{
    view.alpha = 0;
    view.transform = CGAffineTransformMakeScale(fromScale, fromScale);
    
    [view.superview bringSubviewToFront:view];
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        view.alpha = 1;
        //clear the transform
        view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if(completeBlock)
            completeBlock();
    }];
}

#pragma mark - Animation Delegate Methods -
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished
{
    OOBlockBasic completeBlock = [animation valueForKey:kAnimationCompleteBlock];
    
    NSString *animationType = [animation valueForKey:kAnimationType];
    if([animationType isEqualToString:kAnimationType_Flip])
    {
        UIView *view = [animation valueForKey:kFlipAnimationView];
        UIView *mirrorView = [animation valueForKey:kFlipAnimationMirrorView];
        NSString *animationStep = [animation valueForKey:kFlipAnimationStep];
        if([animationStep isEqualToString:kFlipAnimationStepFirst])
        {
            mirrorView.hidden = NO;
        }
        else
        {
            //second
            view.hidden = NO;
            
            PRAnimationDirection direction = [[animation valueForKey:kFlipAnimationDirection] integerValue];
            float duration = [[animation valueForKey:kFlipAnimationDuration] floatValue];
            int count = [[animation valueForKey:kFlipAnimationCount] integerValue];
            [self flipForView:mirrorView mirrorView:view direction:direction duration:duration count:count completeBlock:completeBlock];
        }
    }
    else
    {
        UIView *view = [animation valueForKey:kView];
        NSString *keyPath = [animation valueForKey:kKeyPathKey];
        id value = [animation valueForKey:kKeyPathValue];
        [view.layer removeAllAnimations];
        [view setValue:value forKeyPath:keyPath];
        
        if (completeBlock)
        {
            completeBlock();
        }
    }
}

@end
