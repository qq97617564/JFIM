//
//  TIODataBase.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/21.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIODataBase.h"
#import "FMDB.h"

@implementation TIODataBase

+ (instancetype)shareInstance
{
    static TIODataBase *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}


+ (BOOL)createDataBase {return  YES;}

+ (BOOL)createTable:(NSString *)table {return  YES;}

+ (BOOL)existTable:(NSString *)table {return  YES;}

+ (BOOL)existColumn:(NSString *)column inTable:(NSString *)table {return  YES;}

@end
