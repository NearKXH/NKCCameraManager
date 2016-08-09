//
//  NCameraManagerDefaultViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/6.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCameraManagerDefaultViewController.h"

#import "NAudioManager.h"
#import "NCameraManager.h"

#import "NSFileManager+NCMFileOperationManager.h"
#import "UIImage+NCMImageScale.h"

@interface NCameraManagerDefaultViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cameraFlashButton;

@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;

@property (nonatomic, strong) NCameraManager *cameraManager;
@property (nonatomic, strong) NAudioManager *audioManager;
@property (nonatomic, assign) NCameraManagerFlashMode flashMode;

@end

@implementation NCameraManagerDefaultViewController

- (void)dealloc {
    //    [self removeAllTimer];
    NSLog(@"--dealloc--NCameraManagerDefaultViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
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
    //    self.topBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];

    /*
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
     */
}

- (void)configData {
    self.audioManager = [NAudioManager audioManagerWithFileFormat:NAudioManagerFileFormatCAF quality:NAudioManagerQualityHigh];

    self.cameraManager = [NCameraManager cameraManagerAuthorizationWithMode:NCameraManagerModeVedio
                                                                previewView:self.view
                                                        authorizationHandle:^(NCameraManagerResult result, NSError *error) {
                                                            if (result == NCameraManagerResultSuccess) {
                                                                [self.cameraManager startRuningWithBlock:^(NCameraManagerResult result, NSError *error) {
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

    NSString *flashName = @"Auto";
    NSString *imageName = @"lightning";
    switch (self.flashMode) {
    case NCameraManagerFlashModeAudo:
        self.flashMode = NCameraManagerFlashModeOn;
        flashName = @"On";
        imageName = @"lightning-on";
        break;

    case NCameraManagerFlashModeOn:
        self.flashMode = NCameraManagerFlashModeOff;
        flashName = @"Off";
        imageName = @"lightning";
        break;

    case NCameraManagerFlashModeOff:
        self.flashMode = NCameraManagerFlashModeAudo;
        flashName = @"Auto";
        imageName = @"lightning-on";
        break;

    default:
        break;
    }

    NSError *error = nil;
    if ([self.cameraManager changeFlashmode:self.flashMode error:&error] && !error) {
        [self.cameraFlashButton setTitle:flashName forState:UIControlStateNormal];
        [self.cameraFlashButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

        if (self.flashMode == NCameraManagerFlashModeOff) {
            [self.cameraFlashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [self.cameraFlashButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)changeCameraAction:(id)sender {
    [self.cameraManager changeCameraWithHandle:^(NCameraManagerResult result, NSError *error) {
        if (result != NCameraManagerResultSuccess || error) {
            NSLog(@"changeCameraAction\n--result = %ld\n--error = %@", result, error);
        }
    }];
}

#pragma mark bottomView Action
- (IBAction)stillImageAction:(id)sender {
    [self.cameraManager
        snapStillImageIsSaveToPhotoLibrary:false
                               imageHandle:^(NCameraManagerResult result, UIImage *image, NSError *error) {
                                   if (error || !image) {
                                       NSLog(@"snapStillImageIsSaveToPhotoLibrary\n--result = %ld\n--error = %@", result, error);
                                       return;
                                   }

                                   UIImage *newImage = image;
                                   CGFloat width = image.size.width;
                                   CGFloat height = image.size.height;
                                   CGSize size = self.cameraPreviewView.bounds.size;

                                   if (size.width / size.height != width / height && !self.cameraManager.isMovieRecording) {

                                       if (size.width / size.height > width / height) {
                                           height = width / size.width * size.height;
                                       } else {
                                           width = height / size.height * size.width;
                                       }
                                       newImage = [image NCM_cutImageInRect:CGRectMake(self.cameraPreviewView.frame.origin.x,
                                                                                       self.cameraPreviewView.frame.origin.y, width, height)];
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



@end
