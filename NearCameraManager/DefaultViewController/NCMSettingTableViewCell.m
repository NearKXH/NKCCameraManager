//
//  NCMSettingTableViewCell.m
//  NearCamera
//
//  Created by NearKong on 16/8/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMSettingTableViewCell.h"

#import "NCMSettingModel.h"
#import "NCMSettingSingletonModel.h"

#import "NSFileManager+NCMFileOperationManager.h"

@interface NCMSettingTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmented;
@property (weak, nonatomic) IBOutlet UISwitch *switchController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, copy) void (^block)();
@property (nonatomic, strong) NCMSettingModel *model;
@end

@implementation NCMSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (_model.modelType == NCMSettingModelTypeClearAllFile && selected) {
        NSLog(@"setSelected");
        _activity.hidden = false;
        [_activity startAnimating];
        [NSFileManager NCM_clearFileWithRelativePath:NCMFilePathInDirectoryDocumentOriginal fileName:nil error:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0f), dispatch_get_main_queue(), ^{
            [_activity stopAnimating];
            _activity.hidden = true;
        });
    }
    // Configure the view for the selected state
}

- (void)updateCellWithModel:(NCMSettingModel *)model {
    NCMSettingSingletonModel *singletonModel = [NCMSettingSingletonModel sharedInstance];

    _model = model;

    _segmented.hidden = TRUE;
    _switchController.hidden = true;
    _activity.hidden = true;
    [_segmented removeAllSegments];

    NSString *string = nil;
    switch (model.modelType) {
    case NCMSettingModelTypeAudioFormat:
        string = @"格式";

        [_segmented insertSegmentWithTitle:@"CAF" atIndex:0 animated:false];
        [_segmented insertSegmentWithTitle:@"AAC" atIndex:1 animated:false];
        switch (singletonModel.audioFormat) {
        case NAudioManagerFileFormatCAF:
            _segmented.selectedSegmentIndex = 0;
            break;

        case NAudioManagerFileFormatAAC:
            _segmented.selectedSegmentIndex = 1;
            break;
        }
        _segmented.hidden = false;
        break;

    case NCMSettingModelTypeAudioQuality:
        string = @"质量";

        [_segmented insertSegmentWithTitle:@"Low" atIndex:0 animated:false];
        [_segmented insertSegmentWithTitle:@"Height" atIndex:1 animated:false];
        [_segmented insertSegmentWithTitle:@"Lossless" atIndex:2 animated:false];
        switch (singletonModel.audioQuality) {
        case NAudioManagerQualityLow:
            _segmented.selectedSegmentIndex = 0;
            break;
        case NAudioManagerQualityHigh:
            _segmented.selectedSegmentIndex = 1;
            break;
        case NAudioManagerQualityMax:
            _segmented.selectedSegmentIndex = 2;
            break;
        }
        _segmented.hidden = false;
        break;

    case NCMSettingModelTypeAudioPartition:
        string = @"定时分隔";

        _switchController.selected = singletonModel.isPartitionAudio;
        _switchController.hidden = false;
        break;

    case NCMSettingModelTypeAudioPartitionTime:
        string = @"分隔时间";

        [_segmented insertSegmentWithTitle:@"Half An Hour" atIndex:0 animated:false];
        [_segmented insertSegmentWithTitle:@"Hour" atIndex:1 animated:false];
        switch ((NSInteger)singletonModel.partitionAudioTime) {
        case 30 * 60:
            _segmented.selectedSegmentIndex = 0;
            break;

        case 60 * 60:
            _segmented.selectedSegmentIndex = 1;
            break;
        }
        _segmented.hidden = false;
        break;

    case NCMSettingModelTypeClearAllFile:
        string = @"清除所有缓存文件";
        break;
    }

    _settingLabel.text = string;
}

#pragma mark - Action
- (IBAction)switchAction:(id)sender {
    NCMSettingSingletonModel *singletonModel = [NCMSettingSingletonModel sharedInstance];
    singletonModel.isPartitionAudio = _switchController.selected;
}

- (IBAction)segmentAction:(id)sender {
    NSInteger integer = _segmented.selectedSegmentIndex;
    NCMSettingSingletonModel *singletonModel = [NCMSettingSingletonModel sharedInstance];

    switch (_model.modelType) {
    case NCMSettingModelTypeAudioFormat:
        switch (integer) {
        case 0:
            singletonModel.audioFormat = NAudioManagerFileFormatCAF;
            break;
        case 1:
            singletonModel.audioFormat = NAudioManagerFileFormatAAC;
            break;
        }
        break;

    case NCMSettingModelTypeAudioQuality:
        switch (integer) {
        case 0:
            singletonModel.audioQuality = NAudioManagerQualityLow;
            break;
        case 1:
            singletonModel.audioQuality = NAudioManagerQualityHigh;
            break;
        case 2:
            singletonModel.audioQuality = NAudioManagerQualityMax;
            break;
        }
        break;

    case NCMSettingModelTypeAudioPartition:
        switch (integer) {
        case 0:
            singletonModel.partitionAudioTime = 30 * 60;
            break;
        case 1:
            singletonModel.partitionAudioTime = 60 * 60;
            break;
        }
        break;

    default:
        break;
    }
}

@end
