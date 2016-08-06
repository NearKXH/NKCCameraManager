//
//  NCameraManagerDefaultViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/6.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCameraManagerDefaultViewController.h"

@interface NCameraManagerDefaultViewController ()

@end

@implementation NCameraManagerDefaultViewController

- (void)dealloc {
    [self removeAllTimer];
    NSLog(@"--dealloc--NDefaultViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configUI];
    [self configData];
}

- (void)configUI {
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    //    self.topBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    self.audioFlashView.layer.masksToBounds = true;
    self.audioFlashView.layer.cornerRadius = 8.0f;
    self.audioView.layer.masksToBounds = true;
    self.audioView.layer.cornerRadius = 4.0f;
    self.audioView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    self.movieFlashView.layer.masksToBounds = true;
    self.movieFlashView.layer.cornerRadius = 8.0f;
    self.movieView.layer.masksToBounds = true;
    self.movieView.layer.cornerRadius = 4.0f;
    self.movieView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
}

- (void)configData {
    self.manager = [NCameraManager cameraManagerAuthorizationWithMode:NManagerModeVideo | NManagerModeAudio
                                                          previewView:self.view
                                                  authorizationHandle:^(NCameraSetupResult setupResult, NSError *error) {
                                                      if (setupResult != NCameraSetupResultSuccess || error) {
                                                          NSLog(@"\n--result = %ld\nerror = %@--", setupResult, error);
                                                      } else {
                                                          NSLog(@"--Scuess--");
                                                      }
                                                  }];
    [self.manager startRuning];
    
    self.audioManager = [NAudioManager audioManagerWithMode:NAudioManagerModeRecord setupResultBlock:nil];
    
    self.flashMode = NCameraFlashModeAuto;
}


@end
