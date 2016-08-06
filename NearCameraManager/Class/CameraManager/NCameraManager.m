//
//  NCameraManager.m
//  NCamera
//
//  Created by NearKong on 16/6/25.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCameraManager.h"

@import UIKit;
@import AVFoundation;
@import Photos;
#import "NCameraManagerHeader.h"
#import "NCameraPreviewView.h"

#import "NSError+NCMCustomErrorInstance.h"
#import "NSFileManager+NCMFileOperationManager.h"
#import "UIImage+NCMImageScale.h"

@interface NCameraManager () <AVCaptureFileOutputRecordingDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

// initMode
@property (nonatomic, assign) NCameraManagerMode managerMode;
@property (nonatomic, strong) NCameraPreviewView *previewView;
@property (nonatomic, copy) NCameraManagerResultBlock managerResultBlock;
@property (nonatomic, strong) UIView *previewSupperView;

// Session
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic, assign) NCameraManagerResult cameraSetupResult;
@property (nonatomic, assign) NSInteger configDeviceFlag;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic, strong) NSString *recordFileName;
@property (nonatomic, copy) NCameraManagerRecordBlock recordFinishBlock;

@property (nonatomic, assign, readonly, getter=isImageStilling) BOOL imageStilling;

@end

@implementation NCameraManager

- (void)dealloc {
    NSLog(@"--NCameraManager--dealloc");
    if (self.isSessionRunning) {
        [self.session stopRunning];
        [self removeObservers];
    }
}

+ (NCameraManager *)cameraManagerAuthorizationWithMode:(NCameraManagerMode)mode
                                           previewView:(UIView *)previewView
                                   authorizationHandle:(NCameraManagerResultBlock)managerResultBlock {
    NCameraManager *manager = [[NCameraManager alloc] init];
    [manager configInitWithMode:mode previewView:previewView authorizationHandle:managerResultBlock];
    return manager;
}

static const char *kNCameraManagerSessionqueue = "kNCameraManagerSessionqueue";
- (BOOL)configInitWithMode:(NCameraManagerMode)mode previewView:(UIView *)previewView authorizationHandle:(NCameraManagerResultBlock)managerResultBlock {
    self.managerMode = mode;
    self.managerResultBlock = managerResultBlock;
    self.previewSupperView = previewView;
    self.previewView = [[NCameraPreviewView alloc] init];

    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    self.previewView.session = self.session;
    self.sessionQueue = dispatch_queue_create(kNCameraManagerSessionqueue, DISPATCH_QUEUE_SERIAL);
    self.flashMode = AVCaptureFlashModeAuto;

    self.previewSupperView.clipsToBounds = true;
    self.previewView.frame = previewView.bounds;
    [previewView addSubview:self.previewView];
    [previewView sendSubviewToBack:self.previewView];
    self.previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAndExposeTap:)];
    [self.previewView addGestureRecognizer:gesture];

    [self configAuthorization];
    return true;
}

#pragma mark Device Authorization
- (void)configAuthorization {
    self.configDeviceFlag = 0;

    if (self.managerMode == NCameraManagerModeVedio) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                 completionHandler:^(BOOL granted) {
                                     self.configDeviceFlag = self.configDeviceFlag | (1 < 1);
                                     [self configDevice];
                                 }];
    } else {
        self.configDeviceFlag = self.configDeviceFlag | (1 < 1);
    }

    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 self.configDeviceFlag = self.configDeviceFlag | (1);
                                 [self configDevice];
                             }];
}

- (void)configDevice {

    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    dispatch_async(self.sessionQueue, ^{
        if (!((self.configDeviceFlag & (1)) && (self.configDeviceFlag & (1 < 1)))) {
            return;
        }

        NSError *error = nil;
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        /**
         *  判断是否能加载摄像头
         */
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
            self.cameraSetupResult = NCameraManagerResultCameraFailWithCameraConfiguration;
            error = [NSError NCM_errorWithCode:self.cameraSetupResult message:@"Camera Configuration Fail"];
            [self configBlokcWithError:error];
            return;
        }

        /**
         *  判断是否能加载录音
         */
        if (self.managerMode == NCameraManagerModeVedio &&
            [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] != AVAuthorizationStatusAuthorized) {
            self.cameraSetupResult = NCameraManagerResultCameraFailWithAudioConfiguration;
            error = [NSError NCM_errorWithCode:self.cameraSetupResult message:@"Audio Configuration Fail"];
            [self configBlokcWithError:error];
            return;
        }

        /**
         *  开始配置
         */
        [self.session beginConfiguration];

        AVCaptureDevice *videoDevice = [NCameraManager deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!videoDeviceInput || error) {
            self.cameraSetupResult = NCameraManagerResultCameraFailWithCameraDevice;
            [self configBlokcWithError:error];
            return;
        }

        if ([self.session canAddInput:videoDeviceInput]) {
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;

            /**
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                // can only be manipulated on the main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.

                // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                // -[viewWillTransitionToSize:withTransitionCoordinator:].
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if (statusBarOrientation != UIInterfaceOrientationUnknown) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }

                AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
                previewLayer.connection.videoOrientation = initialVideoOrientation;
            });
             */
        } else {
            self.cameraSetupResult = NCameraManagerResultCameraFailWithCameraCanNotAddToSession;
            error = [NSError NCM_errorWithCode:self.cameraSetupResult message:@"Could not add video device input to the session"];
            [self configBlokcWithError:error];
            return;
        }


        if (self.managerMode == NCameraManagerModeVedio) {
            /**
             *  Audio Input
             */
            AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
            if (!audioDeviceInput || error) {
                self.cameraSetupResult = NCameraManagerResultCameraFailWithAudioToSession;
                [self configBlokcWithError:error];
                return;
            }

            if ([self.session canAddInput:audioDeviceInput]) {
                [self.session addInput:audioDeviceInput];
            } else {
                self.cameraSetupResult = NCameraManagerResultCameraFailWithAudioCanNotAddToSession;
                error = [NSError NCM_errorWithCode:self.cameraSetupResult message:@"Could not add audio device input to the session"];
                [self configBlokcWithError:error];
                return;
            }

            /**
             *  movieOutput
             */
            AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
            if ([self.session canAddOutput:movieFileOutput]) {
                [self.session addOutput:movieFileOutput];
                AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
                if (connection.isVideoStabilizationSupported) {
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
                }
                self.movieFileOutput = movieFileOutput;
            } else {
                self.cameraSetupResult = NCameraManagerResultCameraFailWithVedioOutput;
                error = [NSError NCM_errorWithCode:self.cameraSetupResult message:@"Could not add movie file output to the session"];
                [self configBlokcWithError:error];
                return;
            }

            /**
             *  此处可修改为数据量输出
             */
            /**
             AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
             if ([self.session canAddOutput:videoDataOutput]) {
             [self.session addOutput:videoDataOutput];
             [videoDataOutput setSampleBufferDelegate:self queue:self.sessionQueue];
             videoDataOutput.videoSettings =
             [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
             }
             */
        }

        /**
         *  Image Output
         */
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([self.session canAddOutput:stillImageOutput]) {
            stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
            [self.session addOutput:stillImageOutput];
            self.stillImageOutput = stillImageOutput;
        } else {
            self.cameraSetupResult = NCameraManagerResultCameraFailWithImageOutput;
            error = [NSError NCM_errorWithCode:self.cameraSetupResult message:@"Could not add still image output to the session"];
            [self configBlokcWithError:error];
            return;
        }

        self.cameraSetupResult = NCameraManagerResultSuccess;
        [self.session commitConfiguration];

        [self configBlokcWithError:nil];
    });
}

- (void)configBlokcWithError:(NSError *)error {
    [self.session commitConfiguration];
    if (self.managerResultBlock) {
        self.managerResultBlock(self.cameraSetupResult, error);
    }
}

#pragma mark - Session
/**
 *  Runing
 */
- (void)startRuning {
    dispatch_async(self.sessionQueue, ^{
        if (self.cameraSetupResult == NCameraManagerResultSuccess) {
            [self addObservers];
            [self.session startRunning];
            NSLog(@"--NCameraManager--startRunning--");
        }
    });
}

- (void)stopRuning {
    dispatch_async(self.sessionQueue, ^{
        if (self.cameraSetupResult == NCameraManagerResultSuccess) {
            [self.session stopRunning];
            [self removeObservers];
            NSLog(@"--NCameraManager--stopRuning--");
        }
    });
}

#pragma mark Flash Model
- (BOOL)hasFlashInCurrentDevice {
    return self.videoDeviceInput.device.hasFlash;
}

- (BOOL)changeFlashmode:(NCameraFlashMode)flashMode error:(NSError **)error {
    AVCaptureFlashMode avFlashMode = AVCaptureFlashModeAuto;
    switch (flashMode) {
    case NCameraFlashModeAudo:
        avFlashMode = AVCaptureFlashModeAuto;
        break;
    case NCameraFlashModeOn:
        avFlashMode = AVCaptureFlashModeOn;
        break;
    case NCameraFlashModeOff:
        avFlashMode = AVCaptureFlashModeOff;
        break;
    default:
        avFlashMode = AVCaptureFlashModeAuto;
        break;
    }
    return [self setFlashMode:avFlashMode forDevice:self.videoDeviceInput.device error:error];
}

- (BOOL)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device error:(NSError **)error {
    if (device.hasFlash && [device isFlashModeSupported:flashMode] && [device lockForConfiguration:error]) {
        device.flashMode = flashMode;
        [device unlockForConfiguration];
        self.flashMode = flashMode;
        return true;
    }
    return false;
}

#pragma mark Camera Changing
- (void)changeCameraWithHandle:(NCameraManagerResultBlock)block {
    dispatch_async(self.sessionQueue, ^{

        NSError *error = nil;

        if (self.isImageStilling || self.movieFileOutput.isRecording) {
            error = [NSError NCM_errorWithCode:NCameraManagerResultCameraFailWithCameraRuning message:@"Camera Runing"];
            if (block) {
                block(NCameraManagerResultCameraFailWithCameraRuning, error);
            }
            return;
        }

        if (self.cameraSetupResult != NCameraManagerResultSuccess) {
            error = [NSError NCM_errorWithCode:NCameraManagerResultCameraFailWithCameraRuning message:@"Changing Configuration Fail"];
            if (block) {
                block(NCameraManagerResultCameraFailWithChangingConfiguration, error);
            }
            return;
        }

        /**
         *  需要转换的位置
         */
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        switch (currentPosition) {
        case AVCaptureDevicePositionUnspecified:
        case AVCaptureDevicePositionFront:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
        case AVCaptureDevicePositionBack:
            preferredPosition = AVCaptureDevicePositionFront;
            break;
        }

        AVCaptureDevice *videoDevice = [NCameraManager deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!videoDeviceInput || error) {
            if (block) {
                block(NCameraManagerResultCameraFailWithCameraDevice, error);
            }
            return;
        }

        [self.session beginConfiguration];

        // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
        [self.session removeInput:self.videoDeviceInput];

        NCameraManagerResult result = NCameraManagerResultSuccess;
        if ([self.session canAddInput:videoDeviceInput]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(subjectAreaDidChange:)
                                                         name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                       object:videoDevice];

            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
        } else {
            [self.session addInput:self.videoDeviceInput];
            result = NCameraManagerResultCameraFailWithCameraCanNotAddToSession;
            error = [NSError NCM_errorWithCode:result message:@"Could not add video device input to the session"];
        }

        AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if (connection.isVideoStabilizationSupported) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }

        [self.session commitConfiguration];

        if (block) {
            block(result, error);
        }

    });
}

#pragma mark Still Image
- (void)snapStillImageIsSaveToPhotoLibrary:(BOOL)isSave imageHandle:(NCameraManagerStillImageBlock)imageHandle {
    dispatch_async(self.sessionQueue, ^{
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;

        // Update the orientation on the still image output video connection before capturing.
        connection.videoOrientation = previewLayer.connection.videoOrientation;

        // Capture a still image.
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                           completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                               if (imageDataSampleBuffer) {
                                                                   // The sample buffer is not retained. Create image data before saving the still image to
                                                                   // the
                                                                   // photo library
                                                                   // asynchronously.
                                                                   NSData *imageData =
                                                                       [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                   UIImage *image = nil;
                                                                   if (imageData) {
                                                                       image = [[UIImage alloc] initWithData:imageData];
                                                                   }

                                                                   UIImage *newImage = image;
                                                                   if (image) {
                                                                       CGFloat width = image.size.width;
                                                                       CGFloat height = image.size.height;
                                                                       CGSize size = self.previewSupperView.bounds.size;

                                                                       if (size.width / size.height != width / height) {

                                                                           if (size.width / size.height > width / height) {
                                                                               height = width / size.width * size.height;
                                                                           } else {
                                                                               width = height / size.height * size.width;
                                                                           }
                                                                           newImage = [image NCM_cutImageInRect:CGRectMake(0, 0, width, height)];
                                                                           imageData = UIImageJPEGRepresentation(newImage, 1);
                                                                       }
                                                                   }

                                                                   if (isSave) {
                                                                       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                           [UIImage NCM_saveImageInPhotosLibraryFromData:imageData];
                                                                       });
                                                                   }

                                                                   if (imageHandle) {
                                                                       imageHandle(NCameraManagerResultSuccess, newImage, error);
                                                                   }

                                                               } else {
                                                                   if (imageHandle) {
                                                                       imageHandle(NCameraManagerResultCameraFailWithStillImage, nil, error);
                                                                   }
                                                               }
                                                           }];
    });
}

#pragma mark Movie
- (void)startMovieRecordWithBlock:(NCameraManagerResultBlock)block {
    dispatch_async(self.sessionQueue, ^{
        if (!self.movieFileOutput.isRecording) {
            if ([UIDevice currentDevice].isMultitaskingSupported) {
                // Setup background task. This is needed because the
                // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                // callback is not received until AVCam returns to the foreground unless
                // you request background execution time.
                // This also ensures that there will be time to write the file to the
                // photo library when AVCam is backgrounded.
                // To conclude this background execution, -endBackgroundTask is called
                // in
                // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                // after the recorded file has been saved.
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundRecordingID];
                    self.backgroundRecordingID = UIBackgroundTaskInvalid;
                }];
            }

            // Update the orientation on the movie file output video connection before
            // starting recording.
            AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
            connection.videoOrientation = previewLayer.connection.videoOrientation;

            // Turn OFF flash for video recording.
            //[self setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];

            // Start recording to a temporary file.
            NSError *error = nil;
            NSString *outputFilePath = [NSFileManager NCM_fullPathWithRelativePath:NCMFilePathInDirectoryTemp prefix:nil error:&error];
            if (!outputFilePath || error) {
                if (block) {
                    block(NCameraManagerResultCameraFailWithStartRecord, error);
                }
                return;
            }

            NSString *outputFileName = [outputFilePath stringByAppendingPathExtension:@"mov"];
            NSURL *fileUrl = [NSURL fileURLWithPath:outputFileName];
            [self.movieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        } else {
            if (block) {
                NSError *error = [NSError NCM_errorWithCode:NCameraManagerResultCameraFailWithRecording message:@"Camera is not still recording"];
                block(NCameraManagerResultCameraFailWithRecording, error);
            }
        }
    });
}

- (void)stopMovieRecordWithFileName:(NSString *)fileName block:(NCameraManagerRecordBlock)block {
    dispatch_async(self.sessionQueue, ^{
        if (self.movieFileOutput.isRecording) {
            self.recordFileName = fileName;
            self.recordFinishBlock = block;
            [self.movieFileOutput stopRecording];
        } else {
            if (block) {
                NSError *error = [NSError NCM_errorWithCode:NCameraManagerResultCameraFailWithNotRecord message:@"Camera is not recording"];
                block(NCameraManagerResultCameraFailWithNotRecord, nil, NCMFilePathInDirectoryNone, error);
            }
        }
    });
}

#pragma mark - File Output Recording Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
    didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                        fromConnections:(NSArray *)connections
                                  error:(NSError *)error {
    // Note that currentBackgroundRecordingID is used to end the background task
    // associated with this recording.
    // This allows a new recording to be started, associated with a new
    // UIBackgroundTaskIdentifier, once the movie file output's isRecording
    // property
    // is back to NO — which happens sometime after this method returns.
    // Note: Since we use a unique file path for each recording, a new recording
    // will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;

    dispatch_block_t cleanup = ^{
        if (currentBackgroundRecordingID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };

    BOOL success = YES;

    if (error) {
        NSLog(@"Movie file finishing error: %@", error);
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    //    if (success) {
    // Check authorization status.
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            // Save the movie file to the photo library and cleanup.
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                // In iOS 9 and later, it's possible to move the file into the photo
                // library without duplicating the file data.
                // This avoids using double the disk space during save, which can make
                // a difference on devices with limited free disk space.
                if ([PHAssetResourceCreationOptions class]) {
                    PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                    options.shouldMoveFile = YES;
                    PHAssetCreationRequest *changeRequest = [PHAssetCreationRequest creationRequestForAsset];
                    [changeRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                } else {
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                }
            }
                completionHandler:^(BOOL success, NSError *error) {
                    if (!success) {
                        NSLog(@"Could not save movie to photo library: %@", error);
                    }
                    cleanup();
                }];
        } else {
            cleanup();
        }
    }];
    //    } else {
    //        cleanup();
    //    }
}

/**
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate & AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    UIImage *image = [UIImage NCM_imageWithSampleBuffer:sampleBuffer];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [UIImage NCM_saveImageInPhotosLibraryFromData:imageData];
    NSLog(@"--didOutputSampleBuffer--");
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection NS_AVAILABLE(10_7, 6_0) {
    NSLog(@"--didDropSampleBuffer--");
}
 */

#pragma mark - Private
- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint devicePoint =
        [(AVCaptureVideoPreviewLayer *)self.previewView.layer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode
              exposeWithMode:(AVCaptureExposureMode)exposureMode
               atDevicePoint:(CGPoint)point
    monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice *device = self.videoDeviceInput.device;
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            // Setting (focus/exposure)PointOfInterest alone does not initiate a
            // (focus/exposure) operation.
            // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
            if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode]) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }

            if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }

            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        } else {
            NSLog(@"Could not lock device for configuration: %@", error);
        }
    });
}

- (void)deviceOrientationDidChange {
    if (self.movieFileOutput.isRecording) {
        return;
    }

    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    deviceOrientation =
        deviceOrientation == UIDeviceOrientationFaceUp || deviceOrientation == UIDeviceOrientationFaceDown || deviceOrientation == UIDeviceOrientationUnknown
            ? UIDeviceOrientationPortrait
            : deviceOrientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {

        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;

        CGRect screenRect = [UIScreen mainScreen].bounds;
        float screenRatio = screenRect.size.width / screenRect.size.height;

        float width = self.previewSupperView.bounds.size.width;
        float height = self.previewSupperView.bounds.size.height;
        float viewRatio = width / height;

        if (screenRatio > viewRatio) {
            width = height * screenRatio;
        } else {
            height = width / screenRatio;
        }
        self.previewView.layer.bounds = CGRectMake(0, 0, width, height);
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

#pragma mark - KVO and Notifications
static void *kNCameraManagerCapturingStillImageContext = &kNCameraManagerCapturingStillImageContext;
static NSString *const kNCameraManagerCapturingStillImageKVO = @"capturingStillImage";

- (void)addObservers {
    [self configOrientation];
    [self.stillImageOutput addObserver:self
                            forKeyPath:kNCameraManagerCapturingStillImageKVO
                               options:NSKeyValueObservingOptionNew
                               context:kNCameraManagerCapturingStillImageContext];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(subjectAreaDidChange:)
                                                 name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                               object:self.videoDeviceInput.device];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionRuntimeError:)
                                                 name:AVCaptureSessionRuntimeErrorNotification
                                               object:self.session];
    // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
    // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
    // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
    // interruption reasons.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionWasInterrupted:)
                                                 name:AVCaptureSessionWasInterruptedNotification
                                               object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionInterruptionEnded:)
                                                 name:AVCaptureSessionInterruptionEndedNotification
                                               object:self.session];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.stillImageOutput removeObserver:self forKeyPath:kNCameraManagerCapturingStillImageKVO context:kNCameraManagerCapturingStillImageContext];
}

#pragma mark configOrientation
- (void)configOrientation {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self deviceOrientationDidChange];
}

#pragma mark KVO StillImage
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kNCameraManagerCapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        if (isCapturingStillImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewView.layer.opacity = 0.0;
                [UIView animateWithDuration:0.25
                                 animations:^{
                                     self.previewView.layer.opacity = 1.0;
                                 }];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma NSNotification
- (void)subjectAreaDidChange:(NSNotification *)notification {
    CGPoint devicePoint = CGPointMake(0.5, 0.5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus
                  exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
                   atDevicePoint:devicePoint
        monitorSubjectAreaChange:NO];
}

- (void)sessionRuntimeError:(NSNotification *)notification {
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog(@"Capture session runtime error: %@", error);

    // Automatically try to restart the session running if media services were
    // reset and the last start running succeeded.
    // Otherwise, enable the user to try to resume the session running.
    if (error.code == AVErrorMediaServicesWereReset) {
        dispatch_async(self.sessionQueue, ^{
            if (self.isSessionRunning) {
                [self.session startRunning];
            } else {
                NSLog(@"AVErrorMediaServicesWereReset, session is not runing");
            }
        });
    } else {
        //        self.resumeButton.hidden = NO;
    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification {
    // In some scenarios we want to enable the user to resume the session running.
    // For example, if music playback is initiated via control center while using
    // AVCam,
    // then the user can let AVCam resume the session running, which will stop
    // music playback.
    // Note that stopping music playback in control center will not automatically
    // resume the session running.
    // Also note that it is not always possible to resume, see
    // -[resumeInterruptedSession:].
    BOOL showResumeButton = NO;

    // In iOS 9 and later, the userInfo dictionary contains information on why the
    // session was interrupted.
    if (&AVCaptureSessionInterruptionReasonKey) {
        AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
        NSLog(@"Capture session was interrupted with reason %ld", (long)reason);

        if (reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
            reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient) {
            showResumeButton = YES;
        } else if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps) {
            // Simply fade-in a label to inform the user that the camera is
            // unavailable.
            //            self.cameraUnavailableLabel.hidden = NO;
            //            self.cameraUnavailableLabel.alpha = 0.0;
            //            [UIView animateWithDuration:0.25
            //                             animations:^{
            //                                 self.cameraUnavailableLabel.alpha = 1.0;
            //                             }];
        }
    } else {
        NSLog(@"Capture session was interrupted");
        showResumeButton = ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive);
    }

    if (showResumeButton) {
        // Simply fade-in a button to enable the user to try to resume the session
        // running.
        //        self.resumeButton.hidden = NO;
        //        self.resumeButton.alpha = 0.0;
        //        [UIView animateWithDuration:0.25
        //                         animations:^{
        //                             self.resumeButton.alpha = 1.0;
        //                         }];
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    NSLog(@"Capture session interruption ended");

    /*
     if (!self.resumeButton.hidden) {
     [UIView animateWithDuration:0.25
     animations:^{
     self.resumeButton.alpha = 0.0;
     }
     completion:^(BOOL finished) {
     self.resumeButton.hidden = YES;
     }];
     }
     if (!self.cameraUnavailableLabel.hidden) {
     [UIView animateWithDuration:0.25
     animations:^{
     self.cameraUnavailableLabel.alpha = 0.0;
     }
     completion:^(BOOL finished) {
     self.cameraUnavailableLabel.hidden = YES;
     }];
     }
     */
}

#pragma mark - Property
- (BOOL)isSessionRunning {
    return self.session.isRunning;
}

- (BOOL)isImageStilling {
    return self.stillImageOutput.isCapturingStillImage;
}

- (BOOL)isMovieRecording {
    return self.movieFileOutput.isRecording;
}

@end
