 //
//  OOZoomableImageView.h
//  FloatingGallery
//
//  Created by Gary Wong on 2/4/13.
//  Copyright (c) 2013 Oriole2 Ltd. All rights reserved.
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

@protocol OOZoomableImageViewDelegate;
@interface OOZoomableImageView : UIScrollView <UIScrollViewDelegate>
{
}
@property(nonatomic, copy, readonly) UIImageView *imageView;
@property(nonatomic, assign) BOOL shouldMonitorShrinkToMin, outOfBoundTappable, shouldMonitorDeviceOrientation;
@property(nonatomic, assign) id<OOZoomableImageViewDelegate> delegateZoomableImageView;

- (void)displayImage:(UIImage *)image;
- (void)displayImage:(UIImage *)image scaleAspectFit:(BOOL)scaleAspectFit;
- (void)displayEmptyContentWithSize:(CGSize)size;

@end

@protocol OOZoomableImageViewDelegate <UIScrollViewDelegate>
@optional

- (void)zoomableImageViewDidShrinkToMin:(OOZoomableImageView *)zoomableImageView;
- (void)zoomableImageView:(OOZoomableImageView *)zoomableImageView doubleTappedAtPoint:(CGPoint)point;
- (void)zoomableImageView:(OOZoomableImageView *)zoomableImageView didZoomWithIsShrinkToMin:(BOOL)isShrinkToMin;

@end
