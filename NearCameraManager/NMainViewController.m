//
//  NMainViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NMainViewController.h"

#import "NAudioConvertManager.h"
#import "NCMAudioManager.h"
#import "NCameraManagerHeader.h"
#import "NTmpViewController.h"

@import AVFoundation;
#import "NSError+NCustomErrorInstance.h"
#import "NSFileManager+NFileOperationManager.h"

@interface NMainViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NCMAudioManager *audioManager;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSString *recordFullPath;
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
    self.audioManager = [NCMAudioManager audioManagerWithFileFormat:NAudioManagerFileFormatCAF quality:NAudioManagerQualityHigh resultBlock:nil];
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
        [self.audioManager startRecordWithPrefix:@"NCM"
                                     resultBlock:^(NCameraManagerResult result, NSError *error) {
                                         NSLog(@"\nresult = %ld\nerror = %@", result, error);
                                     }];
    }

    if (indexPath.row == 1) {
        [self.audioManager pause];
    }

    if (indexPath.row == 2) {
        [self.audioManager stopRecordWithBlock:^(NCameraManagerResult result, NSString *fullPathFileName, NSError *error) {
            self.recordFullPath = fullPathFileName;
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
        NAudioConvertManager *manager = [NAudioConvertManager shareInstance];
        [manager convertAudioFromFullPath:self.recordFullPath
                               toFileName:[self.recordFullPath lastPathComponent]
                       isSaveOriginalFile:true
                                    block:^(NCameraManagerResult result, NSString *toFullPath, NSError *error) {
                                        NSLog(@"\nresult = %ld\ntoFullPath = %@\nerror = %@", result, toFullPath, error);
                                        [NSFileManager
                                            NCM_moveFileFromOriginalPath:NCMFilePathInDirectoryDocumentConver
                                                        originalFileName:[toFullPath lastPathComponent]
                                                                  toPath:NCMFilePathInDirectoryDocument
                                                              toFileName:[toFullPath lastPathComponent]
                                                                  isCopy:false
                                                                   block:^(NCameraManagerResult result, NSString *fullPath, NSError *error) {
                                                                       NSLog(@"\nresult = %ld\ntoFullPath = %@\nerror = %@", result, fullPath, error);
                                                                   }];
                                    }];
    }

    if (indexPath.row == 4) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *fullPath = [documentPath stringByAppendingPathComponent:@""];
        NSLog(@"%@", fullPath);
    }

    if (indexPath.row == 5) {
        NSError *error = nil;

        //        NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:self.recordFullPath error:&error];

        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.recordFullPath] error:&error];
        NSLog(@"Rate = %f", self.player.rate);
        NSDictionary *dic = self.player.settings;

        NSNumber *num = [dic objectForKey:@"AVFormatIDKey"];

        NSLog(@"settings = \n%@", self.player.settings);
        //#if __LP64__
        //        UInt32 av32 = [num unsignedIntValue];
        //#else
        //        UInt32 av32 = [num unsignedLongValue];
        //#endif
        //
        //        NSLog(@"%d", kAudioFormatLinearPCM);
        //        if (av32 == kAudioFormatLinearPCM) {
        //            NSLog(@"yes");
        //        }
    }

    if (indexPath.row == 6) {
        NSLog(@"%@", [@"sgseh/qwer.mp3" pathExtension]);
        NSLog(@"%@", [@"qwer/sdhsh" pathExtension]);
    }
}

@end
