//
//  TAlertControllerTheme.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TAlertTheme.h"

NSString* const TAlertActionBackgroundImageKey = @"TAlertActionBackgroundImageKey";
NSString* const TAlertActionBackgroundColorKey = @"TAlertActionBackgroundColorKey";
NSString* const TAlertActionHlightBackgroundColorKey = @"TAlertActionHlightBackgroundColorKey";

@interface TAlertTheme ()
@property (strong, nonatomic) NSMutableDictionary *actionTitleAttributesDictionary;
@property (strong, nonatomic) NSMutableDictionary *actionAttributesDictionary;
@end

@implementation TAlertTheme

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightBold], NSForegroundColorAttributeName: UIColor.blackColor};
        self.messageTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightBold], NSForegroundColorAttributeName: UIColor.blackColor};
        self.titleBackgroundColor = CBColorRGB(255, 214, 0);
        
        self.actionTitleAttributesDictionary = [NSMutableDictionary dictionary];
        self.actionAttributesDictionary = [NSMutableDictionary dictionary];
        
        // TAlertActionStyleDefault
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleDefault)] = [NSMutableDictionary dictionary];
        self.actionAttributesDictionary[@(TAlertActionStyleDefault)] = [NSMutableDictionary dictionary];
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleDefault)][@(UIControlStateNormal)] = @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColor.blackColor};
        self.actionTitleAttributesDictionary[@(TAlertActionStyleDefault)][@(UIControlStateDisabled)] = @{NSFontAttributeName :[UIFont systemFontOfSize:16], NSForegroundColorAttributeName: UIColor.blackColor};
        
        self.actionAttributesDictionary[@(TAlertActionStyleDefault)] = @{TAlertActionBackgroundColorKey : [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0],TAlertActionHlightBackgroundColorKey : [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0]};
        
        // TAlertActionStyleCancel
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleCancel)] = [NSMutableDictionary dictionary];
        self.actionAttributesDictionary[@(TAlertActionStyleCancel)] = [NSMutableDictionary dictionary];
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleCancel)][@(UIControlStateNormal)] = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]};
        self.actionTitleAttributesDictionary[@(TAlertActionStyleCancel)][@(UIControlStateDisabled)] = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColor.whiteColor};
        
        self.actionAttributesDictionary[@(TAlertActionStyleCancel)] = @{TAlertActionBackgroundColorKey : [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0] , TAlertActionHlightBackgroundColorKey : [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0]};
        
        // TAlertActionStyleDone
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleDone)] = [NSMutableDictionary dictionary];
        self.actionAttributesDictionary[@(TAlertActionStyleDone)] = [NSMutableDictionary dictionary];
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleDone)][@(UIControlStateNormal)] = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColor.whiteColor};
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleDone)][@(UIControlStateDisabled)] = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColor.whiteColor};
        self.actionAttributesDictionary[@(TAlertActionStyleDone)] = @{TAlertActionBackgroundColorKey : [UIColor colorWithRed:76/255.0 green:148/255.0 blue:232/255.0 alpha:1.0], TAlertActionHlightBackgroundColorKey : [UIColor colorWithRed:38/255.0 green:124/255.0 blue:249/255.0 alpha:1.0]};
        
        // TAlertActionStyleWhite
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleWhite)] = [NSMutableDictionary dictionary];
        self.actionAttributesDictionary[@(TAlertActionStyleWhite)] = [NSMutableDictionary dictionary];
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleWhite)][@(UIControlStateNormal)] = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColor.blackColor};
        
        self.actionTitleAttributesDictionary[@(TAlertActionStyleWhite)][@(UIControlStateDisabled)] = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithRed:76/255.0 green:148/255.0 blue:232/255.0 alpha:1.0]};
        self.actionAttributesDictionary[@(TAlertActionStyleWhite)] = @{TAlertActionBackgroundColorKey : UIColor.whiteColor, TAlertActionHlightBackgroundColorKey : UIColor.whiteColor};
        
        self.contentBackgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (void)setActionTitleAttributes:(NSDictionary<NSString *,id> *)titleTextAttributes forState:(UIControlState)state forActionStyle:(TAlertActionStyle)style
{
    self.actionTitleAttributesDictionary[@(style)][@(state)] = titleTextAttributes;
}

- (NSDictionary<NSString *,id> *)actionTitleAttributesForState:(UIControlState)state forActionStyle:(TAlertActionStyle)style
{
    return self.actionTitleAttributesDictionary[@(style)][@(state)];
}

- (NSDictionary<NSString *,id> *)actionAttributesForActionStyle:(TAlertActionStyle)style
{
    return self.actionAttributesDictionary[@(style)];
}

@end
