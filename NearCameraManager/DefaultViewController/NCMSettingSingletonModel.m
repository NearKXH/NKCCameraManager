//
//  NCMSettingSingletonModel.m
//  NearCamera
//
//  Created by NearKong on 16/8/19.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMSettingSingletonModel.h"

#import "NAudioManager.h"

@implementation NCMSettingSingletonModel

static NSString *const kNCMSettingSingletonModelAudioQuality = @"kNCMSettingSingletonModelAudioQuality";
static NSString *const kNCMSettingSingletonModelAudioFormat = @"kNCMSettingSingletonModelAudioFormat";
static NSString *const kNCMSettingSingletonModelIsPartitionAudio = @"kNCMSettingSingletonModelIsPartitionAudio";
static NSString *const kNCMSettingSingletonModelPartitionAudioTime = @"kNCMSettingSingletonModelPartitionAudioTime";

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static NCMSettingSingletonModel *sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance resetInfoWithCoding];
    });
    return sharedInstance;
}

- (void)resetInfoWithCoding {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];

    NSNumber *number = [user objectForKey:kNCMSettingSingletonModelAudioQuality];
    _audioQuality = [self isNullWithObject:number] ? [number unsignedIntegerValue] : NAudioManagerQualityHigh;

    number = [user objectForKey:kNCMSettingSingletonModelAudioFormat];
    _audioFormat = [self isNullWithObject:number] ? [number unsignedIntegerValue] : NAudioManagerFileFormatAAC;

    number = [user objectForKey:kNCMSettingSingletonModelIsPartitionAudio];
    _isPartitionAudio = [self isNullWithObject:number] ? [number boolValue] : false;

    number = [user objectForKey:kNCMSettingSingletonModelPartitionAudioTime];
    _partitionAudioTime = [self isNullWithObject:number] ? [number doubleValue] : 60 * 60;
}

- (void)updateModel {
    [[NSNotificationCenter defaultCenter] postNotificationName:NCMSettingSingletonModelUpdateNotifcation object:self];

    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:@(_audioQuality) forKey:kNCMSettingSingletonModelAudioQuality];
    [user setObject:@(_audioFormat) forKey:kNCMSettingSingletonModelAudioFormat];
    [user setObject:@(_isPartitionAudio) forKey:kNCMSettingSingletonModelIsPartitionAudio];
    [user setObject:@(_partitionAudioTime) forKey:kNCMSettingSingletonModelPartitionAudioTime];
}

- (BOOL)isNullWithObject:(id)object {
    if (!object || [object isKindOfClass:[NSNull class]]) {
        return false;
    }
    return true;
}

@end
