#include "CCHolder.h"
using namespace cocos2d;

bool CCHolder::init(){
    if (!CCLayer::init()) return false;
    
    CCTouchDispatcher* touchDispatcher = CCDirector::sharedDirector()->getTouchDispatcher();
    touchDispatcher->addTargetedDelegate(this, INT_MIN + 1, true);
    
    return true;
}

void CCHolder::setDelegate(CCHolderDelegate *delegate){
    _delegate = delegate;
}

#pragma mark - Touch Track
bool existComponentTouchDown = false;
bool touchingDown = false;
bool existComponentSingleTap = false;
bool existComponentHovering = false;
unsigned int hoveringNumber = 0;
CCPoint lastTapComponentLocation = CCPointZero;

bool CCHolder::ccTouchBegan(CCTouch* pTouch,CCEvent* pEvent){
    if (!existComponentTouchDown) {
        this->scheduleOnce(schedule_selector(CCHolder::finishTouchDown), kSingleTapInterval);
        existComponentTouchDown = true;
        lastTapComponentLocation = pTouch->getLocationInView();
    }
    return true;
}

void CCHolder::ccTouchMoved(CCTouch* pTouch,CCEvent* pEvent){
    if (!isAlmostSamePoint(pTouch->getPreviousLocationInView(), pTouch->getLocationInView(), 5)) {
        hoveringNumber = 0;
        if (existComponentHovering) {
            _delegate->holderEndHovering(this);
            existComponentHovering = false;
        }else{
            float increatment = pTouch->getLocationInView().x - pTouch->getPreviousLocationInView().x;
            _delegate->holderMovingHorizontally(this, increatment);
        }
    }
}

void CCHolder::ccTouchEnded(CCTouch* pTouch,CCEvent* pEvent){
    if (isAlmostSamePoint(lastTapComponentLocation, pTouch->getLocationInView(), kSamePointErrorLimits)) {
        if (existComponentTouchDown) {
            this->unschedule(schedule_selector(CCHolder::finishTouchDown));
            existComponentTouchDown = false;
            
            if (existComponentSingleTap) {
                this->unschedule(schedule_selector(CCHolder::finishSingleTap));
                existComponentSingleTap = false;
                _delegate->holderDoubleTaped(this);
            }else{
                this->scheduleOnce(schedule_selector(CCHolder::finishSingleTap), kDoubleTapInterval);
                existComponentSingleTap = true;
                lastTapComponentLocation = pTouch->getLocation();
            }
        }
    }
    if (touchingDown) {
        touchingDown = false;
        _delegate->holderTouchedUp(this);
    }
    
    this->unschedule(schedule_selector(CCHolder::checkHovering));
    if (existComponentHovering) {
        _delegate->holderEndHovering(this);
    }
    existComponentTouchDown = existComponentHovering =false;
    lastTapComponentLocation = CCPointZero;
}

void CCHolder::ccTouchCancelled(CCTouch* pTouch,CCEvent* pEvent){
    this->unscheduleAllSelectors();
    if (existComponentHovering) {
        _delegate->holderEndHovering(this);
    }
    existComponentTouchDown = existComponentSingleTap = existComponentHovering =false;
    lastTapComponentLocation = CCPointZero;
}

#pragma mark - Action Component
void CCHolder::finishTouchDown(){
    existComponentTouchDown = false;
    touchingDown = true;
    _delegate->holderTouchedDown(this);
    
    this->schedule(schedule_selector(CCHolder::checkHovering), kHoveringUnit);
}

void CCHolder::finishSingleTap(){
    existComponentSingleTap = false;
    touchingDown = false;
    _delegate->holderSingleTaped(this);
}

void CCHolder::checkHovering(){
    if ((hoveringNumber++ >= kHoveringCount) && !existComponentHovering) {
        existComponentHovering = true;
        _delegate->holderStartHovering(this);
    }
}
