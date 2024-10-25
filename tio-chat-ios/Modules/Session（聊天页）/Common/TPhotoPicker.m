//
//  TPhotoPicker.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TPhotoPicker.h"
#import "HXPhotoPicker.h"
#import "ImportSDK.h"
#import "TMessageMaker.h"

#import "MBProgressHUD+NJ.h"

@interface TPhotoPicker ()
@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXPhotoManager *cameraManager;

@end

@implementation TPhotoPicker

- (instancetype)initWithSession:(TIOSession *)session controller:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        self.session = session;
        self.controller = vc;
    }
    return self;
}

- (HXPhotoManager *)manager
{
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        _manager.configuration.type = HXConfigurationTypeWXChat;
        _manager.configuration.maxNum = 6;
        _manager.configuration.photoMaxNum = 5;
        _manager.configuration.videoMaxNum = 1;
        _manager.configuration.openCamera = NO;
        _manager.configuration.requestImageAfterFinishingSelection = YES;
    }
    return _manager;
}

- (HXPhotoManager *)cameraManager
{
    if (!_cameraManager) {
        _cameraManager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        _cameraManager.configuration.openCamera = YES;
        _cameraManager.configuration.saveSystemAblum = NO;
        _cameraManager.configuration.customAlbumName = @"TIOChat";
        _cameraManager.configuration.customCameraType = HXPhotoCustomCameraTypePhoto;
    }
    return _cameraManager;
}

- (void)fetchPhotosAndVideosWithView:(UIView *)view
{
    [self.manager clearSelectedList];
    CBWeakSelf
    [self.controller hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        
        CBStrongSelfElseReturn
        CBWeakSelf
        
        [allList enumerateObjectsUsingBlock:^(HXPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CBStrongSelfElseReturn
            
            if (obj.subType == HXPhotoModelMediaSubTypePhoto)
            {
                // 图片
                
                if (obj.type != HXPhotoModelMediaTypeCameraPhoto)
                {
                    __block TIOMessage *message = nil;
                    
                    if (obj.type == HXPhotoModelMediaTypePhoto)
                    {
                        CGSize size;
                        if (isOriginal) {
                            size = PHImageManagerMaximumSize;
                        }else {
                            size = CGSizeMake(obj.imageSize.width * 0.5, obj.imageSize.height * 0.5);
                        }
                        [obj requestPreviewImageWithSize:size startRequestICloud:^(PHImageRequestID iCloudRequestId, HXPhotoModel * _Nullable model) {
                            // 如果图片是在iCloud上的话会先走这个方法再去下载
                        } progressHandler:^(double progress, HXPhotoModel * _Nullable model) {
                            // iCloud的下载进度
                        } success:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
                            // image
                            // 发送图片
                            [MBProgressHUD showLoading:@"正在上传" toView:view];
                            message = [TMessageMaker messageForImage:image session:self.session];
                            [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
                                [MBProgressHUD hideHUDForView:view];
                                if (error) {
                                    [MBProgressHUD showError:error.localizedDescription toView:view];
                                }
                            }];
                        } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
                            // 获取失败
                        }];
                    }
                    else if (obj.type == HXPhotoModelMediaTypePhotoGif)
                    {
                        // GIF
                        [obj requestImageDataStartRequestICloud:nil progressHandler:nil success:^(NSData * _Nullable imageData, UIImageOrientation orientation, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
                            [MBProgressHUD showLoading:@"正在上传" toView:view];
                            message = [TMessageMaker messageForImageData:imageData session:self.session ext:@"gif"];
                            // 发送
                            [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
                                [MBProgressHUD hideHUDForView:view];
                                if (error) {
                                    [MBProgressHUD showError:error.localizedDescription toView:view];
                                }
                            }];
                        } failed:nil];
                    }
                }
            }
            else
            {
                // 视频
                
                if (obj.type == HXPhotoModelMediaTypeVideo)
                {
                    // 相册里的视频
                    [MBProgressHUD showLoading:@"正在上传" toView:view];
                    TIOMessage *message = [TMessageMaker messageForVideoURL:obj.videoURL session:self.session];
                    [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
                        [MBProgressHUD hideHUDForView:view];
                        if (error) {
                            [MBProgressHUD showError:error.localizedDescription toView:view];
                        }
                    }];
                }
                else
                {
                    // 本地视频或者网络视频
                }
            }
            
        }];
    } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        
    }];
}

- (void)fetchCameraWithView:(UIView *)view
{
    [self.controller hx_presentCustomCameraViewControllerWithManager:self.cameraManager done:^(HXPhotoModel *model, HXCustomCameraViewController *viewController) {
        
        TIOMessage *message = [TMessageMaker messageForImage:model.previewPhoto session:self.session];
        [MBProgressHUD showLoading:@"正在上传" toView:view];
        [TIOChat.shareSDK.chatManager sendMessage:message completionHandler:^(NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:view];
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:view];
            }
        }];
        
    } cancel:^(HXCustomCameraViewController *viewController) {
        
    }];
}

@end
