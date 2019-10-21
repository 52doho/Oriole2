//
//  OOMoreAppsButton.h
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

#import <UIKit/UIKit.h>

@interface OOMoreAppsButton : UIButton
{
}

+ (id)button;
- (void)setConfig:(NSDictionary *)config;

@end


@interface OOInstagramButton : UIButton
{
}
@property(nonatomic, assign) BOOL showText;

+ (id)button;

@end
