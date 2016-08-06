//
//  NTmpViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NTmpViewController.h"

#import "NCameraManagerHeader.h"
#import "NMainViewController.h"

@interface NTmpViewController ()
@property (nonatomic, strong) NSString *string;

@end

@implementation NTmpViewController

- (void)dealloc {
    NSLog(@"--NTmpViewController--dealloc--");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configUI];
    [self configData];
    [self configAF];
}

- (void)configUI {
    //    self.audioManager = [NCMAudioManager audioManagerWithFileFormat:NAudioManagerFileFormatAAC quality:NAudioManagerQualityLow resultBlock:nil];
    //    __weak NTmpViewController *weakSelf = self;
    //    [self.audioManager stopRecordWithBlock:^(NCameraManagerResult result, NSString *fullPathFileName, NSError *error) {
    //        weakSelf.string = @"qwee";
    //        NSLog(@"--%@--", weakSelf.string);
    //
    //    }];
}

- (void)configData {
}

- (void)configAF {
}

- (IBAction)tmpAction:(id)sender {
    NMainViewController *VC = [[NMainViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

@end
