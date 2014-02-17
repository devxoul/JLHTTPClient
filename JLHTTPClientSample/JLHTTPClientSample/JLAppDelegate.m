//
//  JLAppDelegate.m
//  JLHTTPClientSample
//
//  Created by 전수열 on 2014. 2. 18..
//  Copyright (c) 2014년 xoul. All rights reserved.
//

#import "JLAppDelegate.h"

@implementation JLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
