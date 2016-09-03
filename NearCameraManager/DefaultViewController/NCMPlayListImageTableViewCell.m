//
//  NCMPlayListImageTableViewCell.m
//  NearCamera
//
//  Created by NearKong on 16/8/20.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMPlayListImageTableViewCell.h"

#import "NCMFileDetailImformationModel.h"
#import "NCMPlayListImageCollectionViewCell.h"

@interface NCMPlayListImageTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *sourceArray;
@property (nonatomic, copy) void (^block)(NSInteger row);
@end

@implementation NCMPlayListImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    _sourceArray = @[];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([NCMPlayListImageCollectionViewCell class]) bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:kNCMPlayListImageCollectionViewCellIdentifier];

    _collectionView.pagingEnabled = YES;
    _collectionView.alwaysBounceVertical = false;
    _collectionView.alwaysBounceHorizontal = false;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.clipsToBounds = YES;

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    _collectionView.collectionViewLayout = layout;

    _collectionView.scrollsToTop = false;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat sizeWidth = ([UIScreen mainScreen].bounds.size.width - 20) / 4;
    return CGSizeMake(sizeWidth, sizeWidth);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellWithArray:(NSArray *)sourceArray selectBlock:(void (^)(NSInteger row))block {
    _sourceArray = sourceArray;
    self.block = block;
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sourceArray.count;
}

static NSString *const kNCMPlayListImageCollectionViewCellIdentifier = @"kNCMPlayListImageCollectionViewCellIdentifier";
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NCMPlayListImageCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kNCMPlayListImageCollectionViewCellIdentifier forIndexPath:indexPath];
    NCMFileDetailImformationModel *model = _sourceArray[indexPath.row];
    [cell updateCellWithModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    if (_block) {
        _block(indexPath.row);
    }
}

@end
