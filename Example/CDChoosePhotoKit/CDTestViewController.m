//
//  CDTestViewController.m
//  CDChoosePhotoKit_Example
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
//

#import "CDTestViewController.h"

@implementation CDTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 是否剪裁
    self.isCrop = NO;
    self.cropScale = CGSizeMake(1.0, 1.5);
    // 3. 设置可添加图片的最大数
    self.maxCount = 6;
    // 4. 初始化CollectionView
    [self initCollectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
}
@end
