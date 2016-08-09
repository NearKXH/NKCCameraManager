//
//  NCameraManager.h
//  NCamera
//
//  Created by NearKong on 16/6/25.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

#import "NCameraManagerHeader.h"

typedef NS_ENUM(NSUInteger, NCameraManagerMode) {
    NCameraManagerModeCamera, //只打开摄像头
    NCameraManagerModeVedio,  //录像包括声音
};

typedef NS_ENUM(NSUInteger, NCameraManagerFlashMode) {
    NCameraManagerFlashModeAudo,
    NCameraManagerFlashModeOn,
    NCameraManagerFlashModeOff,
};

typedef void (^NCameraManagerResultBlock)(NCameraManagerResult result, NSError *error);
typedef void (^NCameraManagerStillImageBlock)(NCameraManagerResult result, UIImage *image, NSError *error);
typedef void (^NCameraManagerRecordBlock)(NCameraManagerResult result, NSString *fileFullPath, NCMFilePathInDirectory directory, NSError *error);

@interface NCameraManager : NSObject
@property (nonatomic, assign, readonly, getter=isMovieRecording) BOOL movieRecording;
@property (nonatomic, assign, readonly, getter=isSessionRunning) BOOL sessionRunning;

+ (NCameraManager *)cameraManagerAuthorizationWithMode:(NCameraManagerMode)mode
                                           previewView:(UIView *)previewView
                                   authorizationHandle:(NCameraManagerResultBlock)managerResultBlock;

- (void)configAuthorizationWithAuthorizationHandle:(NCameraManagerResultBlock)managerResultBlock;

/**
 *  Runing
 */
- (void)startRuningWithBlock:(NCameraManagerResultBlock)block;
- (void)stopRuningWithBlock:(NCameraManagerResultBlock)block;

/**
 *  flashModel
 */
- (BOOL)hasFlashInCurrentDevice;
- (BOOL)changeFlashmode:(NCameraManagerFlashMode)flashMode error:(NSError **)error;

/**
 *  CameraChanging
 */
- (void)changeCameraWithHandle:(NCameraManagerResultBlock)block;

/**
 *  Still Image
 */
- (void)snapStillImageIsSaveToPhotoLibrary:(BOOL)isSave imageHandle:(NCameraManagerStillImageBlock)imageHandle;

/**
 *  Movie
 */
- (void)startMovieRecordWithBlock:(NCameraManagerResultBlock)block;
- (void)stopMovieRecordWithFileName:(NSString *)fileName isSave:(BOOL)isSave block:(NCameraManagerRecordBlock)block;

@end
