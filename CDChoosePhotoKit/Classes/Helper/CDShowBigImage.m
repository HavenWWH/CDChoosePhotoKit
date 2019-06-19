//
//  CDShowBigImage.m
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.

#import "CDShowBigImage.h"

@interface CDShowBigImage()

@property (nonatomic, strong) UIScrollView *scrollerView;
@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UIImageView *originImageView;
@property (nonatomic, strong) UIImage *selectImage;
@property (nonatomic, assign) CGRect  imageOriginalRect;
@property (nonatomic, assign) CGFloat proportionFloat;
@property (nonatomic, assign) CGFloat leverlFloat;
@property (nonatomic, assign) CGFloat verticalFloat;
@end


@implementation CDShowBigImage

#pragma mark - Init -
+ (CDShowBigImage *)shareInstance {
    
    static CDShowBigImage *showBigImage = nil;
    if (showBigImage == nil) {
        showBigImage = [[CDShowBigImage alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    [showBigImage initView];
    return showBigImage;
}

#pragma mark - 初始化方法

//初始化视图
- (void)initView {

    [self addSubview:self.scrollerView];
    
    //添加按手势————单击还原关闭图片
    UITapGestureRecognizer *oneTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
    [self.scrollerView addGestureRecognizer:oneTap];
    
    //添加按手势————双击放大缩小图片
    UITapGestureRecognizer *twoTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
    [twoTap setNumberOfTapsRequired:2];
    [self.scrollerView addGestureRecognizer:twoTap];
    
    //设置单、双击优先级(先识别双击，再识别单击)
    [oneTap requireGestureRecognizerToFail:twoTap];

    [self.scrollerView addSubview:self.showImageView];
    
    // 转屏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
 
}
- (void)didChangeRotate:(NSNotification*)notice {
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    self.frame = CGRectMake(0, 0, screenW, screenH);
    self.scrollerView.frame = CGRectMake(0, 0, screenW, screenH);
    
    CGSize AImageSize = self.selectImage.size;
    self.proportionFloat = CGRectGetHeight(self.frame) / AImageSize.height;
    if (AImageSize.width * self.proportionFloat > CGRectGetWidth(self.frame)) {
        
        self.proportionFloat = CGRectGetWidth(self.frame) / AImageSize.width;
    }
    
    self.showImageView.frame = CGRectMake(0, 0, self.selectImage.size.width * self.proportionFloat, self.selectImage.size.height * self.proportionFloat);
    
    //默认缩放比例
    [self.scrollerView setZoomScale:self.proportionFloat];
    [self initMargin];
}
#pragma mark - 手势触发
//点击触发————单击还原关闭图片  双击放大缩小图片
- (void)Tap:(UITapGestureRecognizer *)sender {
    
    if (sender.numberOfTapsRequired == 1) { //单击----还原关闭大图
        
        [self ImageReductionClose];
    } else if (sender.numberOfTapsRequired == 2) {//双击---放大或还原
        
        if (self.scrollerView.zoomScale > self.proportionFloat) {
            
            [self.scrollerView setZoomScale:self.proportionFloat animated:YES];
            
        } else {
            
            //双击坐标相对屏幕坐标
            CGPoint point = [sender locationInView:self];
            //放大图片
            [self enlargeImage:point];
        }
    }
}

//图片还原关闭(带动画效果)
- (void)ImageReductionClose {
    
    [UIView animateWithDuration:0.4 animations:^{
        
        //背景图透明
        [self.scrollerView setBackgroundColor:[UIColor clearColor]];
        //还原缩放比例
        self.scrollerView.zoomScale = self.proportionFloat;
        
        //还原图片初始框架
        CGRect ARect = self.showImageView.frame;
        ARect.origin.x = self.imageOriginalRect.origin.x - self.leverlFloat;
        ARect.origin.y = self.imageOriginalRect.origin.y - self.verticalFloat;
        ARect.size.width = self.imageOriginalRect.size.width;
        ARect.size.height = self.imageOriginalRect.size.height;
        self.showImageView.frame = ARect;
        [UIView commitAnimations];
        
    } completion:^(BOOL finished) {
        
        [self.showImageView removeFromSuperview];
        self.showImageView = nil;
        [self.scrollerView removeFromSuperview];
        self.scrollerView = nil;
        [self removeFromSuperview];
    }];
}

/*
 *作用：放大图片
 *参数：
 *ponint  双击点相对屏幕坐标
 */
- (void)enlargeImage:(CGPoint)ponint {
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.scrollerView setZoomScale:self.scrollerView.maximumZoomScale];
    }];
    
    //相对边距坐标
    CGPoint APanNextPoint =  CGPointMake((ponint.x - self.leverlFloat), (ponint.y - self.verticalFloat));
    
    //滚动视图真实偏移坐标
    CGPoint AOffsetPoint = _scrollerView.contentOffset;
    
    if (_showImageView.image.size.height * self.proportionFloat * self.scrollerView.maximumZoomScale > self.frame.size.height) {
        
        CGFloat Y = APanNextPoint.y * self.scrollerView.zoomScale / self.proportionFloat - self.showImageView.center.y;
        AOffsetPoint.y = AOffsetPoint.y + Y;
        CGFloat AMaxContentHeight= self.scrollerView.contentSize.height - CGRectGetHeight(self.scrollerView.frame);
                AOffsetPoint.y = AOffsetPoint.y < AMaxContentHeight ? AOffsetPoint.y : AMaxContentHeight;
        AOffsetPoint.y = AOffsetPoint.y > 0 ? AOffsetPoint.y : 0;
    }
    
    if (self.showImageView.image.size.width * self.proportionFloat * self.scrollerView.maximumZoomScale > self.frame.size.width) {
        
        CGFloat X = (APanNextPoint.x * self.scrollerView.zoomScale / self.proportionFloat - self.showImageView.center.x);
        AOffsetPoint.x = AOffsetPoint.x + X;
        CGFloat AMaxContentWidth= self.scrollerView.contentSize.width - CGRectGetWidth(self.scrollerView.frame);
        AOffsetPoint.x = AOffsetPoint.x < AMaxContentWidth ? AOffsetPoint.x : AMaxContentWidth;
        AOffsetPoint.x = AOffsetPoint.x > 0 ? AOffsetPoint.x : 0;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.scrollerView setContentOffset:AOffsetPoint];
    }];
}


#pragma mark - UICollectionViewDelegate
//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _showImageView;
}

//缩放时调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    if (scrollView.zoomScale < self.proportionFloat) {
        
        [self.showImageView setCenter:self.center];
        CGRect ARect = self.showImageView.frame;
        ARect.origin.x = ARect.origin.x - self.leverlFloat;
        ARect.origin.y = ARect.origin.y - self.verticalFloat;
        self.showImageView.frame = ARect;
    } else if (scrollView.zoomScale == self.proportionFloat) {
        
        [self.showImageView setCenter:self.center];
        CGRect ARect = self.showImageView.frame;
        ARect.origin.x = 0;
        ARect.origin.y = 0;
        self.showImageView.frame = ARect;
    }
    //初始化边距
    [self initMargin];
}

//初始化边距
- (void)initMargin {
    
    //水平边距
    self.leverlFloat = (self.frame.size.width - self.selectImage.size.width * self.scrollerView.zoomScale)  / 2.0;
    if (self.leverlFloat < 0) {
        
        self.leverlFloat = 0;
    }
    
    //垂直边距
    self.verticalFloat = (CGRectGetHeight(self.frame) - self.selectImage.size.height * self.scrollerView.zoomScale) / 2.0;
    if (self.verticalFloat < 0) {
        
        self.verticalFloat = 0;
    }
    
    //设置边距
    [self.scrollerView setContentInset:UIEdgeInsetsMake(self.verticalFloat, self.leverlFloat, self.verticalFloat, self.leverlFloat)];
}

#pragma mark - 自定义共有方法
//显示图片
- (void)showBigImage:(UIImageView *)imageView {
    
    self.originImageView = imageView;
    self.selectImage = imageView.image;
    //添加显示视图
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    //初始化图片显示视图
    [self initImageView:imageView];
    
    //图片适应居中显示(带动画)
    [self ImageAdaptCenter];
}

#pragma mark - 自定义私有方法
//初始化显示图片
- (void)initImageView:(UIImageView *)imageView {
    
    //保存图片原始框架————相对屏幕位置
    {
        self.imageOriginalRect = imageView.bounds;
        _imageOriginalRect.origin = [imageView convertPoint:CGPointMake(0, 0) toView:[[UIApplication sharedApplication] keyWindow]];
    }
    //计算默认缩放比例
    {
        CGSize AImageSize = imageView.image.size;
        self.proportionFloat = CGRectGetHeight(self.frame) / AImageSize.height;
        if (AImageSize.width * self.proportionFloat > CGRectGetWidth(self.frame)) {
            
            self.proportionFloat = CGRectGetWidth(self.frame) / AImageSize.width;
        }
    }
    
    //初始化图片视图
    {
        [_showImageView setImage:imageView.image];
        [_showImageView setFrame:self.imageOriginalRect];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

//图片适应居中(带动画效果)
- (void)ImageAdaptCenter {
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.scrollerView setBackgroundColor:[UIColor blackColor]];
        CGRect ARect = self.showImageView.frame;
        ARect.size.width = self.showImageView.image.size.width * self.proportionFloat;
        ARect.size.height = self.showImageView.image.size.height * self.proportionFloat;
        self.showImageView.frame = ARect;
        self.showImageView.center = self.center;
        
        
    } completion:^(BOOL finished) {
        
        [self.showImageView setFrame:CGRectMake(0, 0, self.showImageView.image.size.width, self.showImageView.image.size.height)];
        
        //初始化缩放比例
        [self initScaling];
        
        //初始化边距
        [self initMargin];
    }];
}

//初始化缩放比例
- (void)initScaling {
    
    //设置主要滚动视图滚动范围和缩放比例
    [self.scrollerView setContentSize:self.selectImage.size];
    //设置最小伸缩比例
    [self.scrollerView setMinimumZoomScale:_proportionFloat];
    //设置最大伸缩比例
    [self.scrollerView setMaximumZoomScale:_proportionFloat * 3];
    //默认缩放比例
    [self.scrollerView setZoomScale:_proportionFloat];
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIScrollView *)scrollerView {
    if (!_scrollerView) {
        _scrollerView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [_scrollerView setShowsHorizontalScrollIndicator:NO];
        [_scrollerView setShowsVerticalScrollIndicator:NO];
        [_scrollerView setDelegate:self];
    }
    return _scrollerView;
}

- (UIImageView *)showImageView {
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc] init];
        [_showImageView setUserInteractionEnabled:YES];
    }
    return _showImageView;
}
@end
