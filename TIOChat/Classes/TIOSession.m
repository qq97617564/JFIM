//
//  TIOSession.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/20.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOSession.h"
#import "NSString+tio.h"
#import "NSObject+CBJSONSerialization.h"

@implementation TIOSession

+ (instancetype)session:(NSString *)sessionId toUId:(nonnull NSString *)toUId type:(TIOSessionType)sessionType
{
    return [[self alloc] initWithSession:sessionId toUId:toUId type:sessionType];
}

- (instancetype)initWithSession:(NSString *)sessionId toUId:(nonnull NSString *)toUId type:(TIOSessionType)sessionType
{
    self = [super init];
    
    if (self) {
        _sessionId = sessionId;
        _toUId = toUId;
        _sessionType = sessionType;
        _linkStatus = TIOSessionLinkStatusValid;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:TIOSession.class]) {
        return NO;
    }
    
    TIOSession *targetObject = object;
    
    return [self.sessionId isEqual:targetObject.sessionId];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self modelCopy];
}

@end
