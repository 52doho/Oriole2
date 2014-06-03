//
//  OOString+Extend.h
//  Oriole2
//
//  Created by Gary Wong on 11-8-22.
//  Copyright 2011 OO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Extend)

- (BOOL)isNotEmpty;
- (BOOL)isNumberValue;
- (NSString *)urlEncodedString;
- (NSString *)urlDecodedString;


@end