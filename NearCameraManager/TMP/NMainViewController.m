//
//  NMainViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NMainViewController.h"

@import AVFoundation;
#import "NAudioConvertManager.h"
#import "NAudioManager.h"
#import "NCameraManager.h"
#import "NCameraManagerDefaultViewController.h"
#import "NCameraManagerHeader.h"

#import "NSError+NCMCustomErrorInstance.h"
#import "NSFileManager+NCMFileOperationManager.h"


@interface NMainViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NAudioManager *audioManager;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSString *recordFullPath;
@property (nonatomic, strong) NSString *lastFileName;

@property (nonatomic, strong) NCameraManager *cameraManager;
@end

@implementation NMainViewController

- (void)dealloc {
    NSLog(@"--NMainViewController--dealloc--");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configUI];
    [self configData];
}

- (void)configUI {
    self.title = @"首页";
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.alpha = 0.5;
}

- (void)configData {
    self.audioManager = [NAudioManager audioManagerWithFileFormat:NAudioManagerFileFormatCAF quality:NAudioManagerQualityHigh];

    self.cameraManager = [NCameraManager cameraManagerAuthorizationWithMode:NCameraManagerModeVedio
                                                                previewView:self.view
                                                        authorizationHandle:^(NCameraManagerResult result, NSError *error) {
                                                            NSLog(@"--cameraManager--result = %ld--error = %@", result, error);
                                                        }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NMainViewControllerCellIdentifier"];

    NSString *string = @"初始化";
    switch (indexPath.row) {
    case 0:
        string = @"录音";
        break;
    case 1:
        string = @"暂停";
        break;
    case 2:
        string = @"结束";
        break;
    case 3:
        string = @"转码";
        break;

    case 4:
        string = @"播放";
        break;
    case 5:
        string = @"暂停";
        break;
    case 6:
        string = @"结束";
        break;

    case 9:
        string = @"push界面";
        break;

    case 10:
        string = @"开始";
        break;
    case 11:
        string = @"重新设置";
        break;
    case 12:
        string = @"拍照";
        break;
    case 13:
        string = @"开始录像";
        break;
    case 14:
        string = @"结束录像";
        break;
    case 15:
        string = @"结束";
        break;

    default:
        string = [@(indexPath.row) description];
        break;
    }

    cell.textLabel.text = string;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    if (indexPath.row == 0) {
        [self.audioManager startRecordWithPrefix:@"NCM" error:nil];
    }

    if (indexPath.row == 1) {
        [self.audioManager pauseRecordWithError:nil];
    }

    if (indexPath.row == 2) {
        [self.audioManager
            stopRecordWithBlock:^(NCameraManagerResult result, NSString *fullPathFileName, NCMFilePathInDirectory relativeDirectory, NSError *error) {
                self.recordFullPath = fullPathFileName;
                self.lastFileName = fullPathFileName;

                NSString *fileName = [fullPathFileName lastPathComponent];
                [NSFileManager NCM_moveFileFromOriginalPath:NCMFilePathInDirectoryDocumentOriginal
                                           originalFileName:fileName
                                                     toPath:NCMFilePathInDirectoryDocument
                                                 toFileName:fileName
                                                     isCopy:true
                                                      block:^(NCameraManagerResult result, NSString *fullPath, NSError *error) {
                                                          NSLog(@"\nresult = %ld\ntoFullPath = %@\nerror = %@", result, fullPath, error);
                                                      }];
            }];
    }

    if (indexPath.row == 3) {
        NAudioConvertManager *manager = [NAudioConvertManager sharedInstance];
        [manager convertAudioFromFullPath:self.recordFullPath
                               toFileName:[self.recordFullPath lastPathComponent]
                       isSaveOriginalFile:true
                                    block:^(NCameraManagerResult result, NSString *toFullPath, NCMFilePathInDirectory relativeDirectory, NSError *error) {
                                        self.lastFileName = toFullPath;

                                        NSLog(@"\nresult = %ld\ntoFullPath = %@\nerror = %@", result, toFullPath, error);
                                        [NSFileManager
                                            NCM_moveFileFromOriginalPath:NCMFilePathInDirectoryDocumentConver
                                                        originalFileName:[toFullPath lastPathComponent]
                                                                  toPath:NCMFilePathInDirectoryDocument
                                                              toFileName:[toFullPath lastPathComponent]
                                                                  isCopy:true
                                                                   block:^(NCameraManagerResult result, NSString *fullPath, NSError *error) {
                                                                       self.lastFileName = fullPath;
                                                                       NSLog(@"\nresult = %ld\ntoFullPath = %@\nerror = %@", result, fullPath, error);
                                                                   }];
                                    }];
    }

    if (indexPath.row == 4) {
        NSLog(@"%@", self.lastFileName);
        [self.audioManager playWithFullPathFileName:self.lastFileName
                                              error:nil
                                        finishBlock:^(BOOL success) {
                                            NSLog(@"success = %d", success);
                                        }];
    }

    if (indexPath.row == 5) {
        [self.audioManager pausePlaying:nil];
    }

    if (indexPath.row == 6) {
        [self.audioManager stopPlaying];
    }

    /**
     *
     */
    if (indexPath.row == 7) {

        [NSFileManager NCM_clearFileWithRelativePath:NCMFilePathInDirectoryDocumentOriginal fileName:nil error:nil];

        NSString *secondString = [NSString stringWithFormat:@"%02ld", (long)20];
        NSString *minuteString = [NSString stringWithFormat:@"%02ld", (long)2];
        NSString *hoursString = [NSString stringWithFormat:@"%02ld", (long)234];

        NSLog(@"%@--%@--%@--", secondString, minuteString, hoursString);
    }

    if (indexPath.row == 8) {
        NSLog(@"self = %@", self);
        NSLog(@"self.audioManager = %@", self.audioManager);

        id info = self.audioManager.observationInfo;
        NSLog(@"%@", info);
        NSArray *array = [info valueForKey:@"_observances"];
        NSLog(@"%@", array);

        id objc = [array lastObject];
        NSLog(@"%@", objc);

        id Properties = [objc valueForKeyPath:@"_property"];
        NSLog(@"%@", Properties);

        NSString *keyPath = [Properties valueForKeyPath:@"_keyPath"];
        NSLog(@"%@", keyPath);

        //        id infoXXX = [self.audioManager valueForKey:@"observationInfo"];
        //        NSLog(@"%@", infoXXX);
    }


    /**
     *
     */
    if (indexPath.row == 9) {
        NCameraManagerDefaultViewController *vc = [[NCameraManagerDefaultViewController alloc] init];
        [self.navigationController pushViewController:vc animated:true];
    }

    if (indexPath.row == 10) {
        [self.cameraManager startRuningWithBlock:^(NCameraManagerResult result, NSError *error) {
            NSLog(@"--10--result = %ld--error = %@", result, error);
        }];
    }

    if (indexPath.row == 11) {
        [self.cameraManager configAuthorizationWithAuthorizationHandle:^(NCameraManagerResult result, NSError *error) {
            NSLog(@"--11--result = %ld--error = %@", result, error);
        }];
    }

    if (indexPath.row == 12) {
        [self.cameraManager snapStillImageIsSaveToPhotoLibrary:true
                                                   imageHandle:^(NCameraManagerResult result, UIImage *image, NSError *error) {
                                                       NSLog(@"--12--result = %ld--error = %@", result, error);
                                                   }];
    }

    if (indexPath.row == 13) {
        [self.cameraManager startMovieRecordWithBlock:^(NCameraManagerResult result, NSError *error) {
            NSLog(@"--13--result = %ld--error = %@", result, error);
        }];
    }

    if (indexPath.row == 14) {
        [self.cameraManager
            stopMovieRecordWithFileName:nil
                                 isSave:true
                                  block:^(NCameraManagerResult result, NSString *fileFullPath, NCMFilePathInDirectory directory, NSError *error) {

                                      NSLog(@"--14\n--result = %ld\n--error = %@\n--fileFullPath = %@\n--NCMFilePathInDirectory = %ld", result, error,
                                            fileFullPath, directory);
                                      [NSFileManager NCM_moveFileFromOriginalPath:directory
                                                                 originalFileName:[fileFullPath lastPathComponent]
                                                                           toPath:NCMFilePathInDirectoryDocument
                                                                       toFileName:[fileFullPath lastPathComponent]
                                                                           isCopy:false
                                                                            block:^(NCameraManagerResult result, NSString *fullPath, NSError *error) {
                                                                                NSLog(@"--14--xxx\n--result = %ld\n--error = %@\n--fullPath = %@", result,
                                                                                      error, fullPath);
                                                                            }];
                                  }];
    }

    if (indexPath.row == 15) {
        [self.cameraManager stopRuningWithBlock:^(NCameraManagerResult result, NSError *error) {
            NSLog(@"--15--result = %ld--error = %@", result, error);
        }];
    }

    // case 10:
    //    string = @"开始";
    //    break;
    // case 11:
    //    string = @"重新设置";
    //    break;
    // case 12:
    //    string = @"拍照";
    //    break;
    // case 13:
    //    string = @"开始录像";
    //    break;
    // case 14:
    //    string = @"结束录像";
    //    break;
    // case 15:
    //    string = @"结束";
    //    break;
}

@end
