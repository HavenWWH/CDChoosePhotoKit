//
//  CDPhotoListController.m
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import "CDPhotoListController.h"
#import "CDPhotoCollectionViewCell.h"
#import "CDShowBigImage.h"
#import <objc/runtime.h>

// 第三方裁剪库
#import "TOCropViewController.h"


@interface CDPhotoListController ()<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, CDPhotoCollectionViewCellDelegate, TOCropViewControllerDelegate>


@property (nonatomic, strong)PHFetchResult *fetchResult;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger dataCount;

@property (nonatomic, strong) CDPhotoCollectionViewCell *selectCell;
// 裁剪照片控制器
@property (nonatomic, strong) TOCropViewController *cropController;

@property (nonatomic, strong) UIImage *selectImage;
@end

@implementation CDPhotoListController

#pragma mark - Life Cycle Methods
- (void)didReceiveMemoryWarning {
    
    NSLog(@"内存警告");
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"控制器销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataCount = self.selectArray.count;
    
    [self creatCollectionView];
    [self changeRightBarButtonItemTitle];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNacigationItemAction)];
}

#pragma mark - Intial Methods

#pragma mark - Target Methods
- (void)cancelNacigationItemAction {
    
    int count = (int)self.selectArray.count;
    for (int index = (int)self.dataCount; index < count; ++index) {
        
        [self.selectArray removeLastObject];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeRightBarButtonItemTitle {
    
    if (self.selectArray.count > 0) {
        
        [self setRightBarButtonItemWithTitle:[NSString stringWithFormat:@"确定(%@)", @(self.selectArray.count)]];
    } else {
        [self setRightBarButtonItemWithTitle:@"取消"];
    }
}

- (void)didClickNavigationBarViewRightButton {

    if (self.selectArray.count > 0) {
        
        self.okClickComplete ? self.okClickComplete(self.selectArray) : nil;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public Methods
- (void)setRightBarButtonItemWithTitle:(NSString *)title {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style: UIBarButtonItemStylePlain target:self action:@selector(didClickNavigationBarViewRightButton)];
}
#pragma mark - Private Method
- (void)scrollsToBottomAnimated:(BOOL)animated {
    [self.view layoutIfNeeded];
    
    CGFloat offset = self.collectionView.contentSize.height - self.collectionView.bounds.size.height;
    if (offset > 0) {
        
        CGFloat width = (kScreenWidthW - 2 * 2) / 3;
        [self.collectionView setContentOffset:CGPointMake(0, offset+ width/2.0) animated:animated];
    }
}

#pragma mark - External Delegate
#pragma mark - CDPhotoCollectionViewCellDelegate
- (void)selectButonClick: (UIButton *)button cell: (CDPhotoCollectionViewCell *)cell {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: button.tag inSection:0];
    self.selectCell = [self collectionView: self.collectionView cellForItemAtIndexPath: indexPath];
    button.selected = !button.selected;
    
    if (button.selected) {
        
        if (self.selectArray.count >= self.maxCount) {
            [CDPhotoImageHelper showAlertWithTittle:[NSString stringWithFormat:@"最多只能选择%@张图片",@(self.maxCount)] message:nil showController:self isSingleAction:YES complete:nil];
            return;
        }
        NSString *path = [CurrentBundle pathForResource: [NSString stringWithFormat: @"ico_check_select@%zdx.png", ImageScale] ofType: nil inDirectory: CurrentBundleName];
        [button setBackgroundImage: [UIImage imageWithContentsOfFile: path] forState:UIControlStateNormal];
        
        if (!self.isCrop) { // 不剪裁
            
            ImageModel *item = [ImageModel new];
            item.asset = self.selectCell.asset;
            [self.selectArray addObject:item];
        } else { // 需要剪裁
            
            __weak typeof(self)  weakSelf = self;
            [CDPhotoImageHelper getImageDataWithAsset: self.selectCell.asset complete:^(UIImage *image,UIImage*HDImage) {

                if (image) {
                    weakSelf.selectImage = image;
                    [weakSelf presentViewController: weakSelf.cropController animated: NO completion:nil];
                }
            }];
        }
    } else {
        NSString *path = [CurrentBundle pathForResource: [NSString stringWithFormat: @"ico_check_nomal@%zdx.png", ImageScale] ofType: nil inDirectory: CurrentBundleName];
        [button setBackgroundImage: [UIImage imageWithContentsOfFile: path] forState:UIControlStateNormal];
        int count = -1;
        for (ImageModel *subItem in self.selectArray.mutableCopy) {
            count ++;
            if ([subItem.asset.localIdentifier isEqualToString:self.selectCell.asset.localIdentifier]) {
                [self.selectArray removeObjectAtIndex:count];
                break;
            }
        }
    }
    
    [self changeRightBarButtonItemTitle];
    
}

// 放大图片
- (void)coverPhotoClick: (UIGestureRecognizer *)tapGesture cell: (CDPhotoCollectionViewCell *)cell {
    
//    UIImageView *clickImageView = (UIImageView*)tapGesture.view;
//    [[CDShowBigImage shareInstance] showBigImage:clickImageView];
}
#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CDPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"CDPhotoCollectionViewCell" forIndexPath:indexPath];
    
    PHAsset *asset = self.fetchResult[indexPath.row];
    
    [cell settingSelectArray: self.selectArray asset: asset index: indexPath.row withDelegate: self];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = (kScreenWidthW - 2 * 2) / 3;
    return CGSizeMake(width, width);
}

#pragma mark - Setter Getter Methods
- (void)creatCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2.0;
    layout.minimumInteritemSpacing = 2.0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    self.collectionView = collectionView;
    [self.view addSubview:self.collectionView];
    collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName: @"CDPhotoCollectionViewCell" bundle: CurrentBundle] forCellWithReuseIdentifier: @"CDPhotoCollectionViewCell"];
    
    [self scrollsToBottomAnimated:NO];
}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {

    [cropViewController dismissViewControllerAnimated: YES completion: nil];
    ImageModel *item = [ImageModel new];
    item.asset = self.selectCell.asset;
    item.thumbImage = image;
    [self.selectArray addObject:item];
    [self changeRightBarButtonItemTitle];
}

- (void)cropViewController:(nonnull TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled {
    
    [cropViewController dismissViewControllerAnimated: YES completion: nil];
    [self.selectCell settingSelectButton: NO];
    int count = -1;
    for (ImageModel *subItem in self.selectArray.mutableCopy) {
        count ++;
        if ([subItem.asset.localIdentifier isEqualToString:self.selectCell.asset.localIdentifier]) {

            [self.selectArray removeObjectAtIndex:count];
            break;
        }
    }
//    [self.collectionView reloadItemsAtIndexPaths: @[[NSIndexPath indexPathForItem: self.selectCell.closeButton.tag inSection: 0]]];
    [self changeRightBarButtonItemTitle];
}

- (TOCropViewController *)cropController {
    _cropController = [[TOCropViewController alloc] initWithCroppingStyle: TOCropViewCroppingStyleDefault image:self.selectImage];
    _cropController.delegate = self;
    _cropController.title = @"裁剪照片";
    // 自定义剪裁框
    _cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetCustom;
    // 锁定比例
    _cropController.aspectRatioLockEnabled = YES;
   // 设置裁剪比例
    CGSize size = self.cropScale;
    if (self.cropScale.height == 0 && self.cropScale.width == 0 && self.isCrop) {
        size = CGSizeMake(1.0, 1.0);
    }
    _cropController.customAspectRatio = size;
    _cropController.aspectRatioPickerButtonHidden = YES;
    _cropController.toolbar.resetButton.hidden = YES;

    return _cropController;
}

- (PHFetchResult *)fetchResult {
    if (!_fetchResult) {
        _fetchResult = [PHAsset fetchAssetsWithMediaType: PHAssetMediaTypeImage options: nil];
    }
    return _fetchResult;
}

@end






