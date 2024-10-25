//
//  TIOWxCallItemAnswerCandidate.h
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOWxCallItem.h"
#import "TIOICECandidate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOWxCallItemAnswerCandidate : TIOWxCallItem
@property (nonatomic, strong) TIOICECandidate *candidate;
@end

NS_ASSUME_NONNULL_END
