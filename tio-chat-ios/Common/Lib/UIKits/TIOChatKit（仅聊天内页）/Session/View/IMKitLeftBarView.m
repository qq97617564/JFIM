//
//  CBIMLeftBarView.m
//  CawBar
//
//  Created by admin on 2019/11/6.
//

#import "IMKitLeftBarView.h"
#import "FrameAccessor.h"

@implementation IMKitLeftBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSubviews];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)initSubviews
{
    self.badgeView = [IMKitBadgeView viewWithBadgeTip:@""];
    self.badgeView.frame = CGRectMake(0, 8, 0, 0);
    self.badgeView.hidden = YES;
    self.frame = CGRectMake(0.0, 0.0, 50.0, 44.f);
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.badgeView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    for (UIView *view in self.subviews) {
        view.centerY = self.height * .5f;
    }
}

@end
