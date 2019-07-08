//
//  ViewController.m
//  BDSalesforceIntegrationSample
//
//  Created by Jason Xie on 23/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "ViewController.h"
@import BDPointSDK;
@import MarketingCloudSDK;

@interface ViewController () <BDPointDelegate>

@property (weak, nonatomic) IBOutlet UILabel *marketingCloudStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *bdPointStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoneEventReporterStatus;
@property (weak, nonatomic) IBOutlet UITextView *errorTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL successful = NO;
    NSError *error = nil;
    
    successful = [[MarketingCloudSDK sharedInstance] sfmc_configure:&error];
    
    if (successful == NO) {
        _marketingCloudStatusLabel.text = @"Error";
    } else {
        _marketingCloudStatusLabel.text = @"Started";
    }
    
    [BDLocationManager.instance setCustomEventMetaData:@{@"ContactKey": [[MarketingCloudSDK sharedInstance] sfmc_contactKey]}];
    BDLocationManager.instance.sessionDelegate = self;
    BDLocationManager.instance.locationDelegate = self;
    
    [BDLocationManager.instance authenticateWithApiKey:@"__your_ApiKey__" requestAuthorization:authorizedAlways];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)authenticationFailedWithError:(NSError *)error {
    _bdPointStatusLabel.text = @"Error";
}

- (void)authenticationWasDeniedWithReason:(NSString *)reason {
    _bdPointStatusLabel.text = @"Denied";
}

- (void)authenticationWasSuccessful {
    _bdPointStatusLabel.text = @"Started";
}

- (void)didEndSession {
    _bdPointStatusLabel.text = @"Finished";
}

- (void)didEndSessionWithError:(NSError *)error {
    _bdPointStatusLabel.text = @"Finished";
}

- (void)willAuthenticateWithApiKey:(NSString *)apiKey {
    _bdPointStatusLabel.text = @"Starting";
}

- (void)didCheckIntoFence:(BDFenceInfo *)fence
                   inZone:(BDZoneInfo *)zoneInfo
               atLocation: (BDLocationInfo *)location
             willCheckOut:(BOOL)willCheckOut
           withCustomData:(NSDictionary *)customData {
    _zoneEventReporterStatus.text = @"Fence check-in";
}

- (void)didCheckIntoBeacon:(BDBeaconInfo *)beacon
                    inZone:(BDZoneInfo *)zoneInfo
                atLocation: (BDLocationInfo *)locationInfo
             withProximity: (CLProximity)proximity
              willCheckOut: (BOOL)willCheckOut
            withCustomData: (NSDictionary *)customData {
    _zoneEventReporterStatus.text = @"Beacon check-in";
}

- (void)didCheckOutFromFence:(BDFenceInfo *)fence
                      inZone:(BDZoneInfo *)zoneInfo
                      onDate:(NSDate *)date
                withDuration:(NSUInteger)checkedInDuration
              withCustomData:(NSDictionary *)customData {
    _zoneEventReporterStatus.text = @"Fence check-out";
}

- (void)didCheckOutFromBeacon:(BDBeaconInfo *)beacon
                       inZone:(BDZoneInfo *)zoneInfo
                withProximity:(CLProximity)proximity
                       onDate:(NSDate *)date
                 withDuration:(NSUInteger)checkedInDuration
               withCustomData:(NSDictionary *)customData {
    _zoneEventReporterStatus.text = @"Fence check-out";
}

@end
