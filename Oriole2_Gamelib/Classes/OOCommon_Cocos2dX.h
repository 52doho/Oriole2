//
//  OOCommon_Cocos2dX.h
//  GTBX
//
//  Created by Gary Wong on 7/29/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#ifndef __GTBX__OOCommon_Cocos2dX__
#define __GTBX__OOCommon_Cocos2dX__

#include "cocos2d.h"
#include "cocos-ext.h"
USING_NS_CC;
USING_NS_CC_EXT;

#define OOX_RANDOM(from, to) ((arc4random() % RAND_MAX) / (RAND_MAX * 1.0) * (to - from) + from)
#define OOX_RANDOM_MINUS1_1() (OOX_RANDOM(-1, 1))
#define OOX_RANDOM_0_1() (OOX_RANDOM(0, 1))

#define OOX_IsKindOfClass(obj,class) (dynamic_cast<class*>(obj) != NULL)

#endif /* defined(__GTBX__OOCommon_Cocos2dX__) */

#ifndef __GTBX__CCMessageBoxDelegate__
#define __GTBX__CCMessageBoxDelegate__
class CCMessageBoxDelegate
{
public:
    virtual void clickedButtonAtIndex(int index) = 0;
};
#endif

#ifndef __GTBX__OOX_CallbackObject__
#define __GTBX__OOX_CallbackObject__
class OOX_CallbackObject : public CCObject
{
public:
    CREATE_FUNC(OOX_CallbackObject);
    OOX_CallbackObject() {isSessionFirstOpen = false; isError = false; };
    bool init(){ return true; };
    CC_SYNTHESIZE(bool, isSessionFirstOpen, IsSessionFirstOpen);
    CC_SYNTHESIZE(bool, isError, IsError);
};
#endif

bool OOX_isiPhone();
bool OOX_isiPhone_5();
bool OOX_isiPad();

void OOX_oc_retain(void *obj);
void OOX_oc_release(void *obj);

void OOX_setAutoDimScreen(bool dim);
void OOX_removeAllLocalNotifications();

const char * OOX_getCurrentLanguage();
const char * OOX_getAppVersion();
const char * OOX_getLocalizedAppName();
const char * OOX_getFeedbackHeader();
const char * OOX_getFeedbackDeviceInfo();
const char * OOX_getFeedbackDeviceInfoWithNewLine(bool newLine);

void OOX_iRateLogEvent();
void OOX_iRateOpenRatingsPageInAppStore();
void CCMessageBox(const char * pszMsg, const char * pszTitle, CCMessageBoxDelegate *delegate, std::string buttons[], int buttonsLength);

void OOX_showExternalPromotion();

bool OOX_gameCenter_isAvailable();
bool OOX_gameCenter_isUserAuthenticated();
void OOX_gameCenter_openLeaderboard();
void OOX_gameCenter_reportScore(int score, const char *leaderboard);
void OOX_gameCenter_reportAchievement(const char *achievement, float percentComplete);
void OOX_gameCenter_saveData();

void OOX_keychain_saveStringForKey(const char *string, const char *key);
void OOX_keychain_saveIntForKey(int value, const char *key);
void OOX_keychain_saveLongForKey(long value, const char *key);
void OOX_keychain_saveBoolForKey(bool value, const char *key);
const char* OOX_keychain_getStringForKey(const char *key);
int OOX_keychain_getIntForKey(const char *key, int defaultValue);
long OOX_keychain_getLongForKey(const char *key, long defaultValue);
bool OOX_keychain_getBoolForKey(const char *key);

const char* OOX_sec_tripleDES(const char* text, const char* key, bool isDecrypt);
CCData* OOX_sec_AES256(CCData* data, CCData* key, bool isDecrypt);

CCObject * OOX_JSONObjectWithString(const char*str);

const char* OOX_localizedString(const char*str);
const char* OOX_localizedStringInOOBundle(const char*str);

//Ref: http://stackoverflow.com/questions/313970/stl-string-to-lower-case
const char* OOX_lowercaseString(const char*str);

//Ref: http://blog.csdn.net/arduousbonze/article/details/2991397
#ifndef __GTBX__OOX_convertToString__
#define __GTBX__OOX_convertToString__
template <class T>
std::string OOX_convertToString(T value)
{
    std::stringstream ss;
    ss << value;
    return ss.str();
}
#endif

void OOX_convertToReadableText(int value, std::string &str);

void OOX_ui_showToastMessage(const char* text);
void OOX_openUrl(const char* url);

/* creates a new CCImage from with the texture's data.
 Caller is responsible for releasing it by calling delete.
 */
CCImage *OOX_renderNodeToImage(CCNode *node, CCSize size, CCPoint position);
CCImage *OOX_renderNodeToImage(CCNode *node);

void *OOX_getImageWithName(const char *name);
const char *OOX_shareTextManager_valueForKey(const char*key);
//@type 0:facebook, 1 weibo
void OOX_shareImage(void *image, const char *text, int type);
void OOX_shareOnInstagramImage(void *image, const char *text, CCRect rect);

bool OOX_isConnectToFB();
void OOX_sendFBGift(const char *title, const char *message, CCObject *target, SEL_CallFuncO selector);

bool OOX_canSendMail();
void OOX_sendMail(CCArray *toRecipients, const char *body, const char *subject, CCObject *target, SEL_CallFuncO selector);
void OOX_sendMail(CCArray *toRecipients, const char *body, const char *subject);

void OOX_externalPromotionManager_showAdWithPlacement(const char*placement);
