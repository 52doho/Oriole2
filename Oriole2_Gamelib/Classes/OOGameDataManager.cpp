//
//  OOGameDataManager.m
//  SlotsFarm
//
//  Created by ZhangChenglong on 13-7-19.
//  Copyright (c) 2013年 Oriole2 Co., Ltd. All rights reserved.
//

#include "OOGameDataManager.h"
#include "OOSoundManager.h"
#include "OOCommon_Cocos2dX.h"
#include <mach/mach_time.h>//NOTE: only for iOS

#define kKeychainCoins "kKeychainCoins"
#define kKeychainGems "kKeychainGems"
#define kKeychainLevel "kKeychainLevel"
#define kKeychainIsNotificationOn "kKeychainIsNotificationOn"
#define kKeychainIsBGMusicOn "kKeychainIsBGMusicOn"
#define kKeychainIsSoundOn "kKeychainIsSoundOn"
#define kKeychainLastBonusTime "kKeychainLastBonusTime"

//get time since last reboot to avoid date be changed in Settings.
//It's better to get date from web service.
int getTimeInSecondsSinceLastReboot()
{
    const int64_t kOneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    return (int)((mach_absolute_time() * s_timebase_info.numer) / (kOneMillion * 1000 * s_timebase_info.denom));
}

OOGameDataManager::OOGameDataManager()
{
//    CCNotificationCenter::sharedNotificationCenter()->addObserver(this, callfuncO_selector(), "GameCenterManagerReportAchievementNotification", NULL);
}

OOGameDataManager::~OOGameDataManager()
{
//    CCNotificationCenter::sharedNotificationCenter()->removeAllObservers(this);
    
    writeData();
}

void OOGameDataManager::readData()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS && !TARGET_IPHONE_SIMULATOR)
    coins = OOX_keychain_getIntForKey(kKeychainCoins, 0);
    gems = OOX_keychain_getIntForKey(kKeychainGems, 0);
    level = OOX_keychain_getIntForKey(kKeychainLevel, 1);
    lastBonusTime = OOX_keychain_getLongForKey(kKeychainLastBonusTime, 0);
    isNotificationOn = OOX_keychain_getBoolForKey(kKeychainIsNotificationOn);
    isBGMusicOn = OOX_keychain_getBoolForKey(kKeychainIsBGMusicOn);
    isSoundOn = OOX_keychain_getBoolForKey(kKeychainIsSoundOn);
#else
    coins = CCUserDefault::sharedUserDefault()->getIntegerForKey(kKeychainCoins);
    gems = CCUserDefault::sharedUserDefault()->getIntegerForKey(kKeychainGems);
    level = CCUserDefault::sharedUserDefault()->getIntegerForKey(kKeychainLevel);
    if(level <= 0)//bounds check
        level = 1;
    lastBonusTime = CCUserDefault::sharedUserDefault()->getDoubleForKey(kKeychainLastBonusTime);
    isNotificationOn = CCUserDefault::sharedUserDefault()->getBoolForKey(kKeychainIsNotificationOn);
    isBGMusicOn = CCUserDefault::sharedUserDefault()->getBoolForKey(kKeychainIsBGMusicOn);
    isSoundOn = CCUserDefault::sharedUserDefault()->getBoolForKey(kKeychainIsSoundOn);
#endif
    
    //validate checking
    int now = getTimeInSecondsSinceLastReboot();
    if(now < lastBonusTime)
        lastBonusTime = now;
    
    OOSoundManager::sharedSoundManager()->setCanPlayBGM(isBGMusicOn);
    OOSoundManager::sharedSoundManager()->setCanPlayEffect(isSoundOn);
}

void OOGameDataManager::writeData()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS && !TARGET_IPHONE_SIMULATOR)
    OOX_keychain_saveIntForKey(coins, kKeychainCoins);
    OOX_keychain_saveIntForKey(gems, kKeychainGems);
    OOX_keychain_saveIntForKey(level, kKeychainLevel);
    OOX_keychain_saveLongForKey(lastBonusTime, kKeychainLastBonusTime);
    OOX_keychain_saveBoolForKey(isNotificationOn, kKeychainIsNotificationOn);
    OOX_keychain_saveBoolForKey(isBGMusicOn, kKeychainIsBGMusicOn);
    OOX_keychain_saveBoolForKey(isSoundOn, kKeychainIsSoundOn);
#else
    CCUserDefault::sharedUserDefault()->setIntegerForKey(kKeychainCoins, coins);
    CCUserDefault::sharedUserDefault()->setIntegerForKey(kKeychainGems, gems);
    CCUserDefault::sharedUserDefault()->setIntegerForKey(kKeychainLevel, level);
    CCUserDefault::sharedUserDefault()->setDoubleForKey(kKeychainLastBonusTime, lastBonusTime);
    CCUserDefault::sharedUserDefault()->setBoolForKey(kKeychainIsNotificationOn, isNotificationOn);
    CCUserDefault::sharedUserDefault()->setBoolForKey(kKeychainIsBGMusicOn, isBGMusicOn);
    CCUserDefault::sharedUserDefault()->setBoolForKey(kKeychainIsSoundOn, isSoundOn);
    CCUserDefault::sharedUserDefault()->flush();
#endif
}

unsigned int OOGameDataManager::getCoins()
{
    return coins;
}

unsigned int OOGameDataManager::addCoins(unsigned int value)
{
    coins += value;
    
    return coins;
}

unsigned int OOGameDataManager::subtractCoins(unsigned int value)
{
    if(coins >= value)
    {
        coins -= value;
    }
    return coins;
}

unsigned int OOGameDataManager::getGems()
{
    return gems;
}

unsigned int OOGameDataManager::addGems(unsigned int value)
{
    gems += value;
    
    return gems;
}

unsigned int OOGameDataManager::subtractGems(unsigned int value)
{
    if(gems >= value)
    {
        gems -= value;
    }
    return gems;
}

unsigned int OOGameDataManager::getLevel()
{
    return level;
}

void OOGameDataManager::skipToNextLevel()
{
    level++;
}

long OOGameDataManager::getRemainingBonusTime()
{
    long nextBonusTime = lastBonusTime + bonusDuration;
    
//    struct cc_timeval now;
//    CCTime::gettimeofdayCocos2d(&now, NULL);
//    long remaining = nextBonusTime - now.tv_sec;
    int now = getTimeInSecondsSinceLastReboot();
    long remaining = nextBonusTime - now;
    if(remaining < 0)
        remaining = 0;
    
    return remaining;
}

float OOGameDataManager::getBonusDurationInSeconds()
{
    return bonusDuration;
}

void OOGameDataManager::updateLastBonusTime()
{
//    struct cc_timeval now;
//    CCTime::gettimeofdayCocos2d(&now, NULL);
//    lastBonusTime = now.tv_sec;
    lastBonusTime = getTimeInSecondsSinceLastReboot();
}

void OOGameDataManager::setBonusIsReady()
{
//    struct cc_timeval now;
//    CCTime::gettimeofdayCocos2d(&now, NULL);
//    lastBonusTime = now.tv_sec - bonusDuration;
    int now = getTimeInSecondsSinceLastReboot();
    lastBonusTime = now - bonusDuration;
}

bool OOGameDataManager::getIsNotificationOn()
{
    return isNotificationOn;
}

void OOGameDataManager::setIsNotificationOn(bool on)
{
    if(isNotificationOn != on)
    {
        isNotificationOn = on;
    }
}

void OOGameDataManager::toggleIsNotificationOn()
{
    isNotificationOn = !isNotificationOn;
}

bool OOGameDataManager::getIsBGMusicOn()
{
    return isBGMusicOn;
}

void OOGameDataManager::setIsBGMusicOn(bool on)
{
    if(isBGMusicOn != on)
    {
        isBGMusicOn = on;
    }
    OOSoundManager::sharedSoundManager()->setCanPlayBGM(on);
    
    if(!on)
        OOSoundManager::sharedSoundManager()->stopBGM();
}

void OOGameDataManager::toggleIsBGMusicOn()
{
    setIsBGMusicOn(!isBGMusicOn);
}

bool OOGameDataManager::getIsSoundOn()
{
    return isSoundOn;
}

void OOGameDataManager::setIsSoundOn(bool on)
{
    if(isSoundOn != on)
    {
        isSoundOn = on;
    }
    OOSoundManager::sharedSoundManager()->setCanPlayEffect(on);
}

void OOGameDataManager::toggleIsSoundOn()
{
    setIsSoundOn(!isSoundOn);
}
