//
//  IMSessionLayoutImpl.h
//  CawBar
//
//  Created by admin on 2019/11/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IMSessionPrivateProtocol.h"
#import "IMInputViewProtocol.h"
#import "IMSessionConfig.h"
#import "IMSessionInteractorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOSession;

/// tableview和inputview的layout处理
@interface IMKitSessionLayoutImpl : NSObject <IMSessionLayout>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<IMKitInputView> inputView;

- (instancetype)initWithSession:(TIOSession *)session
                  sessionConfig:(id<IMSessionConfig>)sessionConfig;

@end

NS_ASSUME_NONNULL_END
