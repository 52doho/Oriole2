//
//  OOGeometry+Extend.h
//  Oriole2
//
//  Created by Gary Wong on 2/26/11.
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
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>


//unit convertion
static inline CGFloat 
degrees2Radian(const CGFloat degrees)
{
	return degrees * M_PI / 180.0;
}

static inline CGFloat
radian2Degrees(const CGFloat redian)
{
	return redian * 180.0 / M_PI;
}

static inline CGFloat
kg2lbs(const CGFloat kg)
{
	return kg * 2.2046226218488;
}

static inline CGFloat
lbs2kg(CGFloat lbs)
{
	return lbs / 2.2046226218488;
}

static inline CGFloat
centimeter2feet(CGFloat centimeter)
{
	return centimeter / 30.48;
}

static inline CGFloat
feet2centimeter(CGFloat feet)
{
	return feet * 30.48;
}

static inline CGFloat
centimeter2inch(CGFloat centimeter)
{
	return centimeter / 2.54;
}

static inline CGFloat
inch2centimeter(CGFloat inch)
{
	return inch * 2.54;
}

static inline CGFloat
km2Mile(CGFloat km)
{
	return km * 0.62137119223733;
}

static inline CGFloat
mile2Km(CGFloat mile)
{
	return mile / 0.62137119223733;
}


static inline CGSize
ooSizeFitSizeInSize(CGSize size, CGSize inSize)
{
    CGFloat scale;
	CGSize newsize = size;
	
	if (newsize.height && (newsize.height > inSize.height))
	{
		scale = inSize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	if (newsize.width && (newsize.width >= inSize.width))
	{
		scale = inSize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
    
 	return newsize;
}

static inline CGRect
ooRectCenterSizeInSize(CGSize aSize, CGSize inSize)
{
    CGSize size = ooSizeFitSizeInSize(aSize, inSize);
	float dWidth = inSize.width - size.width;
	float dHeight = inSize.height - size.height;
	
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, size.width, size.height);
}

static inline CGRect
ooRectScaleAspectFillSizeInSize(CGSize size, CGSize inSize)
{
    CGFloat scalex = inSize.width / size.width;
	CGFloat scaley = inSize.height / size.height; 
	CGFloat scale = MAX(scalex, scaley);	
	
	CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	
	float dwidth = ((inSize.width - width) / 2.0f);
	float dheight = ((inSize.height - height) / 2.0f);
	
	return CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
}

static inline CGRect
ooRectScaleAspectFitSizeInSize(CGSize size, CGSize inSize)
{
    CGFloat scalex = inSize.width / size.width;
	CGFloat scaley = inSize.height / size.height;
	CGFloat scale = MIN(scalex, scaley);
	
	CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	
	float dwidth = ((inSize.width - width) / 2.0f);
	float dheight = ((inSize.height - height) / 2.0f);
	
	return CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
}



//NOTE:The following are from cocos2d. Copyright is reserved to the authors.
//The prefix of "oop" are changed to "oop" to avoid name conflicting.
/* cocos2d for iPhone
 * http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2007 Scott Lembcke
 * Copyright (c) 2010 Lam Pham
 */

/** @def OO_SWAP
 simple macro that swaps 2 variables
 */
#define OO_SWAP( x, y )			\
({ __typeof__(x) temp  = (x);		\
x = y; y = temp;		\
})

/** Helper macro that creates a CGPoint
 @return CGPoint
 @since v0.7.2
 */
#define oop(__X__,__Y__) CGPointMake(__X__,__Y__)


/** Returns opposite of point.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopNeg(const CGPoint v)
{
	return oop(-v.x, -v.y);
}

/** Calculates sum of two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopAdd(const CGPoint v1, const CGPoint v2)
{
	return oop(v1.x + v2.x, v1.y + v2.y);
}

/** Calculates difference of two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopSub(const CGPoint v1, const CGPoint v2)
{
	return oop(v1.x - v2.x, v1.y - v2.y);
}

/** Returns point multiplied by given factor.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopMult(const CGPoint v, const CGFloat s)
{
	return oop(v.x*s, v.y*s);
}

/** Calculates midpoint between two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopMidpoint(const CGPoint v1, const CGPoint v2)
{
	return oopMult(oopAdd(v1, v2), 0.5f);
}

/** Calculates dot product of two points.
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
oopDot(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}

/** Calculates cross product of two points.
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
oopCross(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

/** Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopPerp(const CGPoint v)
{
	return oop(-v.y, v.x);
}

/** Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopRPerp(const CGPoint v)
{
	return oop(v.y, -v.x);
}

/** Calculates the projection of v1 over v2.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopProject(const CGPoint v1, const CGPoint v2)
{
	return oopMult(v2, oopDot(v1, v2)/oopDot(v2, v2));
}

/** Rotates two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopRotate(const CGPoint v1, const CGPoint v2)
{
	return oop(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

/** Unrotates two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
oopUnrotate(const CGPoint v1, const CGPoint v2)
{
	return oop(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

/** Calculates the square length of a CGPoint (not calling sqrt() )
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
oopLengthSQ(const CGPoint v)
{
	return oopDot(v, v);
}

/** Calculates distance between point an origin
 @return CGFloat
 @since v0.7.2
 */
CGFloat oopLength(const CGPoint v);

/** Calculates the distance between two points
 @return CGFloat
 @since v0.7.2
 */
CGFloat oopDistance(const CGPoint v1, const CGPoint v2);

/** Returns point multiplied to a length of 1.
 @return CGPoint
 @since v0.7.2
 */
CGPoint oopNormalize(const CGPoint v);

/** Converts radians to a normalized vector.
 @return CGPoint
 @since v0.7.2
 */
CGPoint oopForAngle(const CGFloat a);

/** Converts a vector to radians.
 @return CGFloat
 @since v0.7.2
 */
CGFloat oopToAngle(const CGPoint v);


/** Clamp a value between from and to.
 @since v0.99.1
 */
float vs_clampf(float value, float min_inclusive, float max_inclusive);

/** Clamp a point between from and to.
 @since v0.99.1
 */
CGPoint oopClamp(CGPoint p, CGPoint from, CGPoint to);

/** Quickly convert CGSize to a CGPoint
 @since v0.99.1
 */
CGPoint oopFromSize(CGSize s);

/** Run a math operation function on each point component
 * absf, fllorf, ceilf, roundf
 * any function that has the signature: float func(float);
 * For example: let's try to take the floor of x,y
 * oopCompOp(p,floorf);
 @since v0.99.1
 */
CGPoint oopCompOp(CGPoint p, float (*opFunc)(float));

/** Linear Interpolation between two points a and b
 @returns
 alpha == 0 ? a
 alpha == 1 ? b
 otherwise a value between a..b
 @since v0.99.1
 */
CGPoint oopLerp(CGPoint a, CGPoint b, float alpha);


/** @returns if points have fuzzy equality which means equal with some degree of variance.
 @since v0.99.1
 */
BOOL oopFuzzyEqual(CGPoint a, CGPoint b, float variance);


/** Multiplies a nd b components, a.x*b.x, a.y*b.y
 @returns a component-wise multiplication
 @since v0.99.1
 */
CGPoint oopCompMult(CGPoint a, CGPoint b);

/** @returns the signed angle in radians between two vector directions
 @since v0.99.1
 */
float oopAngleSigned(CGPoint a, CGPoint b);

/** @returns the angle in radians between two vector directions
 @since v0.99.1
 */
float oopAngle(CGPoint a, CGPoint b);

/** Rotates a point counter clockwise by the angle around a pivot
 @param v is the point to rotate
 @param pivot is the pivot, naturally
 @param angle is the angle of rotation cw in radians
 @returns the rotated point
 @since v0.99.1
 */
CGPoint oopRotateByAngle(CGPoint v, CGPoint pivot, float angle);

/** A general line-line intersection test
 @param p1 
 is the startpoint for the first line P1 = (p1 - p2)
 @param p2 
 is the endpoint for the first line P1 = (p1 - p2)
 @param p3 
 is the startpoint for the second line P2 = (p3 - p4)
 @param p4 
 is the endpoint for the second line P2 = (p3 - p4)
 @param s 
 is the range for a hitpoint in P1 (pa = p1 + s*(p2 - p1))
 @param t
 is the range for a hitpoint in P3 (pa = p2 + t*(p4 - p3))
 @return bool 
 indicating successful intersection of a line
 note that to truly test intersection for segments we have to make 
 sure that s & t lie within [0..1] and for rays, make sure s & t > 0
 the hit point is		p3 + t * (p4 - p3);
 the hit point also is	p1 + s * (p2 - p1);
 @since v0.99.1
 */
BOOL oopLineIntersect(CGPoint p1, CGPoint p2, 
					  CGPoint p3, CGPoint p4,
					  float *s, float *t);
