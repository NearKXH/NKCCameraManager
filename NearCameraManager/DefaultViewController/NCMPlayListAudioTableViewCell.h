//
//  NCMPlayListAudioTableViewCell.h
//  NearCameraManager
//
//  Created by NearKong on 16/8/12.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCMFileDetailImformationModel;
@interface NCMPlayListAudioTableViewCell : UITableViewCell
- (void)updateCellWithModel:(NCMFileDetailImformationModel *)model isShowButton:(BOOL)isShow;
@end
