//
//  CCLocalizedString.h
//  SkeletonX
//
//  Created by 小苏 on 11-12-1.
//  Copyright (c) 2011年 GeekStudio. All rights reserved.
//

#ifndef _CCLocalizedString_h
#define _CCLocalizedString_h

//Ref: http://www.cocos2d-x.org/boards/18/topics/14981
/*get the localized string by the key, if can't get the value then return mComment
 */
const char * CCLocalizedString(const char * mKey,const char * fileName);
const char * CCLocalizedString(const char * mKey);

#endif
