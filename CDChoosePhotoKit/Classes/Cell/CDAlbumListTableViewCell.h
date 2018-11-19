//
//  CDAlbumListTableViewCell.h
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import <UIKit/UIKit.h>

@interface CDAlbumListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;



@end
