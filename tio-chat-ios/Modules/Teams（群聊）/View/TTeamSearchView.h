//
//  TTeamSearchView.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTeamDefines.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTeamSearchViewDelegate <NSObject>

@end

@interface TTeamSearchView : UIView

@property (assign, nonatomic) TTeamSearchType type;

- (instancetype)initWithType:(TTeamSearchType)type;

- (void)refreshKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
