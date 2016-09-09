//
//  AppDelegate.m
//  BDSalesforceIntegrationSample
//
//  Created by Jason Xie on 23/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "AppDelegate.h"
#import "ETPush.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[ETPush pushManager] applicationLaunchedWithOptions:launchOptions];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                            UIUserNotificationTypeBadge |
                                            UIUserNotificationTypeSound |
                                            UIUserNotificationTypeAlert
                                                                             categories:nil];
    // Notify the SDK what user notification settings have been selected
    [[ETPush pushManager] registerUserNotificationSettings:settings];
    [[ETPush pushManager] registerForRemoteNotifications];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    /**
     Inform the JB4ASDK of the requested notification settings
     */
    [[ETPush pushManager] didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /**
     Inform the JB4ASDK of the device token
     */
    [[ETPush pushManager] registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    /**
     Inform the JB4ASDK that the device failed to register and did not receive a device token
     */
    [[ETPush pushManager] applicationDidFailToRegisterForRemoteNotificationsWithError:error];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    /**
     Inform the JB4ASDK that the device received a local notification
     */
    NSLog(@"Local Notification Receieved");
    [[ETPush pushManager] handleLocalNotification:notification];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push Notification Received");
    [[ETPush pushManager] handleNotification:userInfo forApplicationState:application.applicationState];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    /**
     Inform the JB4ASDK that the device received a remote notification
     */
    [[ETPush pushManager] handleNotification:userInfo forApplicationState:application.applicationState];
    
    /**
     Is it a silent push?
     */
    if (userInfo[@"aps"][@"content-available"]) {
        /**
         Received a silent remote notification...
         Indicate a silent push
         */
        NSLog(@"Silent Push Notification Received");
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    } else {
        /**
         Received a remote notification...
         Clear the badge
         */
        [[ETPush pushManager] resetBadgeCount];
    }
    
    handler(UIBackgroundFetchResultNoData);
}


#pragma mark BDPIntegrationWrapperDelegate

- (void)authenticationFailedWithError:(NSError *)error
{
    NSLog(@"error: %@", error.localizedDescription);
}

@end

