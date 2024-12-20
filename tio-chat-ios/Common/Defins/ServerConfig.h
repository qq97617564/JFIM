//
//  ServerConfig.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#ifndef ServerConfig_h
#define ServerConfig_h

#if DEBUG
//多域名
#define kBaseURLArr              @[@"https://demo-api.23hml.com",@"https://demo-local.23hml.com"]
//主域名
#define kBaseURLString            @"https://demo-local.23hml.com"
#define kHTMLBaseURLString        @"https://demo-local.23hml.com"
#define kResourceURLString        @"https://demo-reslocal.23hml.com"
#define kSecturyKey               @"pxo0xI"

#else

#define kBaseURLArr               @[@"https://demo-local.23hml.com"]
#define kBaseURLString            @"https://demo-local.23hml.com"
#define kHTMLBaseURLString        @"https://demo-local.23hml.com"
#define kResourceURLString        @"https://demo-reslocal.23hml.com"
#define kSecturyKey               @"pxo0xI"

#endif

#define QR_SERVER                 @"https://a.app.qq.com/o/simple.jsp?pkgname=app.suyun8905.test2"

#endif /* ServerConfig_h */
