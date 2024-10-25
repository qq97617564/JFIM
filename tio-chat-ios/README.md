#  Demo 使用及说明
* 工程目录结构

.
├── TIOChat  **（SDK，不依赖Demo中的代码）**
├── TIOChatKit **（可扩展的聊天页组件，不依赖Demo中的代码）**
├── tio-chat-ios **（Demo）**
│   ├── Common（公共组件库、工具库、资源库、常量宏的定义）
│   │   ├── Lib
│   │   ├── Macros
│   │   └── Resourse
│   ├── Modules（业务模块）
│   │   ├── Contacts ```通讯录```
│   │   ├── LoginAndRegister ```登录注册```
│   │   ├── Mine ```个人中心```
│   │   ├── Session ```私聊群聊会话```
│   │   └── SessionList ```会话列表```
│   ├── README.md
│   ├── TIOTabBarController.h
│   ├── ViewController.h
└── └── main.m

* Demo中的文件命名

# `（⚠️不包括SDK、TIOChatKit）Demo中文件均只以T作前缀。例如：TTabBarViewConreoller`


#import "FrameAccessor.h"
