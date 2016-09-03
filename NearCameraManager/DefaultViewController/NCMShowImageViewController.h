//
//  NCMShowImageViewController.h
//  NearCamera
//
//  Created by NearKong on 16/8/20.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCMShowImageViewController : UIViewController
- (instancetype)initWithSourceArray:(NSArray *)array currentPage:(NSInteger)currentPage;
- (void)updateToItem:(NSInteger)row;
@end
