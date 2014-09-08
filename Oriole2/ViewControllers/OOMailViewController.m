//
//  OOMailViewController.m
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

#import "OOMailViewController.h"

@interface OOMailViewController ()
@property(nonatomic, copy) OOBlockNumber didExitBlock;

- (void)_displayComposerSheetSharing;
- (void)_launchMailAppOnDeviceSharing;
@end

@implementation OOMailViewController

@synthesize _mailBody, _mailSubject, _toRecipients, barStyle;
@synthesize didExitBlock;

static OOMailViewController *mController = nil;

+ (id)shareMailViewController
{
    if (mController == nil) {
        mController = [[OOMailViewController alloc] init];
    }

    return mController;
}

- (id)init
{
    if ((self = [super init])) {
        barStyle = UIBarStyleDefault;
    }

    return self;
}

- (void)setToRecipients:(NSArray *)toRecipients
{
    self._toRecipients = toRecipients;
}

- (void)setMailBody:(NSString *)mailBody
{
    self._mailBody = mailBody;
}

- (void)setSubject:(NSString *)mailSubject
{
    self._mailSubject = mailSubject;
}

- (void)showInViewController:(UIViewController *)ctl didExitBlock:(OOBlockNumber)_didExitBlock
{
    self.didExitBlock = _didExitBlock;

    rootVC = ctl;
    mailClass = NSClassFromString(@"MFMailComposeViewController");

    if (mailClass) {
        if ([mailClass canSendMail]) {
            [self _displayComposerSheetSharing];
        } else {
            [[[UIAlertView alloc] initWithTitle:Nil message:OOLocalizedStringInOOBundle(@"No email account found") delegate:nil cancelButtonTitle:OOLocalizedStringInOOBundle(@"OK") otherButtonTitles:nil] show];
            //			[self _launchMailAppOnDeviceSharing];
        }
    } else {
        [self _launchMailAppOnDeviceSharing];
    }
}

- (void)showInViewController:(UIViewController *)ctl
{
    [self showInViewController:ctl didExitBlock:NULL];
}

- (void)setDefaultAndShowInViewController:(UIViewController *)ctl didExitBlock:(OOBlockNumber)_didExitBlock
{
    self.didExitBlock = _didExitBlock;

    [self setToRecipients:[NSArray arrayWithObject:@"support@oriole2.com"]];
    [self setSubject:[OOCommon getFeedbackHeader]];
    [self setMailBody:[OOCommon getFeedbackDeviceInfoWithNewLine:YES]];
    [self showInViewController:ctl];
}

- (void)setDefaultAndShowInViewController:(UIViewController *)ctl
{
    [self setDefaultAndShowInViewController:ctl didExitBlock:NULL];
}

- (void)_launchMailAppOnDeviceSharing
{
    NSString *recipients = [NSString stringWithFormat:@"mailto:?subject=%@", self._mailSubject];
    NSString *body = self._mailBody;

    NSString *email = [NSString stringWithFormat:@"%@&body=%@", recipients, body];

    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)_displayComposerSheetSharing
{
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];

    mailController.mailComposeDelegate = self;
    mailController.modalPresentationStyle = UIModalPresentationFormSheet;
    [mailController.navigationBar setBarStyle:barStyle];

    NSArray *recipients = self._toRecipients;

    if ((recipients != nil) && ([recipients count] > 0)) {
        [mailController setToRecipients:recipients];
    }

    NSString *subject = self._mailSubject;
    [mailController setSubject:subject];

    NSString *body = self._mailBody;
    [mailController setMessageBody:body isHTML:YES];

    [rootVC presentViewController:mailController animated:YES completion:^{
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [rootVC dismissViewControllerAnimated:YES completion:^{
        if (self.didExitBlock) {
            self.didExitBlock([NSNumber numberWithBool:result == MFMailComposeResultSaved || result == MFMailComposeResultSent]);
            self.didExitBlock = nil;
        }
    }];
}

- (void)dealloc
{
    self.didExitBlock = nil;
}

@end
