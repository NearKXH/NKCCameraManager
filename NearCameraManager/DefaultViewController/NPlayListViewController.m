//
//  NPlayListViewController.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/11.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NPlayListViewController.h"

#import "NAudioManager.h"
#import "NCMFileDetailImformationModel.h"
#import "NPlayListModel.h"
#import "NPlayListTableViewCell.h"

#import "NSFileManager+NCMFileOperationManager.h"

@interface NPlayListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NAudioManager *audioManager;
@property (nonatomic, strong) NSArray *sourceArray;
@end

@implementation NPlayListViewController

- (void)dealloc {
    NSLog(@"--dealloc--NPlayListViewController");
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
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];

    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NPlayListTableViewCell class]) bundle:[NSBundle mainBundle]]
        forCellReuseIdentifier:kNPlayListTableViewCellIdentifier];
    [self.view addSubview:_tableView];
}

- (void)configData {

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

    NPlayListModel *imageModel = [[NPlayListModel alloc] init];
    NPlayListModel *audioModel = [[NPlayListModel alloc] init];
    NPlayListModel *videoModel = [[NPlayListModel alloc] init];

    imageModel.sourceMutableArray = imageMutabelArray;
    audioModel.sourceMutableArray = audioMutabelArray;
    videoModel.sourceMutableArray = videoMutabelArray;

    imageModel.modelType = NPlayListModelTypeImage;
    audioModel.modelType = NPlayListModelTypeAudio;
    videoModel.modelType = NPlayListModelTypeVideo;

    _sourceArray = @[ imageModel, audioModel, videoModel ];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NPlayListModel *model = _sourceArray[section];
    if (model.isOpen) {
        return model.sourceMutableArray.count;
    } else {
        return 0;
    }
}

static NSString *const kNPlayListTableViewCellIdentifier = @"kNPlayListTableViewCellIdentifier";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NPlayListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNPlayListTableViewCellIdentifier forIndexPath:indexPath];
    NPlayListModel *playListModel = _sourceArray[indexPath.section];
    NCMFileDetailImformationModel *detailModel = playListModel.sourceMutableArray[indexPath.row];
    [cell updateCellWithModelType:playListModel.modelType model:detailModel];
    return cell;
}



@end
