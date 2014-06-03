//
//  OOMoreAppsView.h
//  BeehiveWeather
//
//  Created by Gary Wong on 6/13/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OOMoreAppsView : UIView
{
    
}
//default: 10 ~ 12
@property(nonatomic, assign) float randomTimeFrom, randomTimeTo;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)startAnimate;
- (void)stopAnimate;

- (void)bindWithData:(NSDictionary *)dic;

@end
