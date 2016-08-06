//
//  UIImage+NCMImageScale.h
//  NearCameraManager
//
//  Created by NearKong on 16/7/30.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreMedia;

@interface UIImage (NCMImageScale)
- (UIImage *)NCM_cutImageInRect:(CGRect)rect;
- (UIImage *)NCM_scaleToSize:(CGSize)size;

+ (UIImage *)NCM_imageWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (void)NCM_saveImageInPhotosLibraryFromData:(NSData *)imageData;
@end
