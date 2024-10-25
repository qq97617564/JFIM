//
//  IMInputAtObject.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/22.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define InputAtStartChar @"@"
#define InputAtEndChar   @"\u2004"

@interface IMInputAtObject : NSObject

/// at的用户ID
@property (nonatomic,   copy) NSString *uid;

/// at的用户昵称
@property (nonatomic,   copy) NSString *nick;

/// [NIMInputAtStartChar, NIMInputAtEndChar] 所在的范围
@property (nonatomic,   assign) NSRange range;

@end

NS_ASSUME_NONNULL_END
