//
//  LFTelephonyNetworkInfo.h
//  Demo1
//
//  Created by wangxiaoxiang on 16/7/19.
//  Copyright © 2016年 wangxiaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LFRadioAccessTechnology) {
    LFRadioAccessTechnologyUnknown,
    LFRadioAccessTechnology2G,
    LFRadioAccessTechnology3G,
    LFRadioAccessTechnologyLTE,
};

@interface LFTelephonyNetworkInfo : NSObject

+ (instancetype)currentInfo;

@property (nonatomic, assign, readonly) LFRadioAccessTechnology radioAccessTechnology;

@end
