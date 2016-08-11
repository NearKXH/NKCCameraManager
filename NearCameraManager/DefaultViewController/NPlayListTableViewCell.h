//
//  NPlayListTableViewCell.h
//  NearCameraManager
//
//  Created by NearKong on 16/8/11.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NPlayListModel.h"

@class NCMFileDetailImformationModel;
@interface NPlayListTableViewCell : UITableViewCell
- (void)updateCellWithModelType:(NPlayListModelType)modelType model:(NCMFileDetailImformationModel *)model;
@end
