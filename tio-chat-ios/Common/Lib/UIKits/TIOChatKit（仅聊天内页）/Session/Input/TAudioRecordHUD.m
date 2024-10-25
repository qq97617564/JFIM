//
//  TRecordHUD.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TAudioRecordHUD.h"
#import <YYWebImage.h>

@interface TAudioRecordHUD ()
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *timerLabel;

@property (strong, nonatomic) YYAnimatedImageView *recordingBg;
@property (strong, nonatomic) UIImageView *cancelingBg;



@end

@implementation TAudioRecordHUD

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 120, 120)];
    
    if (self) {
        self.layer.cornerRadius = 4.f;
        self.clipsToBounds = YES;
        
        UIView *line = [UIView.alloc initWithFrame:CGRectMake(7, 90, CGRectGetWidth(self.frame)-14, 1)];
        line.backgroundColor = UIColor.whiteColor;
        [self addSubview:line];
        
        self.textLabel = [UILabel.alloc initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(line.frame))];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:12];
        self.textLabel.textColor = UIColor.whiteColor;
        [self addSubview:self.textLabel];
        
        self.timerLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 8, CGRectGetWidth(self.frame), 17)];
        self.timerLabel.font = [UIFont systemFontOfSize:12];
        self.timerLabel.textColor = UIColor.whiteColor;
        self.timerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timerLabel];
        
        YYAnimatedImageView *recordingBg = [YYAnimatedImageView.alloc initWithFrame:CGRectMake(0, 0, 120, 48)];
        recordingBg.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-5);
        [self addSubview:recordingBg];
        self.recordingBg = recordingBg;
        
        UIImageView *cancelingBg = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 120, 90)];
        cancelingBg.hidden = YES;
        cancelingBg.image = [UIImage imageNamed:@"cancel_recording"];
        [cancelingBg sizeToFit];
        cancelingBg.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-10);
        [self addSubview:cancelingBg];
        self.cancelingBg = cancelingBg;
    }
    
    return self;
}

- (void)setStatus:(TAudioRecordStatus)status
{
    switch (status) {
        case AudioRecordStatusRecording:
        {
            [self recordingUI];
        }
            break;
        case AudioRecordStatusCancelling:
        {
            [self cancelingUI];
        }
            break;
            
        default:
            break;
    }
}

- (void)setRecordTime:(NSTimeInterval)recordTime
{
    NSInteger minutes = (NSInteger)recordTime / 60;
    NSInteger seconds = (NSInteger)recordTime % 60;
    self.timerLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", minutes, seconds];
}

- (void)recordingUI
{
    self.timerLabel.hidden = NO;
    self.recordingBg.hidden = NO;
    self.cancelingBg.hidden = YES;
    self.backgroundColor = [[UIColor colorWithHex:0x8997AB] colorWithAlphaComponent:0.86];
    self.textLabel.text = @"上滑取消发送";
    
    YYImage *animateImage = [YYImage imageNamed:[self recordingGIF]];
    self.recordingBg.image = animateImage;
}

- (void)cancelingUI
{
    self.timerLabel.hidden = YES;
    self.recordingBg.hidden = YES;
    self.cancelingBg.hidden = NO;
    self.backgroundColor = [[UIColor colorWithHex:0xEF4545] colorWithAlphaComponent:0.86];
    self.textLabel.text = @"松开取消发送";
}

- (NSString *)recordingGIF
{
    NSInteger scale = [UIScreen.mainScreen scale];
    
    NSString *name = [NSString stringWithFormat:@"Voice_input_0%zd.gif",scale];
    
    return name;
}

@end
