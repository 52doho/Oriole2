//
//  OOCommon_IOS.h
//  GTBX
//
//  Created by Gary Wong on 7/29/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#ifdef __OBJC__

#import <Foundation/Foundation.h>
#include "cocos2d.h"
#include "cocos-ext.h"
USING_NS_CC;
USING_NS_CC_EXT;

@interface OOCommon_IOS : NSObject
{
    
}
//Ref: AnalyticXStringUtil
+ (NSString *)nsstringFromCString:(const char *)cstring;
+ (const char *)cstringFromNSString:(NSString *)nsstring;

//Ref: CCFileUtilsIOS
+ (NSDictionary *)nsDictionaryFromCCDictionary:(CCDictionary *)ccDictionary;
+ (CCDictionary *)ccDictionaryFromNSDictionary:(NSDictionary *)dictionary;
+ (NSArray *)nsArrayFromCCArray:(CCArray *)ccArray;
+ (CCArray *)ccArrayFromNSArray:(NSArray *)nsArray;

+ (UIImage *)uiImageFromCCImage:(CCImage *)ccImage;
+ (CCImage *)ccImageFromUIImage:(UIImage *)uiImage;

+ (NSData *)nsDataFromCCData:(CCData *)ccData;
+ (CCData *)ccDataFromNSData:(NSData *)nsData;

@end

#endif