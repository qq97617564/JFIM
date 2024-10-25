//
//  TIOChatTeamManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/18.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIODefines.h"
#import "TIOInvitationApply.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOTeam;
@class TIOTeamMember;
@class TIOUser;
@class TIOSocketPackage;
@class TIOSystemNotification;

typedef NS_ENUM(NSUInteger, TIOTeamCardStatus) {
    TIOTeamCardStatusAvailable  =   1, ///< 分享的群名片可用
    TIOTeamCardStatusUnavailable=   2,///< 分享的群名片不可用
};


typedef void(^TIOTeamsHandler)(NSArray<TIOTeam *> * __nullable team,NSError * __nullable error);
typedef void(^TIOTeamInfoHandler)(TIOTeam * __nullable team, TIOTeamMember * __nullable teamUser ,NSError * __nullable error);
typedef void(^TIOTeamUserHandler)(TIOTeamMember * __nullable teamUser,NSError * __nullable error);
typedef void(^TIOTeamUsersHandler)(NSArray<TIOTeamMember *> * __nullable teamUsers,BOOL first,BOOL last, NSInteger total, NSError * __nullable error);
typedef void(^TIOUsersNotInTeamHandler)(NSArray<TIOUser *> * __nullable users,NSError * __nullable error);
typedef void(^TIOTeamError)(NSError * __nullable error);
typedef void(^TIOCreateTeamHandler)(NSError * __nullable error, NSString * __nullable teamId);
typedef void(^TIOCheckCardJoinToTeamError)(NSError * __nullable error, TIOTeamCardStatus status);
typedef void(^TIOCheckMemberHandler)(NSError * __nullable error, BOOL isInTeam);

/**
--------------------------------------------------------------
`TIOTeamName`创建群时的群昵称
--------------------------------------------------------------
*/
@interface TIOTeamName : NSObject
/// 群昵称
@property (nonatomic, copy) NSString *name;
/// 是否允许服务端在成员发生变动时自动修改群昵称
/// 自动修改群昵称的格式为“ XXX,XXXX,XXX,XXX,XXX,..... ”
/// 建议，当建群时的设置的初始昵称非“ XXX,XXXX,XXX,XXX,XXX,..... ”格式时，allowServerToUpdateAutomatically设为NO，
/// 当格式初始昵为“ XXX,XXXX,XXX,XXX,XXX,..... ”格式时，allowServerToUpdateAutomatically设为YES，方便服务端按此格式进行自动修改
/// 默认为YES
@property (nonatomic, assign) BOOL allowServerToUpdateAutomatically;
@end

/**
--------------------------------------------------------------
`TIOTeamDelegate`群聊回调
--------------------------------------------------------------
*/
@protocol TIOTeamDelegate <NSObject>
@optional
/// 已删除解散群
- (void)didDeleteTeam:(TIOTeam  * _Nullable )team;
/// 已转让群
- (void)didTransferedTeam:(TIOTeam  * _Nullable )team;
/// 已退群
- (void)didExitFromTeam:(TIOTeam  * _Nullable )team;
/// 群信息发生变更:      说明：群信息变动回调的team并不是一个完整team，只包含群ID以及变更的字段信息
- (void)didUpdateTeamInfo:(TIOTeam * _Nullable )team;
/// 被踢出群
- (void)didKickedOut:(TIOSystemNotification *)notification;
/// 重新加入群聊
- (void)didRejoin:(TIOSystemNotification *)notification;
/// 群成员数量变更
- (void)didUpdateMemebersCount:(NSInteger)count;

@end


/**
--------------------------------------------------------------
`TIOTeamManager`群组管理类
--------------------------------------------------------------
*/
@interface TIOTeamManager : NSObject

/// 创建群
/// @param name 群名
/// @param intro 群简介
/// @param userIds 群成员ID数组
- (void)createTeamName:(NSString * _Nullable)name
          introduction:(NSString *)intro
                 users:(NSArray<NSString *> *)userIds
            completion:(TIOCreateTeamHandler)completion;


/// 添加好友（们）进群
/// @param userIds 被添加的用户IDs
/// @param teamId 群ID
/// @param sharerUid 群名片分享者的uid，只有当从群名片加群时必传
- (void)addUser:(NSArray<NSString *> *)userIds toTeam:(NSString *)teamId sharerUid:(NSString * _Nullable)sharerUid completion:(TIOTeamError)completion;

/// 申请加好友进群 申请后等待群主/管理员审核通过
/// @param userIds 进群的用户
/// @param teamId 群
/// @param msg 申请信息
- (void)applyToAddUsers:(NSArray *)userIds toTeam:(NSString *)teamId msg:(NSString *)msg completion:(TIOTeamError)completion;

/// 将用户移出群
/// @param userIds 被移出群的用户们
/// @param teamId 群ID
/// @param completion 结果
- (void)removeUser:(NSArray<NSString *> *)userIds
          fromTeam:(NSString *)teamId
        completion:(TIOTeamError)completion;


/// 获取群信息 + 自己在群内的信息（ 暂不支持从本地数据库读取）
/// @param groupId 群ID
/// @param completion 群信息 + 自己在群内的信息
- (void)fetchTeamInfoWithTeamId:(NSString *)groupId
                     completion:(TIOTeamInfoHandler)completion;
/// 获取用户在群里的信息
- (void)fetchUserInfoInTeam:(NSString *)teamId
                 completion:(TIOTeamUserHandler)completion;

/// 搜索群内成员 返回类型是TIOUser
/// @param key 关键字,为空时，获取所有的可@成员列表，不包括自己
/// @param teamId 群ID
- (void)searchMember:(NSString * _Nullable)key
              inTeam:(NSString *)teamId
          completion:(TIOUsersNotInTeamHandler)completion;

/// 搜索不在群内的好友
/// @param searchKey 搜索词
/// @param teamId 群ID
- (void)searchFriends:(NSString *)searchKey
            notInTeam:(NSString *)teamId
           completion:(TIOUsersNotInTeamHandler)completion;


/// 获取群内所有的成员 返回类型是TIOTeamUser
/// @param teamId 群ID
/// @param pageNumber 页码，从1开始,一次查询100条数据
- (void)fetchMembersInTeam:(NSString *)teamId
                 searchKey:(NSString * _Nullable)key
                pageNumber:(NSInteger)pageNumber
                completion:(TIOTeamUsersHandler)completion;


/// 搜索自己的群聊
/// @param key 搜索关键字
/// @param completion 结果回调
- (void)searchMyTeamsWithKey:(NSString *)key
                  completion:(TIOTeamsHandler)completion;

/// 检查群名片是否可以分享
/// @param teamId 群ID
- (void)checkTeam:(NSString *)teamId canSendCardWithCompletion:(TIOTeamError)completion;

/// 检查分享的群名片
/// @param teamId 群ID
/// @param fromUserId 发送名片的用户ID
- (void)checkTeamShareCard:(NSString *)teamId fromUser:(NSString *)fromUserId completion:(TIOCheckCardJoinToTeamError)completion;

- (void)shareTeam:(NSString *)teamId toUids:(NSArray<NSString *> * _Nullable )uids toTeamIds:(NSArray<NSString *> * _Nullable )teamIds completion:(TIOTeamError)completion;

- (void)checkMember:(NSString *)memberId isInTeam:(NSString *)teamId completion:(TIOCheckMemberHandler)completion;

#pragma mark - 用户更新修改操作

/// 更新用户的群昵称
/// @param newNick 新的用户群昵称
/// @param teamId 所属群
- (void)updateUserNick:(NSString *)newNick
                inTeam:(NSString *)teamId
            completion:(TIOTeamError)completion;

/// 修改群名（群主操作）
/// @param newNick 新的群昵称
/// @param teamId 所属群
- (void)updateTeamName:(NSString *)newNick
                inTeam:(NSString *)teamId
            completion:(TIOTeamError)completion;

/// 修改群公告（群主操作）
/// @param newNotice 新的公告
/// @param teamId 群
- (void)updateTeamNotice:(NSString *)newNotice
                  inTeam:(NSString *)teamId
              completion:(TIOTeamError)completion;

/// 修改群简介（群主操作）
/// @param newIntro 新的简介
/// @param teamId 群
- (void)updateTeamIntro:(NSString *)newIntro
                 inTeam:(NSString *)teamId
             completion:(TIOTeamError)completion;

#pragma mark - 群操作

/// 退群
/// @param teamId 群ID
/// @param completion 操作结果
- (void)exitFromTeam:(NSString *)teamId
          completion:(TIOTeamError)completion;


/// 解散群 删除群
/// @param teamId 群ID
/// @param completion 结果
- (void)deleteTeam:(NSString *)teamId
        completion:(TIOTeamError)completion;


/// 转让群
/// @param teamId 群ID
/// @param uid 要转给的用户uid
/// @param completion 结果
- (void)transferTeam:(NSString *)teamId
              toUser:(NSString *)uid
          completion:(TIOTeamError)completion;

/// 修改成员邀请权限
/// @param teamId 群
/// @param allow 是否x允许加群
- (void)updateJoiningPermissionForTeam:(NSString *)teamId isAllowJoin:(BOOL)allow completion:(TIOTeamError)completion;

/// 修改群审核开关
/// @param teamId 群
/// @param isReview 是否开启审核
- (void)updateReviewingPermissionForTeam:(NSString *)teamId isReview:(BOOL)isReview completion:(TIOTeamError)completion;

/// 获取所有的群组
/// @param completion 群组
- (void)fetchAllTeams:(TIOTeamsHandler)completion;

/// 改变用户角色
/// @param role 新角色 2:普通成员 3:管理员
/// @param uid 操作的对象
/// @param teamid 所在群
- (void)changeMemberRole:(TIOTeamUserRole)role uid:(NSString *)uid inTeam:(NSString *)teamid completion:(TIOTeamError)completion;

/// 获取邀请入群的申请信息
/// @param applyId 申请ID
- (void)fetchApplyInfoForInviting:(NSString *)applyId completion:(void(^)(TIOInvitationApply  * _Nullable applyInfor, NSArray <TIOUser *>  * _Nullable users, NSError * __nullable error))completion;

/// 处理邀请入群的申请
/// @param applyId 申请ID
/// @param mid 消息ID
- (void)dealApplyForInviting:(NSString *)applyId messageId:(NSString *)mid completion:(TIOTeamError)completion;

/// 修改群内加好友开关
/// @param teamId 群
/// @param flag 1:允许群内互加好友 2:不允许群内互加好友
- (void)updateAddingFriendPermissionInTeam:(NSString *)teamId flag:(NSInteger)flag completion:(TIOTeamError)completion;

#pragma mark - 禁言相关
/// 禁言操作
/// @param teamid 群ID
/// @param oper 操作码 1：禁言；2：取消禁言--------必填
/// @param mode 禁言类型：1：用户时长禁言；3：用户长久禁言 ； 4：群禁言--------必填
/// @param duration 时长禁言时间-秒-----------用户时长禁言操作必填
/// @param uid 用户id-------用户禁言必填
- (void)forbiddenSpeakInTeam:(NSString *)teamid oper:(NSInteger)oper mode:(NSInteger)mode duration:(NSInteger)duration uid:(NSString *_Nullable)uid completion:(TIOTeamError)completion;

/// 获取/搜索 禁言用户（列表）
/// @param teamid 群ID
/// @param key 搜索关键字 传nil时，表示搜索全部的禁言用户
/// @param pageNumber 页码
- (void)fetchForbiddenUserListInTeamId:(NSString *)teamid
                             searchKey:(NSString * _Nullable)key
                            pageNumber:(NSInteger)pageNumber
                            completion:(TIOTeamUsersHandler)completion;

/// 检查自己对群成员uid的操作权限（禁言、撤回消息、删除等）
/// @param uid 要操作的群成员
/// @param teamid 群id
- (void)checkStatusForUser:(NSString *)uid inTeam:(NSString *)teamid completion:(void(^)(NSError * _Nullable error, NSDictionary * _Nullable result))completion;


/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIOTeamDelegate>)delegate;


/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIOTeamDelegate>)delegate;

- (void)handler:(TIOSocketPackage *)data;

@end

NS_ASSUME_NONNULL_END
