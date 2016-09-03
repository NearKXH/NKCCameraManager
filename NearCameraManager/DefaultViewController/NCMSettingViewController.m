//
//  NCMSettingViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/11.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMSettingViewController.h"

#import "NCMSettingModel.h"
#import "NCMSettingSingletonModel.h"
#import "NCMSettingTableViewCell.h"

@interface NCMSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *sourceArray;
@property (nonatomic, strong) NCMSettingSingletonModel *settingSingletonModel;
@end

@implementation NCMSettingViewController

- (void)dealloc {
    NSLog(@"--dealloc--NCMSettingViewController");
    [_settingSingletonModel updateModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configUI];
    [self configData];
}

- (void)configUI {
    self.title = @"设置";

    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NCMSettingTableViewCell class]) bundle:[NSBundle mainBundle]]
        forCellReuseIdentifier:kNCMSettingTableViewCellIdentifier];
}

- (void)configData {
    _settingSingletonModel = [NCMSettingSingletonModel sharedInstance];
    [self settingSourceArray];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NCMSettingListModel *listModel = _sourceArray[section];
    return listModel.sourceArray.count;
}

static NSString *const kNCMSettingTableViewCellIdentifier = @"kNCMSettingTableViewCellIdentifier";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NCMSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNCMSettingTableViewCellIdentifier forIndexPath:indexPath];
    NCMSettingModel *model = [(NCMSettingListModel *)_sourceArray[indexPath.section] sourceArray][indexPath.row];
    [cell updateCellWithModel:model];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NCMSettingListModel *listModel = _sourceArray[section];
    NSString *string = nil;
    switch (listModel.modelType) {
    case NCMSettingListModelTypeClear:
        string = @"文件管理";
        break;
    case NCMSettingListModelTypeAudioQuality:
        string = @"音频质量（CAF无损格式，音频体积较大）";
        break;
    case NCMSettingListModelTypeAudioPartition:
        string = @"音频分隔";
        break;
    }

    return string;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - private
- (void)settingSourceArray {
    NCMSettingListModel *audioQuality = [NCMSettingListModel new];
    NCMSettingListModel *audioPartition = [NCMSettingListModel new];
    NCMSettingListModel *fileClear = [NCMSettingListModel new];

    audioQuality.modelType = NCMSettingListModelTypeAudioQuality;
    audioPartition.modelType = NCMSettingListModelTypeAudioPartition;
    fileClear.modelType = NCMSettingListModelTypeClear;

    _sourceArray = @[ audioQuality, audioPartition, fileClear ];

    for (NCMSettingListModel *tmpModel in _sourceArray) {
        tmpModel.sourceArray = [[NSMutableArray alloc] init];
    }

    NSArray *tmpArray = @[
        @(NCMSettingModelTypeAudioQuality),
        @(NCMSettingModelTypeAudioFormat),
        @(NCMSettingModelTypeAudioPartition),
        @(NCMSettingModelTypeAudioPartitionTime),
        @(NCMSettingModelTypeClearAllFile)
    ];

    for (NSNumber *num in tmpArray) {
        NCMSettingModelType type = [num unsignedIntegerValue];
        NCMSettingModel *model = [NCMSettingModel new];
        model.modelType = type;
        switch (type) {
        case NCMSettingModelTypeAudioQuality:
        case NCMSettingModelTypeAudioFormat:
            [audioQuality.sourceArray addObject:model];
            break;

        case NCMSettingModelTypeAudioPartition:
        case NCMSettingModelTypeAudioPartitionTime:
            [audioPartition.sourceArray addObject:model];
            break;

        case NCMSettingModelTypeClearAllFile:
            [fileClear.sourceArray addObject:model];
            break;
        }
    }
}

@end
