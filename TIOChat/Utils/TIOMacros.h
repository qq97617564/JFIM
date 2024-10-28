//
//  TIOMacros.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/19.
//  Copyright © 2019 刘宇. All rights reserved.
//

#ifndef TIOMacros_h
#define TIOMacros_h

#define TIOLogEnable   [[[NSUserDefaults standardUserDefaults] valueForKey:@"TIO_LOG_ENABLE"] boolValue]

#define TIOLog(format,...)  if(YES) {\
NSLog((@"%s[%d]" format), __FUNCTION__, __LINE__, ##__VA_ARGS__);\
} else {}

#define TIOChatErrorDomain @"TIOChatSDK"

#define TIOWeakObject(c) __weak __typeof__(c) WeakObject = c;
#define TIOStrongObjectElseReturn(c) __strong __typeof__(c) c = WeakObject; if(!c) return;
#define TIOWeakSelf __weak __typeof__(self) WeakSelf = self;
#define TIOStrongSelf __strong __typeof__(self) self = WeakSelf;
#define TIOStrongSelfElseReturn __strong __typeof__(self) self = WeakSelf; if(!self) return;

#define TIO_Dispatch_Async_Main(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#endif /* TIOMacros_h */
