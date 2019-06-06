//
//  CDPhotoImageHelper.m
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.


#import "CDPhotoImageHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>



@implementation CDPhotoImageHelper

// 请求相册访问权限
+ (void)requestPhotoAuth:(void(^)(CDCaremaPhotoAuthStatus status))callback {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusNotDetermined) { // 未授权
            if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
                [self executeCallback:callback status: CDCaremaPhotoAuthStatusAuthorized];
            } else {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        [self executeCallback:callback status:CDCaremaPhotoAuthStatusAuthorized];
                    } else if (status == PHAuthorizationStatusDenied) {
                        [self executeCallback:callback status: CDCaremaPhotoAuthStatusDenied];
                    } else if (status == PHAuthorizationStatusRestricted) {
                        [self executeCallback:callback status: CDCaremaPhotoAuthStatusRestricted];
                    }
                }];
            }
        } else if (authStatus == ALAuthorizationStatusAuthorized) {
            
            [self executeCallback:callback status:CDCaremaPhotoAuthStatusAuthorized];
        } else if (authStatus == ALAuthorizationStatusDenied) {
            
            [self executeCallback:callback status:CDCaremaPhotoAuthStatusDenied];
        } else if (authStatus == ALAuthorizationStatusRestricted) {
            [self executeCallback:callback status:CDCaremaPhotoAuthStatusRestricted];
        }
    } else {
        [self executeCallback:callback status:CDCaremaPhotoAuthStatusNotSupport];
    }
}

// 请求相机权限
+ (void)requestCameraAuth:(void(^)(CDCaremaPhotoAuthStatus status))callback {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    [self executeCallback:callback status:CDCaremaPhotoAuthStatusAuthorized];
                } else {
                    [self executeCallback:callback status:CDCaremaPhotoAuthStatusDenied];
                }
            }];
        } else if (authStatus == AVAuthorizationStatusAuthorized) {
            [self executeCallback:callback status:CDCaremaPhotoAuthStatusAuthorized];
        } else if (authStatus == AVAuthorizationStatusDenied) {
            [self executeCallback:callback status:CDCaremaPhotoAuthStatusDenied];
        } else if (authStatus == AVAuthorizationStatusRestricted) {
            [self executeCallback:callback status:CDCaremaPhotoAuthStatusRestricted];
        }
    } else {
        [self executeCallback:callback status:CDCaremaPhotoAuthStatusNotSupport];
    }
}


// 获取相册列表
+ (void)getAlbumListWithAscend:(BOOL)isAscend complete:(void (^)(NSArray<PHFetchResult *> *))complete {
    PHFetchOptions *imageOptions = [[PHFetchOptions alloc] init];
    imageOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:isAscend]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:imageOptions];
    
    
    PHFetchOptions *customOptions = [[PHFetchOptions alloc] init];
    customOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    customOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:isAscend]];
    PHFetchResult *customPhotos = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:customOptions];
    
    NSArray *list = @[allPhotos, customPhotos];
    complete?complete(list):nil;
}

// 获取指定大小的图片
+ (void)getImageWithAsset:(PHAsset *)asset tagetSize:(CGSize)size complete:(void(^)(UIImage *))complete {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // PHImageRequestOptionsResizeModeFast 不设置这种方式获取图片的话, 卡顿很严重,
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options: options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                complete?complete(result):nil;
            });
        });
    }];
}

+ (void)getImageDataWithAsset:(PHAsset *)asset complete:(void (^)( UIImage*))complete {
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    // PHImageRequestOptionsResizeModeFast 不设置这种方式获取图片的话, 卡顿很严重,
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.synchronous = YES;
    option.networkAccessAllowed = true;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options: option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

        complete?complete(result):nil;
    }];
}


#pragma mark - <  获取相册里的所有图片的PHAsset对象  >
+ (NSArray *)getAllPhotosAssetInAblumCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    // 存放所有图片对象
    NSMutableArray *assets = [NSMutableArray array];
    
    // 是否按创建时间排序
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    // 获取所有图片对象
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    // 遍历
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [assets addObject:asset];
    }];
    return assets;
}


+ (BOOL)isOpenLibaryAuthority {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        return  NO;
    }return YES;
}


+ (BOOL)isOpenCaremaAuthority{
    
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}


+ (void)jumpToSetting {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

+ (void)showAlertWithTittle:(NSString *)title message:(NSString *)message showController:(UIViewController *)controller isSingleAction:(BOOL)isSingle complete:(void (^)(NSInteger))complete{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        complete?complete(0):nil;
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        complete?complete(1):nil;
    }];
    if (!isSingle) {
        [alertController addAction:cancleAction];
    }
    [alertController addAction:confirmAction];
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void)getAssetWithImage:(UIImage *)image getAssetSuccess:(void(^)(PHAsset *asset))getSuccess {
    
    __block NSString *assetId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        // 保存相片到相机胶卷，并返回标识
        if (@available(iOS 9.0, *)) {
            assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        } else {
            assetId = (NSString *)[PHAssetChangeRequest creationRequestForAssetFromImage:image];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        // 根据标识获得相片对象
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].lastObject;
        getSuccess(asset);
    }];
}

// 提示权限并跳转
+ (void)showAndJumpWithVc: (UIViewController *)viewController msg: (NSString *)tipMsg {

    [CDPhotoImageHelper  showAlertWithTittle: tipMsg message:nil showController: viewController isSingleAction:NO complete:^(NSInteger index) {
        if (index == 1) {
            [CDPhotoImageHelper jumpToSetting];
        }
    }];
}
// 获取相册中最新的一张图片
+ (PHAsset *)latestAsset {
    
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending: NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    return [assetsFetchResults firstObject];
}
// 保存相片到相机胶卷
+ (void)savePhotoWithImage: (UIImage *)image success: (void(^)(void))success {
    
    // 保存相片到相机胶卷
    NSError *error = nil;
    __block PHObjectPlaceholder *createdAsset = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        
        // iOS9 后才能使用
        if (@available(iOS 9.0, *)) {
            createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
        } else {
            createdAsset = (PHObjectPlaceholder *)[PHAssetChangeRequest creationRequestForAssetFromImage:image];
        }
    } error: &error];
    if (error) {
        NSLog(@"保存相册失败");
    } else {
        success();
    }
}

#pragma mark - callback
+ (void)executeCallback:(void (^)(CDCaremaPhotoAuthStatus))callback status:(CDCaremaPhotoAuthStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (callback) {
            callback(status);
        }
    });
}
@end



@implementation ImageModel



@end
