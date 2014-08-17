//
//  EXTurnCard.cpp
//  Cocos2dxExt
//
//  Created by LiuYanghui on 13-7-10.
//
//

#include "EXTurnCard.h"

#define kInAngleZ        270 //里面卡牌的起始Z轴角度
#define kInDeltaZ        90  //里面卡牌旋转的Z轴角度差

#define kOutAngleZ       0   //封面卡牌的起始Z轴角度
#define kOutDeltaZ       90  //封面卡牌旋转的Z轴角度差

EXTurnCard::EXTurnCard():m_openAnimIn(NULL), m_openAnimOut(NULL)
{
    
}

EXTurnCard::~EXTurnCard()
{
    CC_SAFE_RELEASE(m_openAnimIn);
    CC_SAFE_RELEASE(m_openAnimOut);
}

EXTurnCard* EXTurnCard::create(const char* inCardImageName, const char* outCardImageName, float duration)
{
    EXTurnCard *pSprite = new EXTurnCard();
    if (pSprite && pSprite->init(inCardImageName, outCardImageName, duration))
    {
        pSprite->autorelease();
        return pSprite;
    }
    CC_SAFE_DELETE(pSprite);
    return NULL;
}

bool EXTurnCard::init()
{
    return CCSprite::init();
}

bool EXTurnCard::init(const char* inCardImageName, const char* outCardImageName, float duration)
{
    if (!CCSprite::init())
    {
        return false;
    }
    initData(inCardImageName, outCardImageName, duration);
    return true;
}

#pragma mark - initData
void EXTurnCard::initData(const char* inCardImageName, const char* outCardImageName, float duration)
{
    this->setOpacity(0);
    
    CCPoint position = ccp(CCSprite::getContentSize().width/2, CCSprite::getContentSize().height/2);
    m_isOpened = false;
    
    removeChild(inCard, true);
    inCard = CCSprite::create(inCardImageName);
    inCard->setPosition(position);
    inCard->setVisible(false);
    addChild(inCard);
    
    removeChild(outCard, true);
    outCard = CCSprite::create(outCardImageName);
    outCard->setPosition(position);
    addChild(outCard);
    
    CC_SAFE_RELEASE(m_openAnimIn);
    m_openAnimIn = (CCActionInterval*)CCSequence::create(CCDelayTime::create(duration * .5),
                                                         CCShow::create(),
                                                         CCOrbitCamera::create(duration * .5, 1, 0, kInAngleZ, kInDeltaZ, 0, 0),
                                                         NULL);
    CC_SAFE_RETAIN(m_openAnimIn);
    
    CC_SAFE_RELEASE(m_openAnimOut);
    m_openAnimOut = (CCActionInterval *)CCSequence::create(CCOrbitCamera::create(duration * .5, 1, 0, kOutAngleZ, kOutDeltaZ, 0, 0),
                                                           CCHide::create(),
                                                           CCDelayTime::create(duration * .5),
                                                           NULL);
    CC_SAFE_RETAIN(m_openAnimOut);
}

#pragma mark - public func
void EXTurnCard::openCard()
{
    if (!m_isOpened)
    {
        inCard->runAction(m_openAnimIn);
        outCard->runAction(m_openAnimOut);        
        m_isOpened = !m_isOpened;
    }
}

void EXTurnCard::closeCard()
{
    if (m_isOpened)
    {
        outCard->runAction(m_openAnimIn);
        inCard->runAction(m_openAnimOut);
        m_isOpened = !m_isOpened;
    }
}
