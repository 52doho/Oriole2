//
//  OOCommon_Cocos2dX.cpp
//  GTBX
//
//  Created by Gary Wong on 7/29/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#include "OOCommon_Cocos2dX.h"
#import "GameCenterManager.h"
#import "OOCommon_IOS.h"
#import "Oriole2.h"

@interface ObjCProxy : NSObject<UIAlertViewDelegate, GKLeaderboardViewControllerDelegate>

@property (nonatomic) BOOL needToReleaseSelf;
@property (nonatomic) CCMessageBoxDelegate *delegate;
@property (nonatomic, retain) UIViewController *presentedViewController;

@end

@implementation ObjCProxy

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_delegate)
        _delegate->clickedButtonAtIndex(buttonIndex);
    
    if(_needToReleaseSelf)
        [self release];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [_presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    if(_needToReleaseSelf)
        [self release];
}

- (void)dealloc
{
    [super dealloc];
    CCLOG("proxy dealloc");
}

@end

bool OOX_isiPhone()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
#else
    return false;
#endif
}

bool OOX_isiPhone_5()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return ([[UIScreen mainScreen] bounds].size.height == 568);
#else
    return false;
#endif
}

bool OOX_isiPad()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#else
    return false;
#endif
}

void OOX_oc_retain(void *obj)
{
    NSObject *nsObj = (NSObject *)obj;
    if(obj && [nsObj isKindOfClass:[NSObject class]])
    {
        [nsObj retain];
    }
}

void OOX_oc_release(void *obj)
{
    NSObject *nsObj = (NSObject *)obj;
    if(obj && [nsObj isKindOfClass:[NSObject class]])
    {
        [nsObj release];
    }
}

void OOX_setAutoDimScreen(bool dim)
{
    [UIApplication sharedApplication].idleTimerDisabled = !dim;
}

void OOX_removeAllLocalNotifications()
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

bool OOX_gameCenter_isAvailable()
{
    return [[GameCenterManager sharedManager] isGameCenterAvailable];
}

bool OOX_gameCenter_isUserAuthenticated()
{
    return [[GameCenterManager sharedManager] isUserAuthenticated];
}

void OOX_gameCenter_openLeaderboard()
{
    if(OOX_gameCenter_isUserAuthenticated())
    {
        UIViewController *rootViewController = [OOCommon getRootViewController];
        if(rootViewController)
        {
            ObjCProxy *proxy = [[ObjCProxy alloc] init];
            proxy.needToReleaseSelf = YES;
            proxy.presentedViewController = rootViewController;
            
            GKLeaderboardViewController *leaderboardViewController = [[[GKLeaderboardViewController alloc] init] autorelease];
            [leaderboardViewController setTimeScope:GKLeaderboardTimeScopeAllTime];
            [leaderboardViewController setLeaderboardDelegate:proxy];
            [rootViewController presentViewController:leaderboardViewController animated:YES completion:nil];
        }
    }
    else
    {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:OOLocalizedString(@"Login Game Center to see leaderboard")];
    }
}

void OOX_gameCenter_reportScore(int score, const char *leaderboard)
{
    [[GameCenterManager sharedManager] reportScore:score leaderboard:[OOCommon_IOS nsstringFromCString:leaderboard]];
}

void OOX_gameCenter_reportAchievement(const char *achievement, float percentComplete)
{
    [[GameCenterManager sharedManager] reportAchievement:[OOCommon_IOS nsstringFromCString:achievement] percentComplete:percentComplete];
}

void OOX_gameCenter_saveData()
{
    [[GameCenterManager sharedManager] saveData];
}

const char * OOX_getCurrentLanguage()
{
    return [OOCommon_IOS cstringFromNSString:[OOCommon getCurrentLanguage]];
}

const char * OOX_getAppVersion()
{
    return [OOCommon_IOS cstringFromNSString:[OOCommon getAppVersion]];
}

const char * OOX_getLocalizedAppName()
{
    return [OOCommon_IOS cstringFromNSString:[OOCommon getLocalizedAppName]];
}

const char * OOX_getFeedbackHeader()
{
    return [OOCommon_IOS cstringFromNSString:[OOCommon getFeedbackHeader]];
}

const char * OOX_getFeedbackDeviceInfo()
{
    return [OOCommon_IOS cstringFromNSString:[OOCommon getFeedbackDeviceInfo]];
}

const char * OOX_getFeedbackDeviceInfoWithNewLine(bool newLine)
{
    return [OOCommon_IOS cstringFromNSString:[OOCommon getFeedbackDeviceInfoWithNewLine:newLine]];
}

void OOX_iRateLogEvent()
{
    [[iRate sharedInstance] logEvent:NO];
}

void OOX_iRateOpenRatingsPageInAppStore()
{
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

void CCMessageBox(const char * pszMsg, const char * pszTitle, CCMessageBoxDelegate *delegate, std::string buttons[], int buttonsLength)
{
    NSString * title = (pszTitle) ? [NSString stringWithUTF8String : pszTitle] : nil;
    NSString * msg = (pszMsg) ? [NSString stringWithUTF8String : pszMsg] : nil;
    
    NSMutableArray *aryButtons = [NSMutableArray array];
    for (int i = 0; i < buttonsLength; i ++)
    {
        [aryButtons addObject:[OOCommon_IOS nsstringFromCString:buttons[i].c_str()]];
    }
    
    ObjCProxy *proxy = [[ObjCProxy alloc] init];
    proxy.needToReleaseSelf = YES;
    proxy.delegate = delegate;
    UIAlertView * messageBox = [[UIAlertView alloc] initWithTitle: title
                                                          message: msg
                                                         delegate: proxy
                                                cancelButtonTitle: nil
                                                otherButtonTitles: nil];
    for (NSString *buttonTitle in aryButtons)
    {
        [messageBox addButtonWithTitle:buttonTitle];
    }
    
    [messageBox autorelease];
    [messageBox show];
}

void OOX_showExternalPromotion()
{
//    if([OOExternalPromotionManager instance].adType == OOExternalAdType_Oriole2)
//    {
//        //NOTE: not used in Slots Farm
////        PRAdvertisingViewController *controller = [[PRAdvertisingViewController alloc] initWithDefaultNib];
////        [[OOCommon getRootViewController] presentViewController:controller animated:YES completion:nil];
//    }
//    else
//    {
//        [[OOExternalPromotionManager instance] showMoreApps];
//    }
}

#define kKeychainSvc @"OO Keychain"
void OOX_keychain_saveStringForKey(const char *string, const char *key)
{
    NSError *error = nil;
    [SFHFKeychainUtils storeUsername:[OOCommon_IOS nsstringFromCString:key] andPassword:[OOCommon_IOS nsstringFromCString:string] forServiceName:kKeychainSvc updateExisting:YES error:&error];
    if(error)
    {
        CCLog("error in save game data");
    }
}

void OOX_keychain_saveIntForKey(int value, const char *key)
{
    OOX_keychain_saveStringForKey(CCString::createWithFormat("%i", value)->getCString(), key);
}

void OOX_keychain_saveLongForKey(long value, const char *key)
{
    OOX_keychain_saveStringForKey(CCString::createWithFormat("%li", value)->getCString(), key);
}

void OOX_keychain_saveBoolForKey(bool value, const char *key)
{
    OOX_keychain_saveStringForKey(value ? "YES" : "NO", key);
}

NSString *OOX_keychain_getNSStringForKey(const char *key)
{
    NSString *value = nil;
    NSError *error = nil;
    value = [SFHFKeychainUtils getPasswordForUsername:[OOCommon_IOS nsstringFromCString:key] andServiceName:kKeychainSvc error:&error];
    
    return value;
}

const char* OOX_keychain_getStringForKey(const char *key)
{
    NSString *value = OOX_keychain_getNSStringForKey(key);
    if(value)
        return [OOCommon_IOS cstringFromNSString:value];
    else
        return NULL;
}

int OOX_keychain_getIntForKey(const char *key, int defaultValue)
{
    NSString *value = OOX_keychain_getNSStringForKey(key);
    if(value)
        return [value integerValue];
    else
        return defaultValue;
}

long OOX_keychain_getLongForKey(const char *key, long defaultValue)
{
    NSString *value = OOX_keychain_getNSStringForKey(key);
    if(value)
        return [value longValue];
    else
        return defaultValue;
}

bool OOX_keychain_getBoolForKey(const char *key)
{
    NSString *value = OOX_keychain_getNSStringForKey(key);
    return [value boolValue];
}

const char* OOX_sec_tripleDES(const char* text, const char* key, bool isDecrypt)
{
    if(text == NULL || key == NULL)
        return NULL;
    
    NSString *str = [OOCommon TripleDES:[OOCommon_IOS nsstringFromCString:text] isDecrypt:isDecrypt key:[OOCommon_IOS nsstringFromCString:key]];
    
    return [OOCommon_IOS cstringFromNSString:str];
}

CCData* OOX_sec_AES256(CCData* data, CCData* key, bool isDecrypt)
{
    if(data == NULL || key == NULL)
        return NULL;
    
    NSData *dataOriginal = [NSData dataWithBytes:data->getBytes() length:data->getSize()];
    NSData *dataKey = [NSData dataWithBytes:key->getBytes() length:key->getSize()];
    NSData *dataProcessed;
    if(isDecrypt)
        dataProcessed = [dataOriginal decryptedWithKey:dataKey];
    else
        dataProcessed = [dataOriginal encryptedWithKey:dataKey];
    
    CCData *dataRet = new CCData((unsigned char *)dataProcessed.bytes, dataProcessed.length);
    dataRet->autorelease();
    return dataRet;
}

CCObject * OOX_JSONObjectWithString(const char*str)
{
    if(str == NULL)
        return NULL;
    
    NSError *error = nil;
    NSString *nsStr = [OOCommon_IOS nsstringFromCString:str];
    NSData *data = [nsStr dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if([obj isKindOfClass:[NSArray class]])
    {
        return [OOCommon_IOS ccArrayFromNSArray:obj];
    }
    else if([obj isKindOfClass:[NSDictionary class]])
    {
        return [OOCommon_IOS ccDictionaryFromNSDictionary:obj];
    }
    else
    {
        CCLog("unknown json object");
        
        return NULL;
    }
}

const char* OOX_localizedString(const char*str)
{
    if(str == NULL)
        return NULL;
    
    return [OOCommon_IOS cstringFromNSString:OOLocalizedString([OOCommon_IOS nsstringFromCString:str])];
}

const char* OOX_localizedStringInOOBundle(const char*str)
{
    if(str == NULL)
        return NULL;
    
    return [OOCommon_IOS cstringFromNSString:OOLocalizedStringInOOBundle([OOCommon_IOS nsstringFromCString:str])];
}

char easytolower(char in)
{
    if(in<='Z' && in>='A')
        return in-('Z'-'z');
    return in;
}

const char* OOX_lowercaseString(const char*str)
{
    if(str == NULL)
        return NULL;
    
    std::string data = str;
    std::transform(data.begin(), data.end(), data.begin(), easytolower);
    return data.c_str();
}

void OOX_convertToReadableText(int value, std::string &str)
{
    int absValue = abs(value);
    int remainder = absValue % 1000;
    float quotient = absValue / 1000.0;
    if (quotient >= 1)
    {
        std::string sub = CCString::createWithFormat("%03i", remainder)->getCString();
        if(str.compare("") == 0)
            str = "," + sub;
        else
            str = "," + sub + str;
        
        int v = floorf(quotient);
        OOX_convertToReadableText(v, str);
    }
    else
    {
        std::string sub = CCString::createWithFormat("%i", remainder)->getCString();
        str = sub + str;
    }
    if(value < 0)
        str = "-" + str;
}

void OOX_ui_showToastMessage(const char* text)
{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:[OOCommon_IOS nsstringFromCString:text]];
}

void OOX_openUrl(const char* url)
{
    if(url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[OOCommon_IOS nsstringFromCString:url]]];
    }
}

CCImage *OOX_renderNodeToImage(CCNode *node, CCSize size, CCPoint position)
{
    if(node == NULL)
        return NULL;
    
    CCRenderTexture* renderer = CCRenderTexture::create((int)size.width, (int)size.height);
    
    CCPoint anchorPointBackup = node->getAnchorPoint();
    CCPoint positionBackup = node->getPosition();
    node->setAnchorPoint(CCPointZero);
    node->setPosition(position);
    
    renderer->begin();
    node->visit();
    renderer->end();
    node->setAnchorPoint(anchorPointBackup);
    node->setPosition(positionBackup);
    
    CCImage *image = renderer->newCCImage();
    
    return image;
}

CCImage *OOX_renderNodeToImage(CCNode *node)
{
    return OOX_renderNodeToImage(node, node->getContentSize(), CCPointZero);
}

void *OOX_getImageWithName(const char *name)
{
    return [UIImage imageNamed:[OOCommon_IOS nsstringFromCString:name]];
}

const char *OOX_shareTextManager_valueForKey(const char*key)
{
    if(key == NULL)
        return NULL;
    
    NSString *value = [[OOShareTextManager instance].dicConfig objectForKey:[OOCommon_IOS nsstringFromCString:key]];
    if(value == nil)
        return NULL;
    else
        return [OOCommon_IOS cstringFromNSString:value];
}

void OOX_shareImage(void *image, const char *text, int type)
{
    if(image)
    {
        NSString *serviceType;
        if(type == 0)
            serviceType = SLServiceTypeFacebook;
        else
            serviceType = SLServiceTypeSinaWeibo;
        SLComposeViewController *sharerUIController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        //check view controller, awoid crash: Application tried to present a NULL modal view controller on target
        if(sharerUIController)
        {
            [sharerUIController addImage:(UIImage *)image];
            if(text == NULL)
                text = "";
            [sharerUIController setInitialText:[OOCommon_IOS nsstringFromCString:text]];
            [[OOCommon getRootViewController] presentViewController:sharerUIController animated:YES completion:nil];
        }
    }
    else
    {
        CCLog("image can not be null");
    }
}

void OOX_shareOnInstagramImage(void *image, const char *text, CCRect rect)
{
    if(image)
    {
        NSString *tmpPath = [[[NSFileManager defaultManager] temporaryDataPath] stringByAppendingPathComponent:@"instagram.igo"];
        NSData *data = UIImageJPEGRepresentation((UIImage *)image, 1);
        if(![data writeToFile:tmpPath atomically:YES])
        {
            // failure
            CCLog("image save failed to path %s", [OOCommon_IOS cstringFromNSString:tmpPath]);
            
            return;
        }
        
        NSURL *url = [NSURL fileURLWithPath:tmpPath];
        
        UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController alloc] init];
        interactionController.UTI = @"com.instagram.exclusivegram";
        interactionController.delegate = nil;
        if(text == nil)
            text = "";
        
        [interactionController setAnnotation:@{@"InstagramCaption" : [OOCommon_IOS nsstringFromCString:text]}];
        interactionController.URL = url;
        
        BOOL success = [interactionController presentOpenInMenuFromRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height) inView:[OOCommon getRootViewController].view animated:YES];
        if(!success)
        {
            CCLog("couldn't present document interaction controller");
        }
    }
    else
    {
        CCLog("image can not be null");
    }
}

void OOX_sendFBGift_send(const char *title, const char *message, CCObject *target, SEL_CallFuncO selector, bool isSessionFirstOpen)
{
    FBFrictionlessRecipientCache *friendCache = [[FBFrictionlessRecipientCache alloc] init];
    [friendCache prefetchAndCacheForSession:nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:[OOCommon_IOS nsstringFromCString:message]
                                                    title:[OOCommon_IOS nsstringFromCString:title]
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error)
                                                      {
                                                          // Case A: Error launching the dialog or sending request.
                                                          OOLog(@"Error sending request.");
                                                          std::string buttons[] = {"OK"};
                                                          CCMessageBox([OOCommon_IOS cstringFromNSString:error.localizedDescription], "Oops", NULL, buttons, 1);
                                                      }
                                                      else
                                                      {
                                                          if (result == FBWebDialogResultDialogNotCompleted)
                                                          {
                                                              // Case B: User clicked the "x" icon
                                                              OOLog(@"User canceled request.");
                                                          }
                                                          else
                                                          {
                                                              OOLog(@"Request Sent.");
                                                          }
                                                      }
                                                      if(target && selector)
                                                      {
                                                          OOX_CallbackObject *obj = OOX_CallbackObject::create();
                                                          obj->setIsError(error != NULL);
                                                          obj->setIsSessionFirstOpen(error == NULL && isSessionFirstOpen);
                                                          (target->*selector)(obj);
                                                      }
                                                  }
                                              friendCache:friendCache];
}

bool OOX_isConnectToFB()
{
    return FBSession.activeSession.isOpen;
}

void OOX_sendFBGift(const char *title, const char *message, CCObject *target, SEL_CallFuncO selector)
{
    if (!FBSession.activeSession.isOpen)
    {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error)
                                          {
                                              if(target && selector)
                                              {
                                                  OOX_CallbackObject *obj = OOX_CallbackObject::create();
                                                  obj->setIsError(true);
                                                  obj->setIsSessionFirstOpen(false);
                                                  (target->*selector)(obj);
                                              }
                                              std::string buttons[] = {"OK"};
                                              CCMessageBox([OOCommon_IOS cstringFromNSString:error.localizedDescription], "Oops", NULL, buttons, 1);
                                          }
                                          else if (session.isOpen)
                                          {
                                              OOX_sendFBGift_send(title, message, target, selector, true);
                                          }
                                      }];
    }
    else
    {
        
    }
}

bool OOX_canSendMail()
{
    return [MFMailComposeViewController canSendMail];
}

void OOX_sendMail(CCArray *toRecipients, const char *body, const char *subject, CCObject *target, SEL_CallFuncO selector)
{
    [[OOMailViewController shareMailViewController] setToRecipients:[OOCommon_IOS nsArrayFromCCArray:toRecipients]];
    [[OOMailViewController shareMailViewController] setSubject:[OOCommon_IOS nsstringFromCString:subject]];
    [[OOMailViewController shareMailViewController] setMailBody:[OOCommon_IOS nsstringFromCString:body]];
    [[OOMailViewController shareMailViewController] showInViewController:[OOCommon getRootViewController] didExitBlock:^(NSNumber *number) {
        BOOL success = [number boolValue];
        if(target != NULL && selector != NULL)
        {
            (target->*selector)(CCBool::create(success));
        }
    }];
}

void OOX_sendMail(CCArray *toRecipients, const char *body, const char *subject)
{
    OOX_sendMail(toRecipients, body, subject, NULL, NULL);
}

void OOX_externalPromotionManager_showAdWithPlacement(const char*placement)
{
//    [[OOExternalPromotionManager instance] showAdWithPlacement:[OOCommon_IOS nsstringFromCString:placement]];
}
