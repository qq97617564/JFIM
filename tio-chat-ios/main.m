//
//  main.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/17.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}


