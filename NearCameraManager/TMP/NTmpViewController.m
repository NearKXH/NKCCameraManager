//
//  NTmpViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NTmpViewController.h"

#import "NCameraManagerDefaultViewController.h"
#import "NMainViewController.h"

@interface NTmpViewController ()
@property (nonatomic, strong) NSString *string;

@end

@implementation NTmpViewController

- (void)dealloc {
    NSLog(@"--NTmpViewController--dealloc--");
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
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

- (void)configData {
}

- (IBAction)tmpAction:(id)sender {
    NMainViewController *VC = [[NMainViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)pushAction:(id)sender {
    NCameraManagerDefaultViewController *vc = [[NCameraManagerDefaultViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

@end
