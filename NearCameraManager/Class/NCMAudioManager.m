//
//  NCMAudioManager.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/22.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMAudioManager.h"

@import AVFoundation;
@import UIKit;
#import "NCameraManagerHeader.h"
#import "NSError+NCustomErrorInstance.h"
#import "NSFileManager+NFileOperationManager.h"
//#import "NSString+NFilePathExtension.h"

@interface NCMAudioManager () <AVAudioRecorderDelegate>
@property (nonatomic, assign, readwrite) NAudioManagerQuality quality;
@property (nonatomic, assign) NAudioManagerFileFormat fileExtension;
@property (nonatomic, copy) NAudioManagerFinishBlock recordFinishBlock;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@property (nonatomic, strong) NSString *recordFileFullPath;
@property (nonatomic, assign, readwrite, getter=isPausing) BOOL pausing;

@end

@implementation NCMAudioManager

- (void)dealloc {
    NSLog(@"--NCMAudioManager--dealloc--");
    [self removeObservers];
}

#pragma mark - instance
+ (NCMAudioManager *)audioManagerWithFileFormat:(NAudioManagerFileFormat)fileFormat
                                        quality:(NAudioManagerQuality)quality
                                    resultBlock:(NCameraManagerResultBlock)block {
    NCMAudioManager *audioManager = [[NCMAudioManager alloc] init];
    if (audioManager) {
        audioManager.quality = quality;
        audioManager.fileExtension = fileFormat;
        if (![audioManager configDataWithBlock:(NCameraManagerResultBlock)block]) {
            audioManager = nil;
        }
    }
    return audioManager;
}

- (BOOL)configDataWithBlock:(NCameraManagerResultBlock)block {
    [self addObservers];
    [self configRecordData];
    if (block) {
        block(NCameraManagerResultSuccess, nil);
    }
    return true;
}

- (void)configRecordData {
    self.pausing = false;
}

#pragma mark - AudioSession & AudioRecord
- (void)setupSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

- (NSMutableDictionary *)recordSettings {
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];

    [recordSettings setObject:@(2) forKey:AVNumberOfChannelsKey];

    switch (self.quality) {
    case NAudioManagerQualityLow:
        [recordSettings setObject:@(8000) forKey:AVSampleRateKey];
        [recordSettings setObject:@(AVAudioQualityLow) forKey:AVEncoderAudioQualityKey];
        [recordSettings setObject:@(AVAudioQualityLow) forKey:AVEncoderAudioQualityForVBRKey];
        [recordSettings setObject:@(AVAudioQualityLow) forKey:AVSampleRateConverterAudioQualityKey];
        [recordSettings setObject:@(128000) forKey:AVEncoderBitRateKey];

        break;
    case NAudioManagerQualityHigh:
        [recordSettings setObject:@(44100.0) forKey:AVSampleRateKey];
        [recordSettings setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
        [recordSettings setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityForVBRKey];
        [recordSettings setObject:@(AVAudioQualityHigh) forKey:AVSampleRateConverterAudioQualityKey];
        [recordSettings setObject:@(198000) forKey:AVEncoderBitRateKey];

        break;
    case NAudioManagerQualityMax:
        [recordSettings setObject:@(96000.0) forKey:AVSampleRateKey];
        [recordSettings setObject:@(AVAudioQualityMax) forKey:AVEncoderAudioQualityKey];
        [recordSettings setObject:@(AVAudioQualityMax) forKey:AVEncoderAudioQualityForVBRKey];
        [recordSettings setObject:@(AVAudioQualityMax) forKey:AVSampleRateConverterAudioQualityKey];
        [recordSettings setObject:@(320000) forKey:AVEncoderBitRateKey];

        break;
    default:
        break;
    }

    switch (self.fileExtension) {
    case NAudioManagerFileFormatCAF:
        [recordSettings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        [recordSettings setObject:@(16) forKey:AVLinearPCMBitDepthKey];
        break;

    case NAudioManagerFileFormatAAC:
        [recordSettings setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
        [recordSettings setObject:@(44100.0) forKey:AVSampleRateKey];
        break;

    default:
        break;
    }

    return recordSettings;
}

#pragma mark - Notification
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBackgroundActionNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateActionNotification)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appDidBackgroundActionNotification {
    NSLog(@"--NCMAudioManager--appDidBackgroundActionNotification--");
}

- (void)appWillTerminateActionNotification {
    NSLog(@"--NCMAudioManager--appWillTerminateActionNotification--");
}

#pragma mark - interface
- (void)startRecordWithPrefix:(NSString *)prefix resultBlock:(NCameraManagerResultBlock)block {

    NSError *error = nil;
    [self setupSession];

    if (self.isRecording) {
        if (block) {
            error = [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithRecording message:@"Audio is recording"];
            block(NCameraManagerResultAudioFailWithRecording, error);
        }
        return;
    }

    if (!self.isPausing) {
        NSString *filePath = [NSFileManager NCM_fullPathWithRelativePath:NCMFilePathInDirectoryTemp prefix:prefix error:&error];
        if (!filePath || error) {
            if (block) {
                block(NCameraManagerResultAudioFail, error);
            }
        }

        NSString *fileExtension = @"caf";
        switch (self.fileExtension) {
        case NAudioManagerFileFormatCAF:
            fileExtension = @"caf";
            break;
        case NAudioManagerFileFormatAAC:
            fileExtension = @"aac";
            break;

        default:
            break;
        }

        self.recordFileFullPath = [filePath stringByAppendingPathExtension:fileExtension];
        NSURL *url = [NSURL fileURLWithPath:self.recordFileFullPath];
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[self recordSettings] error:&error];
        self.audioRecorder.delegate = self;
        if (!self.audioRecorder || error) {
            if (block) {
                block(NCameraManagerResultAudioFail, error);
            }
        }
    }

    NCameraManagerResult result = NCameraManagerResultSuccess;
    if ([self.audioRecorder prepareToRecord]) {
        [self setupSession];
        if ([self.audioRecorder record]) {
            self.pausing = false;
            NSLog(@"--NCMAudioManager--startAudioRecord--");
        } else {
            error = [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithStartRecord message:@"start recording fail"];
            result = NCameraManagerResultAudioFailWithStartRecord;
            NSLog(@"--NCMAudioManager--startFail--");
        };
    } else {
        error = [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithNotPrepartToStart message:@"audio recorder not prepare to record"];
        result = NCameraManagerResultAudioFailWithNotPrepartToStart;
        NSLog(@"--NCMAudioManager--startFail--");
    }

    if (block) {
        block(result, error);
    }
}

- (void)pause {
    [self.audioRecorder pause];
    self.pausing = TRUE;
    NSLog(@"--NCMAudioManager--pauseAudioRecord--");
}

- (void)stopRecordWithBlock:(NAudioManagerFinishBlock)block {
    self.recordFinishBlock = block;
    [self.audioRecorder stop];
    NSLog(@"--NCMAudioManager--stopAudioRecord--");
}

#pragma mark - Private
- (void)audioFinishRecord {
    NSString *fileName = [self.recordFileFullPath lastPathComponent];
    [NSFileManager NCM_moveFileFromOriginalPath:NCMFilePathInDirectoryTemp
                               originalFileName:fileName
                                         toPath:NCMFilePathInDirectoryDocumentOriginal
                                     toFileName:fileName
                                         isCopy:false
                                          block:^(NCameraManagerResult result, NSString *fullPath, NSError *error) {
                                              if (self.recordFinishBlock) {
                                                  self.recordFinishBlock(result, fullPath, error);
                                              }
                                          }];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    self.pausing = false;
    NSError *error = flag ? nil : [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithFinishRecord message:@"Audio record fail"];
    if (!flag) {
        if (self.recordFinishBlock) {
            self.recordFinishBlock(NCameraManagerResultAudioFailWithFinishRecord, nil, error);
        }
        return;
    }
    [self audioFinishRecord];
}

#pragma mark - property
- (BOOL)isRecording {
    return self.audioRecorder.recording;
}

@end
