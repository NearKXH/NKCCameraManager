//
//  NCMPlayListImageCollectionViewCell.h
//  NearCamera
//
//  Created by NearKong on 16/8/20.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCMFileDetailImformationModel;
@interface NCMPlayListImageCollectionViewCell : UICollectionViewCell
- (void)updateCellWithModel:(NCMFileDetailImformationModel *)model;
@end
