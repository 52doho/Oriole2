//
//  EXTurnCard.h
//  Cocos2dxExt
//
//  Created by LiuYanghui on 13-7-10.
//
//

#ifndef __Cocos2dxExt__EXTurnCard__
#define __Cocos2dxExt__EXTurnCard__

#include "cocos2d.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;

class EXTurnCard : public CCSprite
{
public:
    CREATE_FUNC(EXTurnCard);
    EXTurnCard();
    ~EXTurnCard();
    static EXTurnCard* create(const char* inCardImageName, const char* outCardImageName, float duration);
    bool init();
    virtual bool init(const char* inCardImageName, const char* outCardImageName, float duration);
    void initData(const char* inCardImageName, const char* outCardImageName, float duration);
    
    void openCard();
    void closeCard();
    
    CCSprite *inCard, *outCard;
    
private:
    bool m_isOpened;
    CCActionInterval* m_openAnimIn;
    CCActionInterval* m_openAnimOut;
};

class EXTurnCardLoader : public CCSpriteLoader
{
public:
    CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(EXTurnCardLoader, loader);
protected:
    CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(EXTurnCard);
};

#endif /* defined(__Cocos2dxExt__EXTurnCard__) */
