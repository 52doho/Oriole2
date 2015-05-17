//
//  OOViewController.m
//  Oriole2_App
//
//  Created by Gary Huang on 12-2-22.
//  Copyright (c) 2012年 Oriole2 Ltd. All rights reserved.
//

#import "OOViewController.h"

@implementation OOViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"res" ofType:@"txt"];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    [_oriole2Ad bindWithData:dic];
}

- (void)viewDidUnload
{
    [self setOriole2Ad:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Hi!"];
//	[[TKAlertCenter defaultCenter] postAlertWithMessage:@"This is the alert system"];
//	[[TKAlertCenter defaultCenter] postAlertWithMessage:@"Use images too!" image:[UIImage imageNamed:@"beer"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)btnMoreAppsTapped:(id)sender
{
//    [OOMoreAppsVC showInViewController:self];
//    [OOCommon openInAppStoreWithID:512796815 viewController:[OOCommon getTopmostViewController]];
    
    [[NSArray array] objectAtIndex:0];
//    OOViewController *vc = [[[OOViewController alloc] initWithNibName:@"OOViewController" bundle:nil] autorelease];
//    vc.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentModalViewController:vc animated:YES];
}

- (IBAction)btnTapped:(id)sender
{
//    [[iRate sharedInstance] logEvent:NO];
//    [iRate sharedInstance].appStoreID = 512796815;
//    [[iRate sharedInstance] promptForRating];
//    [iVersion sharedInstance].appStoreID = 512796815;
}

- (IBAction)btnCancelTapped:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [_oriole2Ad release];
    [super dealloc];
}
@end
