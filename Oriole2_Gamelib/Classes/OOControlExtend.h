//
//  OOControlExtend.h
//  SlotsFarm
//
//  Created by Gary Wong on 8/12/13.
//  Copyright 2013 Oriole2 Co., Ltd. All rights reserved.
//

#ifndef __SlotsFarm__OOControlButtonDisableGray__
#define __SlotsFarm__OOControlButtonDisableGray__

#include "cocos2d.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;

//--------------------------------
class OOControlButtonDisableGray : public CCControlButton
{
public:
    CREATE_FUNC(OOControlButtonDisableGray);
    void setBackgroundSpriteForState(CCScale9Sprite* sprite, CCControlState state);
};

class OOControlButtonDisableGrayLoader : public CCControlButtonLoader
{
public:
    CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(OOControlButtonDisableGrayLoader, loader);
protected:
    CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(OOControlButtonDisableGray);
};


//--------------------------------
//Ref: http://stackoverflow.com/questions/16653013/ccscrollview-with-cccontrolbutton-how-to-control-the-touch-area
class OOControlButtonInScrollView : public OOControlButtonDisableGray
{
public:
    CREATE_FUNC(OOControlButtonInScrollView);
    bool isTouchInside(CCTouch *touch);
    bool ccTouchBegan(CCTouch *touch, CCEvent *event);
    void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
    void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
    void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);
    
private:
    bool dragging;
};

class OOControlButtonInScrollViewLoader : public OOControlButtonDisableGrayLoader
{
public:
    CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(OOControlButtonInScrollViewLoader, loader);
protected:
    CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(OOControlButtonInScrollView);
};

//--------------------------------
class OOLabelBMFontAnimated : public CCLabelBMFont
{
public:
    OOLabelBMFontAnimated(){ valueCurrent = 0; step = 0; };
    CREATE_FUNC(OOLabelBMFontAnimated);
    
    void setIntWithAnimation(int intValue, float animateDuration, unsigned int frame);
    // duration: 1, frame 30
    void setIntWithAnimation(int intValue);
    void setIntWithoutAnimation(int intValue);
    int getIntValue();
    
private:
    float valueCurrent, valueTarget;//NOTE: use float type to accumulate float step
    unsigned int frameCurrent;
    float step;
    
    void _tick();
    void _updateUI();
};

class OOLabelBMFontAnimatedLoader : public CCLabelBMFontLoader
{
public:
    CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(OOLabelBMFontAnimatedLoader, loader);
protected:
    CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(OOLabelBMFontAnimated);
};


//--------------------------------
class OOTableView;
class OOTableViewDelegate
{
public:
    virtual ~OOTableViewDelegate() {}
    virtual void scrollViewDidEndScroll(OOTableView* view) = 0;
};

class OOTableView : public CCTableView
{
public:
    OOTableView();
    static OOTableView* create(CCTableViewDataSource* dataSource, CCSize size);
    
    CC_SYNTHESIZE(OOTableViewDelegate *, delegateTableView, DelegateTableView);
    CC_SYNTHESIZE(float, bounceDistance, BounceDistance);
    CC_SYNTHESIZE(unsigned int, slidingRound, SlidingRound);
    
    void setContentOffsetInDuration_Extend(CCPoint offset, float dt);
    void stopScrollWithDelay(float delay);
    
private:
    void _stoppedAnimatedScroll(CCNode * node);
    void _performedAnimatedScroll(float dt);
    void _stopScroll();
    
    CCPoint targetOffset;
};


//--------------------------------
enum OOProgressSpriteType {
    OOProgressSpriteTypeHorizontal = 0,
    OOProgressSpriteTypeVertical = 1
    };

class OOProgressSprite;
class OOProgressSpriteDelegate
{
public:
    virtual ~OOProgressSpriteDelegate() {}
    virtual void progressSpriteDidChangeProgress(OOProgressSprite *progressSprite, float progress) = 0;
};

/**
 *  从左到右，从下到上
 */
class OOProgressSprite : public CCSprite
{
public:
    OOProgressSprite();
    virtual ~OOProgressSprite();
    CREATE_FUNC(OOProgressSprite);
    
    virtual void onEnter();
    virtual void setTexture(CCTexture2D *texture);
    
    //percent: 0~1
    void setProgress(float percent, bool animated);
    //suppose percent = .3, current progress = .5, if fillFirst, progress will go .5 -> 1 then go 0 -> .3; else it will go from .5 to .3;
    void setProgress(float percent, bool animated, bool fillFirst);
    float getProgressCurrent();
    
    CC_SYNTHESIZE(OOProgressSpriteDelegate *, delegate, Delegate);
    CC_SYNTHESIZE(float, duration, Duration);
    CC_SYNTHESIZE(OOProgressSpriteType, progressType, ProgressType);
    /**
     *  setLeftWidth/setBottomHeight同是设置进度条的起点值
     */
    void setLeftWidth(float width);
    void setBottomHeight(float height);
    
    /**
     *  setRightWidth/setTopHeight同是设置进度条的终点值
     */
    void setRightWidth(float width);
    void setTopHeight(float height);
    
private:
    CCSprite *spriteLeft, *spriteRight;
    float leftWidth, rightWidth, progress, progressTarget, progressVar, progressVarFillFirst1, progressVarFillFirst2;
    unsigned int frame, frameCurrent, frameCurrentFillFirst;
    
    void _updateProgress();
    void _tick();
    void _tickFillFirst();
    void _notifyDelegate();
    void _setSprites();
};

class OOProgressSpriteLoader : public CCSpriteLoader
{
public:
    CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(OOProgressSpriteLoader, loader);
protected:
    CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(OOProgressSprite);
};



#endif