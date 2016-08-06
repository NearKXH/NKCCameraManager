//
//  NMainViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NMainViewController.h"

#import "NAudioConvertManager.h"
#import "NAudioManager.h"
#import "NCameraManagerHeader.h"
#import "NTmpViewController.h"

@import AVFoundation;
#import "NSError+NCMCustomErrorInstance.h"
#import "NSFileManager+NCMFileOperationManager.h"

@interface NMainViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NAudioManager *audioManager;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSString *recordFullPath;
@property (nonatomic, strong) NSString *lastFileName;
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
}

- (void)configData {
    self.audioManager = [NAudioManager audioManagerWithFileFormat:NAudioManagerFileFormatCAF quality:NAudioManagerQualityHigh];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
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

    case 7:
        string = @"摄像";
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
        [self.audioManager playWithFullPathFileName:self.lastFileName error:nil];
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
        
    }
}

@end
