//
//  OOSoundManager.m
//  GuessTheBrand
//
//  Created by Gary Wong on 6/21/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#include "OOSoundManager.h"

static OOSoundManager* m_Instance = NULL;

OOSoundManager::OOSoundManager()
{
    buttonTapSoundName = false;
    
    audioEngine = SimpleAudioEngine::sharedEngine();
}

OOSoundManager::~OOSoundManager()
{
    if(m_Instance)
        delete m_Instance;
    m_Instance = NULL;
}

OOSoundManager* OOSoundManager::sharedSoundManager()
{
    if(m_Instance == NULL)
        m_Instance = new OOSoundManager();
    return m_Instance;
}

unsigned int OOSoundManager::playEffect(const char* soundName, bool loop)
{
    if(canPlayEffect)
    {
        return audioEngine->playEffect(soundName, loop);
    }
    else
        return 0;
}

unsigned int OOSoundManager::playEffect(const char* soundName)
{
    return OOSoundManager::playEffect(soundName, false);
}

unsigned int OOSoundManager::playEffectButtonTap()
{
    if(buttonTapSoundName != NULL)
        return playEffect(buttonTapSoundName);
    else
    {
        CCLog("buttonTapSoundName not set");
        return 0;
    }
}

void OOSoundManager::stopEffect(unsigned int soundId)
{
    audioEngine->stopEffect(soundId);
}

void OOSoundManager::playBGM(const char* soundName, bool loop)
{
    if(canPlayBGM)
    {
        CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(OOSoundManager::_fadeBGMUpdate), this);
        audioEngine->setBackgroundMusicVolume(1);
        
        audioEngine->playBackgroundMusic(soundName, loop);
    }
}

#define kFadeRepeat 15
void OOSoundManager::stopBGM(bool fade)
{
    if(fade)
    {
        isStopBGM = true;
        _fadeBGM();
    }
    else
        audioEngine->stopBackgroundMusic(false);
}

void OOSoundManager::stopBGM()
{
    stopBGM(true);
}

void OOSoundManager::pauseBGM(bool fade)
{
    if(fade)
    {
        isStopBGM = false;
        _fadeBGM();
    }
    else
        audioEngine->pauseBackgroundMusic();
}

void OOSoundManager::pauseBGM()
{
    pauseBGM(true);
}

void OOSoundManager::resumeBGM()
{
    CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(OOSoundManager::_fadeBGMUpdate), this);
    audioEngine->setBackgroundMusicVolume(1);
    
    audioEngine->resumeBackgroundMusic();
}

void OOSoundManager::rewindBGM()
{
    audioEngine->rewindBackgroundMusic();
}

void OOSoundManager::_fadeBGM()
{
    currentBGMusicVolume = 1;
    stepBGMusicVolume = currentBGMusicVolume / kFadeRepeat;
    
    CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(OOSoundManager::_fadeBGMUpdate), this);
    CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(OOSoundManager::_fadeBGMUpdate), this, 1/60., kFadeRepeat, 0, false);
}

void OOSoundManager::_fadeBGMUpdate()
{
    currentBGMusicVolume -= stepBGMusicVolume;
    if(currentBGMusicVolume <= 0)
    {
        if(isStopBGM)
            audioEngine->stopBackgroundMusic(false);
        else
            audioEngine->pauseBackgroundMusic();
        audioEngine->setBackgroundMusicVolume(1);
    }
    else
        audioEngine->setBackgroundMusicVolume(currentBGMusicVolume);
}

