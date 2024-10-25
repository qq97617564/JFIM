//
//  IMSessionDataSourceImpl.h
//  CawBar
//
//  Created by admin on 2019/11/12.
//

#import <Foundation/Foundation.h>
#import "IMSessionPrivateProtocol.h"
#import "IMSessionConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOSession;

/// 数据源
@interface IMKitSessionDataSourceImpl : NSObject <IMSessionDataSource>

- (instancetype)initWithSession:(TIOSession *)session sessionConfig:(id<IMSessionConfig>)sessionConfig;

@end

NS_ASSUME_NONNULL_END
