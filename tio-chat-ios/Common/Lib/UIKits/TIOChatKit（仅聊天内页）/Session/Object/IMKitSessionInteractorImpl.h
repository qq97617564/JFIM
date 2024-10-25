//
//  IMSessionInteractor.h
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import <Foundation/Foundation.h>
#import "IMSessionPrivateProtocol.h"
#import "IMSessionInteractorProtocol.h"
#import "IMSessionConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// 交互管理
@interface IMKitSessionInteractorImpl : NSObject <IMKitSessionInteractor, IMSessionLayoutDelegate>

- (instancetype)initWithSession:(TIOSession *)session sessionConfig:(id<IMSessionConfig>)sessionConfig;

/// 数据源
@property (strong,  nonatomic) id<IMSessionDataSource>          dataSource;

/// 布局器
@property (strong,  nonatomic) id<IMSessionLayout>              layout;

/// 
@property (weak,    nonatomic) id<IMKitSessionInteractorDelegate>  delegate;

@end

NS_ASSUME_NONNULL_END
