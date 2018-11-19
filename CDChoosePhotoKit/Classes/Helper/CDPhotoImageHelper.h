//
//  CDPhotoImageHelper.h
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


#define ImageScale  (NSInteger)[UIScreen mainScreen].scale
#define CurrentBundle [NSBundle bundleForClass: [CDPhotoImageHelper class]]
#define CurrentBundleName [NSString stringWithFormat:@"%@.bundle",  CurrentBundle.infoDictionary[@"CFBundleExecutable"]]

typedef NS_ENUM(NSInteger, AlbumType) {
    AlbumTypeDefault   = 0, // 默认
    AlbumTypeCumstom   = 1  // 自定义
};

typedef NS_ENUM(NSUInteger, CDCaremaPhotoAuthStatus) {
    CDCaremaPhotoAuthStatusAuthorized = 0,    // 已授权
    CDCaremaPhotoAuthStatusDenied,            // 拒绝
    CDCaremaPhotoAuthStatusRestricted,        // 应用没有相关权限，且当前用户无法改变这个权限，比如:家长控制
    CDCaremaPhotoAuthStatusNotSupport         // 硬件等不支持
};

@interface ImageModel : NSObject

@property (nonatomic, strong) UIImage *thumbImage; // 图片
@property (nonatomic, strong) PHAsset *asset;
//@property (nonatomic, assign) NSInteger index;
//@property (nonatomic, strong) NSString *title;

@end

@interface CDPhotoImageHelper : NSObject

/**
 获取相册里的所有图片的PHAsset对象

 @param assetCollection PHAssetCollection 对象
 @param ascending  是否升序
 @return 回调。 返回PHAsset对象数组
 */
+ (NSArray *)getAllPhotosAssetInAblumCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;

/**
 获取相册列表

 @param isAscend 是否升序
 @param complete 回调 返回PHFetchResult数组
 */
+ (void)getAlbumListWithAscend:(BOOL)isAscend complete:(void(^)(NSArray<PHFetchResult *> *albumList))complete;


/**
 获取指定大小的图片

 @param asset PHAsset 对象
 @param size  尺寸
 @param complete 回调 返回image
 */
+ (void)getImageWithAsset:(PHAsset *)asset tagetSize:(CGSize)size complete:(void(^)(UIImage *))complete;

/**
 获取指定的图片

 @param asset PHAsset 对象
 @param complete 回调 返回image
 */
+ (void)getImageDataWithAsset:(PHAsset *)asset complete:(void (^)(UIImage *,UIImage*))complete;

/**
 请求相册访问权限
 
 @param callback 是否授权
 */
+ (void)requestPhotoAuth:(void(^)(CDCaremaPhotoAuthStatus status))callback;

/**
 请求相机权限
 
 @param callback 是否授权
 */
+ (void)requestCameraAuth:(void(^)(CDCaremaPhotoAuthStatus status))callback;

// 是否开启相册权限
+ (BOOL)isOpenLibaryAuthority;

// 是否开启相机权限
+ (BOOL)isOpenCaremaAuthority;

// 跳转到设置界面
+ (void)jumpToSetting;

// 获取相册中最新的一张图片
+ (PHAsset *)latestAsset;

/**
 保存相片到相机胶卷

 @param image 图片
 @param success 成功回调
 */
+ (void)savePhotoWithImage: (UIImage *)image success: (void(^)(void))success;

/**
 提示权限并跳转

 @param viewController 展示的控制权
 @param tipMsg 提示用户的内容
 */
+ (void)showAndJumpWithVc: (UIViewController *)viewController msg: (NSString *)tipMsg;


/**
 保存相片到相机胶卷

 @param image 图片
 @param getSuccess 保存成功的回调
 */
+ (void)getAssetWithImage:(UIImage *)image getAssetSuccess:(void(^)(PHAsset *asset))getSuccess;


/**
 弹窗提示

 @param title 标题
 @param message  内容
 @param controller  展示的控制啊
 @param isSingle Yes 确定  NO 确定 取消
 @param complete 回调
 */
+ (void)showAlertWithTittle:(NSString *)title message:(NSString *)message showController:(UIViewController *)controller isSingleAction:(BOOL)isSingle complete:(void (^)(NSInteger))complete;
@end
