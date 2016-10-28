//
//  ViewController.m
//  Movie
//
//  Created by 张永强 on 16/10/27.
//  Copyright © 2016年 张永强. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //防止视频操作按钮还显示
    self.showsPlaybackControls = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
