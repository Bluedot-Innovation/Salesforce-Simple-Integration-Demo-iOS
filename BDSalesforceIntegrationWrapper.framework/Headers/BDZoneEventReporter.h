//
//  BDZoneEventReporter.h
//  SalesforceIntegrationDemo
//
//  Created by Jason Xie on 10/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "BDPZoneEventReporterDelegate.h"

@interface BDZoneEventReporter : NSObject

/**
 *  The delegate of BDZoneEventReporter with callback methods to indicate 
 *  whether the zone event was reported successfully or not.
 */
@property (nonatomic, assign) id<BDPZoneEventReporterDelegate> delegate;

/**
 *  Gets the shared instance of the `BDZoneEventReporter`.
 *  @return The shared instance of the class.
 */
+ (instancetype)sharedInstance;

/**
 *  Report check-in event for given zone.
 *  @param salesforceSubscriberKey Salesforce subscriber key.
 *  @param zoneId ID of the triggered zone.
 *  @param apiKey API key for the app from HubExchange.
 *  @param packageName Package name for the app from HubExchange.
 *  @param username Email address for the app from HubExchange.
 */
- (void)reportCheckInWithSalesforceSubscriberKey:(NSString *) salesforceSubscriberKey
                                          zoneId:(NSString *) zoneId
                                          apiKey:(NSString *) apiKey
                                     packageName:(NSString *) packageName
                                        username:(NSString *) username;

/**
 *  Report check-out event for given zone.
 *  @param salesforceSubscriberKey Salesforce subscriber key.
 *  @param zoneId ID of the triggered zone.
 *  @param apiKey API key for the app from HubExchange.
 *  @param packageName Package name for the app from HubExchange.
 *  @param username Email address for the app from HubExchange.
 */
- (void)reportCheckOutWithSalesforceSubscriberKey:(NSString *) salesforceSubscriberKey
                                           zoneId:(NSString *) zoneId
                                           apiKey:(NSString *) apiKey
                                      packageName:(NSString *) packageName
                                         username:(NSString *) username;

@end
