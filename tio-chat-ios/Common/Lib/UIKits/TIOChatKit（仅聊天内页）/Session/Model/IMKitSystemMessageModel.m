//
//  IMKitSystemMessageModel.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitSystemMessageModel.h"

@interface IMKitSystemMessageModel ()
@end

@implementation IMKitSystemMessageModel

- (CGSize)contentSize
{
    if (CGSizeEqualToSize(_contentSize, CGSizeZero))
    {
        _contentSize = [self.msg?:@"未知的系统消息" boundingRectWithSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width*0.7, 100) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    }
    return _contentSize;
}

- (CGFloat)height
{
    return self.contentSize.height + 40;
}

@end
