//
//  NSError+NCustomErrorInstance.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/22.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NSError+NCustomErrorInstance.h"

#import "NCameraManagerHeader.h"

@implementation NSError (NCustomErrorInstance)

static NSString *const NCameraManagerErrorIdentifier = @"NCameraManagerError";
+ (NSError *)NCM_errorWithCode:(NCameraManagerResult)code message:(NSString *)message {
    NSError *error =
        [[NSError alloc] initWithDomain:NCameraManagerErrorIdentifier code:code userInfo:@{
            NSLocalizedFailureReasonErrorKey : message ?: @"Fail"
        }];
    return error;
}
@end
