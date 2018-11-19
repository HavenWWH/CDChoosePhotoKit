//
//  CDCustomSheet.m
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import "CDAlbumListTableViewCell.h"

@implementation CDAlbumListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
