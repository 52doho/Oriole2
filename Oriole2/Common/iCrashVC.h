//
//  iCrashVC.h
//  Weathergram
//
//  Created by Gary Wong on 5/29/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iCrashVC : UIViewController
{
    
}
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) IBOutlet UIButton *btnAlwaysSend;
@property (strong, nonatomic) IBOutlet UIButton *btnNoSend;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UITextView *txtDesc;

@property (strong, nonatomic) IBOutlet UIView *bounceAnimationView;

@end
