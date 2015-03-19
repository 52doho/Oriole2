//
//  CALayer+XibConfiguration.h
//  Oriole2
//
//  Created by Gary Wong on 12/1/14.
//  Copyright 2014 Oriole2 Ltd. All rights reserved.
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

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (XibConfiguration)

@property (nonatomic, assign) UIColor *borderUIColor;

@end

@interface UIView (XibConfiguration)

@property (nonatomic, assign) UIColor *backgroundUIColor;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGPoint anchorPoint;

@end
