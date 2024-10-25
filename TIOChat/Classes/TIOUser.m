//
//  TIOUser.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOUser.h"
#import "NSString+tio.h"
#import "NSObject+CBJSONSerialization.h"


@interface TIOUser ()
@property (nonatomic, assign) NSInteger uid;
@end

@implementation TIOUser

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"friendId" : @"id",
    };
}

- (NSString *)avatar
{
    return _avatar.tio_resourceURLString;
}

- (NSString *)userId
{
    if (!_userId) {
        if (self.uid!=0) {
            _userId = [NSString stringWithFormat:@"%zd",_uid];
        } else {
            if (self.friendId!=0) {
                _userId = [NSString stringWithFormat:@"%zd",self.friendId];
            } else {
                _userId = @"";
            }
        }
    }
    return _userId;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self modelCopy];
}

@end
