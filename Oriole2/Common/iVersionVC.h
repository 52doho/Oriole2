//
//  iVersionVC.h
//  Weathergram
//
//  Created by Gary Wong on 5/29/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iVersionVC : UIViewController
{
    
}
@property (strong, nonatomic) IBOutlet UIButton *btnUpdateNow;
@property (strong, nonatomic) IBOutlet UIButton *btnRemindLater;
@property (strong, nonatomic) IBOutlet UIButton *btnNoUpdate;

@property (strong, nonatomic) IBOutlet UILabel *lblAppName;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UITextView *txtDesc;

@property (strong, nonatomic) IBOutlet UIView *bounceAnimationView;

@end
