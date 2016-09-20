//
//  LFNetworkReachability.h
//  LFNetworkReachability
//
//  Created by wangxiaoxiang on 16/8/17.
//  Copyright © 2016年 wangxiaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for LFNetworkReachability.
FOUNDATION_EXPORT double LFNetworkReachabilityVersionNumber;

//! Project version string for LFNetworkReachability.
FOUNDATION_EXPORT const unsigned char LFNetworkReachabilityVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LFNetworkReachability/PublicHeader.h>

#import <Foundation/Foundation.h>
#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>



NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, LFNetworkReachabilityStatus) {
    LFNetworkReachabilityStatusUnknown          = -1,
    LFNetworkReachabilityStatusNotReachable     = 0,
    LFNetworkReachabilityStatusReachableViaWWAN = 1,
    LFNetworkReachabilityStatusReachableViaWiFi = 2,
};

FOUNDATION_EXPORT NSString * const LFNetworkReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const LFNetworkReachabilityChangeStatusKey;

///--------------------
/// @name Functions
///--------------------


FOUNDATION_EXPORT NSString * LFStringFromNetworkReachabilityStatus(LFNetworkReachabilityStatus status);

@interface LFNetworkReachability : NSObject

/**
 The current network reachability status.
 */
@property (readonly, nonatomic, assign) LFNetworkReachabilityStatus networkReachabilityStatus;

@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/**
 Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;


+ (instancetype)sharedReachability;

+ (instancetype)reachabilityForDomain:(NSString *)domain;

+ (instancetype)reachabilityForAddress:(const void *)address;

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability NS_DESIGNATED_INITIALIZER;

/**
 Starts monitoring for changes in network reachability status.
 */
- (void)startMonitoring;

/**
 Stops monitoring for changes in network reachability status.
 */
- (void)stopMonitoring;

///-------------------------------------------------
/// @name Getting Localized Reachability Description
///-------------------------------------------------

/**
 Returns a localized string representation of the current network reachability status.
 */
- (NSString *)localizedNetworkReachabilityStatusString;

///---------------------------------------------------
/// @name Setting Network Reachability Change Callback
///---------------------------------------------------

/**
 Sets a callback to be executed when the network availability of the `baseURL` host changes.
 @param block A block object to be executed when the network availability of the `baseURL` host changes.. This block has no return value and takes a single argument which represents the various reachability states from the device to the `baseURL`.
 */
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(LFNetworkReachabilityStatus status))block;

@end

NS_ASSUME_NONNULL_END

#endif
