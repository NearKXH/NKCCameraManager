//
//  NCMSettingModel.h
//  NearCamera
//
//  Created by NearKong on 16/8/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NCMSettingListModelType) {
    NCMSettingListModelTypeAudioQuality,
    NCMSettingListModelTypeAudioPartition,
    NCMSettingListModelTypeClear,
};

typedef NS_ENUM(NSUInteger, NCMSettingModelType) {
    NCMSettingModelTypeAudioQuality,
    NCMSettingModelTypeAudioFormat,
    NCMSettingModelTypeAudioPartition,
    NCMSettingModelTypeAudioPartitionTime,
    NCMSettingModelTypeClearAllFile,
};

@interface NCMSettingModel : NSObject
@property (nonatomic, assign) NCMSettingModelType modelType;

@end

@interface NCMSettingListModel : NSObject
@property (nonatomic, assign) NCMSettingListModelType modelType;
@property (nonatomic, strong) NSMutableArray<NCMSettingModel *> *sourceArray;

@end
