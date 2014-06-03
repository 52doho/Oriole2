//
//  OOActivityPhotoCool.h
//  BoothCool
//
//  Created by Gary Wong on 4/3/13.
//  Copyright (c) 2013 Oriole2 Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface OOActivityProviderPhotoCool : UIActivityItemProvider<UIActivityItemSource>

@end


@interface OOActivityBase : UIActivity<UIDocumentInteractionControllerDelegate, SKStoreProductViewControllerDelegate>
{
    
}
@property (nonatomic, strong, readonly) UIBarButtonItem *presentFromButton;
@property (nonatomic, assign) UIPopoverController *popoverController;

@property (nonatomic, assign, readonly) CGRect presentFromRect;
@property (nonatomic, strong, readonly) UIView *presentInView;

//view controller to present the store screen
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
@property (nonatomic, strong) NSString *caption;

@end