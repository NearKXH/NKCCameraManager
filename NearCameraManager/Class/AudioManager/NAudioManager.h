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

typedef void (^NAudioManagerFinishRecordingBlock)(NCameraManagerResult result, NSString *fullPathFileName, NCMFilePathInDirectory relativeDirectory,
                                                  NSError *error);
typedef void (^NAudioManagerFinishPlayingBlock)(BOOL success);

@interface NAudioManager : NSObject
@property (nonatomic, assign, readonly) NAudioManagerQuality quality;
@property (nonatomic, assign, readonly, getter=isRecording) BOOL recording;
@property (nonatomic, assign, readonly, getter=isRecordPausing) BOOL recordPausing;

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly, getter=isPlayPausing) BOOL playPausing;

+ (NAudioManager *)audioManagerWithFileFormat:(NAudioManagerFileFormat)fileFormat quality:(NAudioManagerQuality)quality;

/**
 *  Recording
 *
 *  @param prefix File name is prefix_(NSInteger)[NSDate date].timeIntervalSince1970] ,if nil default NCM
 *  @param block
 */
- (NCameraManagerResult)startRecordWithPrefix:(NSString *)prefix error:(NSError **)error;
- (NCameraManagerResult)pauseRecordWithError:(NSError **)error;
- (void)stopRecordWithBlock:(NAudioManagerFinishRecordingBlock)block;

/**
 *  Play
 */
- (NCameraManagerResult)playWithRelativePath:(NCMFilePathInDirectory)relativePath
                                    fileName:(NSString *)fileName
                                       error:(NSError **)error
                                 finishBlock:(NAudioManagerFinishPlayingBlock)block;
- (NCameraManagerResult)playWithFullPathFileName:(NSString *)fileName error:(NSError **)error finishBlock:(NAudioManagerFinishPlayingBlock)block;
- (NCameraManagerResult)pausePlaying:(NSError **)error;
- (void)stopPlaying;

@end
