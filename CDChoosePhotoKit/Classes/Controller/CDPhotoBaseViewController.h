//
//  CDPhotoBaseViewController.h
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.

#import <UIKit/UIKit.h>
#import "CDPhotoImageHelper.h"

@interface CDPhotoBaseViewController : UIViewController

// 选择的照片
@property (nonatomic, strong) NSMutableArray *imageDataSource;
// 保存相册中选中的照片
@property (nonatomic, strong) NSMutableArray *selectArray;
// 最大可选择的照片
@property (nonatomic, assign) NSInteger maxCount;

// 是否剪裁
@property (nonatomic, assign)  BOOL isCrop;
// 剪裁比例。只有isCrop为true有效
@property (nonatomic, assign) CGSize cropScale;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *collectionSuperView;

- (void)initCollectionView;



@end
