//
//  NCameraManagerDefaultViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/6.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCameraManagerDefaultViewController.h"

#import "NAudioManager.h"
#import "NCMPlayListViewController.h"
#import "NCMSettingViewController.h"
#import "NCameraManager.h"

#import "NSFileManager+NCMFileOperationManager.h"
#import "UIImage+NCMImageScale.h"

@interface NCameraManagerDefaultViewController ()
@property (weak, nonatomic) IBOutlet UIView *cameraTopView;
@property (weak, nonatomic) IBOutlet UIButton *cameraFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraHDRButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraChangeButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraSettingButton;

@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (weak, nonatomic) IBOutlet UIView *cameraAudioTimerView;
@property (weak, nonatomic) IBOutlet UIButton *cameraAudioTimerPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *cameraAudioTimerLabel;
@property (weak, nonatomic) IBOutlet UIView *cameraVideoTimerView;
@property (weak, nonatomic) IBOutlet UIView *cameraVideoTimerShowView;
@property (weak, nonatomic) IBOutlet UILabel *cameraVideoTimerLabel;

@property (weak, nonatomic) IBOutlet UIView *cameraBottomView;
@property (weak, nonatomic) IBOutlet UIButton *cameraAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraPlayButton;

@property (nonatomic, strong) NCameraManager *cameraManager;
@property (nonatomic, strong) NAudioManager *audioManager;
@property (nonatomic, assign) NCameraManagerFlashMode flashMode;

@property (nonatomic, strong) NSTimer *audioTimer;
@property (nonatomic, strong) NSTimer *videoTimer;
@property (nonatomic, assign) NSInteger audioCount;
@property (nonatomic, assign) NSInteger videoCount;
@end

@implementation NCameraManagerDefaultViewController

- (void)dealloc {
    [self removeAllTimer];
    if ([_cameraManager isMovieRecording]) {
        [_cameraManager
            stopMovieRecordWithFileName:nil
                                 isSave:false
                                  block:^(NCameraManagerResult result, NSString *fileFullPath, NCMFilePathInDirectory directory, NSError *error) {
                                      NSLog(@"--stopMovieRecordWithFileName\n--result = %ld\n--fileFullPath = %@\n--relativeDirectory = %ld\n--error = %@",
                                            result, fileFullPath, directory, error);
                                  }];
    }
    NSLog(@"--dealloc--NCameraManagerDefaultViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeAllTimer];
}

#pragma mark - Inital
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configUI];
    [self configData];
}

- (void)configUI {
    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    _cameraAudioTimerView.layer.masksToBounds = true;
    _cameraAudioTimerView.layer.cornerRadius = 4.0f;
    _cameraAudioTimerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];

    _cameraVideoTimerShowView.layer.masksToBounds = true;
    _cameraVideoTimerShowView.layer.cornerRadius = 8.0f;
    _cameraVideoTimerView.layer.masksToBounds = true;
    _cameraVideoTimerView.layer.cornerRadius = 4.0f;
    _cameraVideoTimerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
}

- (void)configData {
    self.audioManager = [NAudioManager audioManagerWithFileFormat:NAudioManagerFileFormatAAC quality:NAudioManagerQualityHigh];

    self.cameraManager = [NCameraManager cameraManagerAuthorizationWithMode:NCameraManagerModeVedio
                                                                previewView:self.view
                                                        authorizationHandle:^(NCameraManagerResult result, NSError *error) {
                                                            if (result == NCameraManagerResultSuccess && !error) {
                                                                [_cameraManager startRuningWithBlock:^(NCameraManagerResult result, NSError *error) {
                                                                    NSLog(@"startRuningWithBlock\n--result = %ld\n--error = %@", result, error);
                                                                }];
                                                            } else {
                                                                NSLog(@"cameraManagerAuthorizationWithMode\n--result = %ld\n--error = %@", result, error);
                                                            }
                                                        }];
    self.flashMode = NCameraManagerFlashModeAudo;
}

#pragma mark -
#pragma mark topView Action
- (IBAction)changeFlashAction:(id)sender {

    NSString *flashName = nil;
    NSString *imageName = nil;
    NCameraManagerFlashMode flashMode = _flashMode;
    switch (flashMode) {
    case NCameraManagerFlashModeAudo:
        flashMode = NCameraManagerFlashModeOn;
        flashName = @"On";
        imageName = @"lightning-on";
        break;

    case NCameraManagerFlashModeOn:
        flashMode = NCameraManagerFlashModeOff;
        flashName = @"Off";
        imageName = @"lightning";
        break;

    case NCameraManagerFlashModeOff:
        flashMode = NCameraManagerFlashModeAudo;
        flashName = @"Auto";
        imageName = @"lightning-on";
        break;
    }

    NSError *error = nil;
    if ([_cameraManager changeFlashmode:_flashMode error:&error] && !error) {
        [_cameraFlashButton setTitle:flashName forState:UIControlStateNormal];
        [_cameraFlashButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

        if (flashMode == NCameraManagerFlashModeOff) {
            [_cameraFlashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [_cameraFlashButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }

        self.flashMode = flashMode;

    } else {
        NSLog(@"--changeFlashAction--error = %@", error);
    }
}

- (IBAction)changeCameraAction:(id)sender {
    [_cameraManager changeCameraWithHandle:^(NCameraManagerResult result, NSError *error) {
        if (result != NCameraManagerResultSuccess || error) {
            NSLog(@"changeCameraAction\n--result = %ld\n--error = %@", result, error);
        }
    }];
}

- (IBAction)settingAction:(id)sender {
    NCMSettingViewController *settingViewController = [[NCMSettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController animated:true];
}

#pragma mark previewView Action
- (IBAction)audioPauseAction:(id)sender {
    NSError *error = nil;
    if (_cameraAudioTimerPauseButton.selected) {
        if ([_audioManager startRecordWithPrefix:nil error:&error] == NCameraManagerResultSuccess && !error) {
            _cameraAudioTimerPauseButton.selected = !_cameraAudioTimerPauseButton.selected;
            [_audioTimer setFireDate:[NSDate date]];
        }

    } else {
        if ([_audioManager pauseRecordWithError:&error] == NCameraManagerResultSuccess && !error) {
            _cameraAudioTimerPauseButton.selected = !_cameraAudioTimerPauseButton.selected;
            [_audioTimer setFireDate:[NSDate distantFuture]];
        }
    }
}

#pragma mark bottomView Action
- (IBAction)stillImageAction:(id)sender {
    [_cameraManager
        snapStillImageIsSaveToPhotoLibrary:false
                               imageHandle:^(NCameraManagerResult result, UIImage *image, NSError *error) {
                                   if (error || !image) {
                                       NSLog(@"snapStillImageIsSaveToPhotoLibrary\n--result = %ld\n--error = %@", result, error);
                                       return;
                                   }

                                   UIImage *newImage = image;
                                   CGFloat width = image.size.width;
                                   CGFloat height = image.size.height;
                                   CGSize size = _cameraPreviewView.bounds.size;

                                   if (size.width / size.height != width / height && !_cameraManager.isMovieRecording) {

                                       if (size.width / size.height > width / height) {
                                           height = width / size.width * size.height;
                                       } else {
                                           width = height / size.height * size.width;
                                       }
                                       newImage = [image
                                           NCM_cutImageInRect:CGRectMake(_cameraPreviewView.frame.origin.x, _cameraPreviewView.frame.origin.y, width, height)];
                                   }

                                   NSData *imageData = UIImageJPEGRepresentation(newImage, 1);
                                   [UIImage NCM_saveImageInPhotosLibraryFromData:imageData];

                                   NSError *tmpError = nil;
                                   NSString *outputFilePath =
                                       [NSFileManager NCM_fullPathWithRelativePath:NCMFilePathInDirectoryDocumentOriginal prefix:nil error:&tmpError];
                                   if (outputFilePath && !tmpError) {
                                       outputFilePath = [outputFilePath stringByAppendingPathExtension:@"jpeg"];
                                       [[NSFileManager defaultManager] createFileAtPath:outputFilePath contents:imageData attributes:nil];
                                   }
                               }];
}

- (IBAction)audioRecordAction:(id)sender {
    [self uploadAudioManagerRecord];
}

- (IBAction)videoRecordAction:(id)sender {
    [self uploadCameraManagerRecord];
}

- (IBAction)pushPlayListAction:(id)sender {
    NCMPlayListViewController *playListViewController = [[NCMPlayListViewController alloc] init];
    [self.navigationController pushViewController:playListViewController animated:true];
}

#pragma mark - Private
- (void)uploadAudioManagerRecord {
    if ([_audioManager isRecording] || [_audioManager isRecordPausing]) {
        [_audioManager
            stopRecordWithBlock:^(NCameraManagerResult result, NSString *fullPathFileName, NCMFilePathInDirectory relativeDirectory, NSError *error) {
                NSLog(@"--stopRecordWithBlock\n--result = %ld\n--fullPathFileName = %@\n--relativeDirectory = %ld\n--error = %@", result, fullPathFileName,
                      relativeDirectory, error);
                if (result == NCameraManagerResultSuccess && !error) {
                    _cameraAudioTimerView.hidden = true;
                    _cameraAudioButton.selected = false;
                    [self removeAudioTimer];
                    [self updateButtonState];
                }
            }];

    } else {
        NSError *error = nil;
        if ([_audioManager startRecordWithPrefix:nil error:&error] == NCameraManagerResultSuccess && !error) {
            [self setupAudioRecordTimer];
            _cameraAudioTimerView.hidden = false;
            _cameraAudioButton.selected = true;
            [self updateButtonState];
        }
    }
}

static NSTimeInterval kNCameraBottomViewAlphaTimeInterval = 0.5f;
- (void)uploadCameraManagerRecord {
    if ([_cameraManager isMovieRecording]) {
        [_cameraManager
            stopMovieRecordWithFileName:nil
                                 isSave:true
                                  block:^(NCameraManagerResult result, NSString *fileFullPath, NCMFilePathInDirectory directory, NSError *error) {
                                      NSLog(@"--stopMovieRecordWithFileName\n--result = %ld\n--fileFullPath = %@\n--relativeDirectory = %ld\n--error = %@",
                                            result, fileFullPath, directory, error);
                                      if (result == NCameraManagerResultSuccess && !error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              _cameraVideoTimerView.hidden = true;
                                              _cameraVideoButton.selected = false;
                                              [self removeMovieTimer];
                                              [self updateButtonState];

                                              UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否保存"
                                                                                                                       message:nil
                                                                                                                preferredStyle:UIAlertControllerStyleAlert];
                                              [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
                                                  textField.placeholder = fileFullPath;
                                              }];
                                              UIAlertAction *cancel =
                                                  [UIAlertAction actionWithTitle:@"取消"
                                                                           style:UIAlertActionStyleCancel
                                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                                             [NSFileManager NCM_clearFileWithFullFilePath:fileFullPath error:nil];
                                                                         }];

                                              UIAlertAction *config = [UIAlertAction
                                                  actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              UITextField *textField = alertController.textFields.firstObject;
                                                              if (![textField.text isEqualToString:@""]) {
                                                                  [NSFileManager
                                                                      NCM_moveFileFromOriginalPath:directory
                                                                                  originalFileName:[fileFullPath lastPathComponent]
                                                                                            toPath:directory
                                                                                        toFileName:[textField.text stringByAppendingPathExtension:@"aac"]
                                                                                            isCopy:false
                                                                                             block:nil];
                                                              }
                                                          }];

                                              [alertController addAction:cancel];
                                              [alertController addAction:config];

                                              [UIView animateWithDuration:kNCameraBottomViewAlphaTimeInterval
                                                               animations:^{
                                                                   _cameraBottomView.backgroundColor = [UIColor blackColor];
                                                                   _cameraTopView.backgroundColor = [UIColor blackColor];
                                                               }];
                                          });
                                      }
                                  }];

    } else {
        [_cameraManager startMovieRecordWithBlock:^(NCameraManagerResult result, NSError *error) {
            if (result == NCameraManagerResultSuccess && !error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupCameraRecordTimer];
                    _cameraVideoTimerView.hidden = false;
                    _cameraVideoButton.selected = true;
                    [self updateButtonState];

                    [UIView animateWithDuration:kNCameraBottomViewAlphaTimeInterval
                                     animations:^{
                                         _cameraBottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
                                         _cameraTopView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
                                     }];
                });
            }
        }];
    }
}

- (void)uploadAudioTimerUI {
    _audioCount++;

    NSInteger second = _audioCount % 60;
    NSInteger minute = _audioCount / 60 % 60;
    NSInteger hours = _audioCount / 3600;

    NSString *secondString = [NSString stringWithFormat:@"%02ld", (long)second];
    NSString *minuteString = [NSString stringWithFormat:@"%02ld", (long)minute];
    NSString *hoursString = [NSString stringWithFormat:@"%02ld", (long)hours];

    _cameraAudioTimerLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hoursString, minuteString, secondString];
}

- (void)uploadVideoTimerUI {
    _videoCount++;

    NSInteger second = _videoCount % 60;
    NSInteger minute = _videoCount / 60 % 60;
    NSInteger hours = _videoCount / 3600;

    NSString *secondString = [NSString stringWithFormat:@"%02ld", (long)second];
    NSString *minuteString = [NSString stringWithFormat:@"%02ld", (long)minute];
    NSString *hoursString = [NSString stringWithFormat:@"%02ld", (long)hours];

    _cameraVideoTimerLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hoursString, minuteString, secondString];
    _cameraVideoTimerShowView.hidden = _videoCount % 2;
}

- (void)updateButtonState {
    if ([_audioManager isRecording] || [_audioManager isRecordPausing]) {
        _cameraPlayButton.enabled = false;
        _cameraSettingButton.enabled = false;
        return;
    }

    if (([_cameraManager isMovieRecording])) {
        _cameraPlayButton.enabled = false;
        _cameraFlashButton.enabled = false;
        _cameraHDRButton.enabled = false;
        _cameraChangeButton.enabled = false;
        _cameraSettingButton.enabled = false;
        return;
    }

    _cameraPlayButton.enabled = true;
    _cameraFlashButton.enabled = true;
    _cameraHDRButton.enabled = true;
    _cameraChangeButton.enabled = true;
    _cameraSettingButton.enabled = true;
}

#pragma mark - Timer
- (void)setupAudioRecordTimer {
    _audioCount = 0;
    _cameraAudioTimerLabel.text = @"00:00:00";
    _cameraAudioTimerPauseButton.selected = false;
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(uploadAudioTimerUI) userInfo:nil repeats:true];
}

- (void)setupCameraRecordTimer {
    _videoCount = 0;
    _cameraVideoTimerLabel.text = @"00:00:00";
    _cameraVideoTimerShowView.hidden = false;
    self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(uploadVideoTimerUI) userInfo:nil repeats:true];
}

- (void)removeAllTimer {
    [self removeAudioTimer];
    [self removeMovieTimer];
}

- (void)removeAudioTimer {
    if (_audioTimer.isValid) {
        [_audioTimer invalidate];
        _audioTimer = nil;
    }
}

- (void)removeMovieTimer {
    if (_videoTimer.isValid) {
        [_videoTimer invalidate];
        _videoTimer = nil;
    }
}

#pragma mark - System
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
