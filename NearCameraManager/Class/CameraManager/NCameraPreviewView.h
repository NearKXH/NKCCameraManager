//
//  NCameraPreviewView.h
//  NCamera
//
//  Created by NearKong on 16/6/26.
//  Copyright © 2016年 NearKong. All rights reserved.
//

@import UIKit;

@class AVCaptureSession;
@interface NCameraPreviewView : UIView
@property (nonatomic) AVCaptureSession *session;
@end
