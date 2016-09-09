//
//  BDIntegrationManager.h
//  SalesforceIntegrationDemo
//
//  Created by Jason Xie on 9/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDPIntegrationManagerDelegate.h"

@interface BDIntegrationManager : NSObject

@property (nonatomic) id<BDPIntegrationManagerDelegate>  delegate;

+ (instancetype)instance;

- (void)authenticateETPush;

- (void)authenticateBDPoint;

@end