//
//  BDPIntegrationManagerDelegate.h

//  SalesforceIntegrationDemo
//
//  Created by Jason Xie on 9/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

@protocol BDPIntegrationManagerDelegate <NSObject>

- (void)configureETPushSuccessful;

- (void)authenticatePointSDKSuccessful;

@optional

- (void)configureETPushFailedWithError: (NSError *)error;

- (void)authenticatePointSDKFailedWithError: (NSError *)error;

@end
