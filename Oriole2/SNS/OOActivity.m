//
//  OOActivityPhotoCool.m
//  BoothCool
//
//  Created by Gary Wong on 4/3/13.
//  Copyright (c) 2013 Oriole2 Ltd. All rights reserved.
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

#import "OOActivity.h"
#import "OOCommon.h"

@implementation OOActivityProviderPhotoCool

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return [super activityViewController:activityViewController itemForActivityType:activityType];
}

@end

@interface OOActivityBase ()

@property (nonatomic, assign) UIImage                         *imageToEdit;
@property (nonatomic, strong) UIDocumentInteractionController *interactionController;
@end

@implementation OOActivityBase

- (id)initWithPresentViewController:(UIViewController *)viewController barButton:(UIBarButtonItem *)presentFromButton
{
    if ((self = [super init])) {
        _viewController = viewController;
        _presentFromButton = presentFromButton;
    }

    return self;
}

- (id)initWithPresentViewController:(UIViewController *)viewController rect:(CGRect)presentFromRect view:(UIView *)presentInView
{
    if ((self = [super init])) {
        _viewController = viewController;
        _presentFromRect = presentFromRect;
        _presentInView = presentInView;
    }

    return self;
}

#pragma mark - UIDocumentInteractionControllerDelegate -
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    [self activityDidFinish:YES];
}

#pragma mark - SKStoreProductViewControllerDelegate -
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    viewController.delegate = nil;
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface OOActivityPhotoCool ()
{
    __strong OOActivityPhotoCool *_retained_self;
}

@end

@implementation OOActivityPhotoCool

- (NSString *)activityType
{
    return @"com.Oriole2.activity.OpenInPhotoCool";
}

- (BOOL)_canEditInPhotoCool
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"photocool://"]] || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"photocoolfree://"]];
}

- (NSString *)activityTitle
{
    if ([self _canEditInPhotoCool]) {
        return OOLocalizedStringInOOBundle(@"Open in PhotoCool");
    } else {
        return OOLocalizedStringInOOBundle(@"Download PhotoCool");
    }
}

- (UIImage *)activityImage
{
    if (kIsiPad) {
        return [UIImage imageNamed:@"Oriole2.bundle/Share/Activity_PhotoCool~ipad.png"];
    } else {
        return [UIImage imageNamed:@"Oriole2.bundle/Share/Activity_PhotoCool~iphone.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (NSObject *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }

    return NO;
}

#define kPhotoCoolCrossPromotionEventName @"Cross promotion: PhotoCool"
- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    // retain self for iPhone
    _retained_self = self;

    for (NSObject *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            self.imageToEdit = (UIImage *)item;
            break;
        }
    }
}

- (UIViewController *)activityViewController
{
    return nil;
}

- (void)performActivity
{
    if ([self _canEditInPhotoCool]) {
        NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"PhotoCool.jpg"];

        if (![UIImageJPEGRepresentation(self.imageToEdit, 1) writeToFile:tmpPath atomically:YES]) {
            // failure
            OOLog(@"image save failed to path %@", tmpPath);
            [self activityDidFinish:NO];

            return;
        }

        OOBlockBasic completion = ^{
            NSURL *url = [NSURL fileURLWithPath:tmpPath];

            if (self.interactionController == nil) {
                self.interactionController = [[UIDocumentInteractionController alloc] init];

                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"photocool://"]]) {
                    self.interactionController.UTI = @"com.Oriole2.PhotoCoolExclusive";
                } else {
                    self.interactionController.UTI = @"com.Oriole2.PhotoCoolFreeExclusive";
                }

                self.interactionController.delegate = self;
            }

            self.interactionController.URL = url;

            BOOL success;

            if (self.presentFromButton) {
                success = [self.interactionController presentOpenInMenuFromBarButtonItem:self.presentFromButton animated:YES];
            } else {
                success = [self.interactionController presentOpenInMenuFromRect:self.presentFromRect inView:self.presentInView animated:YES];
            }

            if (!success) {
                OOLog(@"couldn't present document interaction controller");
            }
        };

        if (self.viewController.presentedViewController) {
            [self.viewController dismissViewControllerAnimated:YES completion:completion];
        } else {
            completion();
        }
    } else {
        // open photocool free in app store
        [OOCommon openInAppStoreWithID:520418326 viewController:self.viewController];
    }

    [self activityDidFinish:YES];
}

- (void)dealloc
{
}

#pragma mark - UIDocumentInteractionControllerDelegate -
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [super productViewControllerDidFinish:viewController];

    viewController.delegate = nil;
    _retained_self = nil; // release self for iPhone.
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    _retained_self = nil; // release self for iPhone.
}

@end

#pragma mark - OOActivityInstagram -
@implementation OOActivityInstagram

- (NSString *)activityType
{
    return @"com.Oriole2.activity.OpenInInstagram";
}

- (NSString *)activityTitle
{
    return @"Instagram";
}

- (UIImage *)activityImage
{
    if (kIsiPad) {
        return [UIImage imageNamed:@"Oriole2.bundle/Share/Activity_Instagram~ipad.png"];
    } else {
        return [UIImage imageNamed:@"Oriole2.bundle/Share/Activity_Instagram~iphone.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];

    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        return NO; // no instagram.
    }

    for (NSObject *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }

    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (NSObject *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            self.imageToEdit = (UIImage *)item;
            break;
        }
    }
}

- (UIViewController *)activityViewController
{
    return nil;
}

- (void)performActivity
{
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];

    if (![UIImageJPEGRepresentation(self.imageToEdit, 1) writeToFile:tmpPath atomically:YES]) {
        // failure
        OOLog(@"image save failed to path %@", tmpPath);
        [self activityDidFinish:NO];

        return;
    }

    NSURL *url = [NSURL fileURLWithPath:tmpPath];

    if (self.interactionController == nil) {
        self.interactionController = [[UIDocumentInteractionController alloc] init];
        self.interactionController.UTI = @"com.instagram.exclusivegram";
        self.interactionController.delegate = self;

        if (self.caption) {
            [self.interactionController setAnnotation:@{@"InstagramCaption" : self.caption}];
        }
    }

    self.interactionController.URL = url;

    OOBlockBasic completion = ^{
        if (self.popoverController) {
            [self.popoverController dismissPopoverAnimated:NO];
        }

        BOOL success;

        if (self.presentFromButton) {
            success = [self.interactionController presentOpenInMenuFromBarButtonItem:self.presentFromButton animated:YES];
        } else {
            success = [self.interactionController presentOpenInMenuFromRect:self.presentFromRect inView:self.presentInView animated:YES];
        }

        if (!success) {
            OOLog(@"couldn't present document interaction controller");
        }
    };

    if (self.viewController.presentedViewController) {
        [self.viewController dismissViewControllerAnimated:YES completion:completion];
    } else {
        completion();
    }
}

@end
