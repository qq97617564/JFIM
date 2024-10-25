//
//  CBIMConfig.m
//  CawBar
//
//  Created by admin on 2019/11/26.
//

#import "TIOConfig.h"

@implementation TIOConfig

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _timeoutInterval = 5;
        _heartBeatInterval = 0;
        _reconnectCount = 30;
    }
    
    return self;
}

+ (instancetype)configWithLinkAddress:(NSString *)linkAddress linkPort:(uint16_t)linkPort httpsAddress:(NSString *)httpsAddress
{
    TIOConfig *config = [TIOConfig.alloc init];
    config.linkAddress = linkAddress;
    config.linkPort = linkPort;
    config.httpsAddress = httpsAddress;
    
    return config;
}

@end
