//
//  NCMPlayListHeaderFooterView.h
//  NearCameraManager
//
//  Created by NearKong on 16/8/12.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCMPlayListModel;
@interface NCMPlayListHeaderFooterView : UITableViewHeaderFooterView
- (void)updateHeaderFooterViewWithModel:(NCMPlayListModel *)model;
@end
