//
//  IMKitMessageTextContentView.h
//  CawBar
//
//  Created by admin on 2019/11/15.
//

#import "IMKitMessageContentView.h"

NS_ASSUME_NONNULL_BEGIN

@class M80AttributedLabel;

@interface IMKitMessageTextContentView : IMKitMessageContentView

@property (weak, nonatomic) M80AttributedLabel *contentLabel;

@end

NS_ASSUME_NONNULL_END
