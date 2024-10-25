//
//  IMKitKeyInfo.m
//  CawBar
//
//  Created by admin on 2019/11/20.
//

#import "IMKitKeyInfo.h"
#import "TIOKitTool.h"

NSNotificationName const IMKitKeyboardWillChangeFrameNotification = @"IMKitKeyboardWillChangeFrameNotification";
NSNotificationName const IMKitKeyboardWillHideNotification = @"IMKitKeyboardWillHideNotification";

@implementation IMKitKeyInfo

@synthesize keyboardHeight = _keyboardHeight;

+ (instancetype)instance
{
    static IMKitKeyInfo *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IMKitKeyInfo alloc] init];
    });
    return instance;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}


- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame   = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _isVisiable = endFrame.origin.y != TIOKitTool.keyWindow.frame.size.height;
    _keyboardHeight = _isVisiable? endFrame.size.height: 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:IMKitKeyboardWillChangeFrameNotification object:nil userInfo:notification.userInfo];
}



- (void)keyboardWillHide:(NSNotification *)notification
{
    _isVisiable = NO;
    _keyboardHeight = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:IMKitKeyboardWillHideNotification object:nil userInfo:notification.userInfo];
}


@end
