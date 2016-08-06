//
//  NAudioManager.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/29.
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

typedef void (^NAudioManagerFinishBlock)(NCameraManagerResult result, NSString *fullPathFileName, NCMFilePathInDirectory relativeDirectory, NSError *error);

@interface NAudioManager : NSObject
@property (nonatomic, assign, readonly) NAudioManagerQuality quality;
@property (nonatomic, assign, readonly, getter=isRecording) BOOL recording;
@property (nonatomic, assign, readonly, getter=isRecordPausing) BOOL recordPausing;

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly, getter=isPlayPausing) BOOL playPausing;

/**
 *  暂时一定会成功，可以不判断block
 *
 *  @param quality       注意，max真的很大，测试6秒，有5M
 *  @param fileExtension <#fileExtension description#>
 *  @param block
 *
 *  @return
 */
+ (NAudioManager *)audioManagerWithFileFormat:(NAudioManagerFileFormat)fileFormat quality:(NAudioManagerQuality)quality;

/**
 *  Recording
 *
 *  @param prefix File name is prefix_(NSInteger)[NSDate date].timeIntervalSince1970] ,if nil default NCameraManagerFileNamePrefix
 *  @param block
 */
- (NCameraManagerResult)startRecordWithPrefix:(NSString *)prefix error:(NSError **)error;
- (NCameraManagerResult)pauseRecordWithError:(NSError **)error;
- (void)stopRecordWithBlock:(NAudioManagerFinishBlock)block;

- (NCameraManagerResult)playWithRelativePath:(NCMFilePathInDirectory)relativePath fileName:(NSString *)fileName error:(NSError **)error;
- (NCameraManagerResult)playWithFullPathFileName:(NSString *)fileName error:(NSError **)error;
- (NCameraManagerResult)pausePlaying:(NSError **)error;
- (void)stopPlaying;

@end
