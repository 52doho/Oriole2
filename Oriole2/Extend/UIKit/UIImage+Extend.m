//
//  UIImage+Extend.m
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

#import "UIImage+Extend.h"
#import "OOGeometry+Extend.h"

@implementation UIImage (Extend)

- (UIImage *)scaleToSize:(CGSize)newSize thenCropWithRect:(CGRect)cropRect
{
    CGContextRef context;
    CGImageRef   imageRef;
    CGSize       inputSize;
    UIImage      *outputImage = nil;
    CGFloat      scaleFactor, width;

    // resize, maintaining aspect ratio:

    inputSize = self.size;
    scaleFactor = newSize.height / inputSize.height;
    width = roundf(inputSize.width * scaleFactor);

    if (width > newSize.width) {
        scaleFactor = newSize.width / inputSize.width;
        newSize.height = roundf(inputSize.height * scaleFactor);
    } else {
        newSize.width = width;
    }

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);

    context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), self.CGImage);
    outputImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    inputSize = newSize;

    // constrain crop rect to legitimate bounds
    if ((cropRect.origin.x >= inputSize.width) || (cropRect.origin.y >= inputSize.height)) {
        return outputImage;
    }

    if (cropRect.origin.x + cropRect.size.width >= inputSize.width) {
        cropRect.size.width = inputSize.width - cropRect.origin.x;
    }

    if (cropRect.origin.y + cropRect.size.height >= inputSize.height) {
        cropRect.size.height = inputSize.height - cropRect.origin.y;
    }

    // crop
    if ((imageRef = CGImageCreateWithImageInRect(outputImage.CGImage, cropRect))) {
        outputImage = [[UIImage alloc] initWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }

    return outputImage;
}

- (UIImage *)scaleToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

// http://iphonedevelopertips.com/cocoa/how-to-mask-an-image.html
- (UIImage *)maskWith:(UIImage *)image
{
    CGImageRef maskRef = image.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef), NULL, false);

    CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
    UIImage    *maskImage = [UIImage imageWithCGImage:masked];

    CGImageRelease(mask);
    CGImageRelease(masked);
    return maskImage;
}

- (CGImageRef)_createGradientImageWithWidth:(int)width height:(int)height
{
    CGImageRef theCGImage = NULL;

    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, width, height,
            8, 0, colorSpace, kCGImageAlphaNone);

    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requHHes it)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};

    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);

    CGColorSpaceRelease(colorSpace);

    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(0, height);

    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
        gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);

    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);

    // return the imageref containing the gradient
    return theCGImage;
}

- (UIImage *)reflectedWithHeight:(CGFloat)height
{
    if (height == 0) {
        return nil;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // create the bitmap context
    CGContextRef mainViewContentContext = CGBitmapContextCreate(NULL, self.size.width, height, 8,
                                                       0, colorSpace,
                                                       // this will give us an optimal BGRA format for the device:
                                                       (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    
    CGColorSpaceRelease(colorSpace);

    // create a 2 bit CGImage containing a gradient that will be used for masking the
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as requHHed, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = [self _createGradientImageWithWidth:1 height:height];

    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, self.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);

    // In order to grab the part of the image that we want to render, we move the context origin to the
    // height of the image that we want to capture, then we flip the context so that the image draws upside down.
    CGContextTranslateCTM(mainViewContentContext, 0.0, height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);

    // draw the image into the bitmap context
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextDrawImage(mainViewContentContext, rect, self.CGImage);

    // create CGImageRef of the main view bitmap content, and then release that bitmap context
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);

    // convert the finished reflection image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];

    // image is retained by the property setting above, so we can release the original
    CGImageRelease(reflectionImage);

    return theImage;
}

- (UIImage *)imageAtRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage    *subImage = [UIImage imageWithCGImage:imageRef];

    CGImageRelease(imageRef);

    return subImage;
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;

    CGSize  imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;

    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;

    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;

    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }

        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // center the image

        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    // this is actually the interesting part:
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (newImage == nil) {
        NSLog(@"could not scale image");
    }

    return newImage;
}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;

    CGSize  imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;

    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;

    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;

    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor < heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }

        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // center the image

        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    // this is actually the interesting part:
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (newImage == nil) {
        NSLog(@"could not scale image");
    }

    return newImage;
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;

    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;

    //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;

    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

    // this is actually the interesting part:
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (newImage == nil) {
        NSLog(@"could not scale image");
    }

    return newImage;
}

- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:radian2Degrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView            *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees2Radian(degrees));

    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 0);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);

    //   // Rotate the image context
    CGContextRotateCTM(bitmap, degrees2Radian(degrees));

    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// Proportionately resize, completely fit in view, no cropping
- (UIImage *)imageFitInSize:(CGSize)size
{
    CGSize newSize = ooSizeFitSizeInSize(self.size, size);

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);

    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newimg;
}

// Center, no resize
- (UIImage *)imageCenterInSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);

    CGSize imageSize = self.size;
    float  dwidth = (size.width - imageSize.width) / 2.0f;
    float  dheight = (size.height - imageSize.height) / 2.0f;

    CGRect rect = CGRectMake(dwidth, dheight, imageSize.width, imageSize.height);
    [self drawInRect:rect];

    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newimg;
}

// Fill all pixels
- (UIImage *)imageFillInSize:(CGSize)size
{
    CGSize  imageSize = self.size;
    CGFloat scalex = size.width / imageSize.width;
    CGFloat scaley = size.height / imageSize.height;
    CGFloat scale = MAX(scalex, scaley);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);

    CGFloat width = imageSize.width * scale;
    CGFloat height = imageSize.height * scale;

    float dwidth = ((size.width - width) / 2.0f);
    float dheight = ((size.height - height) / 2.0f);

    CGRect rect = CGRectMake(dwidth, dheight, imageSize.width * scale, imageSize.height * scale);
    [self drawInRect:rect];

    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newimg;
}

@end
