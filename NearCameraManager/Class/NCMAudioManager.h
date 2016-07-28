//
//  NCMAudioManager.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/22.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NCameraManagerHeader.h"

typedef NS_ENUM(NSUInteger, NAudioManagerQuality) {
    NAudioManagerQualityLow,
    NAudioManagerQualityHigh,
    NAudioManagerQualityMax,
};

typedef NS_ENUM(NSUInteger, NAudioManagerFileFormat) {
    NAudioManagerFileFormatCAF, // CAF
    NAudioManagerFileFormatAAC, // AAC
};

typedef void (^NAudioManagerFinishBlock)(NCameraManagerResult result, NSString *fullPathFileName, NSError *error);

@interface NCMAudioManager : NSObject
@property (nonatomic, assign, readonly) NAudioManagerQuality quality;
@property (nonatomic, assign, readonly, getter=isRecording) BOOL recording;
@property (nonatomic, assign, readonly, getter=isPausing) BOOL pausing;

/**
 *  暂时一定会成功，可以不判断block
 *
 *  @param quality       注意，max真的很大，测试6秒，有5M
 *  @param fileExtension <#fileExtension description#>
 *  @param block
 *
 *  @return
 */
+ (NCMAudioManager *)audioManagerWithFileFormat:(NAudioManagerFileFormat)fileFormat
                                           quality:(NAudioManagerQuality)quality
                                       resultBlock:(NCameraManagerResultBlock)block;

/**
 *  Recording
 *
 *  @param prefix File name is prefix_(NSInteger)[NSDate date].timeIntervalSince1970] ,if nil default NCameraManagerFileNamePrefix
 *  @param block
 */
- (void)startRecordWithPrefix:(NSString *)prefix resultBlock:(NCameraManagerResultBlock)block;
- (void)pause;
- (void)stopRecordWithBlock:(NAudioManagerFinishBlock)block;

@end
