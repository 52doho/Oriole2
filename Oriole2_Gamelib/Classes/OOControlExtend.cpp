//
//  OOControlExtend.m
//  SlotsFarm
//
//  Created by Gary Wong on 8/12/13.
//  Copyright 2013 Oriole2 Co., Ltd. All rights reserved.
//

#include "OOControlExtend.h"
#include "OOCommon_Cocos2dX.h"

//--------------------------------
static const ccColor3B LIGHT_GRAY={200,200,200};
void OOControlButtonDisableGray::setBackgroundSpriteForState(CCScale9Sprite* sprite, CCControlState state)
{
    CCControlButton::setBackgroundSpriteForState(sprite, state);
    
    if(state == CCControlStateDisabled)
    {
        sprite->setColor(LIGHT_GRAY);
    }
}


//--------------------------------
void OOLabelBMFontAnimated::setIntWithAnimation(int intValue, float animateDuration, unsigned int frame)
{
    if(animateDuration > 0 && frame > 0)
    {
        frameCurrent = frame;
        valueTarget = intValue;
        
        step = (float)(intValue - valueCurrent)/frame;
        float interval = animateDuration / frame;
        //unschedule last selector
        unschedule(schedule_selector(OOLabelBMFontAnimated::_tick));
        schedule(schedule_selector(OOLabelBMFontAnimated::_tick), interval, frame, 0);
    }
    else
    {
        valueCurrent = valueTarget = intValue;
        _updateUI();
    }
}

void OOLabelBMFontAnimated::setIntWithAnimation(int intValue)
{
    setIntWithAnimation(intValue, .5, 10);
}

void OOLabelBMFontAnimated::setIntWithoutAnimation(int intValue)
{
    setIntWithAnimation(intValue, 0, 0);
}

int OOLabelBMFontAnimated::getIntValue()
{
    return valueTarget;
}

void OOLabelBMFontAnimated::_tick()
{
    if(frameCurrent > 0)
    {
        frameCurrent--;
        valueCurrent += step;
    }
    else
    {
        //last frame
        valueCurrent = valueTarget;
    }
    _updateUI();
}

void OOLabelBMFontAnimated::_updateUI()
{
    std::string str;
    OOX_convertToReadableText(valueCurrent, str);
    CCLabelBMFont::setString(str.c_str());
}


//--------------------------------
OOTableView::OOTableView()
{
    delegateTableView = NULL;
    bounceDistance = 6;
    slidingRound = 0;
}

OOTableView* OOTableView::create(CCTableViewDataSource* dataSource, CCSize size)
{
    OOTableView *table = new OOTableView();
    table->initWithViewSize(size, NULL);
    table->autorelease();
    table->setDataSource(dataSource);
    table->_updateCellPositions();
    table->_updateContentSize();
    
    return table;
}

#define kBounceDuration .1
void OOTableView::setContentOffsetInDuration_Extend(CCPoint offset, float dt)
{
    m_pContainer->stopAllActions();
    targetOffset = offset;
    
    CCPoint currentOffset = this->getContentOffset();
    CCMoveTo *bounce1 = CCMoveTo::create(kBounceDuration, ccp(currentOffset.x, currentOffset.y + bounceDistance));
    CCMoveTo *moveTo = CCMoveTo::create(dt, ccp(offset.x, offset.y - bounceDistance));
    //Ref:http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:actions_ease
    CCEaseSineInOut *ease = CCEaseSineInOut::create(moveTo);
    CCMoveTo *bounce2 = CCMoveTo::create(kBounceDuration, ccp(offset.x, offset.y));
    CCFiniteTimeAction *expire = CCCallFuncN::create(this, callfuncN_selector(OOTableView::_stoppedAnimatedScroll));
    
    m_pContainer->runAction(CCSequence::create(bounce1, ease, bounce2, expire, NULL));
    this->schedule(schedule_selector(OOTableView::_performedAnimatedScroll));
}

void OOTableView::stopScrollWithDelay(float delay)
{
    CCFiniteTimeAction *expire = CCCallFunc::create(this, callfunc_selector(OOTableView::_stopScroll));
    this->runAction(CCSequence::create(CCDelayTime::create(delay), expire, NULL));
}

void OOTableView::_stopScroll()
{
    m_pContainer->stopAllActions();
    this->setContentOffset(targetOffset);
    
    CCPoint currentOffset = this->getContentOffset();
    CCMoveTo *bounce1 = CCMoveTo::create(kBounceDuration, ccp(currentOffset.x, currentOffset.y + bounceDistance));
    CCMoveTo *bounce2 = CCMoveTo::create(kBounceDuration, ccp(currentOffset.x, currentOffset.y));
    CCFiniteTimeAction *expire = CCCallFuncN::create(this, callfuncN_selector(OOTableView::_stoppedAnimatedScroll));
    
    m_pContainer->runAction(CCSequence::create(bounce1, bounce2, expire, NULL));
}

void OOTableView::_stoppedAnimatedScroll(CCNode * node)
{
    this->unschedule(schedule_selector(OOTableView::_performedAnimatedScroll));
    // After the animation stopped, "scrollViewDidScroll" should be invoked, this could fix the bug of lack of tableview cells.
    if (m_pDelegate != NULL)
    {
        m_pDelegate->scrollViewDidScroll(this);
    }
    if(delegateTableView != NULL)
    {
        delegateTableView->scrollViewDidEndScroll(this);
    }
}

void OOTableView::_performedAnimatedScroll(float dt)
{
    if (m_bDragging)
    {
        this->unschedule(schedule_selector(OOTableView::_performedAnimatedScroll));
        return;
    }
    
    if (m_pDelegate != NULL)
    {
        m_pDelegate->scrollViewDidScroll(this);
    }
}


//--------------------------------
OOProgressSprite::OOProgressSprite()
:spriteLeft(NULL)
,spriteRight(NULL)
{
    duration = .8;
    leftWidth = rightWidth = 0;
    progress = 0;
    delegate = NULL;
    progressType = OOProgressSpriteTypeHorizontal;
}

OOProgressSprite::~OOProgressSprite()
{
}

void OOProgressSprite::onEnter()
{
    CCSprite::onEnter();
    
    //hide original sprite
    setOpacity(0);
    
    _setSprites();
}

void OOProgressSprite::setTexture(CCTexture2D *texture)
{
    CCSprite::setTexture(texture);
    _setSprites();
}

void OOProgressSprite::_setSprites()
{
    if (spriteLeft != NULL)
    {
        spriteLeft->removeFromParentAndCleanup(true);
    }
    if (spriteRight != NULL)
    {
        spriteRight->removeFromParentAndCleanup(true);
    }
    if (getTexture() != NULL)
    {
        spriteLeft = new CCSprite();
        spriteLeft->autorelease();
        spriteLeft->initWithTexture(getTexture(), getTextureRect(), isTextureRectRotated());
        spriteLeft->setAnchorPoint(CCPointZero);
        spriteLeft->setPosition(CCPointZero);
        addChild(spriteLeft);
        
        spriteRight = new CCSprite();
        spriteRight->autorelease();
        spriteRight->initWithTexture(getTexture(), getTextureRect(), isTextureRectRotated());
        spriteRight->setAnchorPoint(CCPointZero);
        spriteRight->setPosition(CCPointZero);
        addChild(spriteRight);
    }
}

void OOProgressSprite::setLeftWidth(float width)
{
    if (progressType == OOProgressSpriteTypeHorizontal)
    {
        CCRect rect = this->getTextureRect();
        CCAssert(width <= rect.size.width, "width must not larger than texture width");
        leftWidth = width;
        
        rect = CCRectMake(rect.origin.x, rect.origin.y, leftWidth, rect.size.height);
        spriteLeft->setTextureRect(rect, isTextureRectRotated(), rect.size);
        _updateProgress();
    }
    else if (progressType == OOProgressSpriteTypeVertical)
    {
        setBottomHeight(width);
    }
}

void OOProgressSprite::setBottomHeight(float height)
{
    if (progressType == OOProgressSpriteTypeVertical)
    {
        CCRect rect = this->getTextureRect();
        CCAssert(height <= rect.size.height, "height must not larger than texture height");
        leftWidth = height;
        
        rect = CCRectMake(rect.origin.x, rect.origin.y, rect.size.width, leftWidth);
        spriteLeft->setTextureRect(rect, isTextureRectRotated(), rect.size);
        _updateProgress();
    }
    else if (progressType == OOProgressSpriteTypeHorizontal)
    {
        setLeftWidth(height);
    }
}

void OOProgressSprite::setRightWidth(float width)
{
    if (progressType == OOProgressSpriteTypeHorizontal)
    {
        CCSize size = this->getContentSize();
        CCAssert(width <= size.width, "width must not larger than texture width");
        rightWidth = width;
        
        _updateProgress();
    }
    else if (progressType == OOProgressSpriteTypeVertical)
    {
        setTopHeight(width);
    }
}

void OOProgressSprite::setTopHeight(float height)
{
    if (progressType == OOProgressSpriteTypeVertical)
    {
        CCSize size = this->getContentSize();
        CCAssert(height <= size.height, "height must not larger than texture height");
        rightWidth = height;
        
        _updateProgress();
    }
    else if (progressType == OOProgressSpriteTypeHorizontal)
    {
        setRightWidth(height);
    }
}

void OOProgressSprite::_updateProgress()
{
    CCRect rect = this->getTextureRect();
    if (progressType == OOProgressSpriteTypeHorizontal)
    {
        float padding = leftWidth + (1 - progress) * (rect.size.width - leftWidth - rightWidth);
        if(isTextureRectRotated())
            rect = CCRectMake(rect.origin.x, padding + rect.origin.y, rect.size.width - padding, rect.size.height);
        else
            rect = CCRectMake(padding + rect.origin.x, rect.origin.y, rect.size.width - padding, rect.size.height);
        spriteRight->setTextureRect(rect, isTextureRectRotated(), rect.size);
        
        spriteRight->setPosition(CCPointMake(spriteLeft->getContentSize().width, 0));
    }
    else if (progressType == OOProgressSpriteTypeVertical)
    {
        float padding = leftWidth + (1 - progress) * (rect.size.height - leftWidth - rightWidth);
        if(isTextureRectRotated())
            rect = CCRectMake(padding + rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - padding);
        else
            rect = CCRectMake(rect.origin.x, padding + rect.origin.y, rect.size.width, rect.size.height - padding);
        spriteRight->setTextureRect(rect, isTextureRectRotated(), rect.size);
        
        spriteRight->setPosition(CCPointMake(rect.origin.x, spriteLeft->getContentSize().height));
    }
}

void OOProgressSprite::_tick()
{
    if(frameCurrent > 1)
    {
        frameCurrent--;
        progress += progressVar;
    }
    else
    {
        //last frame
        progress = progressTarget;
    }
    
    _updateProgress();
    _notifyDelegate();
}

void OOProgressSprite::_tickFillFirst()
{
    if(frameCurrentFillFirst == frame / 2)
    {
        progress = progressVarFillFirst2;
    }
    else if(frameCurrentFillFirst > frame / 2)
    {
        progress += progressVarFillFirst2;
    }
    else
    {
        progress += progressVarFillFirst1;
    }
    _updateProgress();
    _notifyDelegate();
    
    frameCurrentFillFirst++;
}

void OOProgressSprite::_notifyDelegate()
{
    if(delegate)
        delegate->progressSpriteDidChangeProgress(this, progress);
}

void OOProgressSprite::setProgress(float percent, bool animated, bool fillFirst)
{
    //bound check
    if(percent < 0)
        percent = 0;
    else if(percent > 1)
        percent = 1;
    
    if (animated)
    {
        frame = frameCurrent = 20;
        progressTarget = percent;
        if(percent < progress && fillFirst)
        {
            progressVarFillFirst1 = (1 - progress) / (frame / 2);
            progressVarFillFirst2 = (percent - 0) / (frame / 2);
            frameCurrentFillFirst = 0;
            
            float interval = duration / frame;
            //unschedule last selector
            unschedule(schedule_selector(OOProgressSprite::_tickFillFirst));
            schedule(schedule_selector(OOProgressSprite::_tickFillFirst), interval, frame - 1, 0);
            
        }
        else
        {
            progressVar = (percent - progress) / frame;
            float interval = duration / frame;
            //unschedule last selector
            unschedule(schedule_selector(OOProgressSprite::_tick));
            schedule(schedule_selector(OOProgressSprite::_tick), interval, frame - 1, 0);
        }
    }
    else
    {
        progress = percent;
        _updateProgress();
    }
}

void OOProgressSprite::setProgress(float percent, bool animated)
{
    setProgress(percent, animated, true);
}

float OOProgressSprite::getProgressCurrent()
{
    return progress;
}


//--------------------------------
bool OOControlButtonInScrollView::isTouchInside(CCTouch *touch) {
    return !dragging && CCControlButton::isTouchInside(touch);
}

bool OOControlButtonInScrollView::ccTouchBegan(CCTouch *touch, CCEvent *event) {
    dragging = false;
    return CCControlButton::ccTouchBegan(touch, event);
}

void OOControlButtonInScrollView::ccTouchMoved(CCTouch *touch, CCEvent *event) {
    if (!dragging && ccpDistance(touch->getLocation(), touch->getStartLocation()) > 25) {
        dragging = true;
    }
    CCControlButton::ccTouchMoved(touch, event);
}

void OOControlButtonInScrollView::ccTouchEnded(CCTouch *touch, CCEvent *event) {
    CCControlButton::ccTouchEnded(touch, event);
    dragging = false;
}

void OOControlButtonInScrollView::ccTouchCancelled(CCTouch *touch, CCEvent *event) {
    CCControlButton::ccTouchCancelled(touch, event);
    dragging = false;
}
