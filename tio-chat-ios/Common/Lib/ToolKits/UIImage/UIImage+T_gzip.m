//
//  UIImage+T_gzip.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/23.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "UIImage+T_gzip.h"

@implementation UIImage (T_gzip)


- (NSData *)compressImageToSize:(NSInteger)toSize scale:(CGFloat)scale
{
    NSData *data = UIImageJPEGRepresentation(self, scale);
    NSUInteger sizeOrigin = [data length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB <= toSize) {
        return data;
    }
    return [self compressImageToSize:toSize scale:0.8 * scale];
}

+ (UIImage *)fileIconWithExt:(NSString *)ext
{
    // file_apk
    // file_m
    // file_pdf
    // file_pic
    // file_ppt
    // file_txt
    // file_unknown
    // file_v
    // file_word
    // file_xls
    // file_zip
    
    
    return [self imageNamed:@"file_unknown"];
}

@end
