//
//  NSString+NFilePathExtension.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/24.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NSString+NFilePathExtension.h"

#import "NCameraManagerHeader.h"

@implementation NSString (NFilePathExtension)
+ (NSString *)NCM_filePathWithDirectory:(NCMFilePathInDirectory)directory prefix:(NSString *)prefix {
    if (!prefix || [prefix isEqualToString:@""]) {
        prefix = NCameraManagerFileNamePrefix;
    }
    NSInteger time = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", prefix, @(time)];
    return [NSString NCM_filePathWithDirectory:directory fileName:fileName];
}

+ (NSString *)NCM_filePathWithDirectory:(NCMFilePathInDirectory)directory fileName:(NSString *)fileName {
    NSString *path = nil;
    if (directory == NCMFilePathInDirectoryDocument) {
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    } else if (directory == NCMFilePathInDirectoryTemp) {
        path = NSTemporaryDirectory();
    } else {
        path = NSTemporaryDirectory();
    }

    if (!fileName || [fileName isEqualToString:@""]) {
        NSInteger time = (NSInteger)[[NSDate date] timeIntervalSince1970];
        fileName = [NSString stringWithFormat:@"%@_%@", NCameraManagerFileNamePrefix, @(time)];
    }

    NSString *fullFileName = [path stringByAppendingPathComponent:fileName];
    return fullFileName;
}

@end
