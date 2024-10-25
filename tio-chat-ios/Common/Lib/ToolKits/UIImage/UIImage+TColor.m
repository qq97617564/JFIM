//
//  UIImage+TColor.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "UIImage+TColor.h"

@implementation UIImage (TColor)

+ (instancetype)imageWithColor:(UIColor *)color
{
    CGRect bounds = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(context, bounds);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (instancetype)imageWithCornerRadius:(CGFloat)cornerRadius size:(CGSize)newSize
{
    // 先将图片裁剪为目标比例 不拉伸压缩
    if (newSize.width == 0) {
        // 意味着不裁切，原尺寸
        newSize = self.size;
    }
    
    UIImage *originImage = [self scaleImage:newSize];
    
    // 开始裁切圆角
    CGRect bounds = CGRectMake(0, 0, newSize.width, newSize.height);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                    cornerRadius:cornerRadius];
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    [originImage drawInRect:bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 圆角裁剪结束
    return image;
}

- (UIImage *)scaleImage:(CGSize)newSize
{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    CGFloat scale = newSize.width / newSize.height;
    CGFloat imageScale = width / height;

    if (imageScale > scale) {
        // 以高为准
        width = height * scale;
    } else if (imageScale < scale) {
        // 以宽为准
        height = width / scale;
    } else {
        // 正常比例
    }
    
    // 中心放大
    CGRect frame = CGRectMake((self.size.width - width) * 0.5, (self.size.height - height) * 0.5, width, height);
    
    CGImageRef imageRef = [self CGImage];
    imageRef = CGImageCreateWithImageInRect(imageRef, frame);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    
    return image;
}

+ (UIImage *)CGContextClip:(UIImage *)img cornerRadius:(CGFloat)c{
    int w  = img.size.width * img.scale;
    int h = img.size.height * img.scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), false, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, c);
    CGContextAddArcToPoint(context, 0, 0, c, 0, c);
    CGContextAddLineToPoint(context, w-c, 0);
    CGContextAddArcToPoint(context, w, 0, w, c, c);
    CGContextAddLineToPoint(context, w, h-c);
    CGContextAddArcToPoint(context, w, h, w-c, h, c);
    CGContextAddLineToPoint(context, c, h);
    CGContextAddArcToPoint(context, 0, h, 0, h-c, c);
    CGContextAddLineToPoint(context, 0, c);
    CGContextClosePath(context);
    
     // 先裁剪 context，再画图，就会在裁剪后的 path 中画
    CGContextClip(context);
    [img drawInRect:CGRectMake(0, 0, w, h)];       // 画图
    CGContextDrawPath(context, kCGPathFill);
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}

+ (UIImage *)UIBezierPathClip:(UIImage *)img cornerRadius:(CGFloat)c{
    int w = img.size.width * img.scale;
    int h = img.size.height * img.scale;
    CGRect rect = CGRectMake(0, 0, w, h);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), false, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:c] addClip];
    [img drawInRect:rect];
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

+ (UIImage *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame andColors:(NSArray *)colors
{
    
    //Create our background gradient layer
    CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
    
    //Set the frame to our object's bounds
    backgroundGradientLayer.frame = frame;
    
    //To simplfy formatting, we'll iterate through our colors array and create a mutable array with their CG counterparts
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)[color CGColor]];
    }
    
    switch (gradientStyle) {
        case UIGradientStyleLeftToRight: {
            
            //Set out gradient's colors
            backgroundGradientLayer.colors = cgColors;
            
            //Specify the direction our gradient will take
            [backgroundGradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
            [backgroundGradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
            
            //Convert our CALayer to a UIImage object
            UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size,NO, [UIScreen mainScreen].scale);
            [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return backgroundColorImage;
        }
            
        case UIGradientStyleRadial: {
            UIGraphicsBeginImageContextWithOptions(frame.size,NO, [UIScreen mainScreen].scale);
            
            //Specific the spread of the gradient (For now this gradient only takes 2 locations)
            CGFloat locations[2] = {0.0, 1.0};
            
            //Default to the RGB Colorspace
            CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
            CFArrayRef arrayRef = (__bridge CFArrayRef)cgColors;
            
            //Create our Fradient
            CGGradientRef myGradient = CGGradientCreateWithColors(myColorspace, arrayRef, locations);
            
            
            // Normalise the 0-1 ranged inputs to the width of the image
            CGPoint myCentrePoint = CGPointMake(0.5 * frame.size.width, 0.5 * frame.size.height);
            float myRadius = MIN(frame.size.width, frame.size.height) * 1.0;
            
            // Draw our Gradient
            CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
                                         0, myCentrePoint, myRadius,
                                         kCGGradientDrawsAfterEndLocation);
            
            // Grab it as an Image
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            
            // Clean up
            CGColorSpaceRelease(myColorspace); // Necessary?
            CGGradientRelease(myGradient); // Necessary?
            UIGraphicsEndImageContext();
            
            return backgroundColorImage;
        }
            
        case UIGradientStyleTopToBottom:
        default: {
            
            //Set out gradient's colors
            backgroundGradientLayer.colors = cgColors;
            
            //Convert our CALayer to a UIImage object
            UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size,NO, [UIScreen mainScreen].scale);
            [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return backgroundColorImage;
        }
            
    }
}

@end
