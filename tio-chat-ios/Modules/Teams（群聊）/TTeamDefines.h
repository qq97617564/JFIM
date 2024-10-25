//
//  TTeamDefines.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#ifndef TTeamDefines_h
#define TTeamDefines_h

typedef NS_ENUM(NSUInteger, TTeamSearchType) {
    TTeamSearchTypeCreate,  ///< 创建群
    TTeamSearchTypeInvite,  ///< 邀请好友入群（非第一次创建群时拉的好友）
    TTeamSearchTypeTransfer,///< 转让群
};

typedef NS_ENUM(NSUInteger, TCellSelectedStatus) {
    TCellSelectedStatusNone,    ///< 未选中，可选择状态
    TCellSelectedStatusSelected,///< 已选择
    TCellSelectedStatusDisabled,///< 不可选择
};

#endif /* TTeamDefines_h */
