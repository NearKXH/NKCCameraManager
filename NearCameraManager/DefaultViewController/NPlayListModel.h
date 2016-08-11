//
//  NPlayListModel.h
//  NearCameraManager
//
//  Created by NearKong on 16/8/11.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NPlayListModelType) {
    NPlayListModelTypeImage,
    NPlayListModelTypeAudio,
    NPlayListModelTypeVideo,
};

@interface NPlayListModel : NSObject
@property (nonatomic, assign) NPlayListModelType modelType;
@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic, strong) NSMutableArray *sourceMutableArray;
@end
