//
//  RMStore+Extend.m
//  CamCool
//
//  Created by Gary Wong on 6/6/14.
//  Copyright (c) 2014 Oriole2 Ltd. All rights reserved.
//

#import "RMStore+Extend.h"
#import "RMStoreAppReceiptVerificator.h"
#import "RMStoreTransactionReceiptVerificator.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation RMStoreKeychainPersistence_Extend

- (void)setPurchasedProductOfIdentifier:(NSString *)productIdentifier
{
    NSDictionary *dic = objc_msgSend(self, NSSelectorFromString(@"transactionsDictionary"));
    NSMutableDictionary *updatedTransactions = [NSMutableDictionary dictionaryWithDictionary:dic];
    updatedTransactions[productIdentifier] = @(1);
    objc_msgSend(self, NSSelectorFromString(@"setTransactionsDictionary:"), updatedTransactions);
}

@end


@implementation RMStore(Extend)

static char KeychainPersistence_Extend;
static char ReceiptVerificator_Extend;

- (RMStoreKeychainPersistence_Extend *)transactionPersistorKeychain
{
    return objc_getAssociatedObject(self, &KeychainPersistence_Extend);
}

- (void)setTransactionPersistorKeychain:(RMStoreKeychainPersistence_Extend *)transactionPersistorKeychain
{
    [self willChangeValueForKey:@"transactionPersistorKeychain"];
    objc_setAssociatedObject(self, &KeychainPersistence_Extend, transactionPersistorKeychain, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"transactionPersistorKeychain"];
}

- (id<RMStoreReceiptVerificator>)receiptVerificator_Extend
{
    return objc_getAssociatedObject(self, &ReceiptVerificator_Extend);
}

- (void)setReceiptVerificator_Extend:(id<RMStoreReceiptVerificator>)receiptVerificator_Extend
{
    [self willChangeValueForKey:@"receiptVerificator_Extend"];
    objc_setAssociatedObject(self, &ReceiptVerificator_Extend, receiptVerificator_Extend, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"receiptVerificator_Extend"];
}

+ (void)initialize
{
    [RMStore defaultStore].transactionPersistorKeychain = [[RMStoreKeychainPersistence_Extend alloc] init];
    [RMStore defaultStore].transactionPersistor = [RMStore defaultStore].transactionPersistorKeychain;
    
    const BOOL iOS7OrHigher = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
    [RMStore defaultStore].receiptVerificator_Extend = iOS7OrHigher ? [[RMStoreAppReceiptVerificator alloc] init] : [[RMStoreTransactionReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = [RMStore defaultStore].receiptVerificator_Extend;
}

+ (void)removeTransactions
{
    [[RMStore defaultStore].transactionPersistorKeychain removeTransactions];
}

+ (BOOL)consumeProductOfIdentifier:(NSString *)productIdentifier
{
    return [[RMStore defaultStore].transactionPersistorKeychain consumeProductOfIdentifier:productIdentifier];
}

+ (NSInteger)countProductOfdentifier:(NSString *)productIdentifier
{
    return [[RMStore defaultStore].transactionPersistorKeychain countProductOfdentifier:productIdentifier];
}

+ (BOOL)isPurchasedProductOfIdentifier:(NSString *)productIdentifier
{
    return [[RMStore defaultStore].transactionPersistorKeychain isPurchasedProductOfIdentifier:productIdentifier];
}

+ (void)setPurchasedProductOfIdentifier:(NSString *)productIdentifier
{
    [[RMStore defaultStore].transactionPersistorKeychain setPurchasedProductOfIdentifier:productIdentifier];
}

+ (NSSet*)purchasedProductIdentifiers
{
    return [[RMStore defaultStore].transactionPersistorKeychain purchasedProductIdentifiers];
}

+ (BOOL)containsProductWithId:(NSString *)productIdentifier price:(float *)price localizedPrice:(NSString **)localizedPrice
{
    SKProduct *thisProduct = [[RMStore defaultStore] productForIdentifier:productIdentifier];
    if (!thisProduct)
        return NO;
    
    if(price)
        *price = [thisProduct.price floatValue];
    if(localizedPrice)
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:thisProduct.priceLocale];
        *localizedPrice = [formatter stringFromNumber:thisProduct.price];
    }
    
    return YES;
}

@end

