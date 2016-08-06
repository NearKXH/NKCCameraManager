//
//  UIImage+NCMImageScale.m
//  NearCameraManager
//
//  Created by NearKong on 16/7/30.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "UIImage+NCMImageScale.h"

@import CoreMedia;
@import Photos;

@implementation UIImage (NCMImageScale)

#pragma mark - Scale Image
/**
 *  切割图片
 *
 *  @param rect 范围，注意图片像素
 *
 */
- (UIImage *)NCM_cutImageInRect:(CGRect)rect {
    UIImage *fixImage = [UIImage NCM_imageInfixOrientation:self];
    CGImageRef imageRef = CGImageCreateWithImageInRect(fixImage.CGImage, rect);
    UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
    return newImage;
}

/**
 *  压缩图片，压缩大小，不存在抽点压缩
 *
 *  @param size 需要的大小，注意图片失真问题
 *
 */
- (UIImage *)NCM_scaleToSize:(CGSize)size {

    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;


    /**
     *  另一个绘图方式
     */
    /**
     CGRect rect = CGRectMake(0, 0, size.width, size.height);
     UIGraphicsBeginImageContext(rect.size);                      //根据size大小创建一个基于位图的图形上下文
     CGContextRef currentContext = UIGraphicsGetCurrentContext(); //获取当前quartz 2d绘图环境
     CGContextClipToRect(currentContext, rect);                   //设置当前绘图环境到矩形框
     CGContextDrawImage(currentContext, rect, self.CGImage);         //绘图
     UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext(); //获得图片
     UIGraphicsEndImageContext();                                    //从当前堆栈中删除quartz 2d绘图环境

     return cropped;
     */
}

#pragma mark - CMSampleBufferRef To Image
/**
 *  通过抽样缓存生成图片，用于AV实时监控摄像头
 *
 *  @param CMSampleBufferRef 抽样缓存
 *
 *  @return 生成图片
 *  注意：videoSettings 设置为 [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
 * forKey:(id)kCVPixelBufferPixelFormatTypeKey];
 */
+ (UIImage *)NCM_imageWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // 用Quartz image创建一个UIImage对象image

    // 释放Quartz image对象
    CGImageRelease(quartzImage);

    return (image);
}

#pragma mark - Save Image to Library
+ (void)NCM_saveImageInPhotosLibraryFromData:(NSData *)imageData {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            // To preserve the metadata, we create an asset from the JPEG NSData representation.
            // Note that creating an asset from a UIImage discards the metadata.
            // In iOS 9, we can use -[PHAssetCreationRequest addResourceWithType:data:options].
            // In iOS 8, we save the image to a temporary file and use +[PHAssetChangeRequest
            // creationRequestForAssetFromImageAtFileURL:].
            if ([PHAssetCreationRequest class]) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
                }
                    completionHandler:^(BOOL success, NSError *error) {
                        if (!success) {
                            NSLog(@"Error occurred while saving image to photo library: %@", error);
                        }
                    }];
            } else {
                NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
                NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
                NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];

                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    NSError *error = nil;
                    [imageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
                    if (error) {
                        NSLog(@"Error occured while writing image data to a temporary file: %@", error);
                    } else {
                        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
                    }
                }
                    completionHandler:^(BOOL success, NSError *error) {
                        if (!success) {
                            NSLog(@"Error occurred while saving image to photo library: %@", error);
                        }

                        // Delete the temporary file.
                        [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
                    }];
            }
        }
    }];
}

#pragma mark - private
/**
 *  纠正图片方向，imageOrientation方向对CGImage有影响，可用initWithCGImage:scale:orientation:纠正，但是CGImage割图存在问题
 *
 *  @param aImage 需要纠正的图片
 *
 *  @return 方向为UIImageOrientationUp的图片
 */
+ (UIImage *)NCM_imageInfixOrientation:(UIImage *)aImage {

    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (aImage.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;

    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;

    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
    default:
        break;
    }

    switch (aImage.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;

    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
    default:
        break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height, CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage), CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        // Grr...
        CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.height, aImage.size.width), aImage.CGImage);
        break;

    default:
        CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.width, aImage.size.height), aImage.CGImage);
        break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
