//
//  SearchAllResult.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "SearchAllResult.h"

@implementation SearchAllResult

+ (instancetype)resultWithChildList:(NSArray *)childList showNumber:(NSInteger)showNumber index:(NSInteger)index title:(nonnull NSString *)title moreTitle:(nonnull NSString *)moreTitle identifier:(nonnull NSString *)identifier
{
    SearchAllResult *model = [SearchAllResult.alloc init];
    model.childList = childList;
    model.showNumber = showNumber;
    model.title = title;
    model.moreTitle = moreTitle;
    model.identifier = identifier;
    model.index = index;
    
    return model;
}

- (NSString *)moreTitle
{
    if (_stateMoreTitle) {
        return _stateMoreTitle[@(_controlState)];
    }
    
    return _moreTitle;
}

@end
