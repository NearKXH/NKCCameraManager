//
//  NCMPlayListAudioTableViewCell.m
//  NearCameraManager
//
//  Created by NearKong on 16/8/12.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NCMPlayListAudioTableViewCell.h"

#import "NCMFileDetailImformationModel.h"

@interface NCMPlayListAudioTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileCreateTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *showButton;

@end

@implementation NCMPlayListAudioTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellWithModel:(NCMFileDetailImformationModel *)model isShowButton:(BOOL)isShow {
    _fileNameLabel.text = model.fileName;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _fileCreateTimeLabel.text = [dateFormatter stringFromDate:model.createTime];

    _showButton.hidden = !isShow;
}

@end
