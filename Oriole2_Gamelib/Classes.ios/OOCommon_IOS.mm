//
//  OOCommon_IOS.m
//  GTBX
//
//  Created by Gary Wong on 7/29/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#import "OOCommon_IOS.h"
#include "OOCommon_Cocos2dX.h"
#import "EAGLView.h"

#define isKindOfClass(obj,class) (dynamic_cast<class*>(obj) != NULL)

@implementation OOCommon_IOS

+ (NSString *)nsstringFromCString:(const char *)cstring
{
    if (cstring == NULL) {
        return NULL;
    }
    
    NSString * nsstring = [[NSString alloc] initWithBytes:cstring length:strlen(cstring) encoding:NSUTF8StringEncoding];
    return [nsstring autorelease];
}

+ (const char *)cstringFromNSString:(NSString *)nsstring
{
    
    if (nsstring == NULL) {
        return NULL;
    }
    
    return [nsstring UTF8String];
}

+ (NSDictionary *)nsDictionaryFromCCDictionary:(CCDictionary *)ccDictionary
{
    if(!ccDictionary)
        return NULL;
    
    CCArray *keys = ccDictionary->allKeys();
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:keys->count()];
    
    CCObject *object;
    CCARRAY_FOREACH(keys, object)
    {
        CCString *keySub = (CCString *)object;
        CCObject *valueSub = ccDictionary->objectForKey(keySub->getCString());
        addValueToNSDict(keySub, valueSub, dic);
    }
    
    return dic;
}

+ (CCDictionary *)ccDictionaryFromNSDictionary:(NSDictionary *)dictionary
{
    if(!dictionary)
        return NULL;
    
    CCDictionary* pDictItem = CCDictionary::create();
    for (id key in [dictionary allKeys])
    {
        id value = [dictionary objectForKey:key];
        addValueToCCDict(key, value, pDictItem);
    }
    return pDictItem;
}

+ (NSArray *)nsArrayFromCCArray:(CCArray *)ccArray
{
    if(!ccArray)
        return NULL;
    
    NSMutableArray *ary = [NSMutableArray arrayWithCapacity:ccArray->count()];
    
    CCObject *object;
    CCARRAY_FOREACH(ccArray, object)
    {
        addItemToNSArray(object, ary);
    }
    return ary;
}

+ (CCArray *)ccArrayFromNSArray:(NSArray *)nsArray
{
    if(!nsArray)
        return NULL;
    
    CCArray* ary = CCArray::create();
    for (id item in nsArray)
    {
        addItemToCCArray(item, ary);
    }
    return ary;
}

+ (UIImage *)uiImageFromCCImage:(CCImage *)ccImage
{
    if(!ccImage)
        return NULL;
    
//    NSData* imgData = [NSData dataWithBytes:ccImage->getData() length:ccImage->getDataLen()];
//    UIImage *uiImage = [[[UIImage alloc] initWithData:imgData] autorelease];
//    
//    return uiImage;
    
    
    //Ref: http://stackoverflow.com/questions/16829076/how-to-convert-ccsprite-to-uiimage-in-cocos2d-x
    //NOTE: not test yet.
    NSUInteger bytesPerPixel = 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, ccImage->getData(), ccImage->getDataLen() * bytesPerPixel, NULL);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    NSUInteger scanWidth = ccImage->getWidth() * bytesPerPixel;
    CGImageRef imageRef = CGImageCreate(ccImage->getWidth(),
                                        ccImage->getHeight(),
                                        8,
                                        bytesPerPixel * 8,
                                        scanWidth,
                                        colorSpaceRef,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        NO,
                                        renderingIntent);
    CGDataProviderRelease(provider);
    
    float scaleContentFactor = CCDirector::sharedDirector()->getContentScaleFactor();
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:scaleContentFactor orientation:UIImageOrientationUp];
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    
    return image;
}

+ (CCImage *)ccImageFromUIImage:(UIImage *)uiImage
{
    if(!uiImage)
        return NULL;
    
    NSData* imgData = UIImagePNGRepresentation(uiImage);
    
    CCImage *ccImage = new CCImage();
    ccImage->initWithImageData((unsigned char *)imgData.bytes, [imgData length], CCImage::kFmtPng, uiImage.size.width, uiImage.size.height);
    ccImage->autorelease();
    
    return ccImage;
}

+ (NSData *)nsDataFromCCData:(CCData *)ccData
{
    if(!ccData)
        return NULL;
    
    NSData* nsData = [NSData dataWithBytes:ccData->getBytes() length:ccData->getSize()];
    return nsData;
}

+ (CCData *)ccDataFromNSData:(NSData *)nsData
{
    if(!nsData)
        return NULL;
    
    CCData *ccData = new CCData((unsigned char *)[nsData bytes], [nsData length]);
    ccData->autorelease();
    return ccData;
}

static void addValueToCCDict(id key, id value, CCDictionary* pDict)
{
    // the key must be a string
    CCAssert([key isKindOfClass:[NSString class]], "The key should be a string!");
    std::string pKey = [key UTF8String];
    
    // the value is a new dictionary
    if ([value isKindOfClass:[NSDictionary class]]) {
        CCDictionary* pSubDict = new CCDictionary();
        for (id subKey in [value allKeys]) {
            id subValue = [value objectForKey:subKey];
            addValueToCCDict(subKey, subValue, pSubDict);
        }
        pDict->setObject(pSubDict, pKey.c_str());
        pSubDict->release();
        return;
    }
    
    // the value is a string
    if ([value isKindOfClass:[NSString class]]) {
        CCString* pValue = new CCString([value UTF8String]);
        
        pDict->setObject(pValue, pKey.c_str());
        pValue->release();
        return;
    }
    
    // the value is a number
    if ([value isKindOfClass:[NSNumber class]]) {
        NSString* pStr = [value stringValue];
        CCString* pValue = new CCString([pStr UTF8String]);
        
        pDict->setObject(pValue, pKey.c_str());
        pValue->release();
        return;
    }
    
    // the value is a array
    if ([value isKindOfClass:[NSArray class]]) {
        CCArray *pArray = new CCArray();
        pArray->init();
        for (id item in value) {
            addItemToCCArray(item, pArray);
        }
        pDict->setObject(pArray, pKey.c_str());
        pArray->release();
        return;
    }
}

static void addValueToNSDict(CCString *key, CCObject *value, NSMutableDictionary* pDict)
{
    // the key must be a string
    CCAssert(OOX_IsKindOfClass(key, CCString), "The key should be a string!");
    
    // the value is a new dictionary
    if (OOX_IsKindOfClass(value, CCDictionary))
    {
        NSMutableDictionary* dicSub = [NSMutableDictionary dictionary];
        [pDict setValue:dicSub forKey:[OOCommon_IOS nsstringFromCString:key->getCString()]];
        
        CCArray *keys = ((CCDictionary *)value)->allKeys();
        
        CCObject *object;
        CCARRAY_FOREACH(keys, object)
        {
            CCString *keySub = (CCString *)object;
            CCObject *valueSub = ((CCDictionary *)value)->objectForKey(keySub->getCString());
            addValueToNSDict(keySub, valueSub, dicSub);
        }
    }
    
    // the value is a string
    if (OOX_IsKindOfClass(value, CCString))
    {
        NSString *str = [OOCommon_IOS nsstringFromCString:((CCString *)value)->getCString()];
        [pDict setValue:str forKey:[OOCommon_IOS nsstringFromCString:key->getCString()]];
    }
    
    // the value is a array
    if (OOX_IsKindOfClass(value, CCArray))
    {
        NSMutableArray *arySub = [NSMutableArray array];
        [pDict setValue:arySub forKey:[OOCommon_IOS nsstringFromCString:key->getCString()]];
        
        CCObject *object;
        CCARRAY_FOREACH((CCArray *)value, object)
        {
            addItemToNSArray(object, arySub);
        }
    }
}

static void addItemToCCArray(id item, CCArray *pArray)
{
    // add string value into array
    if ([item isKindOfClass:[NSString class]]) {
        CCString* pValue = new CCString([item UTF8String]);
        
        pArray->addObject(pValue);
        pValue->release();
        return;
    }
    
    // add number value into array(such as int, float, bool and so on)
    if ([item isKindOfClass:[NSNumber class]]) {
        NSString* pStr = [item stringValue];
        CCString* pValue = new CCString([pStr UTF8String]);
        
        pArray->addObject(pValue);
        pValue->release();
        return;
    }
    
    // add dictionary value into array
    if ([item isKindOfClass:[NSDictionary class]]) {
        CCDictionary* pDictItem = new CCDictionary();
        for (id subKey in [item allKeys]) {
            id subValue = [item objectForKey:subKey];
            addValueToCCDict(subKey, subValue, pDictItem);
        }
        pArray->addObject(pDictItem);
        pDictItem->release();
        return;
    }
    
    // add array value into array
    if ([item isKindOfClass:[NSArray class]]) {
        CCArray *pArrayItem = new CCArray();
        pArrayItem->init();
        for (id subItem in item) {
            addItemToCCArray(subItem, pArrayItem);
        }
        pArray->addObject(pArrayItem);
        pArrayItem->release();
        return;
    }
}

static void addItemToNSArray(CCObject *item, NSMutableArray *pArray)
{
    // add string value into array
    if (OOX_IsKindOfClass(item, CCString))
    {
        NSString *str = [OOCommon_IOS nsstringFromCString:((CCString *)item)->getCString()];
        [pArray addObject:str];
    }
    
    // add dictionary value into array
    if (OOX_IsKindOfClass(item, CCDictionary))
    {
        NSMutableDictionary* dicSub = [NSMutableDictionary dictionary];
        [pArray addObject:dicSub];
        
        CCArray *keys = ((CCDictionary *)item)->allKeys();
        
        CCObject *object;
        CCARRAY_FOREACH(keys, object)
        {
            CCString *keySub = (CCString *)object;
            CCObject *valueSub = ((CCDictionary *)item)->objectForKey(keySub->getCString());
            addValueToNSDict(keySub, valueSub, dicSub);
        }
    }
    
    // add array value into array
    if (OOX_IsKindOfClass(item, CCArray))
    {
        NSMutableArray *arySub = [NSMutableArray array];
        [pArray addObject:arySub];
        
        CCObject *object;
        CCARRAY_FOREACH((CCArray *)item, object)
        {
            addItemToNSArray(object, arySub);
        }
    }
}

@end
