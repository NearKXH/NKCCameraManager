//
//  NCMPlayListImageTableViewCell.h
//  NearCamera
//
//  Created by NearKong on 16/8/20.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCMPlayListImageTableViewCell : UITableViewCell
- (void)updateCellWithArray:(NSArray *)sourceArray selectBlock:(void (^)(NSInteger row))block;
@end
