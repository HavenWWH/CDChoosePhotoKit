//
//  CDAlbumListController.m
//  CDChoosePhotoKit
//
//  Created by 吴文海 on 2018/11/14.
//  Copyright © 2018 Haven. All rights reserved.
// 

#import "CDAlbumListController.h"


@interface CDAlbumListController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation CDAlbumListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
    
    self.tableView.rowHeight = 160;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    NSBundle *currentBundle = [NSBundle bundleForClass: [CDAlbumListController class]];
    
    [self.tableView registerNib: [UINib nibWithNibName:@"CDAlbumListTableViewCell" bundle: currentBundle] forCellReuseIdentifier:@"CDAlbumListTableViewCell"];
    
}

- (void)dismissController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //加载数据
    [self loadAlbums];
}

- (void)loadAlbums {
    
    __weak typeof(self) weakSelf = self;
    [CDPhotoImageHelper getAlbumListWithAscend: YES complete:^(NSArray<PHFetchResult *> *albumList) {
        
        weakSelf.dataSource = albumList;
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CDAlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CDAlbumListTableViewCell" forIndexPath:indexPath];
    PHFetchResult *fetchResult = self.dataSource[indexPath.section];
    cell.albumTitleLabel.text = @"相机胶卷";
    cell.albumDetailLabel.text = [NSString stringWithFormat:@"%@", @(fetchResult.count)];
    if (fetchResult.count > 0) {
        
        PHAsset *asset = fetchResult[0];
        [CDPhotoImageHelper getImageWithAsset:asset tagetSize:CGSizeMake(self.tableView.rowHeight, self.tableView.rowHeight) complete:^(UIImage *image) {
            
            cell.coverImageView.image = image;
        }];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 过滤视频和音频
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType: PHAssetMediaTypeImage options: nil];
    
    CDAlbumListTableViewCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    CDPhotoListController *vc = [[CDPhotoListController alloc] init];
    vc.title = cell.albumTitleLabel.text;
    vc.fetchResult = fetchResult;
    vc.selectArray = self.selctImageArray;
    vc.okClickComplete = self.okClickComplete;
    vc.isCrop = self.isCrop;
    if (self.isCrop) vc.cropScale = self.cropScale;
    vc.maxCount = self.maxCount;
    
    [self.navigationController pushViewController: vc animated:YES];
}


@end
