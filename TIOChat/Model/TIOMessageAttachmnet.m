//
//  TIOMessageAttachmnet.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOMessageAttachmnet.h"
#import "NSString+tio.h"

@interface TIOMessageAttachmnet ()
@property (assign, nonatomic) NSInteger calltype;
@end

@implementation TIOMessageAttachmnet

- (NSString *)coverurl
{
    return _coverurl.tio_resourceURLString;
}

- (NSString *)url
{
    return _url.tio_resourceURLString;
}

- (NSString *)bizavatar
{
    return _bizavatar.tio_resourceURLString;
}

- (TIORTCType)callType
{
    if (self.calltype == 10) {
        return TIORTCTypeVideo;
    } else if (self.calltype == 11) {
        return TIORTCTypeAudio;
    } else {
        return TIORTCTypeVideo;
    }
}

@end
