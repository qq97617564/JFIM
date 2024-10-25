//
//  IMKitInputMoreItem.h
//  CawBar
//
//  Created by admin on 2019/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMKitInputMoreItem : NSObject

/// 名称
@property (copy,    nonatomic)  NSString    *title;
/// 正常状态图片
@property (strong,  nonatomic)  UIImage     *normalImage;
/// 选中时的图片
@property (strong,  nonatomic)  UIImage     *selectedImage;
/// 绑定的事件
@property (assign,  nonatomic)  SEL         selector;

+ (instancetype)itemWithTitle:(NSString *)title
                  normalImage:(UIImage *)normalImage
                selectedImage:(UIImage *)selectedImage
                     selector:(NSString *)selector;

@end

NS_ASSUME_NONNULL_END
