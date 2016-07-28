//
//  NCMFileDetailImformationModel.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/22.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMFileDetailImformationModel.h"

@implementation NCMFileDetailImformationModel
- (instancetype)initWithFullPathFileName:(NSString *)fullPathName {
    self = [super init];
    if (self) {
        _fullPathFileName = fullPathName;
        _fileName = [fullPathName lastPathComponent];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        _exists = [fileManager fileExistsAtPath:fullPathName isDirectory:&_directory];

        if (_exists) {
            NSDictionary *dictionary = [fileManager attributesOfItemAtPath:fullPathName error:nil];
            _size = [dictionary fileSize];
        }
    }
    return self;
}
@end
