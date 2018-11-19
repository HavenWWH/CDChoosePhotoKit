//
//  CDCustomSheet.h
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CDCustomSheetDelegate <NSObject>

-(void)clickButton:(NSUInteger)buttonTag sheetCount:(NSUInteger)sheet;

@end

@interface CDCustomSheet : UIView


@property (nonatomic,weak) id<CDCustomSheetDelegate>delegate;

@property (nonatomic, assign) NSInteger sheetMark;

@property (nonatomic, assign) NSInteger sheeType;

-(CDCustomSheet* )initWithButtons:(NSArray*)allButtons isTableView:(BOOL)tableView sheeType: (NSInteger)sheetType;

@end
