//
//  CatchCrash.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/4/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CatchCrash : NSObject
void uncaughtExceptionHandler(NSException *exception);

- (void)start;

@end

NS_ASSUME_NONNULL_END
