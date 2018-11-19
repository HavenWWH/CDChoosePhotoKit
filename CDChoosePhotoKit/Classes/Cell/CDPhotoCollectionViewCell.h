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
#define kItemWidth      2 * (kScreenWidthW - 4)/3.0

@class CDPhotoCollectionViewCell;
@protocol CDPhotoCollectionViewCellDelegate <NSObject>

@optional
- (void)selectButonClick: (UIButton *)button cell: (CDPhotoCollectionViewCell *)cell;

- (void)coverPhotoClick: (UIGestureRecognizer *)tapGesture cell: (CDPhotoCollectionViewCell *)cell;
@end

@interface CDPhotoCollectionViewCell : UICollectionViewCell

- (void)settingSelectArray: (NSMutableArray *)selectArray asset: (PHAsset *)asset index: (NSInteger)index withDelegate: (id<CDPhotoCollectionViewCellDelegate>)delegate;

@property (nonatomic, strong) PHAsset *asset;

- (void)settingSelectButton:(BOOL)isSelect;
@end
