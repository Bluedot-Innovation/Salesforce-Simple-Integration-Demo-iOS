//
//  BDAuthenticateData.h
//  SalesforceIntegrationDemo
//
//  Created by Jason Xie on 10/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDAuthenticateData : NSObject

+ (instancetype)authenticateData;

@property (nonatomic, readonly) NSString *pointApiKey;
@property (nonatomic, readonly) NSString *pointPackageName;
@property (nonatomic, readonly) NSString *pointUsername;

@property (nonatomic, readonly) NSString *etAppID;
@property (nonatomic, readonly) NSString *etAccessToken;

@end