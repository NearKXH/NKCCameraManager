//
//  NCMPlayListModel.h
//  NearCameraManager
//
//  Created by NearKong on 16/8/12.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NCMPlayListModelType) {
    NCMPlayListModelTypeImage,
    NCMPlayListModelTypeAudio,
    NCMPlayListModelTypeVideo,
};

@interface NCMPlayListModel : NSObject
@property (nonatomic, assign) NCMPlayListModelType modelType;
@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic, strong) NSMutableArray *sourceMutableArray;
@end
