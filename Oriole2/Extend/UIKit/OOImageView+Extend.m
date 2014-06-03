//
//  OOImageView+Extend.m
//  Oriole2
//
//  Created by Gary Wong on 3/3/11.
//  Copyright 2011 Oriole2 Ltd. All rights reserved.
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


#import "OOImageView+Extend.h"


@implementation UIImageView(Themed)

- (void)changeThemeImageTo:(UIImage *)img animated:(BOOL)animated
{
	self.image = nil;
	if (animated)
	{
		self.alpha = 0.0f;
		self.image = img;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3f];
		
		self.alpha = 1.0f;
		
		[UIView commitAnimations];
	}
	else
	{
		self.image = img;
	}
}

- (void)changeThemeImageTo:(UIImage *)img
{
	[self changeThemeImageTo:img animated:YES];
}

@end
