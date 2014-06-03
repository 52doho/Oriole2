//
//  OOViewController.h
//  Oriole2_App
//
//  Created by Gary Huang on 12-2-22.
//  Copyright (c) 2012年 Oriole2 Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OOViewController : UIViewController
{
    
}
@property (retain, nonatomic) IBOutlet OOMoreAppsView *oriole2Ad;

- (IBAction)btnMoreAppsTapped:(id)sender;
- (IBAction)btnTapped:(id)sender;
- (IBAction)btnCancelTapped:(id)sender;

@end
