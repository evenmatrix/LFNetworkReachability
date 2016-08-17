//
//  ViewController.m
//  Demo1
//
//  Created by wangxiaoxiang on 16/7/19.
//  Copyright © 2016年 wangxiaoxiang. All rights reserved.
//

#import "ViewController.h"
#import <LFNetworkReachability/LFNetworkReachability.h>

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)_networkingChange:(NSNotification *)notification {
    NSLog(@"%@",notification.userInfo);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_networkingChange:)
                                                 name:LFNetworkReachabilityDidChangeNotification
                                               object:nil];
    [[LFNetworkReachability sharedReachability] startMonitoring];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
