//
//  LFNetworkReachability.m
//  LaiFeng
//
//  Created by wangxiaoxiang on 16/6/15.
//  Copyright © 2016年 live Interactive. All rights reserved.
//

#import "LFNetworkReachability.h"


#if !TARGET_OS_WATCH
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const LFNetworkReachabilityDidChangeNotification = @"com.youku.laifeng.networking.reachability.changeNotification";
NSString * const LFNetworkReachabilityChangeStatusKey = @"LFNetworkingReachabilityChangeStatusKey";

typedef void (^LFNetworkReachabilityStatusBlock)(LFNetworkReachabilityStatus status);

NSString * LFStringFromNetworkReachabilityStatus(LFNetworkReachabilityStatus status) {
    switch (status) {
        case LFNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"LFNetworkingReachability", nil);
        case LFNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"LFNetworkingReachability", nil);
        case LFNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"LFNetworkingReachability", nil);
        case LFNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"LFNetworkingReachability", nil);
    }
}

static LFNetworkReachabilityStatus LFNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    LFNetworkReachabilityStatus status = LFNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = LFNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = LFNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = LFNetworkReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

/**
 * Queue a status change notification for the main thread.
 *
 * This is done to ensure that the notifications are received in the same order
 * as they are sent. If notifications are sent directly, it is possible that
 * a queued notification (for an earlier status condition) is processed after
 * the later update, resulting in the listener being left in the wrong state.
 */
static void LFPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, LFNetworkReachabilityStatusBlock block) {
    LFNetworkReachabilityStatus status = LFNetworkReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ LFNetworkReachabilityChangeStatusKey: @(status) };
        [notificationCenter postNotificationName:LFNetworkReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

static void LFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    LFPostReachabilityStatusChange(flags, (__bridge LFNetworkReachabilityStatusBlock)info);
}


static const void * LFNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void LFNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface LFNetworkReachability ()
@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) LFNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) LFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation LFNetworkReachability

+ (instancetype)sharedReachability {
    static LFNetworkReachability *_sharedReachability = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedReachability = [self _reachability];
    });
    
    return _sharedReachability;
}

+ (instancetype)reachabilityForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    
    LFNetworkReachability *lfReachability = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return lfReachability;
}

+ (instancetype)reachabilityForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    LFNetworkReachability *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

+ (instancetype)_reachability
{
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self reachabilityForAddress:&address];
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _networkReachability = CFRetain(reachability);
    self.networkReachabilityStatus = LFNetworkReachabilityStatusUnknown;
    
    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == LFNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == LFNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];
    
    if (!self.networkReachability) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    LFNetworkReachabilityStatusBlock callback = ^(LFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
        
    };
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, LFNetworkReachabilityRetainCallback, LFNetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, LFNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            LFPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return LFStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(LFNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] ||
        [key isEqualToString:@"reachableViaWWAN"] ||
        [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif
