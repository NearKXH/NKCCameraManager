//
//  NSFileManager+NFileOperationManager.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/22.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NCameraManagerHeader.h"

typedef NS_ENUM(NSUInteger, NCMFilePathInDirectory) {
    NCMFilePathInDirectoryDocument,         // DOCUMENT
    NCMFilePathInDirectoryDocumentOriginal, // DOCUMENT/NCMOriginal
    NCMFilePathInDirectoryDocumentConver,   // DOCUMENT/NCMConver
    NCMFilePathInDirectoryTemp,             // TMP
};

typedef void (^NSFileManagerMoveFileBlock)(NCameraManagerResult result, NSString *fullPath, NSError *error);

@class NCMFileDetailImformationModel;
@interface NSFileManager (NFileOperationManager)

#pragma mark - FileManager Operate
/**
 *  delete File which in document
 *
 *  @param filePath reative path
 *  @param error
 *
 *  @return
 */
+ (BOOL)NCM_clearFileWithRelativePath:(NCMFilePathInDirectory)relativePath fileName:(NSString *)fileName error:(NSError **)error;

/**
 *  delete file with full path
 *
 *  @param fullPath
 *  @param error
 *
 *  @return
 */
+ (BOOL)NCM_clearFileWithFullFilePath:(NSString *)fullPath error:(NSError **)error;

/**
 *  files in Document with directoryPath
 *
 *  @param directoryPath relative path with Document
 */
+ (NSArray<NCMFileDetailImformationModel *> *)NCM_allFilesWithRelativePath:(NCMFilePathInDirectory)relativePath error:(NSError **)error;

/**
 *  create file from original path
 *
 *  @param originalPath
 *  @param originalFileName from file name, if nil or equal to @"", return Fail
 *  @param toPath
 *  @param toFileName       to file name, if nil, default NCameraManagerFileNamePrefix_(NSInteger)[NSDate date].timeIntervalSince1970]
 *  @param isCopy           if true, copy file, otherwise move
 *  @param block
 */
+ (void)NCM_moveFileFromOriginalPath:(NCMFilePathInDirectory)originalPath
                    originalFileName:(NSString *)originalFileName
                              toPath:(NCMFilePathInDirectory)toPath
                          toFileName:(NSString *)toFileName
                              isCopy:(BOOL)isCopy
                               block:(NSFileManagerMoveFileBlock)block;

#pragma mark - File Name
/**
 *  full path
 *  file name : relativePath_(NSInteger)[[NSDate date] timeIntervalSince1970]
 *
 *  @param relativePath
 *  @param prefix       prefix of file name , if nil, default NCameraManagerFileNamePrefix
 *  @param error
 *
 *  @return
 */
+ (NSString *)NCM_fullPathWithRelativePath:(NCMFilePathInDirectory)relativePath prefix:(NSString *)prefix error:(NSError **)error;

/**
 *  full path
 *
 *  @param relativePath
 *  @param fileName     if nil, default NCameraManagerFileNamePrefix_(NSInteger)[[NSDate date] timeIntervalSince1970]
 *  @param error
 *
 *  @return
 */
+ (NSString *)NCM_fullPathWithRelativePath:(NCMFilePathInDirectory)relativePath fileName:(NSString *)fileName error:(NSError **)error;

@end
