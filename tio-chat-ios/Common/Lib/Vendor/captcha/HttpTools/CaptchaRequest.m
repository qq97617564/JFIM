//
//  CaptchaRequest.m
//  captcha_oc
//
//  Created by kean_qi on 2020/5/23.
//  Copyright © 2020 kean_qi. All rights reserved.
//

#import "CaptchaRequest.h"
#import "HttpToolManager.h"
#import "APPHTTPManager.h"

@implementation CaptchaRequest
//获取验证码接口
+ (void)captchaAccept:(CaptchaType )type FinishedBlock:(void(^)(BOOL result,CaptchaRepModel* captchaRepModel))finishedBlock {
    NSString *URLString = @"/anjiCaptcha/get";
    NSString *captchaType =  @"blockPuzzle";
    switch (type) {
        case puzzle:
            captchaType = @"blockPuzzle";
            break;
        case clickword:
        captchaType = @"clickWord";
        break;
            
        default:
            break;
    }
    NSDictionary *patameters = @{
        @"captchaType": captchaType,
        @"distinguishSignatureVerificationMethod": @"ios"
    };
    [APPHTTPManager t_GET:URLString parameters:patameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
            CaptchaRepModel *model = [[CaptchaRepModel alloc]  initWithDictionary:responseObject[@"data"] error:nil];
            finishedBlock(YES,  model);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finishedBlock(NO, nil);
    } retryCount:1];
}

 //校验验证码
+ (void)captchaCheck:(CaptchaType )type PointJson:(NSString*)pointJson Token:(NSString*)token FinishedBlock:(void(^)(BOOL result,CaptchaRepModel* captchaRepModel))finishedBlock {
    NSString *URLString = @"/anjiCaptcha/check";
    NSString *captchaType =  @"blockPuzzle";
    switch (type) {
        case puzzle:
            captchaType = @"blockPuzzle";
            break;
        case clickword:
        captchaType = @"clickWord";
        break;
            
        default:
            break;
    }
    NSDictionary *patameters = @{
        @"pointJson": pointJson,
        @"captchaType": captchaType,
        @"token": token,
        @"distinguishSignatureVerificationMethod": @"ios"
    };
    [APPHTTPManager t_GET:URLString parameters:patameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
            CaptchaRepModel *model = [[CaptchaRepModel alloc]  initWithDictionary:responseObject[@"data"] error:nil];
            finishedBlock(YES,  model);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finishedBlock(NO, nil);
    } retryCount:1];
}
@end
