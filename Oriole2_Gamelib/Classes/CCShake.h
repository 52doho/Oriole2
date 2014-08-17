//
//  SFModalLayer.cpp
//  SlotsFarm
//
//  Created by Gary Wong on 9/26/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#ifndef __TestCpp__CCShake__
#define __TestCpp__CCShake__

#include "cocos2d.h"

USING_NS_CC;

#define CCSHAKE_EVERY_FRAME	0

class CC_DLL CCShake : public CCActionInterval
{
public:
	virtual ~CCShake();
    virtual CCObject* copyWithZone(CCZone* pZone);
    
    static CCShake* create(float duration, CCPoint amplitude);
    static CCShake* create(float duration, CCPoint amplitude, bool dampening);
    static CCShake* create(float duration, CCPoint amplitude, int shakeNum);
    static CCShake* create(float duration, CCPoint amplitude, bool dampening, int shakeNum);
    bool initWithDuration(float duration, CCPoint amplitude, bool dampening, int shakeNum);
    
	/// @see CCAction::update
	virtual void update(float t);
    
	/// @see CCAction::startWithTarget
	virtual void startWithTarget(CCNode* pTarget);
    
    virtual void stop(void);
    
private:
	float shakeInterval;
	float nextShake;
	bool dampening;
	CCPoint startAmplitude;
	CCPoint amplitude;
	CCPoint last;
};


#endif /* defined(__TestCpp__CCShake__) */
