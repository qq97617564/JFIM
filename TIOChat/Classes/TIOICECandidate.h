//
//  TIOICECandidate.h
//  WebRTCDemo
//
//  Created by 刘宇 on 2020/5/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOICECandidate : NSObject

@property(nonatomic, nullable) NSString *sdpMid;

@property(nonatomic, assign) int sdpMLineIndex;

@property(nonatomic, copy) NSString *candidate;

@property(nonatomic, nullable) NSString *serverUrl;

@property (nonatomic, copy) NSString *usernameFragment;

@end

NS_ASSUME_NONNULL_END
