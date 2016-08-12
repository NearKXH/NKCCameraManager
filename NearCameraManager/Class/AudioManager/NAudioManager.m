//
//  NAudioManager.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/29.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NAudioManager.h"

@import AVFoundation;
@import UIKit;
#import "NCameraManagerHeader.h"

#import "NSError+NCMCustomErrorInstance.h"
#import "NSFileManager+NCMFileOperationManager.h"

@interface NAudioManager () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (nonatomic, assign, readwrite) NAudioManagerQuality quality;
@property (nonatomic, assign) NAudioManagerFileFormat fileExtension;
@property (nonatomic, copy) NAudioManagerFinishRecordingBlock recordFinishBlock;
@property (nonatomic, copy) NAudioManagerFinishPlayingBlock playFinishBlock;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) NSString *recordFileFullPath;
@property (nonatomic, assign, readwrite, getter=isRecordPausing) BOOL recordPausing;
@property (nonatomic, assign, readwrite, getter=isPlayPausing) BOOL playPausing;

@end

@implementation NAudioManager

- (void)dealloc {
    NSLog(@"--NAudioManager--dealloc--");
    [self removeObservers];
}

#pragma mark - instance
+ (NAudioManager *)audioManagerWithFileFormat:(NAudioManagerFileFormat)fileFormat quality:(NAudioManagerQuality)quality {
    NAudioManager *audioManager = [[NAudioManager alloc] init];
    if (audioManager) {
        audioManager.quality = quality;
        audioManager.fileExtension = fileFormat;
        [audioManager configInit];
    }
    return audioManager;
}

- (void)configInit {
    [self addObservers];
    [self configRecordData];
}

- (void)configRecordData {
    self.recordPausing = false;
}

#pragma mark - AudioSession & AudioRecord
- (void)setupSession:(NSError **)error {
    NSError *tmpError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&tmpError];
    if (tmpError) {
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        return;
    }

    [audioSession setActive:YES error:&tmpError];

    if (tmpError) {
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        return;
    }
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

#pragma mark - RECORD INTERFACE
- (NCameraManagerResult)startRecordWithPrefix:(NSString *)prefix error:(NSError **)error {

    NSError *tmpError = nil;
    if (self.isRecording) {
        tmpError = [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithRecording message:@"Audio is recording"];
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        return NCameraManagerResultAudioFailWithRecording;
    }

    [self setupSession:&tmpError];
    if (tmpError) {
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        return NCameraManagerResultAudioFailWithSession;
    }

    if (!self.recordPausing) {
        NSString *filePath = [NSFileManager NCM_fullPathWithRelativePath:NCMFilePathInDirectoryTemp prefix:prefix error:&tmpError];
        if (!filePath || tmpError) {
            [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
            return NCameraManagerResultAudioFail;
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
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[self recordSettings] error:&tmpError];
        self.audioRecorder.delegate = self;
        if (!self.audioRecorder || tmpError) {
            [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
            return NCameraManagerResultAudioFail;
        }
    }

    NCameraManagerResult result = NCameraManagerResultSuccess;
    if ([self.audioRecorder prepareToRecord]) {
        if ([self.audioRecorder record]) {
            self.recordPausing = false;
            NSLog(@"--NCMAudioManager--startAudioRecord--");
        } else {
            tmpError = [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithStartRecord message:@"start recording fail"];
            [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
            result = NCameraManagerResultAudioFailWithStartRecord;
            NSLog(@"--NCMAudioManager--startFail--");
        };
    } else {
        tmpError = [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithNotPrepartToStart message:@"audio recorder not prepare to record"];
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        result = NCameraManagerResultAudioFailWithNotPrepartToStart;
        NSLog(@"--NCMAudioManager--startFail--");
    }
    return result;
}

- (NCameraManagerResult)pauseRecordWithError:(NSError **)error {
    if (self.isRecording) {
        [self.audioRecorder pause];
        self.recordPausing = TRUE;
        NSLog(@"--NCMAudioManager--pauseAudioRecord--");
        return NCameraManagerResultSuccess;
    } else {
        NSError *tmpError = [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithoutRecording message:@"Audio is not recording"];
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        NSLog(@"--NCMAudioManager-- Audio is not recording --");
        return NCameraManagerResultAudioFailWithoutRecording;
    }
}

- (void)stopRecordWithBlock:(NAudioManagerFinishRecordingBlock)block {
    self.recordFinishBlock = block;
    [self.audioRecorder stop];
    NSLog(@"--NCMAudioManager--stopAudioRecord--");
}

#pragma mark - Play INTERFACE
- (NCameraManagerResult)playWithRelativePath:(NCMFilePathInDirectory)relativePath
                                    fileName:(NSString *)fileName
                                       error:(NSError **)error
                                 finishBlock:(NAudioManagerFinishPlayingBlock)block {
    NSError *tmpError = nil;
    NSString *fullPathFileName = [NSFileManager NCM_fullPathWithRelativePath:relativePath fileName:fileName error:&tmpError];
    if (!fullPathFileName || tmpError) {
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        return NCameraManagerResultFileFailWithNonExistent;
    }

    return [self playWithFullPathFileName:fullPathFileName error:error finishBlock:block];
}

- (NCameraManagerResult)playWithFullPathFileName:(NSString *)fileName error:(NSError **)error finishBlock:(NAudioManagerFinishPlayingBlock)block {
    NSError *tmpError = nil;

    if (self.isPlaying) {
        tmpError = [NSError NCM_errorWithCode:NCameraManagerResultPlayFailWithPlaying message:@"Audio is playing"];
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        return NCameraManagerResultPlayFailWithPlaying;
    }

    [self setupSession:&tmpError];
    if (tmpError) {
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        return NCameraManagerResultPlayFailWithSession;
    }
    
    if (!self.playPausing) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
            tmpError = [NSError NCM_errorWithCode:NCameraManagerResultConverFailWithOriginalFileNotExists message:@"Original File Not-Exists"];
            [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
            return NCameraManagerResultConverFailWithOriginalFileNotExists;
        }

        NSURL *url = [NSURL fileURLWithPath:fileName];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&tmpError];
        self.audioPlayer.delegate = self;
        if (!self.audioPlayer || tmpError) {
            [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
            return NCameraManagerResultPlayFail;
        }
    }

    NCameraManagerResult result = NCameraManagerResultSuccess;
    if ([self.audioPlayer prepareToPlay]) {
        if ([self.audioPlayer play]) {
            self.playPausing = false;
            self.playFinishBlock = block;
            NSLog(@"--NCMAudioManager--startAudioPlay--");
        } else {
            tmpError = [NSError NCM_errorWithCode:NCameraManagerResultPlayFailWithStartPlay message:@"start playing fail"];
            [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
            result = NCameraManagerResultPlayFailWithStartPlay;
            NSLog(@"--NCMAudioManager--startFail--");
        };
    } else {
        tmpError = [NSError NCM_errorWithCode:NCameraManagerResultPlayFailWithNotPrepartToStart message:@"audio recorder not prepare to play"];
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        result = NCameraManagerResultPlayFailWithNotPrepartToStart;
        NSLog(@"--NCMAudioManager--startFail--");
    }
    return result;
}

- (NCameraManagerResult)pausePlaying:(NSError **)error {
    if (self.isPlaying) {
        [self.audioPlayer pause];
        self.playPausing = TRUE;
        NSLog(@"--NCMAudioManager--pauseAudioPlay--");
        return NCameraManagerResultSuccess;
    } else {
        NSError *tmpError = [NSError NCM_errorWithCode:NCameraManagerResultPlayFailWithoutPlaying message:@"Audio is not recording"];
        [NSError NCM_perfectErrorWithErrorIndicator:error error:tmpError];
        NSLog(@"--NCMAudioManager-- Audio is not recording --");
        return NCameraManagerResultPlayFailWithoutPlaying;
    }
}

- (void)stopPlaying {
    [self.audioPlayer stop];
    NSLog(@"--NCMAudioManager--stopAudioPlay--");
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
                                                  self.recordFinishBlock(result, fullPath, NCMFilePathInDirectoryDocumentOriginal, error);
                                              }
                                              self.recordFinishBlock = nil;
                                              self.audioRecorder = nil;
                                          }];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    self.recordPausing = false;
    NSError *error = flag ? nil : [NSError NCM_errorWithCode:NCameraManagerResultAudioFailWithFinishRecord message:@"Audio record fail"];
    if (!flag) {
        if (self.recordFinishBlock) {
            self.recordFinishBlock(NCameraManagerResultAudioFailWithFinishRecord, nil, NCMFilePathInDirectoryNone, error);
        }
        return;
    }
    [self audioFinishRecord];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.playFinishBlock) {
        self.playFinishBlock(flag);
    }
    self.playFinishBlock = nil;
}

#pragma mark - property
- (BOOL)isRecording {
    return self.audioRecorder.recording;
}

- (BOOL)isPlaying {
    return self.audioPlayer.isPlaying;
}

@end
