//
//  LFTelephonyNetworkInfo.m
//  Demo1
//
//  Created by wangxiaoxiang on 16/7/19.
//  Copyright © 2016年 wangxiaoxiang. All rights reserved.
//

#import "LFTelephonyNetworkInfo.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface LFTelephonyNetworkInfo ()

@property (nonatomic, assign, readwrite) LFRadioAccessTechnology radioAccessTechnology;

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


- (instancetype)_init {
    self = [super init];
    if (self) {
        _internalInfo = [CTTelephonyNetworkInfo new];
        self.radioAccessTechnology = [[self class] _radioAccessTechnologyWithString:_internalInfo.currentRadioAccessTechnology];
#if DEBUG
        NSLog(@"%@",[[self class] _textWithRadioAccessTechnology:self.radioAccessTechnology]);
#endif
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_radioAccessTechnologyDidChange:)
                                                     name:CTRadioAccessTechnologyDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    _internalInfo = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTRadioAccessTechnologyDidChangeNotification object:nil];
}


- (void)_radioAccessTechnologyDidChange:(NSNotification *)notification {
    self.radioAccessTechnology = [[self class] _radioAccessTechnologyWithString:_internalInfo.currentRadioAccessTechnology];
#if DEBUG
    NSLog(@"%@",[[self class] _textWithRadioAccessTechnology:self.radioAccessTechnology]);
#endif
}

- (LFRadioAccessTechnology)radioAccessTechnology {
    return [[self class] _radioAccessTechnologyWithString:_internalInfo.currentRadioAccessTechnology];
}


- (instancetype)init
{
    [self doesNotRecognizeSelector:@selector(init)];
    return nil;
}

#pragma mark -
#pragma mark - private helper

+ (LFRadioAccessTechnology)_radioAccessTechnologyWithString:(NSString *)string {
    NSString *currentRadioAccessTechnology = string;
    if (currentRadioAccessTechnology) {
        if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
            return LFRadioAccessTechnologyLTE;
        } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] ||
                   [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
            return LFRadioAccessTechnology2G;
        } else {
            return LFRadioAccessTechnology3G;
        }
    }
    return LFRadioAccessTechnologyUnknown;
}

+ (NSString *)_textWithRadioAccessTechnology:(LFRadioAccessTechnology)radioAccessTechnology {
    switch (radioAccessTechnology) {
        case LFRadioAccessTechnologyUnknown: {
            return @"Unknown";
            break;
        }
        case LFRadioAccessTechnology2G: {
            return @"2G";
            break;
        }
        case LFRadioAccessTechnology3G: {
            return @"3G";
            break;
        }
        case LFRadioAccessTechnologyLTE: {
            return @"LTE";
            break;
        }
    }
}

@end
