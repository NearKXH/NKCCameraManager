//
//  NCMPlayListImageCollectionViewCell.m
//  NearCamera
//
//  Created by NearKong on 16/8/20.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMPlayListImageCollectionViewCell.h"

#import "NCMFileDetailImformationModel.h"

@interface NCMPlayListImageCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NCMPlayListImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithModel:(NCMFileDetailImformationModel *)model {
    _imageView.image = [UIImage imageWithContentsOfFile:model.fullPathFileName];
}

@end
