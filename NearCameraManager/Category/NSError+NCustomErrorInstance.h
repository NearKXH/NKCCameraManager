//
//  NSError+NCustomErrorInstance.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/22.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NCameraManagerHeader.h"

@interface NSError (NCustomErrorInstance)
+ (NSError *)NCM_errorWithCode:(NCameraManagerResult)code message:(NSString *)message;
@end
