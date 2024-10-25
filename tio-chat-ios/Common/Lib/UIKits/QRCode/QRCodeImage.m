//
//  QRCodeImage.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/8.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "QRCodeImage.h"
#import "UIImage+TColor.h"

@implementation QRCodeImage

+ (UIImage *)QRImageWithString:(NSString *)infor size:(CGFloat)width logo:(UIImage * _Nullable)logo
{
    return [self QRImageWithData:[infor dataUsingEncoding:NSUTF8StringEncoding] size:width codeColor:UIColor.blackColor logo:logo logoBoderColor:UIColor.whiteColor logoBoderWidth:3 logoSize:CGSizeMake(57, 57) maskImage:nil];
}

+ (UIImage *)QRImageWithDictonary:(NSDictionary *)infor size:(CGFloat)width logo:(UIImage *)logo
{
    NSData *dataImage = [NSJSONSerialization dataWithJSONObject:infor options:0 error:nil];
    return [self QRImageWithData:dataImage size:width codeColor:UIColor.blackColor logo:logo logoBoderColor:UIColor.whiteColor logoBoderWidth:3 logoSize:CGSizeMake(57, 57) maskImage:nil];
}

+ (UIImage *)QRImageWithData:(NSData *)infor size:(CGFloat)width codeColor:(nonnull UIColor *)codeColor logo:(UIImage * _Nullable)logo logoBoderColor:(nonnull UIColor *)logoBoderColor logoBoderWidth:(CGFloat)logoBoderWidth logoSize:(CGSize)logoSize maskImage:(UIImage * _Nullable)maskImage
{
    // 二维码过滤器
    CIFilter *filterImage = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 将二位码过滤器设置为默认属性
    [filterImage setDefaults];
    // 将文字转化为二进制
    NSError *error = nil;
    NSData *dataImage = infor;
    if (error) {
        NSLog(@"error => %@", error.localizedDescription);
        return nil;
    }
    // 打印输入的属性
    NSLog(@"%@", filterImage.inputKeys);
    // KVC 赋值
    [filterImage setValue:dataImage forKey:@"inputMessage"];
    // 取出输出图片
    CIImage *outputImage = [filterImage outputImage];
    CGFloat scaleX = FlexWidth(260) / outputImage.extent.size.width * 2; // extent 返回图片的frame
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleX)];
    
//    CIFilter *colorFilter=[CIFilter filterWithName:@"CIFalseColor"];
//        //5.1设置默认值
//    [colorFilter setDefaults];
//    [colorFilter setValue:outputImage forKey:@"inputImage"];
//    [colorFilter setValue:[CIColor colorWithRed:74/255.0 green:143/255.0 blue:246/255.0] forKey:@"inputColor0"];
////    [colorFilter setValue:[CIColor colorWithRed:48/255.0 green:172/255.0 blue:102/255.0] forKey:@"inputColor0"];
//    [colorFilter setValue:[CIColor colorWithRed:255 green:255 blue:255] forKey:@"inputColor1"];
//
//    outputImage = colorFilter.outputImage;
    
    // 转化图片
    UIImage *image = [UIImage imageWithCIImage:outputImage];
    
    // 开启绘图, 获取图片 上下文<图片大小>
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    // 将二维码图片画上去
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    if (logo) {
        // 白色边框图
        UIImage *whiteImage = [[UIImage imageWithColor:logoBoderColor] imageWithCornerRadius:8 size:CGSizeMake(60, 60)];
        [whiteImage drawInRect:CGRectMake((image.size.width - logoSize.width*2 - logoBoderWidth*2) / 2, (image.size.width - logoSize.height*2 - logoBoderWidth*2) / 2, (logoSize.width+logoBoderWidth)*2, (logoSize.height+logoBoderWidth)*2)];
        
        // 将小图片画上去
        [logo drawInRect:CGRectMake((image.size.width - logoSize.width*2) / 2, (image.size.width - logoSize.height*2) / 2, logoSize.width*2, logoSize.height*2)];
    }
    // 获取最终的图片
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat extentWidth = CGRectGetWidth(extent);
    CGFloat extentHeight = CGRectGetHeight(extent);
    if (size < extentWidth || size < extentHeight) {
       size = MIN(CGRectGetWidth(extent), CGRectGetHeight(extent));
    }

    CGFloat scale = MIN(size/extentWidth, size/extentHeight);

    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);

    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
