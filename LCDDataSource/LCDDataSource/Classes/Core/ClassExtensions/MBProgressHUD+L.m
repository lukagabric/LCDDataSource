//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "MBProgressHUD+L.h"


@implementation MBProgressHUD (L)


+ (MBProgressHUD *)showProgressForView:(UIView *)view
{
    NSArray *huds = [MBProgressHUD allHUDsForView:view];
    
    if (huds && [huds count] > 0)
        return nil;
    
	MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.dimBackground = YES;
	[view addSubview:hud];
	[hud show:YES];
    
	return hud;
}


+ (void)hideProgressForView:(UIView *)view
{
    [self hideAllHUDsForView:view animated:YES];
}


@end