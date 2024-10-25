//
//  TIOFriendManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOUser;
@class TIOApplyUser;
@class TIOSocketPackage;

typedef void(^TIOFriendHandler)(NSError * __nullable error);

typedef void(^TIOFrinendsBlock)(NSArray<TIOUser *> * __nullable users,NSError * __nullable error);

typedef void(^TIOUserBlock)(TIOUser * __nullable users,NSError * __nullable error);

typedef void(^TIOSearchFriendsHandler)(NSArray<TIOUser *> * __nullable users,BOOL firstPage, BOOL lastPage, NSInteger total, NSError * __nullable error);

/**
 添加好友的操作
 */
typedef NS_ENUM(NSUInteger, TIOFriendOperation) {
    TIOFriendOperationAdd       =   1,  ///< 直接加好友
    TIOFriendOperationRequest   =   2,  ///< 请求加好友
    TIOFriendOperationAdopt     =   3,  ///< 通过好友申请
    TIOFriendOperationReject    =   4,  ///< 拒绝好友申请
    TIOFriendOperationIgnore    =   5,  ///< 忽略好友申请
};

/**
 好友的请求状态
 TIOFriendReqStatusWaitting 等待审核
 TIOFriendReqStatusAdded 已添加
 TIOFriendReqStatusRejected 已拒绝
 TIOFriendReqStatusTimeout 请求过期
 */
typedef NS_ENUM(NSUInteger, TIOFriendReqStatus) {
    TIOFriendReqStatusAdded     =   1, ///< 已添加
    TIOFriendReqStatusWaitting  =   2, ///< 等待审核
    TIOFriendReqStatusIgnored   =   3, ///< 已忽略
    TIOFriendReqStatusRejected  =   4, ///< 已拒绝
    TIOFriendReqStatusTimeout   =   5, ///< 请求过期
};

/**
搜索好友的搜索类型
TIOSearchContentTypeNick 按昵称搜索
TIOSearchContentTypeFriendId 按好友ID搜索
TIOSearchContentTypeRemarkname 按备注搜索
TIOSearchContentTypeAll 搜索全部类型
*/
typedef NS_ENUM(NSUInteger, TIOSearchContentCondition) {
    TIOSearchContentTypeNick,     ///< 按昵称或者群名搜索
    TIOSearchContentTypeFriendId, ///< 按好友ID或群ID搜索
    TIOSearchContentTypeRemarkname, ///< 按备注或群备注搜索
    TIOSearchContentTypeAll       ///< 搜索全部类型
};

typedef NS_ENUM(NSUInteger, TIOSearchContentScope) {
    TIOSearchContentScopeFriend,    ///<  搜索范围仅限好友
    TIOSearchContentScopeTeam,      ///< 搜索范围包括好友以及群
};

@interface TIOSearchOption : NSObject
/// 搜索的关键字
@property (copy, nonatomic) NSString *searchText;
/// 使用搜索自己的好友API时要设置有效
@property (assign, nonatomic) TIOSearchContentCondition searchContentType;
/// 搜索范围：好友 群聊
@property (assign, nonatomic) TIOSearchContentScope scope;
/// 第几页，默认从1开始
@property (assign, nonatomic) NSInteger pageNumber;
/// 每次查询的数据量
@property (assign, nonatomic) NSInteger pageSize;
@end

/**
--------------------------------------------------------------
`TIOFriendRequest`好友请求
--------------------------------------------------------------
*/
@interface TIOFriendRequest : NSObject

/// 对方用户的ID
@property (copy,    nonatomic) NSString *userId;
/// 直接添加好友时，message为备注
/// 请求添加好友时，message为附加消息
/// 通过好友申请时，message为备注
/// 拒绝好友申请时，message为空
@property (copy,    nonatomic) NSString *message;
/// 请求操作
@property (assign,  nonatomic) TIOFriendOperation operation;
@end

/**
--------------------------------------------------------------
`TIOFriendDelegate`好友模块回调
--------------------------------------------------------------
*/
@protocol TIOFriendDelegate <NSObject>
@optional
/// 删除用户 回调，系统通知也会同步触发，处理任意即可
/// @param user 被删除的用户，仅uid有效
- (void)didDeleteFriend:(TIOUser * _Nullable )user;
@end


/**
--------------------------------------------------------------
`TIOFriendManager`好友管理类
--------------------------------------------------------------
*/
@interface TIOFriendManager : NSObject

/// 添加好友
/// 操作：直接添加｜申请添加
/// @param request 添加好友请求（TIOFriendOperationAdd直接添加，TIOFriendOperationRequest申请添加）
/// @param completion 添加操作完成后的回调
- (void)addFrinend:(TIOFriendRequest *)request completion:(TIOFriendHandler)completion;


/// 处理好友申请
/// 操作：通过申请｜拒绝申请
/// @param request 处理好友申请的请求 （TIOFriendOperationAdopt通过申请 TIOFriendOperationReject拒绝申请）
/// @param completion 处理操作完成后的回调
- (void)handleApply:(TIOFriendRequest *)request completion:(TIOFriendHandler)completion;


/// 删除好友
/// @param friendId 好友的用户ID
/// @param completion 完成后的回调
- (void)deleteFriend:(NSString *)friendId completion:(TIOFriendHandler)completion;


/// 获取申请列表------包括同意和未同意的所有数据
- (void)fetchApplyListWithCompletion:(void(^)(NSArray<TIOApplyUser *> * __nullable users, NSError * __nullable error))completion;
/// 获取最新的（未读的）加好友申请
- (void)fetchNewApplyListWithCompletion:(void(^)(NSInteger newApplyCount, NSError * __nullable error))completion;


/// 获取好友列表
/// note:方法返回值暂时没有数据,请使用completions中的异步数据，后期会增加return本地数据
/// @param completion 异步处理结果
- (nullable NSArray<TIOUser *> *)fetchMyFriends:(TIOFrinendsBlock)completion;


/// 将好友（非好友）拉黑到黑名单，如果是非好友，拉黑后，对方不能加你为好友
/// @param friendId 好友的用户ID
/// @param completion 完成后的回调
- (void)addToBlackList:(NSString *)friendId completion:(TIOFriendHandler)completion;


/// 将好友从黑名单中移除
/// @param friendId 好友的用户ID
/// @param completion 完成后的回调
- (void)removeFromBlackList:(NSString *)friendId completion:(TIOFriendHandler)completion;

/// 获取针某个用户的拉黑（屏蔽）状态
/// @param uid 某个用户
/// @param completion black=YES 已经拉黑uid用户 NO，没有拉黑
- (void)fetchBlackStatusToUserId:(NSString *)uid completion:(void(^)(BOOL black))completion;


/// 是否是自己的好友
/// Note：暂不提供同步判断，在异步回调里获取判断结果
/// @param userId 用户ID
/// @param completion 异步结果
- (void)isMyFriend:(NSString *)userId completion:(void(^)(BOOL isFriend, NSError * __nullable error))completion;

/// 检查加对方为好友时的条件
/// @param touid 对方的UID
/// @param completion 回调
- (void)checkAddConditionWithUid:(NSString *)touid completion:(void(^)(NSInteger condition, NSError * __nullable error))completion;


/// 从本地读取指定userId的用户信息
- (TIOUser *)userInfor:(NSString *)userId;
/// 从服务端拉取指定userId的用户信息，同时会存储到本地
- (void)fetchUserInfo:(NSString *)userId completion:(TIOUserBlock)completion;

/// 搜索好友（仅好友）
/// 一次查询20条数据
/// @param option 搜索条件
/// @param completion 搜索结果回调
- (void)searchFrinedsWithOption:(TIOSearchOption *)option completion:(TIOSearchFriendsHandler)completion;

/// 搜索用户（好友+非好友）
/// @param option 搜索条件
/// @param completion 搜索结果回调
- (void)searchUserWithOption:(TIOSearchOption *)option completion:(TIOSearchFriendsHandler)completion;

- (void)updateRemark:(NSString *)reamrk uid:(NSString *)uid completion:(void(^)(NSError * __nullable error))completion;

/// 将好友推荐给指定的好友（们）以及群聊（们）
/// @param uid 要推荐的好友
/// @param uids 发送给的好友（们）
/// @param teamIds 发送给的群聊（们）
- (void)shareUser:(NSString *)uid toUids:( NSArray<NSString *> * _Nullable )uids toTeamIds:(NSArray<NSString *> * _Nullable )teamIds completion:(TIOFriendHandler)completion;

- (void)handler:(TIOSocketPackage *)data;

/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIOFriendDelegate>)delegate;

/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIOFriendDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
