#ifndef __Eva4Explode__CCHolder__
#define __Eva4Explode__CCHolder__

#include "cocos2d.h"
using namespace cocos2d;
class CCHolderDelegate;
#define kSingleTapInterval 0.2
#define kDoubleTapInterval 0.2
#define kHoveringCount 3
#define kHoveringUnit 0.1
#define kSamePointErrorLimits 30
#define isAlmostSamePoint(pointA, pointB, limits) (fabs(pointA.x - pointB.x) < limits && fabs(pointA.y - pointB.y) < limits)

class CCHolder : public cocos2d::CCLayer {
public:
    virtual bool init();
    CREATE_FUNC(CCHolder);
    void setDelegate(CCHolderDelegate* delegate);
private:
    CCHolderDelegate* _delegate;
    void finishTouchDown();
    void finishSingleTap();
    void startHovering();
    void checkHovering();

    virtual bool ccTouchBegan(CCTouch* pTouch,CCEvent* pEvent);
    virtual void ccTouchMoved(CCTouch* pTouch,CCEvent* pEvent);
    virtual void ccTouchEnded(CCTouch* pTouch,CCEvent* pEvent);
    virtual void ccTouchCancelled(CCTouch* pTouch,CCEvent* pEvent);
};

class CCHolderDelegate {
public:
    virtual void holderTouchedDown(CCHolder* holder){};
    virtual void holderTouchedUp(CCHolder* holder){};
    virtual void holderSingleTaped(CCHolder* holder){};
    virtual void holderDoubleTaped(CCHolder* holder){};
    virtual void holderStartHovering(CCHolder* holder){};
    virtual void holderEndHovering(CCHolder* holder){};
    virtual void holderMovingHorizontally(CCHolder* holder, float increament){};
};

#endif /* defined(__Eva4Explode__CCHolder__) */

