//
//  NCMFileDetailImformationModel.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/22.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMFileDetailImformationModel : NSObject

@property (nonatomic, strong, readonly) NSString *fullPathFileName;
@property (nonatomic, strong, readonly) NSString *fileName;

@property (nonatomic, assign, readonly, getter=isExists) BOOL exists;
@property (nonatomic, assign, readonly, getter=isDirectory) BOOL directory;

@property (nonatomic, assign, readonly) unsigned long long size;
@property (nonatomic, strong, readonly) NSDate *createTime;

- (instancetype)initWithFullPathFileName:(NSString *)fullPathName;

@end
