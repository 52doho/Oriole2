//
//  RMStore+Extend.h
//  CamCool
//
//  Created by Gary Wong on 6/6/14.
//  Copyright (c) 2014 Oriole2 Ltd. All rights reserved.
//

#import "RMStore.h"
#import "RMStoreKeychainPersistence.h"

@interface RMStoreKeychainPersistence_Extend : RMStoreKeychainPersistence

- (void)setPurchasedProductOfIdentifier:(NSString *)productIdentifier;

@end

@interface RMStore(Extend)

@property (nonatomic, strong) RMStoreKeychainPersistence_Extend *transactionPersistorKeychain;

+ (void)removeTransactions;

+ (BOOL)consumeProductOfIdentifier:(NSString *)productIdentifier;

+ (NSInteger)countProductOfdentifier:(NSString *)productIdentifier;

+ (BOOL)isPurchasedProductOfIdentifier:(NSString *)productIdentifier;

+ (void)setPurchasedProductOfIdentifier:(NSString *)productIdentifier;

+ (NSSet*)purchasedProductIdentifiers;

+ (BOOL)containsProductWithId:(NSString *)productId price:(float *)price localizedPrice:(NSString **)localizedPrice;

@end
