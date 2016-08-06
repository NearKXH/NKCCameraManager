//
//  NCameraPreviewView.m
//  NCamera
//
//  Created by NearKong on 16/6/26.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCameraPreviewView.h"

@import AVFoundation;

@implementation NCameraPreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    previewLayer.session = session;
}

@end
