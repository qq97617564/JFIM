//
//  utils.h
//  EHKWeboxDemo
//
//  Created by pill on 2019/11/22.
//  Copyright © 2019 EHK. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EHKWeboxManager.h"
#import "EHKValueAddServiceManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface utils : NSObject
+ (UIColor *)getNavColor;
+(NSString *)getSymbol:(NSString * )type;
+(NSString *)getOrderName:(NSString * )type ;

+(void)configuration:(EHKWeboxManager * )wallet walletid:(NSString *)walletid token:(NSString *)token businessCode:(EHKWEBOX_BUSINESSCODE )businessCode vc:(UIViewController *)sender;

@end

NS_ASSUME_NONNULL_END
