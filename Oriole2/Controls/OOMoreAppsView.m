//
//  OOMoreAppsView.m
//  BeehiveWeather
//
//  Created by Gary Wong on 6/13/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#import "OOMoreAppsView.h"
#import "MBProgressHUD.h"
#import "OOCommon.h"

@interface OOMoreAppsView()
{
    BOOL canAnimate;
    UIButton *btn1, *btn2;
    NSArray *aryImageNames;
    OOMoreAppsEntity *moreAppsEntity;
}

@end

@implementation OOMoreAppsView

- (void)_setDefault
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    
    aryImageNames = [NSArray arrayWithObjects:@"Oriole2.bundle/Images/MoreApps_Oriole2_Orange.png",
                     @"Oriole2.bundle/Images/MoreApps_Oriole2_Blue.png",
                     @"Oriole2.bundle/Images/MoreApps_Oriole2_Green.png", nil];
    
    btn1 = [[UIButton alloc] init];
    btn1.backgroundColor = [UIColor clearColor];
    btn1.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn1.contentMode = UIViewContentModeScaleAspectFit;
    uint newTag = 0;
    [btn1 setImage:[self _getRandomImageExceptWithTag:-1 newTag:&newTag] forState:UIControlStateNormal];
    btn1.tag = newTag;
    [self addSubview:btn1];
    
    btn2 = [[UIButton alloc] init];
    btn2.backgroundColor = [UIColor clearColor];
    btn2.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn2.contentMode = UIViewContentModeScaleAspectFit;
    btn2.tag = 1;
    btn2.hidden = YES;
    [self insertSubview:btn2 belowSubview:btn1];
    
    self.randomTimeFrom = 10;
    self.randomTimeTo = 12;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _setDefault];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _setDefault];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    btn1.frame = btn2.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setRandomTimeFrom:(float)value
{
    if(value <= _randomTimeTo)
        _randomTimeFrom = value;
}

- (void)setRandomTimeTo:(float)value
{
    if(value >= _randomTimeFrom)
        _randomTimeTo = value;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [btn1 addTarget:target action:action forControlEvents:controlEvents];
    [btn2 addTarget:target action:action forControlEvents:controlEvents];
}

- (void)bindWithData:(OOMoreAppsEntity *)entity
{
    if([entity isKindOfClass:[OOMoreAppsEntity class]])
    {
        moreAppsEntity = entity;
        
        [self addTarget:self action:@selector(_moreAppsViewTapped) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)_moreAppsViewTapped
{
    UIViewController *topmostViewController = [OOCommon getTopmostViewController];
    NSUInteger appId = NSUIntegerMax;
    for (OOAppEntity *app in moreAppsEntity.aryAppEntities)
    {
        uint _id = app.appId;
        NSString *scheme = app.scheme;
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]])
            continue;//has been installed
        else
        {
            appId = _id;
            break;
        }
    }
    if(appId != NSUIntegerMax && topmostViewController)
    {
        MBProgressHUD *hud = [OOCommon openInAppStoreWithID:appId viewController:topmostViewController showHudInView:self];
        hud.opacity = 0;
        hud.labelText = nil;
    }
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:moreAppsEntity.artistUrl]];
}

- (UIImage *)_getRandomImageExceptWithTag:(int)tag newTag:(uint *)newTag
{
    uint i = OORANDOM(0, aryImageNames.count);
    while (i == tag)
    {
        i = OORANDOM(0, aryImageNames.count);
    }
    NSString *name = aryImageNames[i];
    UIImage *image = kUniversalImage(name);
    if(newTag)
        *newTag = i;
    
    return image;
}

#pragma mark - Animation -
- (void)_actuallyAnimate
{
    UIButton *from, *to;
    if(btn1.hidden)
    {
        from = btn2;
        to = btn1;
    }
    else
    {
        from = btn1;
        to = btn2;
    }
    uint newTag = 0;
    [to setImage:[self _getRandomImageExceptWithTag:from.tag newTag:&newTag] forState:UIControlStateNormal];
    to.tag = newTag;
    NSUInteger option = OORANDOM(1, 8);
    option = option << 20;
    [UIView transitionFromView:from toView:to duration:.5 options:option | UIViewAnimationOptionShowHideTransitionViews completion:^(BOOL finished) {
        [self _checkAnimate];
    }];
}

- (void)_checkAnimate
{
    if(canAnimate)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_actuallyAnimate) object:nil];
        float delay = OORANDOM(_randomTimeFrom, _randomTimeTo);
        //        float delay = 2;
        [self performSelector:@selector(_actuallyAnimate) withObject:nil afterDelay:delay];
    }
}

- (void)startAnimate
{
    canAnimate = YES;
    
    [self _checkAnimate];
}

- (void)stopAnimate
{
    canAnimate = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_actuallyAnimate) object:nil];
}

- (void)removeFromSuperview
{
    [self stopAnimate];
    
    [super removeFromSuperview];
}

- (void)dealloc
{
    OOLog(@"OOMoreAppsView dealloc");
}

@end
