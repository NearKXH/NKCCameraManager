//
//  NDefaultViewController.h
//  NCamera
//
//  Created by NearKong on 16/6/25.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NCameraType) {
    NCameraTypeCamera = 1 << 1,
    NCameraTypeSquare = 1 << 2,
    NCameraTypeRecord = 1 << 3,
};

@interface NDefaultViewController : UIViewController

@end
