//
//  CDViewController.m
//  CDChoosePhotoKit
//
//  Created by Haven on 11/14/2018.
//  Copyright (c) 2018 Haven. All rights reserved.
//

#import "CDViewController.h"
#import "CDTestViewController.h"
#import "CDPhotoBaseViewController.h"

@interface CDViewController ()

@end

@implementation CDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
}
- (IBAction)push:(id)sender {

    CDTestViewController *vc = [[CDTestViewController alloc] init];
//    MLShowViewController *vc = [[MLShowViewController alloc] init];
    [self.navigationController pushViewController: vc animated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
