//
//  NCameraManagerHeader.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/21.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#ifndef NCameraManagerHeader_h
#define NCameraManagerHeader_h

typedef NS_ENUM(NSInteger, NCameraManagerResult) {
    NCameraManagerResultSuccess = 0, //成功
    NCameraManagerResultFail = -1,   //失败

    /**
     *  录音
     */
    NCameraManagerResultAudioFail = -1000,                      //录音初始化失败
    NCameraManagerResultAudioFailWithNotPrepartToStart = -1001, //录音启动准备失败
    NCameraManagerResultAudioFailWithStartRecord = -1002,       //录音启动失败
    NCameraManagerResultAudioFailWithFinishRecord = -1003,      //录音失败
    NCameraManagerResultAudioFailWithRecording = -1004,         //正在录音
    NCameraManagerResultAudioFailWithoutRecording = -1005,      //没有在录音
    NCameraManagerResultAudioFailWithSession = -1006,           //设置失败


    /**
     *  播放
     */
    NCameraManagerResultPlayFail = -3000,                      //播放初始化失败
    NCameraManagerResultPlayFailWithNotPrepartToStart = -3001, //播放启动准备失败
    NCameraManagerResultPlayFailWithStartPlay = -3002,         //播放启动失败
    NCameraManagerResultPlayFailWithPlaying = -3004,           //正在播放
    NCameraManagerResultPlayFailWithoutPlaying = -1005,        //没有在播放
    NCameraManagerResultPlayFailWithSession = -3006,           //设置失败

    /**
     *  音频转换
     */
    NCameraManagerResultConverFail = -2000,                          //初始化失败
    NCameraManagerResultConverFailWithOriginalFileNotExists = -2001, //原文件不存在
    NCameraManagerResultConverFailWithOriginalFileInstance = -2002,  //原文件初始化失败
    NCameraManagerResultConverFailWithToFileInstance = -2003,        //目标文件初始化失败
    NCameraManagerResultConverFailWithConvering = -2004,             //转换失败

    /**
     *  视频
     *  注意：同时使用了 -4000 & -5000 系列的状态码
     */
    NCameraManagerResultCameraFail = -4000,
    NCameraManagerResultCameraFailWithCameraConfiguration = -4001,      //摄像头加载失败，没有授权
    NCameraManagerResultCameraFailWithCameraDevice = -4002,             //摄像头硬件加载失败
    NCameraManagerResultCameraFailWithCameraCanNotAddToSession = -4003, //摄像头添加失败
    NCameraManagerResultCameraFailWithAudioConfiguration = -5001,       //录音加载失败，没有授权
    NCameraManagerResultCameraFailWithAudioToSession = -50002,          //麦克风硬件加载失败
    NCameraManagerResultCameraFailWithAudioCanNotAddToSession = -5003,  //麦克风添加失败
    NCameraManagerResultCameraFailWithChangingConfiguration = -4004,    //摄像头设置未成功
    NCameraManagerResultCameraFailWithImageOutput = -4005,              //输出图片失败
    NCameraManagerResultCameraFailWithVideoOutput = -4006,              //输出录像失败

    NCameraManagerResultCameraFailWithFlashChanging = -4801,      //改变闪光灯失败
    NCameraManagerResultCameraFailWithCameraRuning = -4802,       //摄像头正在运作
    NCameraManagerResultCameraFailWithSessionRuning = -4900,      //流正在运作
    NCameraManagerResultCameraFailWithSessionStartRuning = -4901, //开始
    NCameraManagerResultCameraFailWithSessionStopRuning = -4902,  //结束

    NCameraManagerResultCameraFailWithStillImage = -4101,   //拍照失败
    NCameraManagerResultCameraFailWithStartRecord = -4201,  //
    NCameraManagerResultCameraFailWithRecording = -4202,    //
    NCameraManagerResultCameraFailWithNotRecord = -4203,    //
    NCameraManagerResultCameraFailWithFinishRecord = -4204, //

    /**
     *  文件操作
     */
    NCameraManagerResultFileFail = -9000,
    NCameraManagerResultFileFailWithNonExistent = -9001, //传入文件不存在
    NCameraManagerResultFileFailWithMoveOrCopy = -9002,  //移动或复制文件失败
};

typedef NS_ENUM(NSUInteger, NCMFilePathInDirectory) {
    NCMFilePathInDirectoryNone,
    NCMFilePathInDirectoryDocument,         // DOCUMENT
    NCMFilePathInDirectoryDocumentOriginal, // DOCUMENT/NCMOriginal
    NCMFilePathInDirectoryDocumentConver,   // DOCUMENT/NCMConver
    NCMFilePathInDirectoryTemp,             // TMP
};

#endif /* NCameraManagerHeader_h */
