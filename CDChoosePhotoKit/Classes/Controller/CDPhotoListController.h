//
//  CDPhotoListController.h
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "CDPhotoImageHelper.h"



@interface CDPhotoListController : UIViewController

@property (nonatomic, strong)PHFetchResult *fetchResult;

@property (nonatomic, copy) void(^okClickComplete)(NSArray<ImageModel *> *images);

@property (nonatomic,strong)NSMutableArray *selectArray;//存储选择的相片

@property (nonatomic, assign) NSInteger maxCount;

// 是否剪裁
@property (nonatomic, assign)  BOOL isCrop;
// 剪裁比例。只有isCrop为true有效, 不传此参数 默认正方型
@property (nonatomic, assign) CGSize cropScale;



@end
