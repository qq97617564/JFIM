//
//  IMSessionContentConfigFactory.h
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import <Foundation/Foundation.h>
#import "IMSessionContentConfig.h"
#import "TIOChatKit.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOMessage;

@interface IMKitSessionContentConfigFactory : NSObject

+ (instancetype)sharedFacotry;
- (id<IMSessionContentConfig>)configBy:(TIOMessage *)message;

@end

NS_ASSUME_NONNULL_END
