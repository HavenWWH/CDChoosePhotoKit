//
//  CDPhotoCollectionViewCell.m
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import "CDPhotoCollectionViewCell.h"
#import "CDPhotoImageHelper.h"

@interface CDPhotoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (nonatomic, weak) id<CDPhotoCollectionViewCellDelegate> delegate;
@end


@implementation CDPhotoCollectionViewCell

#pragma mark - Life Cycle Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.coverImageView.userInteractionEnabled = YES;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverPhotoClick:)]];
    
    [self.selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents: UIControlEventTouchUpInside];
}

#pragma mark - Target Methods
- (void)coverPhotoClick: (UIGestureRecognizer *)gesture {
    
    if ([self.delegate respondsToSelector:@selector(coverPhotoClick:cell:)]) {
        [self.delegate coverPhotoClick: gesture cell: self];
    }
}

- (void)selectButtonAction: (UIButton *)button {
    
    if ([self.delegate respondsToSelector:@selector(selectButonClick:cell:)]) {
        [self.delegate selectButonClick: button cell: self];
    }
}

#pragma mark - Public Methods
- (void)settingSelectArray: (NSMutableArray *)selectArray asset: (PHAsset *)asset size:(CGSize)imageSize index: (NSInteger)index withDelegate: (id<CDPhotoCollectionViewCellDelegate>)delegate {
    
    self.delegate = delegate;
    self.asset = asset;
    
    // 相册对象转图片
    __weak typeof(self) weakSelf = self;
    [CDPhotoImageHelper getImageWithAsset: asset tagetSize:imageSize complete:^(UIImage *image) {
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        weakSelf.coverImageView.image = [UIImage imageWithData: imageData];
    }];
    
    self.selectButton.tag = index;
     NSString *path = [CurrentBundle pathForResource: [NSString stringWithFormat: @"ico_check_nomal@%zdx.png", ImageScale] ofType: nil inDirectory: nil];
    [self.selectButton setBackgroundImage: [UIImage imageWithContentsOfFile: path] forState:UIControlStateNormal];
    
    for (ImageModel *item in selectArray) {
        
        if ([item.asset.localIdentifier isEqualToString:asset.localIdentifier]) {
            
            self.selectButton.selected = YES;
            NSString *path = [CurrentBundle pathForResource: [NSString stringWithFormat: @"ico_check_select@%zdx.png", ImageScale] ofType: nil inDirectory: nil];
            [self.selectButton setBackgroundImage:[UIImage imageWithContentsOfFile: path] forState:UIControlStateNormal];
        }
    }
}

- (void)settingSelectButton:(BOOL)isSelect {
    
    self.selectButton.selected = isSelect;
    NSString *path = [CurrentBundle pathForResource: [NSString stringWithFormat: @"ico_check_nomal@%zdx.png", ImageScale] ofType: nil inDirectory: nil];
    [self.selectButton setBackgroundImage: [UIImage imageWithContentsOfFile: path] forState:UIControlStateNormal];
}

//- (void)setSelectButton:(UIButton *)selectButton {
//    [super setSelected:selected];
//    if (selected) {
//
//        [self.selectButton setBackgroundImage:[UIImage imageNamed:@"ico_check_select" inBundle: PhotoKitBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
//    } else {
//
//        [self.selectButton setBackgroundImage: [UIImage imageNamed:@"ico_check_nomal" inBundle: PhotoKitBundle compatibleWithTraitCollection:nil]  forState:UIControlStateNormal];
//    }
//
//}

@end
