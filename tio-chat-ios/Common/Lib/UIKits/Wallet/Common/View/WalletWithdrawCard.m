//
//  WalletWithdrawCard.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWithdrawCard.h"

@implementation WalletWithdrawCard

- (void)drawRect:(CGRect)rect
{
    NSString *imageName = self.reverse?@"w_detail_card":@"w_withdraw_card";
    UIImage *image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 0, 24) resizingMode:UIImageResizingModeStretch];
    [image drawInRect:rect];
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    // 设置线条的样式
    CGContextSetLineCap(context, kCGLineCapRound);
    // 绘制线的宽度
    CGContextSetLineWidth(context, 1.0);
    // 线的颜色
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHex:0xE8E8E8].CGColor);
    // 开始绘制
    CGContextBeginPath(context);
    // 设置虚线绘制起点
    CGFloat y = self.reverse?122.0:230.0;
    CGContextMoveToPoint(context, 24.0, y);
    // lengths的值｛10,10｝表示先绘制10个点，再跳过10个点，如此反复
    CGFloat lengths[] = {2,2};
    // 虚线的起始点
    CGContextSetLineDash(context, 0, lengths,2);
    // 绘制虚线的终点
    CGContextAddLineToPoint(context, CGRectGetWidth(rect)-24,y);
    // 绘制
    CGContextStrokePath(context);
    // 关闭图像
    CGContextClosePath(context);
}

@end
