//
//  ReacordVideoController.m
//  RecordVideo
//
//  Created by Johnhao on 2017/2/9.
//  Copyright © 2017年 Johnhao. All rights reserved.
//

#import "ReacordVideoController.h"
#import "RecordEngine.h"
#import "RecordProgressView.h"
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define WEAK_SELF     __weak typeof(self) wself = self;

@interface ReacordVideoController ()<RecordEngineDelegate>
/** 闪光灯按钮 */
@property (nonatomic,strong) UIButton *flashLightBtn;
/** 切换摄像头按钮 */
@property (nonatomic,strong) UIButton *changeCameraBtn;
/** 开始按钮 */
@property (nonatomic,strong) UIButton *reacordBtn;
/** 录制视频进度 */
@property (nonatomic,strong) RecordProgressView *progressView;
/** 录制工具 */
@property (nonatomic,strong) RecordEngine *recordEngine;

@end

@implementation ReacordVideoController
#pragma mark - set、get方法
- (RecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[RecordEngine alloc] init];
        _recordEngine.delegate = self;
        _recordEngine.maxRecordTime = 10;
    }
    return _recordEngine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view.backgroundColor = [UIColor blackColor];
    [self setViewsLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_recordEngine == nil) {
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
}


#pragma mark - 界面布局
- (void)setViewsLayout {
    WEAK_SELF
    // 顶部
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(wself.view);
        make.height.equalTo(@(50));
    }];
    
    // 闪光灯
    self.flashLightBtn = [[UIButton alloc] init];
    [self.flashLightBtn setImage:[UIImage imageNamed:@"flashlight-off"] forState:UIControlStateNormal];
    [self.flashLightBtn setImage:[UIImage imageNamed:@"flashlight-on"] forState:UIControlStateSelected];
    [self.flashLightBtn addTarget:self action:@selector(flashLightBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.flashLightBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [topView addSubview:self.flashLightBtn];
    
    [self.flashLightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topView).offset(-10);
        make.top.equalTo(topView.mas_top);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    // 底部
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(wself.view);
        make.height.equalTo(@(200));
    }];
    
    // 进度条
    self.progressView = [[RecordProgressView alloc] init];
    self.progressView.progressColor = [UIColor redColor];
    self.progressView.progressBgColor = [UIColor lightGrayColor];
    [bottomView addSubview:self.progressView];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(bottomView);
        make.height.equalTo(@(5));
    }];
    
    
    // 录制按钮
    self.reacordBtn = [[UIButton alloc] init];
    [self.reacordBtn setImage:[UIImage imageNamed:@"startBtn"] forState:UIControlStateNormal];
    [self.reacordBtn setImage:[UIImage imageNamed:@"endBtn"] forState:UIControlStateSelected];
    [self.reacordBtn addTarget:self action:@selector(reacordBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.reacordBtn];
    
    [self.reacordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.centerX.equalTo(bottomView.mas_centerX);
        make.centerY.equalTo(bottomView.mas_centerY);
    }];
    
    // 取消按钮
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [closeBtn setTitle:@"取消" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:closeBtn];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 30));
        make.centerY.equalTo(bottomView.mas_centerY);
        make.centerX.equalTo(bottomView.mas_left).offset(((SCREEN_WIDTH / 2) - 35) / 2);
    }];
    
    
    // 切换按钮
    self.changeCameraBtn = [[UIButton alloc] init];
    [self.changeCameraBtn setImage:[UIImage imageNamed:@"change"] forState:UIControlStateNormal];
    [self.changeCameraBtn addTarget:self action:@selector(changeCameraBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.changeCameraBtn];
    
    [self.changeCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.equalTo(bottomView.mas_centerY);
        make.centerX.equalTo(bottomView.mas_right).offset(-((SCREEN_WIDTH / 2) - 35) / 2);
    }];
}

#pragma mark - 按钮点击事件
- (void)flashLightBtn:(UIButton *)sender {
    if (self.changeCameraBtn.selected == NO) {
        self.flashLightBtn.selected = !self.flashLightBtn.selected;
        if (self.flashLightBtn.selected == YES) {
            [self.recordEngine openFlashLight];
        }else {
            [self.recordEngine closeFlashLight];
        }
    }
}

- (void)reacordBtn:(UIButton *)sender {
    self.reacordBtn.selected = !self.reacordBtn.selected;
    if (self.reacordBtn.selected) {
        [self.recordEngine startCapture];
    }else {
        [self.recordEngine pauseCapture];
        [self recordNextAction];
    }
}

- (void)changeCameraBtn:(UIButton *)sender {
    self.changeCameraBtn.selected = !self.changeCameraBtn.selected;
    if (self.changeCameraBtn.selected == YES) {
        //前置摄像头
        [self.recordEngine closeFlashLight];
        self.flashLightBtn.selected = NO;
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    }else {
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}


- (void)closeBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordNextAction {
    if (_recordEngine.videoPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage, bool isSeccess, NSURL *path) {
            NSLog(@"%@",path);
            weakSelf.block(path);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }else {
        NSLog(@"请先录制视频~");
    }
}

#pragma mark - WCLRecordEngineDelegate
- (void)recordProgress:(CGFloat)progress {
    if (progress >= 1) {
        [self reacordBtn:self.reacordBtn];
    }
    self.progressView.progress = progress;
}
@end
