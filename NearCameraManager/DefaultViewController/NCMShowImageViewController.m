//
//  NCMShowImageViewController.m
//  NearCamera
//
//  Created by NearKong on 16/8/20.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMShowImageViewController.h"

#import "NCMFileDetailImformationModel.h"
#import "NCMShowImageCollectionViewCell.h"

@interface NCMShowImageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (nonatomic, strong) NSArray *sourceArray;
@property (nonatomic, strong) NSMutableDictionary *sourceImageDiction;
@property (nonatomic, assign) NSInteger displayRow;
@property (nonatomic, assign) NSInteger willDisplayRow;
@end

@implementation NCMShowImageViewController

- (void)dealloc {
    NSLog(@"--NCMShowImageViewController--dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithSourceArray:(NSArray *)array currentPage:(NSInteger)currentPage {
    self = [super init];
    if (self) {
        _sourceArray = array;
        _displayRow = currentPage;
        _sourceImageDiction = [[NSMutableDictionary alloc] initWithCapacity:array.count];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configUI];
    [self addObservers];
}

- (void)configUI {
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([NCMShowImageCollectionViewCell class]) bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:kNCMShowImageCollectionViewCellIdentifier];

    _collectionView.pagingEnabled = YES;
    _collectionView.alwaysBounceVertical = false;
    _collectionView.alwaysBounceHorizontal = true;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.clipsToBounds = YES;

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView.collectionViewLayout = layout;

    if (self.sourceArray.count < 2) {
        _numberLabel.hidden = TRUE;
    } else {
        _numberLabel.hidden = FALSE;
    }

    //    _collectionView.alpha = 0;
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5f), dispatch_get_main_queue(), ^{
    //        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.displayRow inSection:0]
    //                                atScrollPosition:UICollectionViewScrollPositionNone
    //                                        animated:true];
    //        _collectionView.alpha = 1.0;
    //    });

    _numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", _displayRow + 1, _sourceArray.count];
}

- (void)updateToItem:(NSInteger)row {
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
    _displayRow = row;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
static NSString *const kNCMShowImageCollectionViewCellIdentifier = @"kNCMShowImageCollectionViewCellIdentifier";
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NCMShowImageCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kNCMShowImageCollectionViewCellIdentifier forIndexPath:indexPath];
    NCMFileDetailImformationModel *model = self.sourceArray[indexPath.row];
    UIImage *image = _sourceImageDiction[model.fileName];
    if (!image || [image isKindOfClass:[NSNull class]]) {
        image = [UIImage imageWithContentsOfFile:model.fullPathFileName];
        _sourceImageDiction[model.fileName] = image;
    }
    cell.showImageView.image = image;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(size.width, size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != _willDisplayRow) {
        _displayRow = _willDisplayRow;
        _numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", _displayRow + 1, _sourceArray.count];
    } else {
        _willDisplayRow = _displayRow;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    _willDisplayRow = indexPath.row;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - System
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - Notification
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBackgroundActionNotification)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)appDidBackgroundActionNotification {
    NSInteger row = self.displayRow;
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
    self.displayRow = row;
}
@end
