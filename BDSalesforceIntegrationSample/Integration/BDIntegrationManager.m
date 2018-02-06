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
        NSString * etPushSubscriberKey = [[ETPush pushManager] getSubscriberKey];
        NSString * userDefaultSubscriberKey =  [userDefaults stringForKey:subscriberKeyUserDefaultsKey];
        NSString * subscriberKey = etPushSubscriberKey ?: userDefaultSubscriberKey;
        
        if ( subscriberKey == nil )
        {
            subscriberKey = [NSUUID UUID].UUIDString;
            [[ETPush pushManager] setSubscriberKey:subscriberKey];
            [userDefaults setValue:subscriberKey forKey:subscriberKeyUserDefaultsKey];
            [[ETPush pushManager] updateET];
        }
        
        if (etPushSubscriberKey == nil && userDefaultSubscriberKey != nil) {

            [[ETPush pushManager] setSubscriberKey:userDefaultSubscriberKey];
            [[ETPush pushManager] updateET];
        }
        
        NSLog(@"SubscriberKey: %@", [userDefaults stringForKey:subscriberKeyUserDefaultsKey]);
    }
}

- (void)authenticateBDPoint
{
    [BDLocationManager.instance authenticateWithApiKey:_authenticateData.pointApiKey
                                           packageName:_authenticateData.pointPackageName
                                              username:_authenticateData.pointUsername];
}

#pragma mark BDPLocationDelegate
- (NSString *)get8601formattedDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDate *now = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:now];
    
    return iso8601String;
}

- (void)didCheckIntoFence:(BDFenceInfo *)fence
                   inZone:(BDZoneInfo *)zoneInfo
              atLocation: (BDLocationInfo *)location
             willCheckOut:(BOOL)willCheckOut
           withCustomData:(NSDictionary *)customData
{
    BDAuthenticateData *authenticateData = BDAuthenticateData.authenticateData;
    
    BDZoneEvent *zoneEvent = [BDZoneEvent build:^(id<BDZoneEventBuilder> builder) {
        [builder setSalesforceSubscriberKey:[[ETPush pushManager] getSubscriberKey]];
        [builder setApiKey:authenticateData.pointApiKey];
        [builder setZoneId:zoneInfo.ID];
        [builder setZoneName:zoneInfo.name];
        [builder setPackageName:authenticateData.pointPackageName];
        [builder setUserName:authenticateData.pointUsername];
        [builder setFenceId:fence.ID];
        [builder setFenceName:fence.name];
        [builder setCheckInTime:[self get8601formattedDate]];
        [builder setCheckInLatitude:[NSNumber numberWithDouble:location.latitude]];
        [builder setCheckInLongitude:[NSNumber numberWithDouble:location.longitude]];
        [builder setCheckInBearing:[NSNumber numberWithDouble:location.bearing]];
        [builder setCheckInSpeed:[NSNumber numberWithDouble:location.speed]];
        [builder setCustomData:customData];
    }];
    
    [[BDZoneEventReporter sharedInstance] reportCheckInWithBDZoneEvent: zoneEvent];
}

- (void)didCheckIntoBeacon:(BDBeaconInfo *)beacon
                    inZone:(BDZoneInfo *)zoneInfo
                atLocation: (BDLocationInfo *)locationInfo
             withProximity: (CLProximity)proximity
              willCheckOut: (BOOL)willCheckOut
            withCustomData: (NSDictionary *)customData
{
    BDAuthenticateData *authenticateData = BDAuthenticateData.authenticateData;
    
    BDZoneEvent *zoneEvent = [BDZoneEvent build:^(id<BDZoneEventBuilder> builder) {
        [builder setSalesforceSubscriberKey:[[ETPush pushManager] getSubscriberKey]];
        [builder setApiKey:authenticateData.pointApiKey];
        [builder setZoneId:zoneInfo.ID];
        [builder setZoneName:zoneInfo.name];
        [builder setPackageName:authenticateData.pointPackageName];
        [builder setUserName:authenticateData.pointUsername];
        [builder setBeaconId:beacon.ID];
        [builder setBeaconName:beacon.name];
        [builder setCheckInTime:[self get8601formattedDate]];
        [builder setCheckInLatitude:[NSNumber numberWithDouble:locationInfo.latitude]];
        [builder setCheckInLongitude:[NSNumber numberWithDouble:locationInfo.longitude]];
        [builder setCheckInBearing:[NSNumber numberWithDouble:locationInfo.bearing]];
        [builder setCheckInSpeed:[NSNumber numberWithDouble:locationInfo.speed]];
        [builder setCustomData:customData];
    }];
    
    [[BDZoneEventReporter sharedInstance] reportCheckInWithBDZoneEvent: zoneEvent];
}

- (void)didCheckOutFromFence:(BDFenceInfo *)fence
                      inZone:(BDZoneInfo *)zoneInfo
                      onDate:(NSDate *)date
                withDuration:(NSUInteger)checkedInDuration
              withCustomData:(NSDictionary *)customData
{
    BDAuthenticateData *authenticateData = BDAuthenticateData.authenticateData;
    
    BDZoneEvent *zoneEvent = [BDZoneEvent build:^(id<BDZoneEventBuilder> builder) {
        [builder setSalesforceSubscriberKey:[[ETPush pushManager] getSubscriberKey]];
        [builder setApiKey:authenticateData.pointApiKey];
        [builder setZoneId:zoneInfo.ID];
        [builder setZoneName:zoneInfo.name];
        [builder setPackageName:authenticateData.pointPackageName];
        [builder setUserName:authenticateData.pointUsername];
        [builder setFenceId:fence.ID];
        [builder setFenceName:fence.name];
        [builder setCheckOutTime:[self get8601formattedDate]];
        [builder setDwellTime:[NSNumber numberWithInt:checkedInDuration]];
        [builder setCustomData:customData];
    }];
    
    [[BDZoneEventReporter sharedInstance] reportCheckOutWithBDZoneEvent: zoneEvent];
}

- (void)didCheckOutFromBeacon:(BDBeaconInfo *)beacon
                       inZone:(BDZoneInfo *)zoneInfo
                withProximity:(CLProximity)proximity
                       onDate:(NSDate *)date
                 withDuration:(NSUInteger)checkedInDuration
               withCustomData:(NSDictionary *)customData
{
    BDAuthenticateData *authenticateData = BDAuthenticateData.authenticateData;
    
    BDZoneEvent *zoneEvent = [BDZoneEvent build:^(id<BDZoneEventBuilder> builder) {
        [builder setSalesforceSubscriberKey:[[ETPush pushManager] getSubscriberKey]];
        [builder setApiKey:authenticateData.pointApiKey];
        [builder setZoneId:zoneInfo.ID];
        [builder setZoneName:zoneInfo.name];
        [builder setPackageName:authenticateData.pointPackageName];
        [builder setUserName:authenticateData.pointUsername];
        [builder setBeaconId:beacon.ID];
        [builder setBeaconName:beacon.name];
        [builder setCheckOutTime:[self get8601formattedDate]];
        [builder setDwellTime:[NSNumber numberWithInt:checkedInDuration]];
        [builder setCustomData:customData];
    }];
    [[BDZoneEventReporter sharedInstance] reportCheckOutWithBDZoneEvent: zoneEvent];
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
