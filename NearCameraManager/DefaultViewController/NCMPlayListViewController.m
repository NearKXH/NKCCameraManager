//
//  NCMPlayListViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/12.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMPlayListViewController.h"

#import "NAudioManager.h"
#import "NCMFileDetailImformationModel.h"
#import "NCMPlayListAudioTableViewCell.h"
#import "NCMPlayListHeaderFooterView.h"
#import "NCMPlayListModel.h"

#import "NSFileManager+NCMFileOperationManager.h"

@interface NCMPlayListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *audioButton;
@property (nonatomic, strong) UILabel *audioLabel;

@property (nonatomic, strong) NAudioManager *audioManager;
@property (nonatomic, strong) NSArray *sourceArray;

@property (nonatomic, strong) NCMFileDetailImformationModel *audioModel;
@property (nonatomic, assign) NSInteger audioCurrentRow;
@end

@implementation NCMPlayListViewController

- (void)dealloc {
    NSLog(@"--dealloc--NCMPlayListViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:true];
}

#pragma mark - inital
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configUI];
    [self configData];
}

- (void)configUI {
    self.title = @"文件浏览";

    CGRect rect = self.view.bounds;
    rect.size.height -= 60;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];

    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NCMPlayListAudioTableViewCell class]) bundle:[NSBundle mainBundle]]
        forCellReuseIdentifier:kNCMPlayListAudioTableViewCellIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NCMPlayListHeaderFooterView class]) bundle:[NSBundle mainBundle]]
        forHeaderFooterViewReuseIdentifier:kNCMPlayListTableViewHeaderFooterViewIdentifier];
    [self.view addSubview:_tableView];

    rect.origin.y = rect.size.height;
    rect.size.height = 60;
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];

    _audioButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, 45, 45)];
    [_audioButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_audioButton addTarget:self action:@selector(audioAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_audioButton];

    _audioLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 200, 60)];
    _audioLabel.text = nil;
    _audioLabel.textColor = [UIColor whiteColor];
    [view addSubview:_audioLabel];
}

- (void)configData {
    _audioManager = [NAudioManager audioManagerWithFileFormat:NAudioManagerFileFormatAAC quality:NAudioManagerQualityHigh];
    _audioCurrentRow = -1;

    NSMutableArray *imageMutabelArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *audioMutabelArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *videoMutabelArray = [[NSMutableArray alloc] initWithCapacity:0];

    NSError *error = nil;
    NSArray *tmpArray = [NSFileManager NCM_allFilesWithRelativePath:NCMFilePathInDirectoryDocumentOriginal error:&error];
    for (NCMFileDetailImformationModel *tmpModel in tmpArray) {
        NSString *filePathExtension = [tmpModel.fileName pathExtension];
        if ([filePathExtension isEqualToString:@"mov"]) {
            [videoMutabelArray addObject:tmpModel];
        } else if ([filePathExtension isEqualToString:@"jepg"]) {
            [imageMutabelArray addObject:tmpModel];
        } else if ([filePathExtension isEqualToString:@"aac"] || [filePathExtension isEqualToString:@"caf"] || [filePathExtension isEqualToString:@"mp3"]) {
            [audioMutabelArray addObject:tmpModel];
        }
    }

    NCMPlayListModel *imageModel = [[NCMPlayListModel alloc] init];
    NCMPlayListModel *audioModel = [[NCMPlayListModel alloc] init];
    NCMPlayListModel *videoModel = [[NCMPlayListModel alloc] init];

    imageModel.sourceMutableArray = imageMutabelArray;
    audioModel.sourceMutableArray = audioMutabelArray;
    videoModel.sourceMutableArray = videoMutabelArray;

    imageModel.modelType = NCMPlayListModelTypeImage;
    audioModel.modelType = NCMPlayListModelTypeAudio;
    videoModel.modelType = NCMPlayListModelTypeVideo;

    _sourceArray = @[ imageModel, audioModel, videoModel ];

    audioModel.isOpen = true;
    _sourceArray = @[ audioModel ];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NCMPlayListModel *model = _sourceArray[section];
    if (model.isOpen) {
        return model.sourceMutableArray.count;
    } else {
        return 0;
    }
}

static NSString *const kNCMPlayListAudioTableViewCellIdentifier = @"kNCMPlayListAudioTableViewCellIdentifier";
static NSString *const kNCMPlayListTableViewHeaderFooterViewIdentifier = @"kNCMPlayListTableViewHeaderFooterViewIdentifier";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NCMPlayListAudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNCMPlayListAudioTableViewCellIdentifier forIndexPath:indexPath];
    NCMPlayListModel *playListModel = _sourceArray[indexPath.section];
    NCMFileDetailImformationModel *detailModel = playListModel.sourceMutableArray[indexPath.row];
    [cell updateCellWithModel:detailModel isShowButton:(indexPath.row == _audioCurrentRow)];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NCMPlayListHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kNCMPlayListTableViewHeaderFooterViewIdentifier];
    NCMPlayListModel *model = _sourceArray[section];
    [view updateHeaderFooterViewWithModel:model
                                openBlock:^{
                                    model.isOpen = !model.isOpen;
                                    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
                                }];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NCMPlayListModel *model = _sourceArray[indexPath.section];
    NSInteger rowHeight = 0;
    switch (model.modelType) {
    case NCMPlayListModelTypeAudio:
        rowHeight = 55;
        break;

    default:
        break;
    }

    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self updatePlayManagerWithIndexPath:indexPath];
}

#pragma mark - Action
- (void)audioAction {
    if ([_audioManager isPlaying]) {
        [_audioManager pausePlaying:nil];
        [_audioButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    } else {
        if (_audioModel) {
            [_audioManager playWithFullPathFileName:_audioModel.fullPathFileName error:nil finishBlock:nil];
            [_audioButton setImage:[UIImage imageNamed:@"pause-Play"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Private
- (void)updatePlayManagerWithIndexPath:(NSIndexPath *)indexPath {
    NCMPlayListModel *playLiatModel = _sourceArray[indexPath.section];
    NCMFileDetailImformationModel *detailModel = playLiatModel.sourceMutableArray[indexPath.row];
    switch (playLiatModel.modelType) {
    case NCMPlayListModelTypeAudio:
        _audioCurrentRow = indexPath.row;
        [self updateAudioPlayerWithModel:detailModel];
        break;

    case NCMPlayListModelTypeImage:
        break;

    case NCMPlayListModelTypeVideo:
        break;

    default:
        break;
    }
}

- (void)updateAudioPlayerWithModel:(NCMFileDetailImformationModel *)model {
    if ([_audioManager isPlaying] || [_audioManager isPlayPausing]) {
        [_audioManager stopPlaying];
    }

    [_audioManager playWithFullPathFileName:model.fullPathFileName error:nil finishBlock:nil];
    [_audioButton setImage:[UIImage imageNamed:@"pause-Play"] forState:UIControlStateNormal];
    _audioLabel.text = model.fileName;
    _audioModel = model;

    [_tableView reloadData];
}

@end
