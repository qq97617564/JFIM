//
//  WaterMarkTool.m
//  WaterMark
//
//  Created by 刘宇 on 2021/2/22.
//

#import "WaterMarkTool.h"

@implementation WaterMarkTool

+ (UIImage *)addWatermark:(NSMutableAttributedString *)waterText toOriginImage:(UIImage *)originImage withRotationAngle:(CGFloat)rotation horizontalSpacing:(CGFloat)horizontalSpacing verticalSpacing:(CGFloat)verticalSpacing
{
    //原始image的宽高
    CGFloat viewWidth = originImage.size.width;
    CGFloat viewHeight = originImage.size.height;
    
    UIGraphicsBeginImageContextWithOptions(originImage.size, NO, 0);
    // 绘制图片
    [originImage drawInRect:CGRectMake(0, 0, viewWidth, viewHeight)];
    // 添加水印
    if (waterText.length > 0) {
        CGFloat horizontalSpace = horizontalSpacing;// 水平间隔
        CGFloat vertivalSpace = verticalSpacing; // 竖直间隔
        NSMutableAttributedString *attrStr = waterText;
        //绘制文字的宽高
        CGFloat strWidth = attrStr.size.width;
        CGFloat strHeight = attrStr.size.height;
        // 开始旋转上下文矩阵，绘制水印文字
        CGContextRef context = UIGraphicsGetCurrentContext();
        //将绘制原点（0，0）调整到源image的中心
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(viewWidth/2, viewHeight/2));
        //以绘制原点为中心旋转  (M_PI_2 / 3 ) <45>角度
        CGContextConcatCTM(context, CGAffineTransformMakeRotation(-rotation / 2));
    //将绘制原点恢复初始值，保证当前context中心和源image的中心处在一个点(当前context已经旋转，所以绘制出的任何layer都是倾斜的)
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-viewWidth/2, -viewHeight/2));
        
        // 对角线
        CGFloat sqrtLength = sqrt(viewWidth*viewWidth + viewHeight*viewHeight);
        //计算需要绘制的列数和行数
        int horCount = sqrtLength / (strWidth + horizontalSpace) + 1;
        int verCount = sqrtLength / (strHeight + vertivalSpace) + 1;
        
        //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
        CGFloat orignX = -(sqrtLength-viewWidth)/2;
        CGFloat orignY = -(sqrtLength-viewHeight)/2;
        //在每列绘制时X坐标叠加
        CGFloat tempOrignX = orignX;
        //在每行绘制时Y坐标叠加
        CGFloat tempOrignY = orignY;
        for (int i = 0; i < horCount * verCount; i++) {
//            [waterText.string drawInRect:CGRectMake(tempOrignX, tempOrignY, strWidth, strHeight) withAttributes:];
            [waterText drawInRect:CGRectMake(tempOrignX, tempOrignY, strWidth, strHeight)];
            if (i % horCount == 0 && i != 0) {
                tempOrignX = orignX;
                tempOrignY += (strHeight + vertivalSpace);
            }else{
                tempOrignX += (strWidth + horizontalSpace);
            }
        }
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)addWatermark:(NSString *)text toOriginImage:(UIImage *)onImage
{
    return [self addWatermark:({
        NSMutableAttributedString *attributedString = [NSMutableAttributedString.alloc init];
        [attributedString appendAttributedString:[NSAttributedString.alloc initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor colorWithRed:229/255.f green:240/255.f blue:255/255.f alpha:1],NSBackgroundColorAttributeName:[UIColor clearColor]}]];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle.alloc init];
        style.alignment = NSTextAlignmentCenter;
        style.maximumLineHeight = 30;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
        
        attributedString;
    }) toOriginImage:onImage withRotationAngle:M_PI_2 horizontalSpacing:50 verticalSpacing:50];
}

@end
