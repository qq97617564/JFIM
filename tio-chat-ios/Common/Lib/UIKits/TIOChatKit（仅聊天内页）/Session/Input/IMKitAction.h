//
//  IMKitAction.h
//  CawBar
//
//  Created by admin on 2019/11/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IMKitActionType) {
    IMKitActionAudio,   // 录音
    IMKitActionText,    // 文字键盘
    IMKitActionField,    // 输入框
    IMKitActionEmoticon,// 表情
    IMKitActionSend,    // 发送
    IMKitActionMore,    // 更多面板
    IMKitActionCustom,  // 自定义类型
};

@interface IMKitAction : NSObject

@property (assign, nonatomic) IMKitActionType actionType;

@property (strong, nonatomic) UIImage *normalImage;

@property (strong, nonatomic) UIImage *selectedImage;

@property (assign, nonatomic) CGSize size;

@property (assign, nonatomic) id action;

@property (assign, nonatomic) SEL selector;

@property (assign, nonatomic) Class actionClass;

@end

NS_ASSUME_NONNULL_END
