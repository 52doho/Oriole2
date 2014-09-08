//
//  OOMailViewController.h
//  Mail
//
//  Created by Gary Wong on 11-7-16.
//  Copyright 2011 Oriole2 Ltd. All rights reserved.
//
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "OOCommon.h"

@interface OOMailViewController : NSObject <MFMailComposeViewControllerDelegate>
{
    Class            mailClass;
    NSString         *_mailBody;
    NSString         *_mailSubject;
    NSArray          *_toRecipients;
    UIViewController *rootVC;
    UIBarStyle       barStyle;
}
@property (nonatomic, retain) NSString   *_mailBody;
@property (nonatomic, retain) NSString   *_mailSubject;
@property (nonatomic, retain) NSArray    *_toRecipients;
@property (nonatomic, assign) UIBarStyle barStyle;

+ (id)shareMailViewController;
- (void)setToRecipients:(NSArray *)toRecipients;
- (void)setMailBody:(NSString *)mailBody;
- (void)setSubject:(NSString *)mailSubject;
- (void)showInViewController:(UIViewController *)ctl;
- (void)showInViewController:(UIViewController *)ctl didExitBlock:(OOBlockNumber)didExitBlock;
- (void)setDefaultAndShowInViewController:(UIViewController *)ctl;
- (void)setDefaultAndShowInViewController:(UIViewController *)ctl didExitBlock:(OOBlockNumber)didExitBlock;

@end
