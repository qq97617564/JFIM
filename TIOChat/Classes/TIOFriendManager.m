//
//  TIOFriendManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOFriendManager.h"
#import "TIOHTTPSManager.h"
#import "TIOBroadcastDelegate.h"
#import "TIOMacros.h"
#import "TIOUser.h"
#import "TIOApplyUser.h"
#import "NSString+tio.h"
#import "NSObject+CBJSONSerialization.h"
#import "TIOChat.h"
#import "TIOSocketPackage.h"
#import "TIOCmdConfiguator.h"
#import "TIOSystemNotification.h"
#import "TIOChatHeader.h"
#import "TIONetworkNotificationCenter.h"

@implementation TIOSearchOption
@end

@implementation TIOFriendRequest
@end

@interface TIOFriendManager ()
@property (nonatomic, strong) TIOBroadcastDelegate<TIOFriendDelegate> *multiDelegate;
@property (nonatomic, copy) NSString *deleteUId;
@end

@implementation TIOFriendManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIOFriendDelegate> *)[TIOBroadcastDelegate.alloc init];
    }
    return self;
}

- (void)addFrinend:(TIOFriendRequest *)request completion:(TIOFriendHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSError *error = nil;
    NSString *errorMsg = nil;
    switch (request.operation) {
        case 0:
        {
            errorMsg = @"未指定具体的添加好友操作";
        }
            break;
        case TIOFriendOperationAdopt:
        {
            errorMsg = @"操作与方法不匹配：TIOFriendOperationAdopt";
        }
            break;
        case TIOFriendOperationReject:
        {
            errorMsg = @"操作与方法不匹配：TIOFriendOperationReject";
        }
            break;
        case TIOFriendOperationIgnore:
        {
            errorMsg = @"操作与方法不匹配：TIOFriendOperationIgnore";
        }
            break;
        default:
            break;
    }
    
    if (errorMsg) {
        
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
        TIOLog(@"%@",errorMsg);
        
        completion(error);
        
        return;
    }
    
    if (request.operation == TIOFriendOperationAdd) {
        
        NSDictionary *params = @{
            @"touid" : request.userId
        };
        
        [TIOHTTPSManager tio_POST:@"/chat/addFriend" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            completion(nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            TIOLog(@"%@",error);
            completion(error);
        }];
        
    } else {
        
        NSDictionary *params = @{
            @"touid" : request.userId,
            @"greet" : request.message?:@""
        };
        
        [TIOHTTPSManager tio_POST:@"/chat/friendApply" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            completion(nil);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            TIOLog(@"%@",error);
            
            completion(error);
        }];
    }
}

- (void)handleApply:(TIOFriendRequest *)request completion:(TIOFriendHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSError *error = nil;
    NSString *errorMsg = nil;
    
    NSString *result = 0;
    
    switch (request.operation) {
        case 0:
        {
            errorMsg = @"未指定具体的添加好友操作";
        }
            break;
        case TIOFriendOperationAdd:
        {
            errorMsg = @"操作与方法不匹配：TIOFriendOperationAdd";
        }
            break;
        case TIOFriendOperationRequest:
        {
            errorMsg = @"操作与方法不匹配：TIOFriendOperationRequest";
        }
            break;
        case TIOFriendOperationAdopt:
        {
            result = @"1";
        }
            break;
        case TIOFriendOperationReject:
        {
            result = @"2";
        }
            break;
        default:
            break;
    }
    
    if (errorMsg) {
        
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
        TIOLog(@"%@",errorMsg);
        
        completion(error);
        
        return;
    }
    
    if (request.operation == TIOFriendOperationAdopt) { // 通过申请
        NSDictionary *params = @{
            @"applyid" : request.userId,
            @"remarkname" : request.message?:@"",
        };
        
        [TIOHTTPSManager tio_POST:@"/chat/dealApply" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            completion(nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            TIOLog(@"%@",error);
            
            completion(error);
        }];
    } else if (request.operation == TIOFriendOperationIgnore) { // 忽略申请
        NSDictionary *params = @{
            @"applyid" : request.userId,
        };
        
        [TIOHTTPSManager tio_POST:@"/friend/ignoreApply" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            completion(nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            TIOLog(@"%@",error);
            
            completion(error);
        }];
    }
}

- (void)deleteFriend:(NSString *)friendId completion:(TIOFriendHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    if (friendId.length == 0) {
        
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"被删除的好友ID不能为空"}];
        
        TIOLog(@"%@",error.localizedDescription);
        
        completion(error);
        
        return;
    }
    
    NSDictionary *params = @{
        @"touid" : friendId
    };
    
    self.deleteUId = friendId;
    
    [TIOHTTPSManager tio_POST:@"/chat/delFriend" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        completion(nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.deleteUId = nil;
        TIOLog(@"%@",error);
        
        completion(error);
    }];
}

- (void)fetchApplyListWithCompletion:(void (^)(NSArray<TIOApplyUser *> * _Nullable, NSError * _Nullable))completion
{
    NSString *uid = TIOChat.shareSDK.loginManager.userInfo.userId;
    [TIOHTTPSManager tio_GET:@"/chat/applyList" parameters:@{@"uid":uid} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *list = [TIOApplyUser objectArrayWithJSONArray:responseObject[@"data"]];
        completion(list, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"%@",error);
        completion(nil, error);
    }];
}

- (void)fetchNewApplyListWithCompletion:(void (^)(NSInteger, NSError * _Nullable))completion
{
    NSString *uid = TIOChat.shareSDK.loginManager.userInfo.userId;
    [TIOHTTPSManager tio_GET:@"/chat/applyData" parameters:@{@"uid":uid} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger count = [responseObject[@"data"] integerValue];
        completion(count, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"%@",error);
        completion(0, error);
    }];
}

- (NSArray<TIOUser *> *)fetchMyFriends:(TIOFrinendsBlock)completion
{
    [TIOHTTPSManager tio_GET:@"/chat/mailList" parameters:@{@"mode":@"1"} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"获取我的好友 => %@",responseObject[@"data"][@"fd"]);
        NSArray *list = [TIOUser objectArrayWithJSONArray:responseObject[@"data"][@"fd"]];
        
        completion(list, nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
    
    return nil;
}

- (void)addToBlackList:(NSString *)friendId completion:(TIOFriendHandler)completion
{
    NSDictionary *params = @{
        @"touid" : friendId,
        @"oper" : @"2"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/oper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)removeFromBlackList:(NSString *)friendId completion:(TIOFriendHandler)completion
{
    NSDictionary *params = @{
        @"touid" : friendId,
        @"oper" : @"3"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/oper" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)fetchBlackStatusToUserId:(NSString *)uid completion:(void (^)(BOOL))completion
{
    NSDictionary *params = @{
        @"uid" : uid
    };
    [TIOHTTPSManager tio_POST:@"/user/block" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger status = [responseObject[@"data"] integerValue] == 1;
        completion(status);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)isMyFriend:(NSString *)userId completion:(void (^)(BOOL, NSError * _Nullable))completion
{
    // TODO: 需要对接 暂时只提供异步回调
    if (userId.length == 0) {
        
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"对方用户ID不能为空字符串"}];
        
        TIOLog(@"%@",error.localizedDescription);
        
        completion(NO,error);
        
        return;
    }
    
    [TIOHTTPSManager tio_POST:@"/chat/isFriend" parameters:@{@"touid" : userId} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSInteger type = [responseObject[@"data"] integerValue];
        
        BOOL re = type == 1 ? YES : NO;
        
        completion(re, nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(NO, error);
    }];
}

- (void)checkAddConditionWithUid:(NSString *)touid completion:(void (^)(NSInteger, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"touid" : touid
    };
    [TIOHTTPSManager tio_POST:@"/chat/checkAddFriend" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger result = [responseObject[@"data"] integerValue];
        completion(result, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(0, error);
    }];
}

- (TIOUser *)userInfor:(NSString *)userId
{
    // TODO: 需要实现本地读取
    return nil;
}

- (void)fetchUserInfo:(NSString *)userId completion:(TIOUserBlock)completion
{
    // TODO: 需要实现从服务端拉取
    [TIOHTTPSManager tio_GET:@"/user/info" parameters:@{@"uid":userId} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOUser *user = [TIOUser objectWithJSONObject:responseObject[@"data"]];
        completion(user, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, error);
    }];
}

- (void)searchFrinedsWithOption:(TIOSearchOption *)option completion:(nonnull TIOSearchFriendsHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(nil, NO, NO, 0, error);
        
        return;
    }
    
    if ([NSString isEmpty:option.searchText]) {
        
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"搜索内容不能为空"}];
        
        completion(nil, NO, NO, 0, error);
        
        return;
    }
    
    NSDictionary *params = @{
        @"searchkey" : option.searchText?:@"",
        @"mode" : @"1"
    };
    
    [TIOHTTPSManager tio_POST:@"/chat/mailList" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [TIOUser objectArrayWithJSONArray:responseObject[@"data"][@"fd"]];
        NSInteger total = 0;
        BOOL last = YES;
        BOOL first = YES;
        completion(array, first, last, total, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, NO, NO, 0, error);
    }];
}

- (void)searchUserWithOption:(TIOSearchOption *)option completion:(TIOSearchFriendsHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(nil, NO, NO, 0, error);
        
        return;
    }
    if ([NSString isEmpty:option.searchText]) {
        
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"搜索内容不能为空"}];
        
        completion(nil, NO, NO, 0, error);
        
        return;
    }
    
    NSDictionary *params = @{
        @"nick" : option.searchText?:@"",
        @"pageNumber" : @(option.pageNumber)
    };
    
    [TIOHTTPSManager tio_POST:@"/user/search" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [TIOUser objectArrayWithJSONArray:responseObject[@"data"][@"list"]];
        NSInteger total = [responseObject[@"data"][@"totalRow"] integerValue];
        BOOL first = [responseObject[@"data"][@"firstPage"] boolValue];
        BOOL last = [responseObject[@"data"][@"lastPage"] boolValue];
        completion(array, first, last, total, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, NO, NO, 0, error);
    }];
}

- (void)updateRemark:(NSString *)reamrk uid:(NSString *)uid completion:(void (^)(NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"remarkname" : reamrk?:@"",
        @"frienduid" : uid
    };
    [TIOHTTPSManager tio_POST:@"/friend/modifyRemarkname" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)shareUser:(NSString *)uid toUids:(NSArray<NSString *> * _Nullable)uids toTeamIds:(NSArray<NSString *> * _Nullable)teamIds completion:(nonnull TIOFriendHandler)completion
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
    
    params[@"chatmode"] = @"1";
    params[@"cardid"] = uid;
    
    [TIOHTTPSManager tio_POST:@"/chat/shareCard" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

#pragma mark - 公开

- (void)addDelegate:(id<TIOFriendDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOFriendDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)handler:(TIOSocketPackage *)data
{
    if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdSystemNtf]) {
        TIOSystemNotification *model = [TIOSystemNotification objectWithJSONObject:data.body];
        if (model.code == 32) {
            // 同时删除会话和通讯录的好友

            if (model.bizdata) {
                TIOUser *deletedUser = [TIOUser.alloc init];
                deletedUser.userId = model.bizdata;
                [self.multiDelegate didDeleteFriend:deletedUser];
            }

            self.deleteUId = nil;
        }
    }
}

@end
