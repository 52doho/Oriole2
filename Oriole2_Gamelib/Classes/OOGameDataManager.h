//
//  OOGameDataManager.h
//  SlotsFarm
//
//  Created by ZhangChenglong on 13-7-19.
//  Copyright (c) 2013年 Oriole2 Co., Ltd. All rights reserved.
//

#include "cocos2d.h"
USING_NS_CC;

class OOGameDataManager : public CCObject
{
public:
    OOGameDataManager();
    virtual ~OOGameDataManager();
    
    unsigned int getCoins();
    unsigned int addCoins(unsigned int value);
    unsigned int subtractCoins(unsigned int value);
    
    unsigned int getGems();
    unsigned int addGems(unsigned int value);
    unsigned int subtractGems(unsigned int value);
    
    unsigned int getLevel();
    virtual void skipToNextLevel();
    
    bool getIsNotificationOn();
    void setIsNotificationOn(bool on);
    void toggleIsNotificationOn();
    
    bool getIsBGMusicOn();
    void setIsBGMusicOn(bool on);
    void toggleIsBGMusicOn();
    bool getIsSoundOn();
    void setIsSoundOn(bool on);
    void toggleIsSoundOn();
    
    void updateLastBonusTime();
    void setBonusIsReady();
    // 0 sec means bonus is ready
    long getRemainingBonusTime();
    float getBonusDurationInSeconds();
    
protected:
    unsigned int coins, gems, level;
    long lastBonusTime;
    unsigned int bonusDuration = 60 * 60;//seconds
    bool isNotificationOn, isBGMusicOn, isSoundOn;
    
    void readData();
    void writeData();
};
