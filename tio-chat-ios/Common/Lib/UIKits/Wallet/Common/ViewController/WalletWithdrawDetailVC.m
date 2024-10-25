//
//  WalletWithdrawDetailVC.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletWithdrawDetailVC.h"
#import "FrameAccessor.h"
#import "UIImageView+Web.h"

#import "WalletManager.h"

@interface WalletWithdrawDetailVC ()

@end

@implementation WalletWithdrawDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI
{
    NSString *cardNo = @"卡号未知";
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        cardNo = [self.model.bankcardnumber substringFromIndex:self.model.bankcardnumber.length-4];
    } else if (WalletManager.shareInstance.vendor == WalletVendorNewPay) {
        cardNo = [self.model.cardno substringFromIndex:self.model.cardno.length-4];
    }
    
    UIImageView *logoView  = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 44, 44)];
    logoView.image = [UIImage imageNamed:@"w_withdraw_logo"];
    logoView.centerX = self.view.middleX;
    logoView.top = Height_NavBar + 30;
    [self.view addSubview:logoView];
    
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectMake(20, logoView.bottom+10, self.view.width-40, 22)];
    titleLabel.text = [NSString stringWithFormat:@"提现到-%@(%@)",self.model.bankname,cardNo];
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    UILabel *amountLabel = [UILabel.alloc initWithFrame:CGRectMake(20, titleLabel.bottom+10, self.view.width-40, 47)];
    amountLabel.text = [NSString stringWithFormat:@"%.2f",self.model.amount/100.f];
    amountLabel.textColor = [UIColor colorWithHex:0x333333];
    amountLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:38];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:amountLabel];
    
    
    // 处理进度
    NSArray *texts = nil;
    NSArray *images = nil; // w_progress_3已完成  w_progress_1当前完成 w_progress_2未完成
    NSArray *textColors = nil;
    NSArray *lineColors = nil;
    
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        if ([self.model.status isEqualToString:@"SUCCESS"]) {
            // 成功
            texts = @[@"提现申请",@"银行处理中",@"提现成功"];
            images = @[@"w_progress_3",@"w_progress_3",@"w_progress_1"];
            textColors = @[[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x333333]];
            lineColors = @[[UIColor colorWithHex:0xAFCFFF],[UIColor colorWithHex:0xAFCFFF]];
        } else if ([self.model.status isEqualToString:@"PROCESS"]) {
            // 处理中
            texts = @[@"提现申请",@"银行处理中",@"提现成功"];
            images = @[@"w_progress_3",@"w_progress_1",@"w_progress_2"];
            textColors = @[[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x333333],[UIColor colorWithHex:0x888888]];
            lineColors = @[[UIColor colorWithHex:0xAFCFFF],[UIColor colorWithHex:0xF1F1F1]];
        } else {
            // 失败
            texts = @[@"提现申请",@"银行处理中",@"提现失败"];
            images = @[@"w_progress_3",@"w_progress_3",@"w_progress_error"];
            textColors = @[[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x333333]];
            lineColors = @[[UIColor colorWithHex:0xAFCFFF],[UIColor colorWithHex:0xAFCFFF]];
        }
    } else {
        if ([self.model.status isEqualToString:@"1"]) {
            // 成功
            texts = @[@"提现申请",@"银行处理中",@"提现成功"];
            images = @[@"w_progress_3",@"w_progress_3",@"w_progress_1"];
            textColors = @[[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x333333]];
            lineColors = @[[UIColor colorWithHex:0xAFCFFF],[UIColor colorWithHex:0xAFCFFF]];
        } else if ([self.model.status isEqualToString:@"2"]) {
            // 处理中
            texts = @[@"提现申请",@"银行处理中",@"提现成功"];
            images = @[@"w_progress_3",@"w_progress_1",@"w_progress_2"];
            textColors = @[[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x333333],[UIColor colorWithHex:0x888888]];
            lineColors = @[[UIColor colorWithHex:0xAFCFFF],[UIColor colorWithHex:0xF1F1F1]];
        } else {
            // 失败
            texts = @[@"提现申请",@"银行处理中",@"提现失败"];
            images = @[@"w_progress_3",@"w_progress_3",@"w_progress_error"];
            textColors = @[[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x888888],[UIColor colorWithHex:0x333333]];
            lineColors = @[[UIColor colorWithHex:0xAFCFFF],[UIColor colorWithHex:0xAFCFFF]];
        }
    }
    
    CGFloat iconLeftPadding = (self.view.width-66)/4.f;
    
    for (int i = 0; i < 3; i++) {
        UIImageView *img1 = [UIImageView.alloc initWithImage:[UIImage imageNamed:images[i]]];
        img1.bounds = CGRectMake(0, 0, 22, 22);
        img1.top = Height_NavBar + 190;
        img1.left = iconLeftPadding + (22+iconLeftPadding)*i;
        [self.view addSubview:img1];
        
        if (i != 2) {
            UIView *line = [UIView.alloc initWithFrame:CGRectMake(0, 0, iconLeftPadding-8, 1)];
            line.centerY = img1.centerY;
            line.left = img1.right + 4;
            line.backgroundColor = lineColors[i];
            [self.view addSubview:line];
        }
        
        UILabel *label = [UILabel.alloc init];
        label.text = texts[i];
        label.textColor = textColors[i];
        label.font = [UIFont systemFontOfSize:16];
        [label sizeToFit];
        label.top = img1.bottom+10;
        label.centerX = img1.centerX;
        [self.view addSubview:label];
    }
    
    UIView *lineView = [UIView.alloc initWithFrame:CGRectMake(15,Height_NavBar + 274, self.view.width-30, 1)];
    [lineView.layer addSublayer:({
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setBounds:lineView.bounds];
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
        [shapeLayer setFillColor:[UIColor clearColor].CGColor];
              //  设置虚线颜色为blackColor
        [shapeLayer setStrokeColor:[UIColor colorWithHex:0xE8E8E8].CGColor];
              //  设置虚线宽度
        [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
        [shapeLayer setLineJoin:kCALineJoinRound];
              //  设置线宽，线间距
        [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:2], nil]];
              //  设置路径
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, 0);
        CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
        [shapeLayer setPath:path];
        CGPathRelease(path);
        
        shapeLayer;
    })];
    [self.view addSubview:lineView];
    
    NSString *amount = [NSString stringWithFormat:@"¥%.2f",self.model.amount/100.f];
    NSString *serverFee = [NSString stringWithFormat:@"¥%.2f",(self.model.amount-self.model.arrivalamount)/100.f];
    NSString *ordernumber = @"";
    if (WalletManager.shareInstance.vendor == WalletVendorYiPay) {
        ordernumber = self.model.serialnumber?:@"";
    } else {
        ordernumber = self.model.reqid?:@"";
    }
    NSString *bank = [NSString stringWithFormat:@"%@(%@)",self.model.bankname,cardNo];
    
    NSString *createtime = self.model.bizcreattime?:@"";
    NSString *completetime = self.model.bizcompletetime?:@"";
    
    NSArray *names = @[@"提现金额",@"手续费",@"单号",@"到账银行",@"提交时间",@"到账时间"];
    NSArray *values = @[amount, serverFee, ordernumber, bank, createtime, completetime];
    
    for (int i = 0; i < names.count; i++) {
        UILabel *nameLabel = [self customLabel:names[i]];
        nameLabel.left = 20;
        nameLabel.top = lineView.bottom+30 + (nameLabel.height + 15) * i;
        [self.view addSubview:nameLabel];
        
        UILabel *valueLabel = nil;
        
        if (i == 0) {
            valueLabel = [self valueLabel2:values[i]];
        } else {
            valueLabel = [self customLabel:values[i]];
        }

        valueLabel.right = self.view.width - 20;
        valueLabel.centerY = nameLabel.centerY;
        [self.view addSubview:valueLabel];
        
        if (i == 3) {
            UIImageView *icon = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, 23, 23)];
            [icon tio_imageUrl:self.model.bankicon placeHolderImageName:@"" radius:0];
            icon.right = valueLabel.left-1;
            icon.centerY = valueLabel.centerY;
            [self.view addSubview:icon];
        }
    }
}

- (UILabel *)customLabel:(NSString *)title
{
    UILabel *label = [UILabel.alloc init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHex:0x666666];
    [label sizeToFit];
    
    return label;
}

- (UILabel *)valueLabel1:(NSString *)text
{
    UILabel *label = [UILabel.alloc init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHex:0x333333];
    [label sizeToFit];
    
    return label;
}

- (UILabel *)valueLabel2:(NSString *)text
{
    UILabel *label = [UILabel.alloc init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    label.textColor = [UIColor colorWithHex:0x333333];
    [label sizeToFit];
    
    return label;
}

@end
