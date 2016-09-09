//
//  ViewController.m
//  BDSalesforceIntegrationSample
//
//  Created by Jason Xie on 23/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "ViewController.h"
#import <BDSalesforceIntegrationWrapper/BDZoneEventReporter.h>
#import "BDIntegrationManager.h"
#import "ETPush.h"
#import "BDAuthenticateData.h"

@interface ViewController () <BDPZoneEventReporterDelegate, BDPIntegrationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *etPushStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *bdPointStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoneEventReporterStatus;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BDIntegrationManager.instance.delegate = self;
    BDZoneEventReporter.sharedInstance.delegate = self;
    
    [BDIntegrationManager.instance authenticateETPush];
    [BDIntegrationManager.instance authenticateBDPoint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BDPZoneEventReporterDelegate

- (void)reportSuccessful
{
    _zoneEventReporterStatus.text = @"Successful";
}

- (void)reportFailedWithError:(NSError *)error
{
    _zoneEventReporterStatus.text = @"Failed";
    _errorLabel.text = error.localizedDescription;
}

#pragma mark BDPIntegrationWrapperDelegate

- (void)configureETPushSuccessful
{
    _etPushStatusLabel.text = @"Started";
}

- (void)authenticatePointSDKSuccessful
{
    _bdPointStatusLabel.text = @"Started";
}

@end
