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

@interface ViewController () <BDPGeoTriggeringEventDelegate>

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
    
    MarketingCloudSDKConfigBuilder *mcsdkBuilder = [MarketingCloudSDKConfigBuilder new];
    [mcsdkBuilder sfmc_setApplicationId:@"__your app id__"];
    [mcsdkBuilder sfmc_setAccessToken:@"__your access token__"];
    [mcsdkBuilder sfmc_setMarketingCloudServerUrl:@"__your app endpoint__"];
    [mcsdkBuilder sfmc_setMid:@"__your account mid__"];
    [mcsdkBuilder sfmc_setAnalyticsEnabled:@(NO)];
    [mcsdkBuilder sfmc_setPiAnalyticsEnabled:@(NO)];
    [mcsdkBuilder sfmc_setLocationEnabled:@(NO)];
    [mcsdkBuilder sfmc_setInboxEnabled:@(NO)];
    [mcsdkBuilder sfmc_setUseLegacyPIIdentifier:@(YES)];

    successful = [[MarketingCloudSDK sharedInstance] sfmc_configureWithDictionary:[mcsdkBuilder sfmc_build] error:&error];
    
    if (successful == NO) {
        _marketingCloudStatusLabel.text = @"Error";
    } else {
        _marketingCloudStatusLabel.text = @"Started";
    }
    
    [[MarketingCloudSDK sharedInstance] sfmc_setContactKey:@"__your_contactKey__"];
    
    [BDLocationManager.instance setCustomEventMetaData:@{@"ContactKey": [[MarketingCloudSDK sharedInstance] sfmc_contactKey]}];
    
    BDLocationManager.instance.geoTriggeringEventDelegate = self;

    [BDLocationManager.instance requestWhenInUseAuthorization];
}

- (void)didEnterZone:(BDZoneEntryEvent *)enterEvent
{
    _zoneEventReporterStatus.text = @"Zone check-in";
}

- (void)didExitZone:(BDZoneExitEvent *)exitEvent
{
    _zoneEventReporterStatus.text = @"Zone check-out";
}

- (IBAction)startBluedotSDK:(id)sender {
    
    [BDLocationManager.instance initializeWithProjectId:@"YourBluedotProjectId" completion:^(NSError * _Nullable error) {
        if(error != nil){
            self->_bdPointStatusLabel.text = @"Initialization Failed";
            return;
        }
        self->_bdPointStatusLabel.text = @"Initialized";
        [BDLocationManager.instance requestAlwaysAuthorization];
        
        [BDLocationManager.instance startGeoTriggeringWithCompletion:^(NSError * _Nullable error) {
            if(error != nil){
                self->_bdPointStatusLabel.text = @"Start GeoTriggering Failed";
                return;
            }
            self->_bdPointStatusLabel.text = @"GeoTriggering Started";
        }];
    }];
}
@end
