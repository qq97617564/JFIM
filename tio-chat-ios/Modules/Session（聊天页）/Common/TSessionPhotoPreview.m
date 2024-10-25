//
//  TSessionPhotoManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSessionPhotoPreview.h"
#import "HXPhotoPicker.h"
#import "ImportSDK.h"
#import "TPhotoPreviewModel.h"
#import "MBProgressHUD+NJ.h"

@interface TSessionPhotoPreview () <HXPhotoPreviewViewControllerDelegate>
@property (strong, nonatomic) HXPhotoManager *manager;
@property (weak,   nonatomic) UIViewController *onVC;
@property (strong, nonatomic) TIOSession *session;
@property (strong, nonatomic) TPhotoPreviewModel *currentModel;

@property (strong, nonatomic) NSArray<HXCustomAssetModel *> *hx_assetModels;

@end

@implementation TSessionPhotoPreview

- (instancetype)initWithSession:(TIOSession *)session onVC:(nonnull UIViewController *)onVC
{
    self = [super init];
    
    if (self) {
        self.mediaModels = [NSMutableArray array];
        self.onVC = onVC;
        self.session = session;
    }
    
    return self;
}

- (void)addModel:(TPhotoPreviewModel *)model
{
    for (HXCustomAssetModel *assetModel in self.hx_assetModels) {
        if ([assetModel.networkImageURL.absoluteString isEqualToString:model.assetModel.networkImageURL.absoluteString]) {
            return;
        }
    }
    
    // 添加进数组 等待排序
    [self.mediaModels addObject:model];
    // 按消息顺序排序
    NSArray *sortModels = [self.mediaModels sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TPhotoPreviewModel *first = obj1;
        TPhotoPreviewModel *last = obj2;
        return first.timestamp < last.timestamp ? NSOrderedAscending : NSOrderedDescending;
    }];
    self.hx_assetModels = [sortModels valueForKey:@"assetModel"];
}

- (void)cleanModels
{
    [self.mediaModels removeAllObjects];
}

- (void)alertWithCurrentMediaModel:(TPhotoPreviewModel *)currentMediaModel
{
    __block NSInteger index = self.mediaModels.count-1;
    self.currentModel = currentMediaModel;
    
    [self.hx_assetModels enumerateObjectsUsingBlock:^(HXCustomAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.currentModel.assetModel.networkImageURL.absoluteString isEqualToString:obj.networkImageURL.absoluteString])
        {
            index = idx;
            
            *stop = YES;
        }
    }];
    
    [self addPreview:index];
}

#pragma mark - private

- (void)addPreview:(NSInteger)index
{
    HXPhotoManager *photoManager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
    photoManager.configuration.type =   HXConfigurationTypeWXChat;
    photoManager.configuration.saveSystemAblum = YES;
    photoManager.configuration.photoMaxNum = 0;
    photoManager.configuration.videoMaxNum = 0;
    photoManager.configuration.maxNum = 10;
    photoManager.configuration.selectTogether = YES;
    photoManager.configuration.photoCanEdit = NO;
    photoManager.configuration.videoCanEdit = NO;
    
    // 长按事件
    photoManager.configuration.previewRespondsToLongPress = ^(UILongPressGestureRecognizer *longPress, HXPhotoModel *photoModel, HXPhotoManager *manager, HXPhotoPreviewViewController *previewViewController) {
        
        HXPhotoBottomViewModel *model = [[HXPhotoBottomViewModel alloc] init];
        model.title = @"保存";
        model.subTitle = @"这是一个长按事件";
        
        [HXPhotoBottomSelectView showSelectViewWithModels:@[model] headerView:nil showTopLineView:YES cancelTitle:nil selectCompletion:^(NSInteger index, HXPhotoBottomViewModel * _Nonnull model) {
            if (index == 0) {
                if (photoModel.subType == HXPhotoModelMediaSubTypePhoto) {
                    UIImage *image = [YYImageCache.sharedCache getImageForKey:[YYWebImageManager.sharedManager cacheKeyForURL:photoModel.networkPhotoUrl]];
                    if (image) {
                        [HXPhotoTools savePhotoToCustomAlbumWithName:@"TIOChat" photo:image location:nil complete:^(HXPhotoModel * _Nullable model, BOOL success) {
                            if (success) {
                                [MBProgressHUD showSuccess:@"已保存到系统相册" toView:previewViewController.view];
                            }
                        }];
                    }
                } else if (photoModel.subType == HXPhotoModelMediaSubTypeVideo) {
                    NSString *videoFilePath = [HXPhotoTools getVideoURLFilePath:photoModel.videoURL];
                    NSURL *videoFileURL = [NSURL fileURLWithPath:videoFilePath];
                    if ([HXPhotoTools fileExistsAtVideoURL:photoModel.videoURL]) {
                        [HXPhotoTools saveVideoToCustomAlbumWithName:@"TIOChat" videoURL:videoFileURL location:nil complete:^(HXPhotoModel * _Nullable model, BOOL success) {
                            if (success) {
                                [MBProgressHUD showSuccess:@"已保存到系统相册" toView:previewViewController.view];
                            }
                        }];
                    }
                } else {
                    
                }
            }
        } cancelClick:nil];
    };
    [photoManager addCustomAssetModel:self.hx_assetModels];
    /// 这里需要注意一下
    /// 这里的photoManager 和 self.manager 不是同一个
    /// 虽然展示的是一样的内容但是是两个单独的东西
    /// 所以会出现通过外部预览时,网络图片是正方形被裁剪过了样子.这是因为photoManager这个里面的网络图片还未下载的原因
    /// 如果将 photoManager 换成 self.manager 则不会出现这样的现象
    [self.onVC hx_presentPreviewPhotoControllerWithManager:photoManager
                                              previewStyle:HXPhotoViewPreViewShowStyleDark
                                              currentIndex:index
                                                 photoView:nil];
}

@end
