//
//  CDShowBigImage.h
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CDShowBigImage : UIView <UIScrollViewDelegate>

+ (CDShowBigImage *)shareInstance;

/**
 * 放大图片
 */
- (void)showBigImage:(UIImageView *)imageView;

@end
