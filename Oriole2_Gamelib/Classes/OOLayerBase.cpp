//
//  OOLayerBase.m
//  GTB
//
//  Created by Gary Wong on 6/24/13.
//  Copyright 2013 Oriole2 Co., Ltd. All rights reserved.
//

#include "OOLayerBase.h"

OOLayerBase::OOLayerBase()
: mAnimationManager(NULL)
{
    
}

OOLayerBase::~OOLayerBase()
{
    CC_SAFE_RELEASE_NULL(mAnimationManager);
}

SEL_MenuHandler OOLayerBase::onResolveCCBCCMenuItemSelector(CCObject *pTarget, const char *pSelectorName)
{
    return NULL;
}

SEL_CCControlHandler OOLayerBase::onResolveCCBCCControlSelector(CCObject *pTarget, const char *pSelectorName)
{
    return NULL;
}

bool OOLayerBase::onAssignCCBMemberVariable(CCObject *pTarget, const char *pMemberVariableName, CCNode *pNode)
{
    return false;
}

void OOLayerBase::setAnimationManager(cocos2d::extension::CCBAnimationManager *pAnimationManager)
{
    CC_SAFE_RELEASE_NULL(mAnimationManager);
    mAnimationManager = pAnimationManager;
    CC_SAFE_RETAIN(mAnimationManager);
}

CCBAnimationManager* OOLayerBase::getAnimationManager()
{
    return mAnimationManager;
}

void OOLayerBase::onNodeLoaded(CCNode *pNode, CCNodeLoader *pNodeLoader)
{
}

void OOLayerBase::completedAnimationSequenceNamed(const char *name)
{
    
}
