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

    /**
     *  音频转换
     */
    NCameraManagerResultConverFail = -2000,                          //初始化失败
    NCameraManagerResultConverFailWithOriginalFileNotExists = -2001, //原文件不存在
    NCameraManagerResultConverFailWithOriginalFileInstance = -2002,  //原文件初始化失败
    NCameraManagerResultConverFailWithToFileInstance = -2003,        //目标文件初始化失败
    NCameraManagerResultConverFailWithConvering = -2004,             //转换失败

    /**
     *  文件操作
     */
    NCameraManagerResultFileFail = -9000,
    NCameraManagerResultFileFailWithNonExistent = -9001, //传入文件不存在
    NCameraManagerResultFileFailWithMoveOrCopy = -9002,  //移动或复制文件失败
};

typedef void (^NCameraManagerResultBlock)(NCameraManagerResult result, NSError *error);

static NSString *const NCameraManagerFileNamePrefix = @"NCM";

#endif /* NCameraManagerHeader_h */
