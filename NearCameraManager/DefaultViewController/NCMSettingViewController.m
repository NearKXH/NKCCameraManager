//
//  NCMSettingViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/11.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMSettingViewController.h"

@interface NCMSettingViewController ()

@end

@implementation NCMSettingViewController

- (void)dealloc {
    NSLog(@"--dealloc--NCMSettingViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configUI];
    [self configData];
}

- (void)configUI {
    self.title = @"设置";
}

- (void)configData {
}

@end
