//
//  TCheckBoxController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCheckBoxController.h"
#import "FrameAccessor.h"
#import "UIButton+Enlarge.h"

@interface TCheckBoxController ()
@property (strong,  nonatomic) NSArray *items;
@property (strong,  nonatomic) NSMutableArray<UIButton *> *checkButtons;
@end

@implementation TCheckBoxController

+ (TCheckBoxController *)alertWithTitle:(NSString *)title items:(NSArray *)items
{
    TCheckBoxController *object = [[self alloc] initWithTitle:title contentView:[UIView.alloc init] items:items];
    return object;
}

- (instancetype)initWithTitle:(NSString *)title contentView:(UIView *)contentView items:(NSArray *)items
{
    self = [super initWithTitle:title contentView:contentView];
    if (self) {
        self.index = -1;
        self.items = items;
        self.checkButtons = [NSMutableArray arrayWithCapacity:items.count];
        
        UIView *contentView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 276, items.count*20+(items.count-1)*10)];
        self.contentView = contentView;
        
        CGFloat leftPading = 0;
        NSString *maxStr = @"";
        
        for (NSString *str in items) {
            if (str.length > maxStr.length) {
                maxStr = str;
            }
        }
        
        leftPading = (self.contentView.width - [maxStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 22) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.width - 20 - 3) * 0.5;
        
        for (int i = 0; i < items.count; i++) {
            
            UIButton *cBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cBtn.bounds = CGRectMake(0, 0, 15, 15);
            [cBtn setImage:[UIImage imageNamed:@"check_normal"] forState:UIControlStateNormal];
            [cBtn setImage:[UIImage imageNamed:@"check_selected"] forState:UIControlStateSelected];
            cBtn.tag = 1000+i;
            [cBtn setEnlargeEdgeWithTop:20 right:20 bottom:20 left:20];
            [cBtn addTarget:self action:@selector(checkbtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:cBtn];
            [self.checkButtons addObject:cBtn];
            
            
            UILabel *label = [UILabel.alloc initWithFrame:CGRectZero];
            label.text = items[i];
            label.textColor = [UIColor colorWithHex:0x666666];
            label.font = [UIFont systemFontOfSize:15];
            [label sizeToFit];
            [self.contentView addSubview:label];
            
            cBtn.left = leftPading;
            cBtn.top = (20+10)*i;
            label.left = cBtn.right + 3;
            label.centerY = cBtn.centerY;
        }
        
    }
    return self;
}

- (void)checkbtnDidClicked:(UIButton *)sender
{
    if (self.index == sender.tag - 1000) {
        // 取消
        sender.selected = NO;
        self.index = -1;
        self.t_selected = NO;
    } else {
        if (self.index != -1) {
            self.checkButtons[self.index].selected = NO;
        }
        sender.selected = YES;
        self.index = sender.tag - 1000;
        self.t_selected = YES;
    }
}

@end
