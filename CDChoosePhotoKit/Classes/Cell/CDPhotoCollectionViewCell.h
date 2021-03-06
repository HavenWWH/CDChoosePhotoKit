//
//  CDPhotoCollectionViewCell.h
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#define kScreenWidthW             [[UIScreen mainScreen] bounds].size.width
#define kScreenHeightH            [[UIScreen mainScreen] bounds].size.height
#define kIs_iPhoneX kScreenWidthW >=375.0f && kScreenHeightH >=812.0f

@class CDPhotoCollectionViewCell;
@protocol CDPhotoCollectionViewCellDelegate <NSObject>

@optional
- (void)selectButonClick: (UIButton *)button cell: (CDPhotoCollectionViewCell *)cell;

- (void)coverPhotoClick: (UIGestureRecognizer *)tapGesture cell: (CDPhotoCollectionViewCell *)cell asset:(PHAsset *)asset;
@end

@interface CDPhotoCollectionViewCell : UICollectionViewCell

- (void)settingSelectArray: (NSMutableArray *)selectArray asset: (PHAsset *)asset size:(CGSize)imageSize index: (NSInteger)index withDelegate: (id<CDPhotoCollectionViewCellDelegate>)delegate;

@property (nonatomic, strong) PHAsset *asset;

- (void)settingSelectButton:(BOOL)isSelect;
@end
