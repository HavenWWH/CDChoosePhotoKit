//
//  CDViewController.m
//  CDChoosePhotoKit
//
//  Created by Haven on 11/14/2018.
//  Copyright (c) 2018 Haven. All rights reserved.
//

#import "CDViewController.h"
#import "CDPhotoListController.h"

@interface CDViewController ()
@property (nonatomic, strong) NSMutableArray *selectPhotoArray;
@property (nonatomic, strong) NSMutableArray *cameraMutaArray;
@end

@implementation CDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

// 保存相片到相机胶卷 涉及到相机和相册结合的多选的时候, 相机拍照的时候需要用此方法保存图片, 且再次进入相册时需要将选中的照片传入
- (void)savePhotoToLibary:(UIImage *)image {
    
    __weak typeof(self) weakSelf = self;
    [CDPhotoImageHelper savePhotoWithImage: image success:^{
        
        /** 获取最新照片拍照的图片 */
        PHAsset *PHasset = [CDPhotoImageHelper latestAsset];
        
        ImageModel *item = [ImageModel new];
        item.asset = PHasset;
        [weakSelf.selectPhotoArray addObject: item];
    }];
}


- (IBAction)push:(id)sender {

    CDPhotoListController *vc = [[CDPhotoListController alloc] init];
    vc.selectArray = self.selectPhotoArray;
    vc.maxCount = 6;
    vc.isCrop = false;
//    vc.minimumImageWidth = 100;
    vc.cropScale = CGSizeMake(1, 1);
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    __weak typeof(self) weakSelf = self;
    vc.okClickComplete = ^(NSArray<ImageModel *> *images){

        [weakSelf.cameraMutaArray removeAllObjects];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [images enumerateObjectsUsingBlock:^(ImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (obj.asset && obj.thumbImage) {
             
                    [weakSelf.cameraMutaArray addObject:obj.thumbImage];
                } else {
                    
                    [CDPhotoImageHelper getImageDataWithAsset:obj.asset complete:^(UIImage *image) {
                        
                        if (image) {
                            
                            [weakSelf.cameraMutaArray addObject:image];
                        }
                    }];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // 回主线程刷新数据
                    NSLog(@"cameraMutaArray:%@", weakSelf.cameraMutaArray);
                });
            }];
        });
    };
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)selectPhotoArray {
    
    if (!_selectPhotoArray) {
        _selectPhotoArray = [[NSMutableArray alloc] init];
    }
    return _selectPhotoArray;
}

- (NSMutableArray *)cameraMutaArray {
    if (!_cameraMutaArray) {
        _cameraMutaArray = [NSMutableArray array];
    }
    return _cameraMutaArray;
}
@end
