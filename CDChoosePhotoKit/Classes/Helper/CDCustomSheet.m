//
//  CDCustomSheet.m
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.

#import "CDCustomSheet.h"

#define BUTTONH 50
#define ButtonViewH 150
#define CDChoosePhotoKitSCREENH [UIScreen mainScreen].bounds.size.height
#define CDChoosePhotoKitSCREENW [UIScreen mainScreen].bounds.size.width
@interface CDCustomSheet()

@property (nonatomic,strong) UIView * contentView;
@property (nonatomic, assign) CGFloat buW;
@end

@implementation CDCustomSheet

static NSArray * allbus = nil;


-(CDCustomSheet* )initWithButtons:(NSArray*)allButtons isTableView:(BOOL)tableView sheeType: (NSInteger)sheetType {
    
    allbus = allButtons;
    self.sheeType = sheetType;
    self.buW = CDChoosePhotoKitSCREENW;
    CGFloat startHeight = 0;
    if (tableView) {
        startHeight = -64;
    }
    CDCustomSheet * sheet = [[CDCustomSheet alloc] initWithFrame:CGRectMake(0, startHeight, self.buW, CDChoosePhotoKitSCREENH)];
    sheet.userInteractionEnabled = YES;
    [self bringSubviewToFront: sheet];
    CGRect frame = sheet.frame;
    [sheet set: frame.size.width];
    return sheet;
    
}

-(void)set: (CGFloat)sheetW {
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        weakSelf.contentView.frame = CGRectMake(0, CDChoosePhotoKitSCREENH - ButtonViewH, sheetW, ButtonViewH);
    }];
}



-(instancetype)initWithFrame:(CGRect)frame {
    
    if (self=[super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        CGFloat buw = frame.size.width;
        UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0,buw, CDChoosePhotoKitSCREENH)];
        back.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
        back.userInteractionEnabled = YES;
        [self addSubview:back];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CDChoosePhotoKitSCREENH,  buw, ButtonViewH)];
        _contentView.userInteractionEnabled = YES;
        [self addSubview: _contentView];
        for (int i = 0; i < allbus.count; i++) {
            
            UIButton * bu = [UIButton buttonWithType: UIButtonTypeCustom];
            bu.tag = i;
            bu.backgroundColor = [UIColor whiteColor];
            bu.frame = CGRectMake(0, BUTTONH * i, buw, BUTTONH);
            [_contentView addSubview: bu];
            [bu setTitle: allbus[i] forState:UIControlStateNormal];
            [bu setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
            [bu addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, BUTTONH - 2, buw, 1)];
            line.backgroundColor = [UIColor colorWithRed: 242.0 / 255.0 green: 242.0 / 255.0 blue: 242.0 / 255.0 alpha: 1.0];
            bu.enabled = YES;
            [bu addSubview: line];
        }
        UIButton * bu = [UIButton buttonWithType:UIButtonTypeCustom];
        bu.backgroundColor = [UIColor whiteColor];
        [bu setTitleColor:  [UIColor blackColor] forState:UIControlStateNormal];
        bu.frame = CGRectMake(0, BUTTONH * allbus.count, buw, BUTTONH);
        [bu setTitle: @"取消" forState:UIControlStateNormal];
        [bu addTarget:self action:@selector(cancle:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:bu];

    }
    return self;
}
- (void)cancle: (UIButton *)button {
    
     [self cancelButtonAction];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self cancelButtonAction];
}
-(void)clickButton:(UIButton*)button {
    
    [self.delegate  clickButton: button.tag sheetCount:self.sheetMark];
    [self removeFromSuperview];
}

-(void)cancelButtonAction {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        weakSelf.contentView.frame = CGRectMake(0, CDChoosePhotoKitSCREENH, self.buW, ButtonViewH);
    } completion:^(BOOL finished) {
        
        [weakSelf removeFromSuperview];
        if ([weakSelf.delegate respondsToSelector:@selector(clickButton:sheetCount:)]) {
            [weakSelf.delegate clickButton: 999 sheetCount: weakSelf.sheetMark];
        }
    }];
}

@end
