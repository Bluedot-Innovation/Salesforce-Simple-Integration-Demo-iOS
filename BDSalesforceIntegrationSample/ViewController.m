//
//  ViewController.m
//  BDSalesforceIntegrationSample
//
//  Created by Jason Xie on 23/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "ViewController.h"
#import <BluedotPointSDK-Salesforce/BluedotPointSDK-Salesforce.h>

@interface ViewController () <BDPZoneEventReporterDelegate, BDPIntegrationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *marketingCloudStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *bdPointStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoneEventReporterStatus;
@property (weak, nonatomic) IBOutlet UITextView *errorTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BDIntegrationManager.instance.delegate = self;
    BDZoneEventReporter.sharedInstance.delegate = self;
    
    _marketingCloudStatusLabel.text = [self authenticationStatusMessage:BDIntegrationManager.instance.salesforceAuthenticationStatus];
    _bdPointStatusLabel.text = [self authenticationStatusMessage:BDIntegrationManager.instance.pointSDKAuthenticationStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)authenticationStatusMessage:(AuthenticationStatus)status {
    switch (status) {
        case AuthenticationStatusNotAuthenticated:
            return @"Not authenticated";
        case AuthenticationStatusAuthenticated:
            return @"Started";
        case AuthenticationStatusFailed:
            return @"Failed";
    }
}

#pragma mark BDPZoneEventReporterDelegate

- (void)reportSuccessful
{
    _zoneEventReporterStatus.text = @"Successful";
}

- (void)reportFailedWithError:(NSError *)error
{
    _zoneEventReporterStatus.text = @"Failed";
    
   NSString *errorMessage = [NSString stringWithFormat:@"Zone event report error: %@", error.localizedDescription];
   _errorTextView.text = [_errorTextView.text stringByAppendingString:errorMessage];
}

#pragma mark BDPIntegrationWrapperDelegate

- (void)configureMarketingCloudSDKSuccessful
{
    _marketingCloudStatusLabel.text = @"Started";
}

- (void)authenticatePointSDKSuccessful
{
    _bdPointStatusLabel.text = @"Started";
}

@end
