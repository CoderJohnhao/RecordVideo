//
//  ViewController.m
//  RecordVideo
//
//  Created by Johnhao on 2017/2/9.
//  Copyright © 2017年 Johnhao. All rights reserved.
//

#import "ViewController.h"
#import "ReacordVideoController.h"
#import <Masonry.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define WEAK_SELF     __weak typeof(self) wself = self;

@interface ViewController ()
/** 路径 */
@property (nonatomic,strong) UILabel *pathLabel;
@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WEAK_SELF
    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitle:@"录制视频" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.centerX.equalTo(wself.view.mas_centerX);
        make.centerY.equalTo(wself.view.mas_centerY);
    }];
    
    [btn addTarget:self action:@selector(reacordVideo) forControlEvents:UIControlEventTouchUpInside];
    
    self.pathLabel = [[UILabel alloc] init];
    self.pathLabel.text = @"1231";
    self.pathLabel.textAlignment = NSTextAlignmentCenter;
    self.pathLabel.numberOfLines = 0;
    [self.view addSubview:self.pathLabel];
    
    [self.pathLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btn.mas_bottom).offset(10);
        make.left.right.equalTo(wself.view);
    }];
}

- (void)reacordVideo {
    ReacordVideoController *reacordVideoVC = [[ReacordVideoController alloc] init];
    reacordVideoVC.block = ^(NSURL *path){
        NSLog(@"path: %@",path);
        self.pathLabel.text = [NSString stringWithFormat:@"%@",path];
    };
    [self presentViewController:reacordVideoVC animated:YES completion:nil];
}
@end
