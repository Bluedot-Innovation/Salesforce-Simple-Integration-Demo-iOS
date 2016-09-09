//
//  BDPZoneEventReporterDelegate.h
//  SalesforceIntegrationDemo
//
//  Created by Jason Xie on 9/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

@protocol BDPZoneEventReporterDelegate <NSObject>

/**
 *  This method indicates that a zone event has been reported successfully.
 */
- (void)reportSuccessful;

/**
 *  Indicates a communication error with the server when sending zone event.
 *  @param error Error returned by backend with error code and description.
 */
- (void)reportFailedWithError:(NSError *) error;

@end
