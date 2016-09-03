//
//  NAudioConvertManager.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/22.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NAudioConvertManager.h"

@import AVFoundation;
#import "NCameraManagerHeader.h"
#import "lame.h"

#import "NSError+NCMCustomErrorInstance.h"
#import "NSFileManager+NCMFileOperationManager.h"

@interface NAudioConvertManager ()
@property (nonatomic, strong) dispatch_queue_t converQueue;
@end

@implementation NAudioConvertManager

- (void)dealloc {
    NSLog(@"--NAudioConvertManager--dealloc--");
}

static char const *kNAudioConvertManagerConverQueueIdentifier = "kNAudioConvertManagerConverQueueIdentifier";
+ (NAudioConvertManager *)sharedInstance {
    static NAudioConvertManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[NAudioConvertManager alloc] init];
        if (shareInstance) {
            [shareInstance configData];
        }
    });
    return shareInstance;
}

- (void)configData {
    self.converQueue = dispatch_queue_create(kNAudioConvertManagerConverQueueIdentifier, DISPATCH_QUEUE_SERIAL);
}

#pragma mark - Conver
- (void)convertAudioFromFullPath:(NSString *)fromFullPath
                      toFileName:(NSString *)toFileName
              isSaveOriginalFile:(BOOL)isSave
                           block:(NAudioConvertResultBlock)block {

    dispatch_async(self.converQueue, ^{
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:fromFullPath]) {
            error = [NSError NCM_errorWithCode:NCameraManagerResultConverFailWithOriginalFileNotExists message:@"Original File Not-Exists"];
            if (block) {
                block(NCameraManagerResultConverFailWithOriginalFileNotExists, nil, NCMFilePathInDirectoryNone, error);
            }
            return;
        }

        NSString *fileName = toFileName;
        if (![[toFileName pathExtension] isEqualToString:@".mp3"]) {
            fileName = [toFileName stringByAppendingPathExtension:@"mp3"];
        }
        NSString *toFullPath = [NSFileManager NCM_fullPathWithRelativePath:NCMFilePathInDirectoryDocumentConver fileName:fileName error:&error];
        if (!toFullPath || error) {
            if (block) {
                block(NCameraManagerResultConverFailWithToFileInstance, nil, NCMFilePathInDirectoryNone, error);
            }
            return;
        }

        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fromFullPath] error:&error];
        if (!player || error) {
            if (block) {
                block(NCameraManagerResultConverFailWithOriginalFileInstance, nil, NCMFilePathInDirectoryNone, error);
            }
            return;
        }

        NSDictionary *settings = player.settings;
        NSNumber *settingValue = settings[@"AVFormatIDKey"];
#if __LP64__
        UInt32 audioKey = [settingValue unsignedIntValue];
#else
        UInt32 audioKey = [settingValue unsignedLongValue];
#endif
        if (audioKey != kAudioFormatLinearPCM) {
            error = [NSError NCM_errorWithCode:NCameraManagerResultConverFailWithOriginalFileInstance message:@"just canver CAF format"];
            if (block) {
                block(NCameraManagerResultConverFailWithOriginalFileInstance, nil, NCMFilePathInDirectoryNone, error);
            }
            return;
        }

        BOOL scuess = [self audio_PCMtoMP3FromFullPath:fromFullPath toFullPath:toFullPath originalSettings:settings error:&error];
        if (!scuess || error) {
            if (block) {
                block(NCameraManagerResultConverFailWithOriginalFileNotExists, nil, NCMFilePathInDirectoryNone, error);
            }
            return;
        }

        if (block) {
            block(NCameraManagerResultSuccess, toFullPath, NCMFilePathInDirectoryDocumentConver, error);
        }

        if (!isSave) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSFileManager NCM_clearFileWithFullFilePath:fromFullPath error:nil];
            });
        }
    });
}

#pragma mark - Private
- (BOOL)audio_PCMtoMP3FromFullPath:(NSString *)fromFullPath
                        toFullPath:(NSString *)toFullPath
                  originalSettings:(NSDictionary *)settings
                             error:(NSError **)error {
    BOOL scuess = true;
    NSString *mp3FilePath = toFullPath;
    float sampleRateKey = [settings[@"AVSampleRateKey"] floatValue];
    int numberOfChannelsKey = [settings[@"AVNumberOfChannelsKey"] intValue];

    @try {
        int read;
        int write;

        FILE *pcm = fopen([fromFullPath cStringUsingEncoding:1], "rb"); // source 被转换的音频文件位置
        fseek(pcm, 4 * 1024, SEEK_CUR);                                 // skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  // output 输出生成的Mp3文件位置

        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];


        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, sampleRateKey);
        lame_set_VBR(lame, vbr_default);
        lame_set_num_channels(lame, numberOfChannelsKey);
        //        lame_set_mode(lame,2);
        //        lame_set_brate(lame,11);
        //        lame_set_quality(lame, 2);//音质 2=high 5 = medium 7=low
        lame_init_params(lame);

        do {
            read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    } @catch (NSException *exception) {
        NSLog(@"--NAudioConvertManager--error = %@", [exception description]);
        *error = [NSError NCM_errorWithCode:NCameraManagerResultConverFailWithConvering message:[exception description]];
        scuess = false;
    } @finally {
//        NSLog(@"MP3生成成功: %@", toFullPath);
    }

    return scuess;
}

@end
