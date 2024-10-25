//
//  TDownloadFileListViewController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/7/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TDownloadFileListViewController.h"
#import "TDownloadFileCell.h"
#import "TDownloadTool.h"

@interface TDownloadFileListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak,    nonatomic) UITableView *tableView;
@property (strong,  nonatomic) NSArray *dataSource;
@end

@implementation TDownloadFileListViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.title = @"下载的文件";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchFiles];
    [self addTableView];
}

- (void)addTableView
{
    UITableView *tableView = [UITableView.alloc initWithFrame:CGRectMake(0, Height_NavBar, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - Height_NavBar) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    [tableView registerClass:TDownloadFileCell.class forCellReuseIdentifier:NSStringFromClass(TDownloadFileCell.class)];
    tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDownloadFileCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TDownloadFileCell.class) forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:@"file_unknown"];
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *path = [TDownloadTool documentPath];
    NSString *filename = self.dataSource[indexPath.row];
    path = [path stringByAppendingPathComponent:filename];
    self.t_callback(self, path);
    
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    NSLog(@"data = %@",data);
}

- (void)fetchFiles
{
    if ([TDownloadTool existFileDocument]) {
        NSFileManager * fileManger = [NSFileManager defaultManager];
        NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:[TDownloadTool documentPath] error:nil];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:dirArray.count];
        for (NSString * str in dirArray) {
            [array addObject:str];
        }
        
        self.dataSource = array;
    }
}

@end
