//
//  IMSessionConfigurator.m
//  CawBar
//
//  Created by admin on 2019/11/12.
//

#import "IMKitSessionConfigurator.h"
#import "TIOSessionViewController.h"
#import "IMKitSessionTableAdapter.h"
#import "IMKitSessionLayoutImpl.h"
#import "IMKitSessionInteractorImpl.h"
#import "IMKitSessionDataSourceImpl.h"
#import "ImportSDK.h"

@interface IMKitSessionConfigurator ()

@property (nonatomic, strong) IMKitSessionInteractorImpl   *interactor;
@property (nonatomic, strong) IMKitSessionTableAdapter     *tableAdapter;

@end

@implementation IMKitSessionConfigurator

- (void)dealloc
{
    NSLog(@"dealloc %@",NSStringFromClass(self.class));
}

- (void)setup:(TIOSessionViewController *)sessionVC
{
//    TIOSession *session = sessionVC.session;
    
    IMKitSessionDataSourceImpl *dataSource = [IMKitSessionDataSourceImpl.alloc initWithSession:sessionVC.session sessionConfig:sessionVC.sessionConfig];
    IMKitSessionLayoutImpl *layout = [IMKitSessionLayoutImpl.alloc initWithSession:sessionVC.session sessionConfig:[sessionVC sessionConfig]];
    layout.tableView = sessionVC.tableView;
    layout.inputView = sessionVC.sessionInputView;
    
    _interactor = [IMKitSessionInteractorImpl.alloc initWithSession:sessionVC.session sessionConfig:[sessionVC sessionConfig]];
    _interactor.dataSource = dataSource;
    _interactor.layout = layout;
    _interactor.delegate = sessionVC;
    
    [layout setDelegate:_interactor];
    
    _tableAdapter = [IMKitSessionTableAdapter.alloc init];
    _tableAdapter.interactor = _interactor;
    _tableAdapter.delegate = sessionVC;
    
    sessionVC.tableView.dataSource = _tableAdapter;
    sessionVC.tableView.delegate = _tableAdapter;
    
    [sessionVC setInteractor:_interactor];
    [_interactor resetLayout];
}

@end
