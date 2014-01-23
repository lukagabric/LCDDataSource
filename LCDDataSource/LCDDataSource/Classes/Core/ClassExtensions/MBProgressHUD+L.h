//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "MBProgressHUD.h"


@interface MBProgressHUD (L)


+ (MBProgressHUD *)showProgressForView:(UIView *)view;
+ (void)hideProgressForView:(UIView *)view;


@end