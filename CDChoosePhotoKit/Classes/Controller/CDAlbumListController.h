//
//  CDAlbumListController.h
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "CDPhotoImageHelper.h"
#import "CDAlbumListTableViewCell.h"
#import "CDPhotoListController.h"


@interface CDAlbumListController : UITableViewController

@property (nonatomic, copy) void(^okClickComplete)(NSArray<ImageModel *> *images);
  
@property (nonatomic, strong) NSMutableArray *selctImageArray;

@property (nonatomic, assign) NSInteger maxCount;

// 是否剪裁
@property (nonatomic, assign)  BOOL isCrop;
// 剪裁比例。只有isCrop为true有效
@property (nonatomic, assign) CGSize cropScale;
@end
