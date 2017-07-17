//
//  BDZoneEventReporter.h
//  SalesforceIntegrationDemo
//
//  Created by Jason Xie on 10/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "BDPZoneEventReporterDelegate.h"
#import "BDZoneEvent.h"

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
 *  @param BDZoneEvent event containing information of given zone
 */
- (void)reportCheckInWithBDZoneEvent:(BDZoneEvent *) zoneEvent;

/**
 *  Report check-out event for given zone.
 *  @param BDZoneEvent event containing information of given zone
 */
- (void)reportCheckOutWithBDZoneEvent:(BDZoneEvent *) zoneEvent;

@end
