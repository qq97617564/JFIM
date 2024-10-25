//
//  IMSessionDataSource.h
//  CawBar
//
//  Created by admin on 2019/11/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IMMessageCellProtocol.h"
#import "IMSessionInteractorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class IMKitMessageModel;

/// UITableView适配器
@interface IMKitSessionTableAdapter : NSObject <UITableViewDelegate, UITableViewDataSource>

/// 交互
@property (nonatomic, weak) id<IMKitSessionInteractor>   interactor;

/// cell代理
@property (nonatomic, weak) id<IMMessageCellProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
