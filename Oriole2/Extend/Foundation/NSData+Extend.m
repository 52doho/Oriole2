//
//  NSData+Extend.m
//  Oriole2
//
//  Created by Gary Wong on 2/12/11.
//  Copyright 2011 Oriole2 Ltd. All rights reserved.
//
// Permission is hereby granted to staffs of Oriole2 Ltd.
// Any person obtaining a copy of this software and associated documentation
// files (the "Software") should not use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software without permission granted by
// Oriole2 Ltd.
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//

#import "NSData+Extend.h"

#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES256)

// Key size is 32 bytes for AES256
#define kKeySize kCCKeySizeAES256

- (NSData *)makeCryptedVersionWithKeyData:(const void *)keyData ofLength:(int)keyLength decrypt:(bool)decrypt
{
    // Copy the key data, padding with zeroes if needed
    char key[kKeySize];

    bzero(key, sizeof(key));
    memcpy(key, keyData, keyLength > kKeySize ? kKeySize : keyLength);

    size_t bufferSize = [self length] + kCCBlockSizeAES128;
    void   *buffer = malloc(bufferSize);

    size_t dataUsed;

    CCCryptorStatus status = CCCrypt(decrypt ? kCCDecrypt : kCCEncrypt,
            kCCAlgorithmAES128,
            kCCOptionPKCS7Padding | kCCOptionECBMode,
            key, kKeySize,
            NULL,
            [self bytes], [self length],
            buffer, bufferSize,
            &dataUsed);

    switch (status) {
    case kCCSuccess:
        return [NSData dataWithBytesNoCopy:buffer length:dataUsed];

    case kCCParamError:
        NSLog(@"Error: NSDataAES256: Could not %s data: Param error", decrypt ? "decrypt" : "encrypt");
        break;

    case kCCBufferTooSmall:
        NSLog(@"Error: NSDataAES256: Could not %s data: Buffer too small", decrypt ? "decrypt" : "encrypt");
        break;

    case kCCMemoryFailure:
        NSLog(@"Error: NSDataAES256: Could not %s data: Memory failure", decrypt ? "decrypt" : "encrypt");
        break;

    case kCCAlignmentError:
        NSLog(@"Error: NSDataAES256: Could not %s data: Alignment error", decrypt ? "decrypt" : "encrypt");
        break;

    case kCCDecodeError:
        NSLog(@"Error: NSDataAES256: Could not %s data: Decode error", decrypt ? "decrypt" : "encrypt");
        break;

    case kCCUnimplemented:
        NSLog(@"Error: NSDataAES256: Could not %s data: Unimplemented", decrypt ? "decrypt" : "encrypt");
        break;

    default:
        NSLog(@"Error: NSDataAES256: Could not %s data: Unknown error", decrypt ? "decrypt" : "encrypt");
    }

    free(buffer);
    return nil;
}

- (NSData *)encryptedWithKey:(NSData *)key
{
    return [self makeCryptedVersionWithKeyData:[key bytes] ofLength:[key length] decrypt:NO];
}

- (NSData *)decryptedWithKey:(NSData *)key
{
    return [self makeCryptedVersionWithKeyData:[key bytes] ofLength:[key length] decrypt:YES];
}

@end
