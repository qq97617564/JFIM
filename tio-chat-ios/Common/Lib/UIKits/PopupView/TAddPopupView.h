//
//  TAddPopupView.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TAddPopupView;

/// index 为 -1 时 ，点击半透明区域，没有点击任意item
typedef void(^TAddPopupViewHandler)(TAddPopupView *popupView, NSInteger index, NSString *title);

@interface TAddPopupView : UIView

@property (nonatomic, assign) CGPoint anchorPoint;

+ (instancetype)menuWithItemTitles:(NSArray *)itemTitles itemImages:(NSArray *)itemImages itemHandler:(TAddPopupViewHandler)hander;

- (void)show;

@end

NS_ASSUME_NONNULL_END
