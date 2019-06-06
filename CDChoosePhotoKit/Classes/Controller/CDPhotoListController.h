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

// 选择照片完成回调
@property (nonatomic, copy) void(^okClickComplete)(NSArray<ImageModel *> *images);
// 存储选择的相片
@property (nonatomic,strong)NSMutableArray *selectArray;

// 图片选择最大数量
@property (nonatomic, assign) NSInteger maxCount;
// 图片的尺寸, 默认100 必须设置
@property (nonatomic, assign) CGFloat minimumImageWidth;


// 是否剪裁
@property (nonatomic, assign)  BOOL isCrop;
// 剪裁比例。只有isCrop为true有效, 不传此参数 默认正方型
@property (nonatomic, assign) CGSize cropScale;



@end
