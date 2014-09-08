//
//  OOGeometry+Extend.m
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

#import "OOGeometry+Extend.h"

#define kCGPointEpsilon FLT_EPSILON

CGFloat
oopLength(const CGPoint v)
{
    return sqrtf(oopLengthSQ(v));
}

CGFloat
oopDistance(const CGPoint v1, const CGPoint v2)
{
    return oopLength(oopSub(v1, v2));
}

CGPoint
oopNormalize(const CGPoint v)
{
    return oopMult(v, 1.0f / oopLength(v));
}

CGPoint
oopForAngle(const CGFloat a)
{
    return oop(cosf(a), sinf(a));
}

CGFloat
oopToAngle(const CGPoint v)
{
    return atan2f(v.y, v.x);
}

CGPoint oopLerp(CGPoint a, CGPoint b, float alpha)
{
    return oopAdd(oopMult(a, 1.f - alpha), oopMult(b, alpha));
}

float vs_clampf(float value, float min_inclusive, float max_inclusive)
{
    if (min_inclusive > max_inclusive) {
        OO_SWAP(min_inclusive, max_inclusive);
    }

    return value < min_inclusive ? min_inclusive : value < max_inclusive ? value : max_inclusive;
}

CGPoint oopClamp(CGPoint p, CGPoint min_inclusive, CGPoint max_inclusive)
{
    return oop(vs_clampf(p.x, min_inclusive.x, max_inclusive.x), vs_clampf(p.y, min_inclusive.y, max_inclusive.y));
}

CGPoint oopFromSize(CGSize s)
{
    return oop(s.width, s.height);
}

CGPoint oopCompOp(CGPoint p, float (*opFunc)(float))
{
    return oop(opFunc(p.x), opFunc(p.y));
}

BOOL oopFuzzyEqual(CGPoint a, CGPoint b, float var)
{
    if ((a.x - var <= b.x) && (b.x <= a.x + var)) {
        if ((a.y - var <= b.y) && (b.y <= a.y + var)) {
            return true;
        }
    }

    return false;
}

CGPoint oopCompMult(CGPoint a, CGPoint b)
{
    return oop(a.x * b.x, a.y * b.y);
}

float oopAngleSigned(CGPoint a, CGPoint b)
{
    CGPoint a2 = oopNormalize(a); CGPoint b2 = oopNormalize(b);
    float   angle = atan2f(a2.x * b2.y - a2.y * b2.x, oopDot(a2, b2));

    if (fabs(angle) < kCGPointEpsilon) {
        return 0.f;
    }

    return angle;
}

CGPoint oopRotateByAngle(CGPoint v, CGPoint pivot, float angle)
{
    CGPoint r = oopSub(v, pivot);
    float   t = r.x;
    float   cosa = cosf(angle), sina = sinf(angle);

    r.x = t * cosa - r.y * sina;
    r.y = t * sina + r.y * cosa;
    r = oopAdd(r, pivot);
    return r;
}

BOOL oopLineIntersect(CGPoint p1, CGPoint p2,
    CGPoint p3, CGPoint p4,
    float *s, float *t)
{
    CGPoint p13, p43, p21;
    float   d1343, d4321, d1321, d4343, d2121;
    float   numer, denom;

    p13 = oopSub(p1, p3);

    p43 = oopSub(p4, p3);

    // Roughly equal to zero but with an epsilon deviation for float
    // correction
    if (oopFuzzyEqual(p43, CGPointZero, kCGPointEpsilon)) {
        return false;
    }

    p21 = oopSub(p2, p1);

    // Roughly equal to zero
    if (oopFuzzyEqual(p21, CGPointZero, kCGPointEpsilon)) {
        return false;
    }

    d1343 = oopDot(p13, p43);
    d4321 = oopDot(p43, p21);
    d1321 = oopDot(p13, p21);
    d4343 = oopDot(p43, p43);
    d2121 = oopDot(p21, p21);

    denom = d2121 * d4343 - d4321 * d4321;

    if (fabs(denom) < kCGPointEpsilon) {
        return false;
    }

    numer = d1343 * d4321 - d1321 * d4343;

    *s = numer / denom;
    *t = (d1343 + d4321 * (*s)) / d4343;

    return true;
}

float oopAngle(CGPoint a, CGPoint b)
{
    float angle = acosf(oopDot(oopNormalize(a), oopNormalize(b)));

    if (fabs(angle) < kCGPointEpsilon) {
        return 0.f;
    }

    return angle;
}
