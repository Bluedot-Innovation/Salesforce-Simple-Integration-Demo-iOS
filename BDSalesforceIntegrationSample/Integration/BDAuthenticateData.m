//
//  BDAuthenticateData.m
//  SalesforceIntegrationDemo
//
//  Created by Jason Xie on 10/08/2016.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDAuthenticateData.h"

static NSString *kBDPointApiKey = @"BDPointApiKey";
static NSString *kBDPointPackageName = @"BDPointPackageName";
static NSString *kBDPointUsername = @"BDPointUsername";

static NSString *kETDebugAppID = @"ETDebugAppID";
static NSString *kETDebugAccessToken = @"ETDebugAccessToken";
static NSString *kETProdAppID = @"ETProdAppID";
static NSString *kETProdAccessToken = @"ETProdAccessToken";

@interface BDAuthenticateData()

@property (nonatomic, readwrite) NSString *pointApiKey;
@property (nonatomic, readwrite) NSString *pointPackageName;
@property (nonatomic, readwrite) NSString *pointUsername;

@property (nonatomic, readwrite) NSString *etAppID;
@property (nonatomic, readwrite) NSString *etAccessToken;

@end

@implementation BDAuthenticateData

+ (instancetype) authenticateData
{
    static BDAuthenticateData  *shareInstance = nil;
    static dispatch_once_t   dispatchOncePredicate  = 0;
    
    dispatch_block_t singletonInit = ^
    {
        dispatch_block_t mainInit = ^
        {
            shareInstance = [ [ BDAuthenticateData alloc ] init ];
            NSBundle *mainBundle = [ NSBundle mainBundle ];

            shareInstance.pointApiKey = [ mainBundle objectForInfoDictionaryKey:kBDPointApiKey ];
            shareInstance.pointPackageName = [ mainBundle objectForInfoDictionaryKey:kBDPointPackageName ];
            shareInstance.pointUsername = [ mainBundle objectForInfoDictionaryKey:kBDPointUsername ];

#ifdef DEBUG
            shareInstance.etAppID = [mainBundle objectForInfoDictionaryKey:kETDebugAppID];
            shareInstance.etAccessToken = [mainBundle objectForInfoDictionaryKey:kETDebugAccessToken];
#else
            shareInstance.etAppID = [mainBundle objectForInfoDictionaryKey:kETProdAppID];
            shareInstance.etAccessToken = [mainBundle objectForInfoDictionaryKey:kETProdAccessToken];
#endif
        };
        
        if( NSThread.currentThread.isMainThread )
        {
            mainInit();
        }
        else
        {
            dispatch_sync( dispatch_get_main_queue(), mainInit );
        }
    };
    
    dispatch_once( &dispatchOncePredicate, singletonInit );
    
    return( shareInstance );
}



@end