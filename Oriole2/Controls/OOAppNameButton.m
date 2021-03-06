//
//  OOAppNameButton.m
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

#import "OOAppNameButton.h"
#import "OOCommon.h"
#import "LKBadgeView.h"
#import "OOAnimationManager.h"
#import "iVersion.h"

@interface OOAppNameButton ()
{
    LKBadgeView *badgeView;
}

@end

@implementation OOAppNameButton

+ (id)buttonWithName:(NSString *)name {
    OOAppNameButton *button = [[OOAppNameButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [button setTitle:name forState:UIControlStateNormal];
    return button;
}

- (void)_setDefault
{
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;

    badgeView = [[LKBadgeView alloc] init];
    badgeView.badgeColor = [UIColor redColor];
    badgeView.textColor = [UIColor whiteColor];
    badgeView.font = [UIFont boldSystemFontOfSize:12];
    badgeView.horizontalAlignment = LKBadgeViewHorizontalAlignmentRight;
    badgeView.outlineWidth = 0;
    badgeView.text = @"NEW";
    [self addSubview:badgeView];
    [self addTarget:self action:@selector(_viewTapped) forControlEvents:UIControlEventTouchDown];
    
    [[OOCommon instance] iVersionStateChanged:^(BOOL hasNew) {
        badgeView.hidden = !hasNew;
        self.enabled = hasNew;
        if (hasNew) {
            [[OOAnimationManager instance] stretchAnimationForView:self deltaScaleX:.1 deltaScaleY:.1 duration:2 delay:2 repeatCount:-1 completeBlock:nil];
        }
    }];
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

    UILabel *label = nil;
    for (UIView *subView in [self subviews]) {
        if ([subView isKindOfClass:[UILabel class]]) {
            label = (UILabel *)subView;
        }
    }
    CGSize size = self.frame.size;
    CGFloat height = 22;
    badgeView.frame = CGRectMake(0, label.frame.origin.y - height, size.width, height);
    
    // set again to SHOW badge
    badgeView.text = badgeView.text;
}

- (void)_viewTapped
{
    [[iVersion sharedInstance] openAppPageInAppStore];
}

@end
