//
//  OOZoomableImageView.m
//  FloatingGallery
//
//  Created by Gary Wong on 2/4/13.
//  Copyright (c) 2013 Oriole2 Ltd. All rights reserved.
//

#import "OOZoomableImageView.h"
#import "OOView+Extend.h"
#import "OOCommon.h"

@interface OOZoomableImageView()
{
    float cachedMinZoomScale;
}

@end

@implementation OOZoomableImageView
@synthesize imageView;

- (void)_setDefault
{
    self.backgroundColor = [UIColor clearColor];
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    self.userInteractionEnabled = YES;
    
    //add gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_doubleTapped:)];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self _setDefault];
    }
    return self;
}

- (void)awakeFromNib
{
    [self _setDefault];
}

- (void)setShouldMonitorDeviceOrientation:(BOOL)value
{
    if(_shouldMonitorDeviceOrientation != value)
    {
        _shouldMonitorDeviceOrientation = value;
        
        if(value)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
}

- (void)_orientationDidChange:(NSNotification *)notification
{
    CGPoint restorePoint = [self _pointToCenterAfterRotation];
    CGFloat restoreScale = [self _scaleToRestoreAfterRotation];
    [self _setMaxMinZoomScalesForCurrentBounds];
    [self _restoreCenterPoint:restorePoint scale:restoreScale];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _delegateZoomableImageView = nil;
}

// Rather than the default behaviour of a {0,0} offset when an image is too small to fill the UIScrollView we're going to return an offset that centres the image in the UIScrollView instead.
- (void)setContentOffset:(CGPoint)anOffset
{
	if(imageView != nil)
    {
		CGSize zoomViewSize = imageView.frame.size;
		CGSize scrollViewSize = self.bounds.size;
		
		if(zoomViewSize.width < scrollViewSize.width)
        {
			anOffset.x = -(scrollViewSize.width - zoomViewSize.width) / 2.0;
		}
		
		if(zoomViewSize.height < scrollViewSize.height)
        {
			anOffset.y = -(scrollViewSize.height - zoomViewSize.height) / 2.0;
		}
	}
	
	super.contentOffset = anOffset;
}

- (void)displayImage:(UIImage *)image scaleAspectFit:(BOOL)scaleAspectFit
{
    if(imageView == nil)
    {
        imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
    }
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    if(scaleAspectFit)
    {
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(0, 0, self.width, self.height);
    }
    else
    {
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    imageView.image = image;
    self.contentSize = imageView.frame.size;
    
    [self _setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
    
    OOLog(@"displayImage, end frame: %@", NSStringFromCGRect(imageView.frame));
}

- (void)displayImage:(UIImage *)image
{
    [self displayImage:image scaleAspectFit:NO];
}

- (void)displayEmptyContentWithSize:(CGSize)size
{
    if(imageView == nil)
    {
        imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
    }
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    imageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.contentSize = size;
    [self _setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)_setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = imageView.frame.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    CGFloat maxScale = 1;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale)
    {
        minScale = maxScale;
        maxScale += .1;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = cachedMinZoomScale = minScale;
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

// returns the center point, in image coordinate space, to try to restore after rotation.
- (CGPoint)_pointToCenterAfterRotation
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    return [self convertPoint:boundsCenter toView:imageView];
}

// returns the zoom scale to attempt to restore after rotation.
- (CGFloat)_scaleToRestoreAfterRotation
{
    CGFloat contentScale = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
        contentScale = 0;
    
    return contentScale;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

// Adjusts content offset and scale to try to preserve the old zoomscale and center.
- (void)_restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
{
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:oldCenter fromView:imageView];
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}

- (void)_doubleTapped:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:imageView];
    if (self.zoomScale == self.maximumZoomScale)
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
	else
    {
		// Zoom in
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
        
        if(_shouldMonitorShrinkToMin)
        {
            if([_delegateZoomableImageView respondsToSelector:@selector(zoomableImageView:doubleTappedAtPoint:)])
                [_delegateZoomableImageView zoomableImageView:self doubleTappedAtPoint:touchPoint];
        }
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(_outOfBoundTappable)
        return YES;
    else
        return [super pointInside:point withEvent:event];
}

#pragma mark - UIScrollView delegate -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_shouldMonitorShrinkToMin)
    {
        if([_delegateZoomableImageView respondsToSelector:@selector(scrollViewDidScroll:)])
            [_delegateZoomableImageView scrollViewDidScroll:self];
    }
}


#define kScale .7
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if(_shouldMonitorShrinkToMin && self.alpha != 0)
    {
        BOOL isShrinkToMin;
        if (self.zoomScale / cachedMinZoomScale < kScale)
        {
            self.minimumZoomScale = self.zoomScale;
            isShrinkToMin = YES;
        }
        else
        {
            self.minimumZoomScale = cachedMinZoomScale;
            isShrinkToMin = NO;
        }
        OOLog(@"scrollViewDidZoom  :%.2f, %.2f, %.2f", scrollView.zoomScale, scrollView.minimumZoomScale, scrollView.maximumZoomScale);
        if([_delegateZoomableImageView respondsToSelector:@selector(zoomableImageView:didZoomWithIsShrinkToMin:)])
            [_delegateZoomableImageView zoomableImageView:self didZoomWithIsShrinkToMin:isShrinkToMin];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if(_shouldMonitorShrinkToMin)
    {
        if (self.zoomScale / cachedMinZoomScale < kScale)
        {
            if([_delegateZoomableImageView respondsToSelector:@selector(zoomableImageViewDidShrinkToMin:)])
                [_delegateZoomableImageView zoomableImageViewDidShrinkToMin:self];
        }
    }
}
@end