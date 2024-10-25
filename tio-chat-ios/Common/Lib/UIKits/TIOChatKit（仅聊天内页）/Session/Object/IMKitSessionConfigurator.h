//
//  IMSessionConfigurator.h
//  CawBar
//
//  Created by admin on 2019/11/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOSessionViewController;
/// 聊天会话页配置器
/// 配置交互器、布局器、数据源管理器、UITableView适配器
@interface IMKitSessionConfigurator : NSObject

- (void)setup:(TIOSessionViewController *)sessionVC;

@end

NS_ASSUME_NONNULL_END
