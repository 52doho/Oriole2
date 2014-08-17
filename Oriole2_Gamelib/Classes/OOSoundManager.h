//
//  OOSoundManager.h
//  GuessTheBrand
//
//  Created by Gary Wong on 6/21/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#ifndef __SlotsFarm__OOSoundManager__
#define __SlotsFarm__OOSoundManager__

#include "cocos2d.h"
#include "SimpleAudioEngine.h"

USING_NS_CC;
using namespace CocosDenshion;

class OOSoundManager : public CCObject
{
public:
    OOSoundManager();
    virtual ~OOSoundManager();
    
    static OOSoundManager* sharedSoundManager();
    
    CC_SYNTHESIZE(bool, canPlayEffect, CanPlayEffect);
    CC_SYNTHESIZE(bool, canPlayBGM, CanPlayBGM);
    CC_SYNTHESIZE(const char*, buttonTapSoundName, ButtonTapSoundName);
    
    unsigned int playEffect(const char* soundName, bool loop);
    unsigned int playEffect(const char* soundName);
    unsigned int playEffectButtonTap();
    void stopEffect(unsigned int soundId);
    
    void playBGM(const char* soundName, bool loop);
    void stopBGM(bool fade);
    void stopBGM();
    void pauseBGM(bool fade);
    void pauseBGM();
    void resumeBGM();
    void rewindBGM();
    
private:
    void _fadeBGM();
    void _fadeBGMUpdate();
    float /*originalBGMusicVolume, */currentBGMusicVolume, stepBGMusicVolume;
    bool isStopBGM;
    SimpleAudioEngine *audioEngine;
};

#endif