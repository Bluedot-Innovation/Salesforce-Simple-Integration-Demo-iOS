//
//  BDZoneEvent.h
//  BDSalesforceIntegrationWrapper
//
//  Created by Ravindra Wuyyuru on 29/6/17.
//  Copyright © 2017 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol BDZoneEventBuilder <NSObject>

@required
- (void)setSalesforceSubscriberKey:(NSString *)salesforceSubscriberKey;
- (void)setApiKey:(NSString *)apiKey;
- (void)setPackageName:(NSString *)packageName;
- (void)setUserName:(NSString *)userName;
- (void)setZoneId:(NSString *)zoneId;

@optional
- (void)setZoneName:(NSString *)zoneName;
- (void)setFenceId:(NSString *)fenceId;
- (void)setFenceName:(NSString *)fenceName;
- (void)setBeaconId:(NSString *)beaconId;
- (void)setBeaconName:(NSString *)beaconName;

- (void)setCheckInTime:(NSString *)checkInTime;
- (void)setCheckOutTime:(NSString *)checkOutTime;
- (void)setCheckInLatitude:(NSNumber *)checkInLatitude;
- (void)setCheckInLongitude:(NSNumber *)checkInLongitude;
- (void)setCheckInBearing:(NSNumber *)checkInBearing;

- (void)setCheckInSpeed:(NSNumber *)checkInSpeed;
- (void)setDwellTime:(NSNumber *)dwellTime;
- (void)setCustomData:(NSDictionary *)customData;
@end


@interface BDZoneEvent :NSObject

@property (nonatomic, readonly)  NSString *salesforceSubscriberKey;
@property (nonatomic, readonly)  NSString *apiKey;
@property (nonatomic, readonly)  NSString *packageName;
@property (nonatomic, readonly)  NSString *userName;
@property (nonatomic, readonly)  NSString *zoneId;
@property (nonatomic, readonly)  NSString *zoneName;
@property (nonatomic, readonly)  NSString *fenceId;
@property (nonatomic, readonly)  NSString *fenceName;
@property (nonatomic, readonly)  NSString *beaconId;
@property (nonatomic, readonly)  NSString *beaconName;
@property (nonatomic, readonly)  NSString *checkInTime;
@property (nonatomic, readonly)  NSString *checkOutTime;
@property (nonatomic, readonly)  NSNumber *checkInLatitude;
@property (nonatomic, readonly)  NSNumber *checkInLongitude;
@property (nonatomic, readonly)  NSNumber *checkInBearing;
@property (nonatomic, readonly)  NSNumber *checkInSpeed;
@property (nonatomic, readonly)  NSNumber *dwellTime;
@property (nonatomic, readonly)  NSDictionary *customData;


+ (instancetype)build:(void(^)(id<BDZoneEventBuilder>builder))buildBlock;
- (NSDictionary *)dictionary;

@end
