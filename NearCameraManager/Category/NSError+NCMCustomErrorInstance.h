//
//  NSError+NCMCustomErrorInstance.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/29.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NCameraManagerHeader.h"

@interface NSError (NCMCustomErrorInstance)
+ (NSError *)NCM_errorWithCode:(NCameraManagerResult)code message:(NSString *)message;
+ (void)NCM_perfectErrorWithErrorIndicator:(NSError **)errorIndicator error:(NSError *)error;
@end
