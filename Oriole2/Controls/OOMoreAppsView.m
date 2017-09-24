//
//  OOMoreAppsView.m
//  BeehiveWeather
//
//  Created by Gary Wong on 6/13/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
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

#import "OOMoreAppsView.h"
#import "MBProgressHUD.h"
#import "OOCommon.h"

@interface OOMoreAppsView ()
{
    BOOL             canAnimate;
    UIButton         *btn1, *btn2;
    NSArray          *aryImageNames;
//    OOMoreAppsEntity *moreAppsEntity;
}

@end

@implementation OOMoreAppsView

- (NSString *)_getLocalPathForImageUrl:(NSString *)url {
    NSString *filename = [url lastPathComponent];
    if (filename.length == 0) {
        return nil;
    }
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *folder = [path stringByAppendingPathComponent:@"ads"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [folder stringByAppendingPathComponent:filename];
}

- (BOOL)_isWebUrl:(NSString *)str {
    return str.length > 0 && [str rangeOfString:@"http"].location == 0;
}

- (void)_setDefault
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;

    if (!aryImageNames) {
        [self setBannerImageUrls:[NSArray arrayWithObjects:@"Oriole2.bundle/Images/MoreApps_Oriole2_Orange.png",
                               @"Oriole2.bundle/Images/MoreApps_Oriole2_Blue.png",
                               @"Oriole2.bundle/Images/MoreApps_Oriole2_Green.png", nil]];
    }

    btn1 = [[UIButton alloc] init];
    btn1.backgroundColor = [UIColor clearColor];
    btn1.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn1.contentMode = UIViewContentModeScaleAspectFit;
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

    if (self) {
        [self _setDefault];
    }

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _setDefault];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    btn1.frame = btn2.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setBannerImageUrls:(NSArray *)imageUrls {
    NSMutableArray *_newImages = [NSMutableArray array];
    for (id imageUrl in imageUrls) {
        if ([imageUrl isKindOfClass:[NSString class]]) {
            [_newImages addObject:imageUrl];
            
            if ([self _isWebUrl:imageUrl]) {
                NSString *path = [self _getLocalPathForImageUrl:imageUrl];
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSURL *url = [NSURL URLWithString:imageUrl];
                        if (url) {
                            NSData *imageData = [NSData dataWithContentsOfURL:url];
                            [imageData writeToFile:path atomically:YES];
                        }
                    });
                }
            }
        }
    }
    if ([_newImages count] > 0) {
        aryImageNames = _newImages;
        
        uint newTag = 0;
        [btn1 setImage:[self _getRandomImageExceptWithTag:-1 newTag:&newTag] forState:UIControlStateNormal];
        btn1.tag = newTag;
    }
}

- (void)setRandomTimeFrom:(float)value
{
    if (value > 0 && value <= _randomTimeTo) {
        _randomTimeFrom = value;
    }
}

- (void)setRandomTimeTo:(float)value
{
    if (value > 0 && value >= _randomTimeFrom) {
        _randomTimeTo = value;
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [btn1 addTarget:target action:action forControlEvents:controlEvents];
    [btn2 addTarget:target action:action forControlEvents:controlEvents];
}

//- (void)bindWithData:(OOMoreAppsEntity *)entity
//{
//    if ([entity isKindOfClass:[OOMoreAppsEntity class]]) {
//        moreAppsEntity = entity;
//    }
//
//    [self addTarget:self action:@selector(_moreAppsViewTapped) forControlEvents:UIControlEventTouchUpInside];
//}

- (void)_moreAppsViewTapped
{
    UIViewController *topmostViewController = [OOCommon getTopmostViewController];
    NSUInteger       appId = NSUIntegerMax;

//    for (OOAppEntity *app in moreAppsEntity.aryAppEntities) {
//        NSUInteger _id = app.appId;
//        NSString *scheme = app.scheme;
//
//        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]]) {
//            continue; // has been installed
//        } else {
//            appId = _id;
//            break;
//        }
//    }

    if ((appId != NSUIntegerMax) && topmostViewController) {
        [OOCommon openInAppStoreWithID:appId viewController:topmostViewController];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/artist/oriole2-co.-ltd./id506665225?mt=8"]];
    }
}

- (UIImage *)_getRandomImageExceptWithTag:(NSUInteger)tag newTag:(uint *)newTag
{
    NSUInteger count = aryImageNames.count;
    uint i = OORANDOM(0, count);

    while (i == tag && count > 1)
        i = OORANDOM(0, count);

    UIImage  *image;
    NSString *name = aryImageNames[i];
    if ([self _isWebUrl:name]) {
        NSString *path = [self _getLocalPathForImageUrl:name];
        image = [UIImage imageWithContentsOfFile:path];
    } else {
        image = kUniversalImage(name);
    }

    if (newTag) {
        *newTag = i;
    }

    return image;
}

#pragma mark - Animation -
- (void)_actuallyAnimate
{
    UIButton *from, *to;

    if (btn1.hidden) {
        from = btn2;
        to = btn1;
    } else {
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
    if (canAnimate) {
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
