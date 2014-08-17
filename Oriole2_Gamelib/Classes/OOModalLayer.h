#ifndef GTBMODALLAYER_H
#define GTBMODALLAYER_H
//
//  OOModalLayer.h
//  GTB
//
//  Created by Gary Wong on 6/24/13.
//  Copyright 2013 Oriole2 Co., Ltd. All rights reserved.
//

#include "OOLayerBase.h"

#define kModalLayerTapOnLayerColor \
virtual void tapOnLayerColor();

class OOModalLayer;
class OOModalLayerDelegate
{
public:
    virtual ~OOModalLayerDelegate() {}
    virtual void modelLayerOnExit(OOModalLayer *layer) = 0;
};

class OOModalLayer: public OOLayerBase
{
public:
    OOModalLayer();
    virtual ~OOModalLayer();
    virtual void onEnter();
    virtual void onExit();
    
    kCCBaseProtocol;
    CC_SYNTHESIZE(OOModalLayerDelegate *, delegate, Delegate);
    
    void registerWithTouchDispatcher();
    bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
    void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
    
    kModalLayerTapOnLayerColor;
    
private:
    int priority;
    
    bool _containsTouchableControlInNode(CCNode * node, CCTouch * touch);
    bool _containsNonLayerColorInNode(CCNode * node, CCTouch * touch, unsigned int depth);
};

#endif //GTBMODALLAYER_H