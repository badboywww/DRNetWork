//
//  DRViewController.m
//  DRNetWork
//
//  Created by badboywww on 07/25/2022.
//  Copyright (c) 2022 badboywww. All rights reserved.
//

#import "DRViewController.h"
#import <DRNetWork/DRNetWorkToolsHeader.h>

@interface DRViewController ()

@end

@implementation DRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self test];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)test {
    
    [DRNetWorkTools.sharedManager netWorkWithURL:@"https://www.baidu.com" method:(NetworkMethod)0 header:@{
        @"a":@"a",
        @"b":@"b"
    } params:nil success:^(id _Nonnull) {
        
    } failed:^(id _Nonnull) {
        
    }];
}

@end
