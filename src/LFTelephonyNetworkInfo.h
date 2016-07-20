//
//  LFTelephonyNetworkInfo.h
//  Demo1
//
//  Created by wangxiaoxiang on 16/7/19.
//  Copyright © 2016年 wangxiaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_WATCH
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

typedef NS_ENUM(NSUInteger, LFRadioAccessTechnologyGroup) {
    LFRadioAccessTechnologyGroupUnknown,
    LFRadioAccessTechnologyGroup2G,
    LFRadioAccessTechnologyGroup3G,
    LFRadioAccessTechnologyGroup4G,
};

FOUNDATION_EXTERN NSString * const LFSubscriberCellularProviderChinaUnicom;     ///<中国联通

FOUNDATION_EXTERN NSString * const LFSubscriberCellularProviderChinaTelecom;    ///<中国电信

FOUNDATION_EXTERN NSString * const LFSubscriberCellularProviderCMCC;            ///<中国移动

@interface LFTelephonyNetworkInfo : NSObject

+ (instancetype)currentInfo;

@property (nonatomic, assign, readonly) LFRadioAccessTechnologyGroup radioAccessTechnologyGroup;

@property (readonly) NSString *radioAccessTechnology;

@property (readonly) CTCarrier *subscriberCellularProvider;

@end

#endif //!TARGET_OS_WATCH
