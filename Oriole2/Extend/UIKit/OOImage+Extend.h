//
//  OOImage+Extend.h
//  Oriole2
//
//  Created by Gary Wong on 2/12/11.
//  Copyright 2011 Oriole2 Ltd. All rights reserved.
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


#import <Foundation/Foundation.h>

@interface UIImage(Extend)

- (UIImage *)scaleToSize:(CGSize)newSize thenCropWithRect:(CGRect)cropRect;
- (UIImage *)scaleToSize:(CGSize)newSize;
- (UIImage *)maskWith:(UIImage *)img;
- (UIImage *)reflectedWithHeight:(CGFloat)height;

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

// Proportionately resize, completely fit in view, no cropping
- (UIImage *)imageFitInSize:(CGSize)size;
// Center, no resize
- (UIImage *)imageCenterInSize:(CGSize)size;
// Fill all pixels
- (UIImage *)imageFillInSize:(CGSize)size;

@end