 //
//  OOZoomableImageView.h
//  FloatingGallery
//
//  Created by Gary Wong on 2/4/13.
//  Copyright (c) 2013 Oriole2 Ltd. All rights reserved.
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
