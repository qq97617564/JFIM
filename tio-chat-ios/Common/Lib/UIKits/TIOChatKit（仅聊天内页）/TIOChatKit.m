//
//  IMKit.m
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import "TIOChatKit.h"
#import "IMKitCellLayoutConfig.h"

@implementation TIOChatKit

+ (instancetype)shareSDK
{
    static TIOChatKit *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _cellConfig = [IMKitCellLayoutConfig.alloc init];
        _config = [IMKitConfig.alloc init];
    }
    
    return self;
}

@end
