//
//  AppDelegate.m
//  BDSalesforceIntegrationSample
//
//  Created by Jason Xie on 23/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "AppDelegate.h"
#import <BluedotPointSDK-Salesforce/BluedotPointSDK-Salesforce.h>
@import UserNotifications;
@import MarketingCloudSDK;
@import BDPointSDK;

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // set the UNUserNotificationCenter delegate - the delegate must be set here in didFinishLaunchingWithOptions
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge
                                                                        completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                                                            if (error == nil) {
                                                                                if (granted == YES) {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                                                                                    });
                                                                                }
                                                                            }
                                                                        }];
    
    [BDIntegrationManager.instance authenticateMarketingCloudSDK];
    [BDIntegrationManager.instance authenticateBDPointWithAuthorization:authorizedAlways];
    
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /**
     Inform the MarketingCloudSDK of the device token
     */
    [[MarketingCloudSDK sharedInstance] sfmc_setDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    /**
     Inform the MarketingCloudSDK that the device failed to register and did not receive a device token
     */
    os_log_debug(OS_LOG_DEFAULT, "didFailToRegisterForRemoteNotificationsWithError = %@", error);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
    // tell the MarketingCloudSDK about the notification
    [[MarketingCloudSDK sharedInstance] sfmc_setNotificationRequest:response.notification.request];
    
    if (completionHandler != nil) {
        completionHandler();
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UNMutableNotificationContent *theSilentPushContent = [[UNMutableNotificationContent alloc] init];
    theSilentPushContent.userInfo = userInfo;
    UNNotificationRequest *theSilentPushRequest = [UNNotificationRequest requestWithIdentifier:[NSUUID UUID].UUIDString content:theSilentPushContent trigger:nil];
    
    [[MarketingCloudSDK sharedInstance] sfmc_setNotificationRequest:theSilentPushRequest];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

@end

