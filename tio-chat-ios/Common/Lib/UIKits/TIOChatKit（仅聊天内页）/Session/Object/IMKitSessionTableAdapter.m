//
//  IMSessionDataSource.m
//  CawBar
//
//  Created by admin on 2019/11/8.
//

#import "IMKitSessionTableAdapter.h"
#import "IMKitMessageCellFactory.h"
#import "FrameAccessor.h"

@interface IMKitSessionTableAdapter ()
@property (nonatomic, strong) IMKitMessageCellFactory *cellFactory;
@end

@implementation IMKitSessionTableAdapter

- (void)dealloc
{
    NSLog(@"dealloc %@",NSStringFromClass(self.class));
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _cellFactory = [[IMKitMessageCellFactory alloc] init];
    }
    
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.interactor.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id model = [self.interactor.items objectAtIndex:indexPath.row];
    
    if ([model isKindOfClass:[IMKitMessageModel class]])
    {
        cell = [self.cellFactory cellInTable:tableView forMessageMode:model];
        [(IMKitMesssageCell *)cell setDelegate:self.delegate];
    }
    else if ([model isKindOfClass:IMKitTimeModel.class])
    {
        cell = [self.cellFactory cellInTable:tableView forTimeMode:model];
    }
    else if ([model isKindOfClass:IMKitSystemMessageModel.class])
    {
        cell = [self.cellFactory cellInTable:tableView forSystemModel:model];
    }
    else
    {
        NSAssert(1, @"not support model");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    id modelInArray = [[self.interactor items] objectAtIndex:indexPath.row];
    if ([modelInArray isKindOfClass:[IMKitMessageModel class]])
    {
        IMKitMessageModel *model = (IMKitMessageModel *)modelInArray;
        
        CGSize size = [model contentSize:tableView.width];
        CGFloat avatarMarginY = [model avatarMargin].y;

        UIEdgeInsets contentViewInsets = model.contentViewInsets;
        UIEdgeInsets bubbleViewInsets  = model.bubbleViewInsets;
        cellHeight = size.height + contentViewInsets.top + contentViewInsets.bottom + bubbleViewInsets.top + bubbleViewInsets.bottom;
        cellHeight = cellHeight > (model.avatarSize.height + avatarMarginY) ? cellHeight : model.avatarSize.height + avatarMarginY;
    }
    else if ([modelInArray isKindOfClass:[IMKitTimeModel class]])
    {
        cellHeight = [(IMKitTimeModel *)modelInArray height];
    }
    else if ([modelInArray isKindOfClass:[IMKitSystemMessageModel class]])
    {
        cellHeight = [(IMKitSystemMessageModel *)modelInArray height];
    }
    else
    {
        NSAssert(0, @"not support model");
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了cell");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    if (distanceFromBottom <= height + 5) {
        self.interactor.scrollToBottomStatus = 1;
    } else {
        self.interactor.scrollToBottomStatus = 2;
    }
}

@end
