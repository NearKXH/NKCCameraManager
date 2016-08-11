//
//  NPlayListTableViewCell.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/11.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NPlayListTableViewCell.h"

@implementation NPlayListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellWithModelType:(NPlayListModelType)modelType model:(NCMFileDetailImformationModel *)model {
}

@end
