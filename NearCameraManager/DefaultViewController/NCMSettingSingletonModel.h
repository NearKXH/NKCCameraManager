//
//  NCMSettingSingletonModel.h
//  NearCamera
//
//  Created by NearKong on 16/8/19.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NAudioManager.h"

static NSString *const NCMSettingSingletonModelUpdateNotifcation = @"NCMSettingSingletonModelUpdateNotifcation";
@interface NCMSettingSingletonModel : NSObject

@property (nonatomic, assign) NAudioManagerQuality audioQuality;
@property (nonatomic, assign) NAudioManagerFileFormat audioFormat;

@property (nonatomic, assign) BOOL isPartitionAudio;
@property (nonatomic, assign) NSTimeInterval partitionAudioTime;

+ (instancetype)sharedInstance;
- (void)updateModel;
@end
