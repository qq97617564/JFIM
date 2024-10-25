//
//  TIOTeam.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/25.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOTeam.h"
#import "NSObject+CBJSONSerialization.h"
#import "NSString+tio.h"

@interface TIOTeam ()
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger groupid;
@property (nonatomic, assign) NSInteger membercount;// 获取群组信息时服务器返回的群成员数量字段
@property (nonatomic, assign) NSInteger joinnum;// 获取群列表和查询群列表时服务器返回的群成员数量字段
@property (nonatomic, assign) NSInteger applyflag;
@end

@implementation TIOTeam

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"teamId" : @"id",
        @"joinType" : @"joinmode",
    };
}

- (NSString *)teamId
{
    if (!_teamId) {
        _teamId = [NSString stringWithFormat:@"%zd",self.groupid];
    }
    return _teamId;
}

- (NSInteger)memberNumber
{
    if (!_memberNumber) {
        if (_membercount) {
            _memberNumber = _membercount;
        }
        
        if (_joinnum) {
            _memberNumber = _joinnum;
        }
    }
    
    return _memberNumber;
}

- (NSString *)managerId
{
    if (!_managerId) {
        _managerId = [NSString stringWithFormat:@"%zd",self.uid];
    }
    return _managerId;
}

- (NSString *)avatar
{
    return _avatar.tio_resourceURLString;
}

- (BOOL)applyFlag
{
    return _applyflag==1;
}

@end
