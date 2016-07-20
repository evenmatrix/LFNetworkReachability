//
//  LFTelephonyNetworkInfo.m
//  Demo1
//
//  Created by wangxiaoxiang on 16/7/19.
//  Copyright © 2016年 wangxiaoxiang. All rights reserved.
//

#import "LFTelephonyNetworkInfo.h"
#import <UIKit/UIKit.h>

#if !TARGET_OS_WATCH

NSString * const LFSubscriberCellularProviderChinaUnicom = @"中国联通";     ///<中国联通

NSString * const LFSubscriberCellularProviderChinaTelecom = @"中国电信";    ///<中国电信

NSString * const LFSubscriberCellularProviderCMCC = @"中国移动";            ///<中国移动

@interface LFTelephonyNetworkInfo ()

@property (nonatomic, assign, readwrite) LFRadioAccessTechnologyGroup radioAccessTechnologyGroup;

@end

@implementation LFTelephonyNetworkInfo {
    CTTelephonyNetworkInfo *_internalInfo;
}

+ (instancetype)currentInfo {
    static LFTelephonyNetworkInfo *g_telephonyNetworkInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_telephonyNetworkInfo = [[LFTelephonyNetworkInfo alloc] _init];
    });
    return g_telephonyNetworkInfo;
}

#pragma mark -
#pragma mark - Lifecycle

- (instancetype)init {
    [self doesNotRecognizeSelector:@selector(init)];
    return nil;
}

- (instancetype)_init {
    self = [super init];
    if (self) {
        _internalInfo = [CTTelephonyNetworkInfo new];
        LFRadioAccessTechnologyGroup newGroup = [[self class] _radioAccessTechnologyGroupWithString:_internalInfo.currentRadioAccessTechnology];
        self.radioAccessTechnologyGroup = newGroup;
#if DEBUG
        NSLog(@"init->%@",[[self class] _stringWithRadioAccessTechnologyGroup:self.radioAccessTechnologyGroup]);
#endif
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(_radioAccessTechnologyDidChangeNotification:)
                              name:CTRadioAccessTechnologyDidChangeNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(_applicationDidBecomeActiveNotification:)
                              name:UIApplicationDidBecomeActiveNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(_applicationDidEnterBackgroundNotification:)
                              name:UIApplicationDidEnterBackgroundNotification
                            object:nil];
    }
    return self;
}

- (void)dealloc {
    _internalInfo = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark - Notifications
- (void)_applicationDidEnterBackgroundNotification:(NSNotification *)note{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:CTRadioAccessTechnologyDidChangeNotification
                           object:nil];
}


- (void)_applicationDidBecomeActiveNotification:(NSNotification *)note{
    _internalInfo = [CTTelephonyNetworkInfo new];
    LFRadioAccessTechnologyGroup newGroup = [[self class] _radioAccessTechnologyGroupWithString:_internalInfo.currentRadioAccessTechnology];
    self.radioAccessTechnologyGroup = newGroup;
#if DEBUG
    NSLog(@"did become active->%@",[[self class] _stringWithRadioAccessTechnologyGroup:self.radioAccessTechnologyGroup]);
#endif
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(_radioAccessTechnologyDidChangeNotification:)
                          name:CTRadioAccessTechnologyDidChangeNotification
                        object:nil];
}

- (void)_radioAccessTechnologyDidChangeNotification:(NSNotification *)notification {
    LFRadioAccessTechnologyGroup newGroup = [[self class] _radioAccessTechnologyGroupWithString:_internalInfo.currentRadioAccessTechnology];
    self.radioAccessTechnologyGroup = newGroup;
#if DEBUG
    NSLog(@"RAT did change->%@",[[self class] _stringWithRadioAccessTechnologyGroup:self.radioAccessTechnologyGroup]);
#endif
}


#pragma mark -
#pragma mark - setter & getter
- (NSString *)radioAccessTechnology {
    return _internalInfo.currentRadioAccessTechnology;
}


- (CTCarrier *)subscriberCellularProvider {
    return _internalInfo.subscriberCellularProvider;
}



#pragma mark -
#pragma mark - private helper

/*
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyGPRS          __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyEdge          __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyWCDMA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyHSDPA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyHSUPA         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMA1x        __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORev0  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORevA  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyCDMAEVDORevB  __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyeHRPD         __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 CORETELEPHONY_EXTERN NSString * const CTRadioAccessTechnologyLTE           __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);
 */
+ (LFRadioAccessTechnologyGroup)_radioAccessTechnologyGroupWithString:(NSString *)string {
    NSString *currentRadioAccessTechnology = string;
    if (currentRadioAccessTechnology) {
        if ([currentRadioAccessTechnology isEqual:CTRadioAccessTechnologyLTE]) {
            return LFRadioAccessTechnologyGroup4G;
        } else if ([currentRadioAccessTechnology isEqual:CTRadioAccessTechnologyEdge] ||
                   [currentRadioAccessTechnology isEqual:CTRadioAccessTechnologyGPRS]) {
            return LFRadioAccessTechnologyGroup2G;
        } else {
            return LFRadioAccessTechnologyGroup3G;
        }
    }
    return LFRadioAccessTechnologyGroupUnknown;
}

+ (NSString *)_stringWithRadioAccessTechnologyGroup:(LFRadioAccessTechnologyGroup)radioAccessTechnologyGroup {
    switch (radioAccessTechnologyGroup) {
        case LFRadioAccessTechnologyGroupUnknown: {
            return @"Unknown";
            break;
        }
        case LFRadioAccessTechnologyGroup2G: {
            return @"2G";
            break;
        }
        case LFRadioAccessTechnologyGroup3G: {
            return @"3G";
            break;
        }
        case LFRadioAccessTechnologyGroup4G: {
            return @"4G";
            break;
        }
    }
}

@end

#endif //#if !TARGET_OS_WATCH
