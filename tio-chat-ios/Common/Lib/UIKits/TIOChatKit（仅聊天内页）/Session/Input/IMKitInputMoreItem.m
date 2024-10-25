//
//  IMKitInputMoreItem.m
//  CawBar
//
//  Created by admin on 2019/11/15.
//

#import "IMKitInputMoreItem.h"

@interface IMKitInputMoreItem ()
@property (copy, nonatomic) NSString *selectorName;
@end

@implementation IMKitInputMoreItem

+ (instancetype)itemWithTitle:(NSString *)title normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage selector:(nonnull NSString *)selector
{
    IMKitInputMoreItem *item = [IMKitInputMoreItem.alloc init];
    item.title = title;
    item.normalImage = normalImage;
    item.selectedImage = selectedImage;
    item.selectorName = selector;
    
    return item;
}

- (SEL)selector
{
    return NSSelectorFromString(_selectorName);
}

@end
