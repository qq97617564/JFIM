//
//  TRecordHUD.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMInputViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAudioRecordHUD : UIView

@property (assign, nonatomic) TAudioRecordStatus status;

@property (assign, nonatomic) NSTimeInterval recordTime;

@end

NS_ASSUME_NONNULL_END
