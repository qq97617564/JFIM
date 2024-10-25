//
//  TIOWxCallItemReply.h
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOWxCallItem.h"
#import "TIODefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOWxCallItemReply : TIOWxCallItem

@property (copy,    nonatomic) NSString *reason;
@property (assign,  nonatomic) TIORTCReplyResult result;

@end

NS_ASSUME_NONNULL_END
