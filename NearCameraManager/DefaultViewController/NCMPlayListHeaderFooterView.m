//
//  NCMPlayListHeaderFooterView.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/12.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMPlayListHeaderFooterView.h"

#import "NCMPlayListModel.h"

@interface NCMPlayListHeaderFooterView ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UIImageView *openImageView;

@property (nonatomic, strong) void (^block)();
@end

@implementation NCMPlayListHeaderFooterView

- (void)updateHeaderFooterViewWithModel:(NCMPlayListModel *)model openBlock:(void (^)())block {
    NSString *imageName = nil;
    NSString *headerName = nil;
    switch (model.modelType) {
    case NCMPlayListModelTypeAudio:
        imageName = @"music";
        headerName = @"音频";
        break;

    case NCMPlayListModelTypeImage:
        imageName = @"pictures";
        headerName = @"图";
        break;

    case NCMPlayListModelTypeVideo:
        imageName = @"film";
        headerName = @"录像";
        break;

    default:
        break;
    }

    _nameLabel.text = headerName;
    _headerImage.image = [UIImage imageNamed:imageName];
    if (model.isOpen) {
        _openImageView.image = [UIImage imageNamed:@"arrowDown"];
    } else {
        _openImageView.image = [UIImage imageNamed:@"arrowRight"];
    }

    _block = block;
}

- (IBAction)openAction:(id)sender {
    if (_block) {
        _block();
    }
}

@end
