//
//  BDIntegrationManager.m
//  SalesforceIntegrationDemo
//
//  Created by Jason Xie on 9/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BDSalesforceIntegrationWrapper/BDZoneEventReporter.h>
#import <BDPointSDK.h>
#import "BDIntegrationManager.h"
#import "BDAuthenticateData.h"
#import "ETPush.h"

static NSString *subscriberKeyUserDefaultsKey = @"SubcriberKeyUserDefaultsKey";

@interface BDIntegrationManager () <BDPointDelegate>

@property (nonatomic) BDAuthenticateData *authenticateData;

@end

@implementation BDIntegrationManager

+ (instancetype)instance
{
    static BDIntegrationManager  *shareInstance = nil;
    static dispatch_once_t   dispatchOncePredicate  = 0;
    
    dispatch_block_t singletonInit = ^
    {
        dispatch_block_t mainInit = ^
        {
            shareInstance = [ [ BDIntegrationManager alloc ] init ];
            [ shareInstance setup ];
        };
        
        if( NSThread.currentThread.isMainThread )
        {
            mainInit();
        }
        else
        {
            dispatch_sync( dispatch_get_main_queue(), mainInit );
        }
    };
    
    dispatch_once( &dispatchOncePredicate, singletonInit );
    
    return( shareInstance );
}

- (void)setup
{
    BDLocationManager.instance.sessionDelegate = self;
    BDLocationManager.instance.locationDelegate = self;
    _authenticateData = BDAuthenticateData.authenticateData;
}

- (void)authenticateETPush
{
    BOOL successful = NO;
    NSError *error = nil;
    
    successful = [[ ETPush pushManager ] configureSDKWithAppID:_authenticateData.etAppID
                                                andAccessToken:_authenticateData.etAccessToken
                                                 withAnalytics:NO
                                           andLocationServices:NO
                                          andProximityServices:NO
                                                 andCloudPages:NO
                                               withPIAnalytics:NO
                                                         error:&error];
    
    if ( successful == NO )
    {
        if ( [ _delegate respondsToSelector:@selector(configureETPushFailedWithError:) ] )
            [ _delegate configureETPushFailedWithError:error ];
    }
    else
    {
        if ( [ _delegate respondsToSelector:@selector(configureETPushSuccessful) ] )
            [ _delegate configureETPushSuccessful ];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * subscriberKey = [[ETPush pushManager] getSubscriberKey] ?: [userDefaults stringForKey:subscriberKeyUserDefaultsKey];
        
        if ( subscriberKey == nil )
        {
            subscriberKey = [NSUUID UUID].UUIDString;
            [[ETPush pushManager] setSubscriberKey:subscriberKey];
            [userDefaults setValue:subscriberKey forKey:subscriberKeyUserDefaultsKey];
            [[ETPush pushManager] updateET];
        }
        
        NSLog(@"SubscriberKey: %@", subscriberKey);
    }
}

- (void)authenticateBDPoint
{
#ifdef DEBUG
    [BDLocationManager.instance authenticateWithApiKey:_authenticateData.pointApiKey
                                           packageName:_authenticateData.pointPackageName
                                              username:_authenticateData.pointUsername
                                           endpointURL:[NSURL URLWithString:@"https://uat3.bluedotinnovation.com/pointapi-v1"]];
#else
    [BDLocationManager.instance authenticateWithApiKey:_authenticateData.pointApiKey
                                           packageName:_authenticateData.pointPackageName
                                              username:_authenticateData.pointUsername];
#endif
}

- (void)reportCheckInWithZoneId:(NSString *)zoneId
{
    BDAuthenticateData *authenticateData = BDAuthenticateData.authenticateData;
    
    [[BDZoneEventReporter sharedInstance] reportCheckInWithSalesforceSubscriberKey:[[ETPush pushManager] getSubscriberKey]
                                                                            zoneId:zoneId
                                                                            apiKey:authenticateData.pointApiKey
                                                                       packageName:authenticateData.pointPackageName
                                                                          username:authenticateData.pointUsername];
}

- (void)reportCheckOutWithZoneId:(NSString *)zoneId
{
    BDAuthenticateData *authenticateData = BDAuthenticateData.authenticateData;
    
    [[BDZoneEventReporter sharedInstance] reportCheckOutWithSalesforceSubscriberKey:[[ETPush pushManager] getSubscriberKey]
                                                                             zoneId:zoneId
                                                                             apiKey:authenticateData.pointApiKey
                                                                        packageName:authenticateData.pointPackageName
                                                                           username:authenticateData.pointUsername];
}

#pragma mark BDPLocationDelegate

- (void)didCheckIntoFence:(BDFenceInfo *)fence
                   inZone:(BDZoneInfo *)zoneInfo
             atCoordinate:(BDLocationCoordinate2D)coordinate
                   onDate:(NSDate *)date
             willCheckOut:(BOOL)willCheckOut
           withCustomData:(NSDictionary *)customData
{
    [ self reportCheckInWithZoneId:zoneInfo.ID ];
}

- (void)didCheckIntoBeacon:(BDBeaconInfo *)beacon
                    inZone:(BDZoneInfo *)zoneInfo
             withProximity:(CLProximity)proximity
                    onDate:(NSDate *)date
              willCheckOut:(BOOL)willCheckOut
            withCustomData:(NSDictionary *)customData
{
    [ self reportCheckInWithZoneId:zoneInfo.ID ];
}

- (void)didCheckOutFromFence:(BDFenceInfo *)fence
                      inZone:(BDZoneInfo *)zoneInfo
                      onDate:(NSDate *)date
                withDuration:(NSUInteger)checkedInDuration
              withCustomData:(NSDictionary *)customData
{
    [self reportCheckOutWithZoneId:zoneInfo.ID];
}

- (void)didCheckOutFromBeacon:(BDBeaconInfo *)beacon
                       inZone:(BDZoneInfo *)zoneInfo
                withProximity:(CLProximity)proximity
                       onDate:(NSDate *)date
                 withDuration:(NSUInteger)checkedInDuration
               withCustomData:(NSDictionary *)customData
{
    [self reportCheckOutWithZoneId:zoneInfo.ID];
}

#pragma mark BDPSessionDelegate

- (void)authenticationWasSuccessful
{
    if ( _delegate && [ _delegate respondsToSelector:@selector(authenticatePointSDKSuccessful) ] )
        [ _delegate authenticatePointSDKSuccessful ];
}

- (void)authenticationWasDeniedWithReason: (NSString *)reason
{
    if ( _delegate && [ _delegate respondsToSelector:@selector(authenticatePointSDKFailedWithError:) ] ) {
        NSError *error = [ NSError errorWithDomain:NSStringFromClass(self.class)
                                              code:kCFSOCKS4ErrorRequestFailed
                                          userInfo:@{ NSLocalizedDescriptionKey: reason } ];
        [ _delegate authenticatePointSDKFailedWithError:error ];
    }
}

- (void)authenticationFailedWithError: (NSError *)error
{
    if ( _delegate && [ _delegate respondsToSelector:@selector(authenticatePointSDKFailedWithError:) ] )
        [ _delegate authenticatePointSDKFailedWithError:error ];
}

- (void)willAuthenticateWithUsername: (NSString *)username
                              apiKey: (NSString *)apiKey
                         packageName: (NSString *)packageName
{
}

- (void)didEndSession
{
}

- (void)didEndSessionWithError: (NSError *)error
{
}

@end