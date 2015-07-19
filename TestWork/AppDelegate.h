//
//  AppDelegate.h
//  TestWork
//
//  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define ApplicationDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatterUser;


@end

