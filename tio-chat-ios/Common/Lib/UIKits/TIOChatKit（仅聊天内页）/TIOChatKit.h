//
//  IMKit.h
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import <Foundation/Foundation.h>
#import "IMKitCellLayoutConfig.h"
#import "IMCellConfig.h"
#import "IMKitConfig.h"
#import "ImportSDK.h"
#import "IMKitMessageSetting.h"
#import "IMKitSessionConfigurator.h"
#import "IMSessionInteractorProtocol.h"
#import "IMKitAvatarImageView.h"
#import "IMKitMessageContentView.h"
#import "TIOKitTool.h"
#import "IMKitEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOChatKit : NSObject

+ (instancetype)shareSDK;

@property (strong, nonatomic) id<IMCellLayoutConfig> cellConfig;

@property (strong, nonatomic) IMKitConfig *config;

@end
    
NS_ASSUME_NONNULL_END
