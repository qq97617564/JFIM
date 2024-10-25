//
//  IMKitMessageFileContentView.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageFileContentView.h"
#import "TIOChatKit.h"

#import "FrameAccessor.h"

#import "TIOKitTool.h"

@interface IMKitMessageFileContentView ()
/// 文件名label
@property (weak, nonatomic) UILabel *fileNameLabel;
/// 文件图标
@property (weak, nonatomic) UIImageView *fileImage;
/// 文件大小label
@property (weak, nonatomic) UILabel *fileSizeLabel;
@end

@implementation IMKitMessageFileContentView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        UILabel *fileNameLabel = [UILabel.alloc init];
        fileNameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        fileNameLabel.textAlignment = NSTextAlignmentLeft;
        fileNameLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:fileNameLabel];
        self.fileNameLabel = fileNameLabel;
        
        UILabel *fileSizeLabel = [UILabel.alloc init];
        fileSizeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        fileSizeLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:fileSizeLabel];
        self.fileSizeLabel = fileSizeLabel;
        
        UIImageView *fileImage = [UIImageView.alloc init];
        [self addSubview:fileImage];
        self.fileImage = fileImage;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIEdgeInsets contentInsets = self.messageModel.contentViewInsets;
    
    [self.fileNameLabel sizeToFit];
    if (self.fileNameLabel.width > self.width - contentInsets.left - contentInsets.right - _fileImage.width - 10) {
        self.fileNameLabel.width = self.width - contentInsets.left - contentInsets.right - _fileImage.width - 10;
    }
    self.fileNameLabel.left = contentInsets.left;
    self.fileNameLabel.top = 8;
    self.fileNameLabel.height = 22;
    
    [self.fileSizeLabel sizeToFit];
    self.fileSizeLabel.left = contentInsets.left;
    self.fileSizeLabel.top = self.fileNameLabel.bottom+4;
    self.fileSizeLabel.height = 20;
    
    _fileImage.right = self.width - contentInsets.right;
    _fileImage.centerY = self.middleY;
}

- (void)refreshData:(IMKitMessageModel *)messageModel
{
    [super refreshData:messageModel];
    
    IMKitMessageSetting *setting = [TIOChatKit.shareSDK.config setting:messageModel.message];
    TIOMessage * message = messageModel.message;
    
    self.fileNameLabel.textColor = setting.textColor;
    self.fileNameLabel.font = setting.font;
    self.fileNameLabel.text = message.attachmentObjects.firstObject.filename;
    
    self.fileSizeLabel.text = [TIOKitTool fileSize:message.attachmentObjects.firstObject.size];
    
    /*
    TIOFileTypePDF  = 1, ///< PDF
    TIOFileTypeTXT  = 2, ///< TXT
    TIOFileTypeDOC  = 3, ///< DOC
    TIOFileTypeXLS  = 4, ///< XLS
    TIOFileTypePPT  = 5, ///< PPT
    TIOFileTypeAPK  = 6, ///< APK
    TIOFileTypeIMG  = 7, ///< IMG
    TIOFileTypeZIP  = 8, ///< ZIP
    TIOFileTypeVIDEO= 9, ///< VIDEO
    TIOFileTypeAUDIO= 10,///< AUDIO
    TIOFileTypeOTHER= 11,///< OTHER
     */
    switch (message.attachmentObjects.firstObject.fileicontype) {
        case TIOFileTypePDF:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_pdf"];
            break;
        }
        case TIOFileTypeTXT:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_txt"];
            break;
        }
        case TIOFileTypeDOC:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_word"];
            break;
        }
        case TIOFileTypeXLS:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_xls"];
            break;
        }
        case TIOFileTypePPT:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_ppt"];
            break;
        }
        case TIOFileTypeAPK:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_apk"];
            break;
        }
        case TIOFileTypeIMG:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_pic"];
            break;
        }
        case TIOFileTypeZIP:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_zip"];
            break;
        }
        case TIOFileTypeVIDEO:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_v"];
            break;
        }
        case TIOFileTypeAUDIO:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_m"];
            break;
        }
        case TIOFileTypeOTHER:
        {
            self.fileImage.image = [UIImage imageNamed:@"file_unknown"];
            break;
        }
        
        default:
            self.fileImage.image = [UIImage imageNamed:@"file_unknown"];
            break;
    }
    
    [self.fileImage sizeToFit];
}

@end
