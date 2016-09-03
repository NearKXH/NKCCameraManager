//
//  NCMSettingTableViewCell.h
//  NearCamera
//
//  Created by NearKong on 16/8/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCMSettingModel;
@interface NCMSettingTableViewCell : UITableViewCell
- (void)updateCellWithModel:(NCMSettingModel *)model;
@end
