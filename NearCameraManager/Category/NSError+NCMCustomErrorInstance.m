//
//  NSError+NCMCustomErrorInstance.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/29.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NSError+NCMCustomErrorInstance.h"

#import "NCameraManagerHeader.h"

@implementation NSError (NCMCustomErrorInstance)
static NSString *const kNCameraManagerErrorIdentifier = @"NCameraManagerErrorIdentifier";
+ (NSError *)NCM_errorWithCode:(NCameraManagerResult)code message:(NSString *)message {
    NSError *error =
        [[NSError alloc] initWithDomain:kNCameraManagerErrorIdentifier code:code userInfo:@{
            NSLocalizedFailureReasonErrorKey : message ?: @"Fail"
        }];
    return error;
}

+ (void)NCM_perfectErrorWithErrorIndicator:(NSError **)errorIndicator error:(NSError *)error {
    if (errorIndicator) {
        *errorIndicator = error;
    }
}

@end
