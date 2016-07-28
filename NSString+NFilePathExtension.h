//
//  NSString+NFilePathExtension.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/24.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NCameraManagerHeader.h"

@interface NSString (NFilePathExtension)
/**
 *
 *  @param directory
 *  @param prefix
 *
 *  @return full path
 */
+ (NSString *)NCM_filePathWithDirectory:(NCMFilePathInDirectory)directory prefix:(NSString *)prefix;

/**
 *
 *  @param directory
 *  @param fileName
 *
 *  @return full path
 */
+ (NSString *)NCM_filePathWithDirectory:(NCMFilePathInDirectory)directory fileName:(NSString *)fileName;

@end
