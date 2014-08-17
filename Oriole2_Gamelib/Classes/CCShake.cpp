//
//  SFModalLayer.cpp
//  SlotsFarm
//
//  Created by Gary Wong on 9/26/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#include "CCShake.h"


CCShake::~CCShake()
{
}

CCShake* CCShake::create(float duration, CCPoint amplitude)
{
    return create(duration, amplitude, true, CCSHAKE_EVERY_FRAME);
}

CCShake* CCShake::create(float duration, CCPoint amplitude, bool dampening)
{
    return create(duration, amplitude, dampening, CCSHAKE_EVERY_FRAME);
}

CCShake* CCShake::create(float duration, CCPoint amplitude, int shakeNum)
{
    return create(duration, amplitude, true, shakeNum);
}

CCShake* CCShake::create(float duration, CCPoint amplitude, bool dampening, int shakeNum)
{
    CCShake *shack = new CCShake();
    shack->autorelease();
    shack->initWithDuration(duration, amplitude, dampening, shakeNum);
    
    return shack;
}

bool CCShake::initWithDuration(float duration, CCPoint amplitude, bool isDampening, int shakeNum)
{
    CCActionInterval::initWithDuration(duration);
    
    startAmplitude = amplitude;
    dampening = isDampening;
    // calculate shake intervals based on the number of shakes
    if(shakeNum == CCSHAKE_EVERY_FRAME)
        shakeInterval = 0;
    else
        shakeInterval = 1.f/shakeNum;
    
	return true;
}

CCObject* CCShake::copyWithZone(CCZone *pZone)
{
    CCZone* pNewZone = NULL;
    CCShake* pCopy = NULL;
    if(pZone && pZone->m_pCopyObject)
    {
        //in case of being called at sub class
        pCopy = (CCShake*)(pZone->m_pCopyObject);
    }
    else
    {
        pCopy = new CCShake();
        pZone = pNewZone = new CCZone(pCopy);
    }
    
    CCActionInterval::copyWithZone(pZone);
    
    CC_SAFE_DELETE(pNewZone);
    
    pCopy->initWithDuration(m_fDuration, amplitude, dampening, shakeInterval == 0 ? 0 : 1/shakeInterval);
    
    return pCopy;
}

void CCShake::update(float t)
{
	// waits until enough time has passed for the next shake
	if(shakeInterval == CCSHAKE_EVERY_FRAME)
    {
        // shake every frame!
    }
	else if(t < nextShake)
		return; // haven't reached the next shake point yet
	else
		nextShake += shakeInterval; // proceed with shake this time and increment for next shake goal
    
    // calculate the dampening effect, if being used
    if(dampening)
    {
        float dFactor = (1-t);
        amplitude.x = dFactor * startAmplitude.x;
        amplitude.y = dFactor * startAmplitude.y;
    }
    
	CCPoint p = ccp((CCRANDOM_0_1()*amplitude.x*2) - amplitude.x,(CCRANDOM_0_1()*amplitude.y*2) - amplitude.y);
    
	// simultaneously un-move the last shake and move the next shake
	m_pTarget->setPosition(ccpAdd(ccpSub(m_pTarget->getPosition(), last), p));
    
	// store the current shake value so it can be un-done
	last = p;
}

void CCShake::startWithTarget(CCNode* pTarget)
{
	CCActionInterval::startWithTarget(pTarget);
    
	amplitude	= startAmplitude;
	last		= CCPointZero;
	nextShake	= 0;
}

void CCShake::stop(void)
{
	// undo the last shake
	m_pTarget->setPosition(ccpSub(m_pTarget->getPosition(), last));
    
	CCActionInterval::stop();
}


