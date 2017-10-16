//
//  OOActivityPhotoCool.h
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

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface OOActivityProviderPhotoCool : UIActivityItemProvider <UIActivityItemSource>

@end

@interface OOActivityBase : UIActivity <UIDocumentInteractionControllerDelegate, SKStoreProductViewControllerDelegate>
{
}
@property (nonatomic, assign) UIImage                         *imageToEdit;
@property (nonatomic, strong, readonly) UIBarButtonItem *presentFromButton;
@property (nonatomic, assign) UIPopoverController       *popoverController;

@property (nonatomic, assign, readonly) CGRect presentFromRect;
@property (nonatomic, strong, readonly) UIView *presentInView;

// view controller to present the store screen
@property (nonatomic, assign, readonly) UIViewController *viewController;

- (id)initWithPresentViewController:(UIViewController *)viewController barButton:(UIBarButtonItem *)presentFromButton;
- (id)initWithPresentViewController:(UIViewController *)viewController rect:(CGRect)presentFromRect view:(UIView *)presentInView;
@end

@interface OOActivityPhotoCool : OOActivityBase
{
}

@end

@interface OOActivityInstagram : OOActivityBase
{
}
@property (nonatomic, strong) NSString *caption;// 已经不能使用

+ (BOOL)canOpenInstagram;

@end
