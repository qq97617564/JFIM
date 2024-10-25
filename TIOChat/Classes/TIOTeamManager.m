//
//  TIOChatTeamManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/18.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOTeamManager.h"
#import "TIOBroadcastDelegate.h"
#import "NSString+tio.h"
#import "TIOMacros.h"
#import "TIOHTTPSManager.h"
#import "TIOTeam.h"
#import "TIOUser.h"
#import "TIOTeamMember.h"
#import "NSObject+CBJSONSerialization.h"
#import "TIOSystemNotification.h"
#import "TIOMacros.h"
#import "TIOCmdConfiguator.h"
#import "TIOChat.h"
#import "TIOSocketPackage.h"

@implementation TIOTeamName

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allowServerToUpdateAutomatically = YES;
    }
    return self;
}

@end


@interface TIOTeamManager()
@property (nonatomic, strong) TIOBroadcastDelegate<TIOTeamDelegate> *multiDelegate;
@end

@implementation TIOTeamManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIOTeamDelegate> *)[TIOBroadcastDelegate.alloc init];
    }
    return self;
}

- (void)createTeamName:(NSString *)name introduction:(NSString *)intro users:(NSArray<NSString *> *)userIds completion:(TIOCreateTeamHandler)completion
{
    NSMutableString *uids = [NSMutableString.alloc init];
    [userIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == userIds.count-1) {
            [uids appendFormat:@"%@",obj];
        } else {
            [uids appendFormat:@"%@,",obj];
        }
    }];

    NSDictionary *params = nil;
    
    if (name) {
        params = @{
            @"name" : name,
            @"intro" : intro,
            @"uidList" : uids,
        };
    } else {
        params = @{
            @"intro" : intro,
            @"uidList" : uids,
        };
    }
    
    
    [TIOHTTPSManager tio_POST:@"/chat/createGroup" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *teamId = responseObject[@"data"][@"id"];
        completion(nil, teamId);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error, nil);
    }];
}

- (void)addUser:(NSArray<NSString *> *)userIds toTeam:(NSString *)teamId sharerUid:(NSString *)sharerUid completion:(TIOTeamError)completion
{
    NSMutableString *uids = [NSMutableString.alloc init];
    [userIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uids appendFormat:@"%@,",obj];
    }];
    [uids deleteCharactersInRange:NSMakeRange(uids.length-1, 1)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uids"] = uids;
    params[@"groupid"] = teamId;
    
    if (sharerUid) {
        params[@"applyuid"] = sharerUid;
    }
    
    [TIOHTTPSManager tio_POST:@"/chat/joinGroup" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)applyToAddUsers:(NSArray *)userIds toTeam:(NSString *)teamId msg:(NSString *)msg completion:(TIOTeamError)completion
{
    NSMutableString *uids = [NSMutableString.alloc init];
    [userIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uids appendFormat:@"%@,",obj];
    }];
    [uids deleteCharactersInRange:NSMakeRange(uids.length-1, 1)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uids"] = uids;
    params[@"groupid"] = teamId;
    
    if (msg) {
        params[@"applymsg"] = msg;
    }
    
    [TIOHTTPSManager tio_POST:@"/chat/joinGroupApply" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)removeUser:(NSArray<NSString *> *)userIds fromTeam:(NSString *)teamId completion:(TIOTeamError)completion
{
    NSMutableString *uids = [NSMutableString.alloc init];
    [userIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uids appendFormat:@"%@,",obj];
    }];
    
    NSDictionary *params = @{
        @"uids" : uids,
        @"groupid" : teamId
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/kickGroup" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)fetchTeamInfoWithTeamId:(NSString *)groupId completion:(TIOTeamInfoHandler)completion
{
    if (!groupId) {
        return;
    }
    
    NSDictionary *params = @{
        @"userflag" : @"1",
        @"groupid" : groupId
    };
    
    [TIOHTTPSManager tio_GET:@"/chat/group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOTeam *team = [TIOTeam objectWithJSONObject:responseObject[@"data"][@"group"]];
        TIOTeamMember *teamUser = [TIOTeamMember objectWithJSONObject:responseObject[@"data"][@"groupuser"]];
        completion(team, teamUser, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, nil, error);
    }];
}

- (void)fetchUserInfoInTeam:(NSString *)teamId completion:(nonnull TIOTeamUserHandler)completion
{
    NSDictionary *params = @{
        @"userflag" : @"1",
        @"groupid" : teamId
    };
    
    [TIOHTTPSManager tio_GET:@"/chat/group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOTeamMember *team = [TIOTeamMember objectWithJSONObject:responseObject[@"data"][@"groupuser"]];
        completion(team, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, error);
    }];
}

- (void)searchMember:(NSString *)key inTeam:(NSString *)teamId completion:(TIOUsersNotInTeamHandler)completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (key) {
        params[@"searchkey"] = key;
    }
    params[@"groupid"] = teamId;
    
    [TIOHTTPSManager tio_POST:@"/chat/atGroupUserList" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [TIOTeamMember objectArrayWithJSONArray:responseObject[@"data"]];
        completion(array, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, error);
    }];
}

- (void)searchFriends:(NSString *)searchKey notInTeam:(NSString *)teamId completion:(TIOUsersNotInTeamHandler)completion
{
    NSDictionary *params = @{
        @"searchkey" : searchKey,
        @"groupid" : teamId
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/applyGroupFdList" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [TIOUser objectArrayWithJSONArray:responseObject[@"data"]];
        completion(array, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, error);
    }];
}

- (void)fetchMembersInTeam:(NSString *)teamId searchKey:(NSString * _Nullable)key pageNumber:(NSInteger)pageNumber completion:(nonnull TIOTeamUsersHandler)completion
{
    NSDictionary *params = nil;
    if (key) {
        params = @{
            @"groupid" : teamId,
            @"pageNumber" : @(pageNumber),
            @"searchkey" : key
        };
    } else {
        params = @{
            @"groupid" : teamId,
            @"pageNumber" : @(pageNumber)
        };
    }
    
    [TIOHTTPSManager tio_GET:@"/chat/groupUserList" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [TIOTeamMember objectArrayWithJSONArray:responseObject[@"data"][@"list"]];
        BOOL first = [responseObject[@"data"][@"firstPage"] boolValue];
        BOOL last = [responseObject[@"data"][@"lastPage"] boolValue];
        NSInteger total = [responseObject[@"data"][@"totalRow"] integerValue];
        completion(array,first,last, total, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil,NO,NO,-1, error);
    }];
}

- (void)searchMyTeamsWithKey:(NSString *)key completion:(TIOTeamsHandler)completion
{
    if ([NSString isEmpty:key]) {
        
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"搜索群聊的关键字不能为空"}];
        
        completion(nil, error);
        
        return;
    }

    
    NSDictionary *params = @{
        @"searchkey" : key?:@"",
        @"mode" : @"2"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/mailList" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSArray *array = [TIOTeam objectArrayWithJSONArray:responseObject[@"data"][@"group"]];
        completion(array, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, error);
    }];
}

- (void)fetchAllMembersInTeam:(NSString *)teamId completion:(TIOTeamUsersHandler)completion
{
    
}

- (void)checkTeam:(NSString *)teamId canSendCardWithCompletion:(TIOTeamError)completion
{
    // checkAddFriend
    // checkSendCard
    [TIOHTTPSManager tio_POST:@"/chat/checkSendCard" parameters:@{@"groupid" : teamId?:@""} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)checkTeamShareCard:(NSString *)teamId fromUser:(NSString *)fromUserId completion:(TIOCheckCardJoinToTeamError)completion
{
    NSDictionary *params = @{
        @"groupid" : teamId?:@"",
        @"applyuid" : fromUserId?:@""
    };
    [TIOHTTPSManager tio_POST:@"/chat/checkCardJoinGroup" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger status = [responseObject[@"data"] integerValue];
        completion(nil, status);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error, 0);
    }];
}

- (void)shareTeam:(NSString *)teamId toUids:(NSArray<NSString *> *)uids toTeamIds:(NSArray<NSString *> *)teamIds completion:(TIOTeamError)completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (uids) {
        NSMutableString *uidsString = [NSMutableString.alloc init];
        [uids enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == uids.count-1) {
                [uidsString appendFormat:@"%@",obj];
            } else {
                [uidsString appendFormat:@"%@,",obj];
            }
        }];
        
        params[@"uids"] = uidsString;
    }
    
    if (teamIds) {
        NSMutableString *uidsString = [NSMutableString.alloc init];
        [teamIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == teamIds.count-1) {
                [uidsString appendFormat:@"%@",obj];
            } else {
                [uidsString appendFormat:@"%@,",obj];
            }
        }];
        
        params[@"groupids"] = uidsString;
    }
    
    params[@"chatmode"] = @"2";
    params[@"cardid"] = teamId;
    
    [TIOHTTPSManager tio_POST:@"/chat/shareCard" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)checkMember:(NSString *)memberId isInTeam:(NSString *)teamId completion:(TIOCheckMemberHandler)completion
{
    NSDictionary *params = @{
        @"groupid" : teamId,
        @"uid" : memberId
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/checkGroupUser" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BOOL flag = [responseObject[@"data"] integerValue] == 1;
        completion(nil, flag);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error,NO);
    }];
}

- (void)updateUserNick:(NSString *)newNick inTeam:(nonnull NSString *)teamId completion:(nonnull TIOTeamError)completion
{
    // TODO: 修改用户的群昵称
    NSDictionary *params = @{
        @"groupid" : teamId,
        @"nick" : newNick
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/modifyGroupNick" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updateTeamName:(NSString *)newNick inTeam:(NSString *)teamId completion:(TIOTeamError)completion
{
    // TODO: 修改群名
    NSDictionary *params = @{
        @"groupid" : teamId,
        @"name" : newNick
    };
    
    [TIOHTTPSManager tio_POST:@"/group/modifyName" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updateTeamIntro:(NSString *)newIntro inTeam:(NSString *)teamId completion:(TIOTeamError)completion
{
    // TODO: 修改群简介(老接口)
    
    if (!newIntro.length || !teamId.length) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:3000 userInfo:@{NSLocalizedDescriptionKey:@"群ID或简介内容为空"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"intro" : newIntro,
        @"groupid" : teamId
    };
    [TIOHTTPSManager tio_POST:@"/group/modifyIntro" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updateTeamNotice:(NSString *)newNotice inTeam:(NSString *)teamId completion:(TIOTeamError)completion
{
    // TODO: 修改群公告(老接口)
    
    if (!newNotice.length || !teamId.length) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:3000 userInfo:@{NSLocalizedDescriptionKey:@"群ID或简介内容为空"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"notice" : newNotice,
        @"groupid" : teamId
    };
    [TIOHTTPSManager tio_POST:@"/group/modifyNotice" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)exitFromTeam:(NSString *)teamId completion:(TIOTeamError)completion
{
    NSString *uid = [TIOChat.shareSDK.loginManager userInfo].userId;
    if (!teamId.length) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:3000 userInfo:@{NSLocalizedDescriptionKey:@"群ID为空"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"uid" : uid,
        @"groupid" : teamId
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/leaveGroup" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)deleteTeam:(NSString *)teamId completion:(TIOTeamError)completion
{
    NSString *uid = [TIOChat.shareSDK.loginManager userInfo].userId;
    if (!teamId.length) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:3000 userInfo:@{NSLocalizedDescriptionKey:@"群ID为空"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"uid" : uid,
        @"groupid" : teamId
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/delGroup" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)transferTeam:(NSString *)teamId toUser:(NSString *)uid completion:(TIOTeamError)completion
{
    if (!teamId.length) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:3000 userInfo:@{NSLocalizedDescriptionKey:@"群ID为空"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"otheruid" : uid,
        @"groupid" : teamId
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/changeOwner" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updateJoiningPermissionForTeam:(NSString *)teamId isAllowJoin:(BOOL)allow completion:(TIOTeamError)completion
{
    NSDictionary *params = @{
        @"groupid" : teamId,
        @"mode" : allow?@"1":@"2"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/modifyApply" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updateReviewingPermissionForTeam:(NSString *)teamId isReview:(BOOL)isReview completion:(TIOTeamError)completion
{
    NSDictionary *params = @{
        @"groupid" : teamId,
        @"mode" : isReview?@"1":@"2"
    };
    
    [TIOHTTPSManager tio_POST:@"/group/modifyReview" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)fetchAllTeams:(TIOTeamsHandler)completion
{
    NSDictionary *params = @{
        @"mode" : @"2"
    };
    
    [TIOHTTPSManager tio_GET:@"/chat/mailList" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [TIOTeam objectArrayWithJSONArray:responseObject[@"data"][@"group"]];
        completion(array, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, error);
    }];
}

- (void)changeMemberRole:(TIOTeamUserRole)role uid:(NSString *)uid inTeam:(NSString *)teamid completion:(TIOTeamError)completion
{
    NSDictionary *params = @{
        @"uid" : uid?:@"",
        @"groupid" : teamid?:@"",
        @"grouprole" : @(role)
    };
    
    [TIOHTTPSManager tio_GET:@"/group/manager" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)fetchApplyInfoForInviting:(NSString *)applyId completion:(nonnull void (^)(TIOInvitationApply * _Nullable, NSArray<TIOUser *> * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"aid" : applyId?:@""
    };
    [TIOHTTPSManager tio_POST:@"/chat/groupApplyInfo" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOInvitationApply *apply = [TIOInvitationApply objectWithJSONObject:responseObject[@"data"][@"apply"]];
        NSArray *users = [TIOUser objectArrayWithJSONArray:responseObject[@"data"][@"items"]];
        completion(apply, users, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, nil, error);
    }];
}

- (void)dealApplyForInviting:(NSString *)applyId messageId:(NSString *)mid completion:(TIOTeamError)completion
{
    NSDictionary *params = @{
        @"aid" : applyId?:@"",
        @"mid" : mid?:@""
    };
    [TIOHTTPSManager tio_POST:@"/chat/dealGroupApply" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)updateAddingFriendPermissionInTeam:(NSString *)teamId flag:(NSInteger)flag completion:(TIOTeamError)completion
{
    NSDictionary *params = @{
        @"groupid" : teamId,
        @"friendflag" : @(flag)
    };
    [TIOHTTPSManager tio_POST:@"/group/modifyFriendFlag" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)forbiddenSpeakInTeam:(NSString *)teamid oper:(NSInteger)oper mode:(NSInteger)mode duration:(NSInteger)duration uid:(NSString *)uid completion:(TIOTeamError)completion
{
    if (!teamid || teamid.length == 0) {
        completion([NSError errorWithDomain:TIOChatErrorDomain code:3000 userInfo:@{NSLocalizedDescriptionKey:@"群ID为空"}]);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mode"] = @(mode);
    params[@"oper"] = @(oper);
    params[@"groupid"] = teamid;
    if (mode == 1 || mode == 3) {
        params[@"uid"] = uid?:@"";
        params[@"duration"] = @(duration);
    }
    
    [TIOHTTPSManager tio_POST:@"/chat/forbidden" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)fetchForbiddenUserListInTeamId:(NSString *)teamid searchKey:(NSString *)key pageNumber:(NSInteger)pageNumber completion:(TIOTeamUsersHandler)completion
{
    NSDictionary *params = nil;
    if (key) {
        params = @{
            @"groupid" : teamid,
            @"pageNumber" : @(pageNumber),
            @"searchkey" : key
        };
    } else {
        params = @{
            @"groupid" : teamid,
            @"pageNumber" : @(pageNumber)
        };
    }
    
    [TIOHTTPSManager tio_GET:@"/chat/forbiddenUserList" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [TIOTeamMember objectArrayWithJSONArray:responseObject[@"data"][@"list"]];
        BOOL first = [responseObject[@"data"][@"firstPage"] boolValue];
        BOOL last = [responseObject[@"data"][@"lastPage"] boolValue];
        NSInteger total = [responseObject[@"data"][@"totalRow"] integerValue];
        completion(array,first,last, total, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil,NO,NO, -1, error);
    }];
}

- (void)checkStatusForUser:(NSString *)uid inTeam:(NSString *)teamid completion:(nonnull void (^)(NSError * _Nullable, NSDictionary * _Nullable))completion
{
    if (uid.length == 0 || teamid == 0) {
        completion([NSError errorWithDomain:TIOChatErrorDomain code:3000 userInfo:@{NSLocalizedDescriptionKey:@"群ID或uid为空"}], nil);
        return;
    }
    
    NSDictionary *params = @{
        @"uid" : uid,
        @"groupid" : teamid
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/forbiddenFlag" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil, responseObject[@"data"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error, nil);
    }];
}

- (void)addDelegate:(id<TIOTeamDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOTeamDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)handler:(TIOSocketPackage *)data
{
    if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdGroupOperNtf]) {
        TIOSystemNotification *model = [TIOSystemNotification objectWithJSONObject:data.body];
        model.resp = @{
            @"cmd" : @(data.cmd),
            @"body" : data.body
        };
        
        if (model.oper == 1) {
            // 解散群
            TIOTeam *team = [TIOTeam.alloc init];
            team.teamId = model.g;
            [self.multiDelegate didDeleteTeam:team];
        } else if (model.oper == 5) {
            // 退群
            TIOTeam *team = [TIOTeam.alloc init];
            team.teamId = model.g;
            [self.multiDelegate didExitFromTeam:team];
        } else if (model.oper == 2) {
            // 转让
            TIOTeam *team = [TIOTeam.alloc init];
            team.teamId = model.g;
            [self.multiDelegate didTransferedTeam:team];
        } else if (model.oper == 6) {
            // 被踢出去群
            [self.multiDelegate didKickedOut:model];
        } else if (model.oper == 7) {
            // 重新加入群聊
            [self.multiDelegate didRejoin:model];
        } else if (model.oper == 4) {
            // 群成员数量发生变更
            [self.multiDelegate didUpdateMemebersCount:model.bizdata.integerValue];
            [self fetchTeamInfoWithTeamId:model.g completion:^(TIOTeam * _Nullable team, TIOTeamMember * _Nullable teamUser, NSError * _Nullable error) {
                [self.multiDelegate didUpdateTeamInfo:team];
            }];
        } else if (model.oper == 21 || model.oper == 20) {
            // 群名变更
            
            [self fetchTeamInfoWithTeamId:model.g completion:^(TIOTeam * _Nullable team, TIOTeamMember * _Nullable teamUser, NSError * _Nullable error) {
                [self.multiDelegate didUpdateTeamInfo:team];
            }];
            
        } else if (model.oper == 11) {
            // 更新群角色
            [self fetchTeamInfoWithTeamId:model.g completion:^(TIOTeam * _Nullable team, TIOTeamMember * _Nullable teamUser, NSError * _Nullable error) {
                if (team) {
                    team.grouprole = [model.chatItems[@"bizrole"] integerValue];
                    [self.multiDelegate didUpdateTeamInfo:team];
                }
            }];
        }
    }
}

@end
