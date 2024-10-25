//
//  PDCameraScanView.m
//  DiErZhouKaoShi
//
//  Created by 裴铎 on 2018/7/16.
//  Copyright © 2018年 裴铎. All rights reserved.
//

#import "PDCameraScanView.h"
#import "FrameAccessor.h"

@interface PDCameraScanView(){
    CGFloat sceenHeight;
    NSTimer *timer;
    CGRect  scanRect;
    CGFloat kScreen_Width;
    CGFloat kScreen_Height;
}

@property (nonatomic,assign)CGFloat lineWidth;
@property (nonatomic,assign)CGFloat height;
@property (nonatomic,strong)UIColor  *lineColor;
@property (nonatomic, assign)CGFloat scanTime;

@property (nonatomic,   strong) UIView *lineView;
@property (nonatomic,   assign) BOOL scanLineIsUp;
@property (weak,  nonatomic) CADisplayLink *dsiplaylink;

@end

@implementation PDCameraScanView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor]; // 清空背景色，否则为黑
        sceenHeight =self.frame.size.height;
        _height =   300; // 宽高200的正方形
        _lineWidth = 2;   // 扫描框4个脚的宽度
        _lineColor =  [UIColor colorWithHex:0x4C94FF]; // 扫描框4个脚的颜色
        _scanTime = 3;      //扫描线的时间间隔设置
        
        kScreen_Width = [UIScreen mainScreen].bounds.size.width;
        kScreen_Height = [UIScreen mainScreen].bounds.size.height;
        
        [self addSubview:self.lineView];
        CADisplayLink *displayLick = [CADisplayLink displayLinkWithTarget:self selector:@selector(t_scanLineMove)];
        [displayLick addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.dsiplaylink = displayLick;
//        [self scanLineMove];
//
//        //定时，多少秒扫描线刷新一次
//        timer =  [NSTimer scheduledTimerWithTimeInterval:_scanTime target:self selector:@selector(scanLineMove) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)scanLineMove{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake((kScreen_Width-_height)/2, Height_NavBar + 38, _height, 150)];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = line.bounds;
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:118/255.0 blue:255/255.0 alpha:0.00].CGColor,(__bridge id)[UIColor colorWithRed:107/255.0 green:175/255.0 blue:255/255.0 alpha:0.31].CGColor];
    gl.locations = @[@(0),@(1.0f)];
    [line.layer addSublayer:gl];
    
//    line.backgroundColor = [UIColor colorWithHex:0x4C94FF];
    [self addSubview:line];
    [UIView animateWithDuration:_scanTime animations:^{
        line.frame = CGRectMake((self->kScreen_Width-self->_height)/2,  Height_NavBar + 38 + self->_height, self->_height, 0.5);
    } completion:^(BOOL finished) {
        [line removeFromSuperview];
    }];
    
}

- (void)t_scanLineMove
{
    if (self.lineView.bottom >= Height_NavBar + 38 + _height) {
        self.scanLineIsUp = YES; // 向上扫描
    }
    
    if (self.lineView.top <= Height_NavBar + 38) {
        self.scanLineIsUp = NO;  // 向下扫描
    }
    
    if (self.scanLineIsUp) {
        self.lineView.top -= 5;
    } else {
        self.lineView.top += 5;
    }
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [UIView.alloc initWithFrame:CGRectMake((kScreen_Width-_height)/2, Height_NavBar + 38, _height, 100)];
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = _lineView.bounds;
        gl.startPoint = CGPointMake(0.5, 0);
        gl.endPoint = CGPointMake(0.5, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.00].CGColor,(__bridge id)[UIColor colorWithHex:0x4C94FF].CGColor,(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.00].CGColor];
        gl.locations = @[@(0),@(0.5f),@(1.0f)];
        [_lineView.layer addSublayer:gl];
    }
    return _lineView;
}

-(void)drawRect:(CGRect)rect{
    CGFloat   bottomHeight = Height_NavBar + 38;//  (sceenHeight-_height)/2;
    CGFloat   leftWidth = (kScreen_Width-_height)/2;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //设置4个方向的灰度值，透明度为0.5，可自行调整。
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.5);
    CGContextFillRect(ctx, CGRectMake(0, 0, kScreen_Width, bottomHeight));
    CGContextStrokePath(ctx);
    CGContextFillRect(ctx, CGRectMake(0,bottomHeight, leftWidth, _height));
    CGContextStrokePath(ctx);
    CGContextFillRect(ctx, CGRectMake(kScreen_Width-leftWidth, bottomHeight, leftWidth, _height));
    CGContextStrokePath(ctx);
    CGContextFillRect(ctx, CGRectMake(0,bottomHeight+_height, kScreen_Width, kScreen_Height-bottomHeight-_height));
    CGContextStrokePath(ctx);
    
    //扫描框4个脚的设置
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetStrokeColorWithColor(ctx, _lineColor.CGColor);
    //左上角
    CGContextMoveToPoint(ctx, leftWidth, bottomHeight+30);
    CGContextAddLineToPoint(ctx, leftWidth, bottomHeight);
    CGContextAddLineToPoint(ctx, leftWidth+30, bottomHeight);
    CGContextStrokePath(ctx);
    //右上角
    CGContextMoveToPoint(ctx, (kScreen_Width+_height)/2-30, bottomHeight);
    CGContextAddLineToPoint(ctx, (kScreen_Width+_height)/2, bottomHeight);
    CGContextAddLineToPoint(ctx, (kScreen_Width+_height)/2, bottomHeight+30);
    CGContextStrokePath(ctx);
    //左下角
    CGContextMoveToPoint(ctx, leftWidth, bottomHeight+_height-30);
    CGContextAddLineToPoint(ctx, leftWidth,  bottomHeight+_height);
    CGContextAddLineToPoint(ctx, leftWidth+30, bottomHeight+_height);
    CGContextStrokePath(ctx);
    //右下角
    CGContextMoveToPoint(ctx, (kScreen_Width+_height)/2-30, bottomHeight+_height);
    CGContextAddLineToPoint(ctx,  (kScreen_Width+_height)/2,  bottomHeight+_height);
    CGContextAddLineToPoint(ctx,  (kScreen_Width+_height)/2, bottomHeight+_height-30);
    CGContextStrokePath(ctx);
    
    //设置扫描框4个边的颜色和线框。
    //    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    //    CGContextSet_lineWidth(ctx, 1);
    //    CGContextAddRect(ctx, CGRectMake(leftWidth, bottomHeight, height, height));
    //    CGContextStrokePath(ctx);
    scanRect = CGRectMake(leftWidth, bottomHeight, _height, _height);
}

- (void)dealloc{
    //清除计时器
    [self.dsiplaylink invalidate];
    self.dsiplaylink = nil;
    NSLog(@"-[%@ %s]", self.class, sel_getName(_cmd));
//    [timer invalidate];
//    timer = nil;
}

- (void)pause
{
    [self.dsiplaylink setPaused:YES];
}

- (void)resume
{
    [self.dsiplaylink setPaused:NO];
}

@end
