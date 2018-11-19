//
//  CDPhotoBaseViewController.m
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import "CDPhotoBaseViewController.h"
#import "CDAlbumListController.h"
#import "CDCustomSheet.h"
#import "CDShowBigImage.h"

// 第三方裁剪库
#import "TOCropViewController.h"

@class CDPhotoChooseCell;
@protocol CDPhotoChooseCellDelegate <NSObject>

@optional
- (void)deleteButonClick: (UIButton *)button cell: (CDPhotoChooseCell *)cell;

- (void)coverImageClick: (UIGestureRecognizer *)tapGesture cell: (CDPhotoChooseCell *)cell;
@end

@interface CDPhotoChooseCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *choosePhotoImageV;
@property (nonatomic, weak) id<CDPhotoChooseCellDelegate> delegate;

- (void)settingDataArray: (NSMutableArray *)imageData indexRow: (NSInteger)index withDelegate: (id<CDPhotoChooseCellDelegate>)delegate;

@end


@implementation CDPhotoChooseCell

#pragma mark - Intial Methods
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview: self.choosePhotoImageV];
    [self.contentView addSubview:self.deleteButton];
}

#pragma mark - Target Methods
- (void)deleteButtonClick: (UIButton *)deleteButton {
    
    if ([self.delegate respondsToSelector:@selector(deleteButonClick:cell:)]) {
        [self.delegate deleteButonClick: deleteButton cell: self];
    }
}

- (void)choosePhotoImageVTap: (UITapGestureRecognizer *)gesture {
    
    if ([self.delegate respondsToSelector:@selector(coverImageClick:cell:)]) {
        [self.delegate coverImageClick: gesture cell: self];
    }
}

#pragma mark - Public Methods
- (void)settingDataArray: (NSMutableArray *)imageData indexRow: (NSInteger)index withDelegate: (id<CDPhotoChooseCellDelegate>)delegate {
    
    self.delegate = delegate;
    self.choosePhotoImageV.tag = index;
    self.deleteButton.tag = index;

    
    if (index == imageData.count) {
        NSString *path = [CurrentBundle pathForResource: [NSString stringWithFormat: @"plus@%zdx.png", ImageScale] ofType: nil inDirectory: CurrentBundleName];
        self.choosePhotoImageV.image = [UIImage imageWithContentsOfFile: path];
        self.deleteButton.hidden = YES;
    } else {
        
        self.choosePhotoImageV.image = imageData[index];
        self.deleteButton.hidden = NO;
    }
}

#pragma mark - Setter Getter Methods
- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        
        _deleteButton = [[UIButton alloc] initWithFrame: CGRectMake(self.frame.size.width - 30, 0, 30, 30)];
        NSString *path = [CurrentBundle pathForResource: [NSString stringWithFormat: @"close@%zdx.png", ImageScale] ofType: nil inDirectory: CurrentBundleName];
        [_deleteButton setImage: [UIImage imageWithContentsOfFile: path] forState: UIControlStateNormal];
        [_deleteButton addTarget: self action:@selector(deleteButtonClick:) forControlEvents: UIControlEventTouchUpInside];
    }
    return _deleteButton;
}



- (UIImageView *)choosePhotoImageV
{
    if (!_choosePhotoImageV) {
        
        _choosePhotoImageV = [[UIImageView alloc] initWithFrame: CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        _choosePhotoImageV.userInteractionEnabled = YES;
        _choosePhotoImageV.contentMode = UIViewContentModeScaleAspectFill;
        _choosePhotoImageV.clipsToBounds = YES;
        [_choosePhotoImageV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePhotoImageVTap:)]];
        
    }
    return _choosePhotoImageV;
}
@end


// 控制器
@interface CDPhotoBaseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, CDCustomSheetDelegate, CDPhotoChooseCellDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) TOCropViewController *cropController;
@property (nonatomic, strong) UIImage *selectImage;

@end

@implementation CDPhotoBaseViewController

#pragma mark - Life Cycle Methods
- (void)dealloc {
    
    NSLog(@"销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollsToBottomAnimated: NO];
}


#pragma mark - Private Method
- (void)dismissController {
    
    [self dismissViewControllerAnimated: YES completion:nil];
}

- (void)scrollsToBottomAnimated:(BOOL)animated {
    
    [self.view layoutIfNeeded];
    CGFloat offset = self.collectionView.contentSize.width - self.collectionView.bounds.size.width;
    if (offset > 0) {
        [self.collectionView setContentOffset:CGPointMake(offset, 0) animated:animated];
    }
}

// 保存相片到相机胶卷
- (void)savePhotoToLibary:(UIImage *)image {
    
    __weak typeof(self) weakSelf = self;
    [CDPhotoImageHelper savePhotoWithImage: image success:^{
        
        /** 获取最新照片拍照的图片 */
        PHAsset *PHasset = [CDPhotoImageHelper latestAsset];
        
        ImageModel *item = [ImageModel new];
        item.asset = PHasset;
        [weakSelf.selectArray addObject: item];
        
        [CDPhotoImageHelper getImageDataWithAsset:item.asset complete:^(UIImage *image,UIImage*HDImage) {
            
            if (image) {
                [weakSelf.imageDataSource addObject:image];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.collectionView reloadData];
            });
        }];
    }];
}

#pragma mark - Target Methods
- (void)photoListDidClick {
    
    // 请求相册和相机权限
    __weak typeof(self) weakSelf = self;
    [CDPhotoImageHelper requestPhotoAuth:^(CDCaremaPhotoAuthStatus status) {
        
        if (status == CDCaremaPhotoAuthStatusAuthorized) { // 相册可用
            [CDPhotoImageHelper requestCameraAuth:^(CDCaremaPhotoAuthStatus status) {
                
                if (status == CDCaremaPhotoAuthStatusAuthorized) { // 相机可用
                    if (weakSelf.selectArray.count >= weakSelf.maxCount) {
                        [CDPhotoImageHelper showAlertWithTittle:[NSString stringWithFormat:@"最多只能选择%@张图片",@(self.maxCount)] message:nil showController:self isSingleAction:YES complete:nil];
                        return;
                    }
                     NSArray *array = @[@"相机", @"相册"];
                     CDCustomSheet *sheet = [[CDCustomSheet alloc] initWithButtons:array isTableView: NO sheeType: 0];
                     sheet.delegate = self;
                     weakSelf.view.userInteractionEnabled = YES;
                     [weakSelf.view addSubview:sheet];
                } else {
                    [CDPhotoImageHelper showAndJumpWithVc: self msg: @"需要你的同意，来使用相机拍摄反馈图片"];
                }
            }];
        } else {
            [CDPhotoImageHelper showAndJumpWithVc: self msg: @"需要你的同意，来访问相册上传反馈图片"];
        }
    }]; 
}

#pragma mark - MLCustomSheetDelegate
- (void)clickButton:(NSUInteger)buttonTag sheetCount:(NSUInteger)sheet
{
    switch (buttonTag) {
        case 999: { //取消
           
        }
            break;
        case 0: { //照相机
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case 1://本地相簿
        {
            CDAlbumListController *vc = [[CDAlbumListController alloc] init];
            vc.selctImageArray = self.selectArray;
            vc.maxCount = self.maxCount;
            vc.isCrop = self.isCrop;
            if (self.isCrop) vc.cropScale = self.cropScale;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            __weak CDPhotoBaseViewController *weakSelf = self;
            vc.okClickComplete = ^(NSArray<ImageModel *> *images){
                
                [weakSelf.imageDataSource removeAllObjects];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    [images enumerateObjectsUsingBlock:^(ImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if (obj.asset && obj.thumbImage) {
                            
                            [weakSelf.imageDataSource addObject:obj.thumbImage];
                        } else {
                            
                            [CDPhotoImageHelper getImageDataWithAsset:obj.asset complete:^(UIImage *image,UIImage*HDImage) {
                                if (image) {
                                    [weakSelf.imageDataSource addObject:image];
                                }
                            }];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [weakSelf.collectionView reloadData];
                            [weakSelf scrollsToBottomAnimated: NO];
                        });
                    }];
                });
            };
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - CDPhotoChooseCellDelegate
- (void)deleteButonClick:(UIButton *)button cell:(CDPhotoChooseCell *)cell {
    
    if (self.selectArray.count != 0) {
        [self.selectArray removeObjectAtIndex: button.tag];
    }
    if (self.imageDataSource.count != 0) {
        [self.imageDataSource removeObjectAtIndex: button.tag];
    }
    [self.collectionView reloadData];
}

// 图片cell点击
- (void)coverImageClick:(UIGestureRecognizer *)tapGesture cell:(CDPhotoChooseCell *)cell {
    
    UIImageView *clickImageView = (UIImageView*)tapGesture.view;
    NSInteger index = clickImageView.tag;
    if (index == self.imageDataSource.count) {
        
        [self photoListDidClick];
    } else {
        
        [[CDShowBigImage shareInstance] showBigImage:clickImageView];
    }
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.imageDataSource.count == 0) {
        return 1;
    } else {
        return self.imageDataSource.count + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CDPhotoChooseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CDPhotoChooseCell"forIndexPath: indexPath];
    [cell settingDataArray: self.imageDataSource indexRow: indexPath.row withDelegate: self];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"点击了ITEM");
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}


#pragma mark -   imagepicker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        __weak typeof(self) weakSelf = self;
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        self.selectImage = image;
        
        if (!self.isCrop) {
            
            [picker dismissViewControllerAnimated: YES completion:nil];
            
            [self savePhotoToLibary: image];
        } else { // 剪裁
            
            [picker dismissViewControllerAnimated: NO completion:^{
                
                [weakSelf presentViewController: weakSelf.cropController animated: NO completion:nil];
            }];
        }
    }
}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
    
    [cropViewController dismissViewControllerAnimated: YES completion: nil];
    
    [self savePhotoToLibary: image];
}

#pragma mark - Init Methods -
- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(100, 100);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame: CGRectZero collectionViewLayout: layout];
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor grayColor];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if (self.collectionSuperView) {
        
        self.collectionView.frame = CGRectMake(0, 0, self.collectionSuperView.frame.size.width, self.collectionSuperView.frame.size.height);
        [self.collectionSuperView addSubview:self.collectionView];
    } else {
        
        self.collectionView.frame = CGRectMake(50, 200, 400, 100);
        self.collectionView.center = self.view.center;
        [self.view addSubview: self.collectionView];
    }
    
    [self.collectionView registerClass:[CDPhotoChooseCell class]  forCellWithReuseIdentifier: @"CDPhotoChooseCell"];
}


- (TOCropViewController *)cropController {
    
    _cropController = [[TOCropViewController alloc] initWithCroppingStyle: TOCropViewCroppingStyleDefault image: self.selectImage];
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

#pragma mark - Setter Getter Methods
- (NSMutableArray*)imageDataSource {
    if (!_imageDataSource ) {
        _imageDataSource = [NSMutableArray array];
    }
    return _imageDataSource;
}

- (NSMutableArray *)selectArray {
    if (!_selectArray ) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}



@end





