//
//  ThirdResponse.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/29.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "ThirdResponse.h"

@implementation ThirdResponse

- (NSString *)description
{
    return [NSString stringWithFormat:@"[ThirdResponse]description:\nplatform=%zd, \nopenId=%@, \nunionId=%@, \naccessToken=%@, \noriginalResponse=%@",self.platformType, self.openid, self.unionId, self.accessToken, self.originalResponse];;
}

@end
