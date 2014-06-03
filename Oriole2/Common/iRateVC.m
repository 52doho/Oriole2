//
//  iRateVC.m
//  Weathergram
//
//  Created by Gary Wong on 5/29/13.
//  Copyright (c) 2013 Oriole2 Co., Ltd. All rights reserved.
//

#import "iRateVC.h"

@interface iRateVC ()

@end

@implementation iRateVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (void)dealloc
{
    
}

@end
