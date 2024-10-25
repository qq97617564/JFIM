//
//  CBVersionManager.h
//  CawBar
//
//  Created by admin on 2018/12/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CBUpdateType) {
    CBUpdateTypeNone,       ///< 不需要更新
    CBUpdateTypeOptional,   ///< 可选择更新
    CBUpdateTypeForced,     ///< 强制更新
};

@interface CBVersionManager : NSObject

+ (instancetype)shareInstance;

- (void)starManager;
- (void)stopManager;

// optional
- (void)showMessageWithTitle:(NSString *)title content:(NSString *)content type:(CBUpdateType)type;

@end

NS_ASSUME_NONNULL_END
