//
//  Header.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#ifndef Header_h
#define Header_h

/// 登录注册页中输入框的 左边距 ｜ 宽 ｜ 高
#define LoginFieldLeftPadding (IsLowerIphone6?FlexWidth(36):36)
#define LoginFieldWidth (self.view.width - LoginFieldLeftPadding * 2)
#define LoginFieldHeight (IsLowerIphone6?FlexHeight(44):44)

#endif /* Header_h */
