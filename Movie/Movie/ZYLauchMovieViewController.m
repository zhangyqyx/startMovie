//
//  ZYLauchMovieViewController.m
//  Movie
//
//  Created by 张永强 on 16/10/27.
//  Copyright © 2016年 张永强. All rights reserved.
//

#import "ZYLauchMovieViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kIsFirstLauchApp @"kIsFirstLauchApp"

@interface ZYLauchMovieViewController ()
/** 播放开始之前的图片 */
@property (nonatomic , strong)UIImageView *startPlayerImageView;
/** 播放中断时的图片 */
@property (nonatomic , strong)UIImageView *pausePlayerImageView;
/** 定时器 */
@property (nonatomic , strong)NSTimer *timer;
/** 结束按钮 */
@property (nonatomic , strong)UIButton *enterMainButton;


@end

@implementation ZYLauchMovieViewController
- (BOOL)shouldAutorotate {
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   // 设置界面
    [self setupView];
    //添加监听
    [self addNotification];
    //初始化视频
    [self prepareMovie];
    
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
    self.player = nil;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
#pragma mark -- 初始化视频
- (void)prepareMovie {
    //首次运行
    NSString *filePath = nil;
    if (![self isFirstLauchApp]) {
        //第一次安装
        filePath = [[NSBundle mainBundle] pathForResource:@"opening_long_1080*1920.mp4" ofType:nil];
        [self setIsFirstLauchApp:YES];
    }else {
          filePath = [[NSBundle mainBundle] pathForResource:@"opening_short_1080*1920.mp4" ofType:nil];
    }
   //初始化player
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    self.showsPlaybackControls = NO;
    //播放视频
    [self.player play];
    
    
}


#pragma mark -- 初始化视图逻辑
- (void)setupView {
    self.startPlayerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lauch"]];
    _startPlayerImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.contentOverlayView addSubview:_startPlayerImageView];
    //是否是第一次进入视频
    if (![self isFirstLauchApp]) {
        //设置进入主界面的按钮
        [self setupEnterMainButton];
    }
}
- (void)setupEnterMainButton {
    self.enterMainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _enterMainButton.frame = CGRectMake(24, kScreenHeight - 32 - 48, kScreenWidth - 48, 48);
    _enterMainButton.layer.borderWidth =1;
    _enterMainButton.layer.cornerRadius = 24;
    _enterMainButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_enterMainButton setTitle:@"进入应用" forState:UIControlStateNormal];
    _enterMainButton.hidden = YES;
    [self.view addSubview:_enterMainButton];
    [_enterMainButton addTarget:self action:@selector(enterMainAction:) forControlEvents:UIControlEventTouchUpInside];
    //设置定时器当视频播放到第三秒时 展示进入应用
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showEnterMainButton) userInfo:nil repeats:YES];
    
}

#pragma mark -- 进入应用和显示进入按钮
- (void)enterMainAction:(UIButton *)btn {
    //视频暂停
    [self.player pause];
    self.pausePlayerImageView = [[UIImageView alloc] init];
    _pausePlayerImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.contentOverlayView addSubview:_pausePlayerImageView];
    self.pausePlayerImageView.contentMode = UIViewContentModeScaleAspectFit;
    //获取当前暂停时的截图
    [self getoverPlayerImage];
}
- (void)getoverPlayerImage {
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:self.player.currentItem.asset];
    gen.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime actualTime;
    CMTime now = self.player.currentTime;
    [gen setRequestedTimeToleranceAfter:kCMTimeZero];
    [gen setRequestedTimeToleranceBefore:kCMTimeZero];
    CGImageRef image = [gen copyCGImageAtTime:now actualTime:&actualTime error:&error];
    if (!error) {
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        self.pausePlayerImageView.image = thumb;
    }
    NSLog(@"%f , %f",CMTimeGetSeconds(now),CMTimeGetSeconds(actualTime));
    NSLog(@"%@",error);
    //视频播放结束
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self moviePlaybackComplete];
    });
    
}
//显示进入按钮
- (void)showEnterMainButton {
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:self.player.currentItem.asset];
    gen.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime actualTime;
    CMTime now = self.player.currentTime;
    [gen setRequestedTimeToleranceAfter:kCMTimeZero];
    [gen setRequestedTimeToleranceBefore:kCMTimeZero];
    [gen copyCGImageAtTime:now actualTime:&actualTime error:&error];
    NSInteger currentPlayBackTime = (NSInteger)CMTimeGetSeconds(actualTime);
    if (currentPlayBackTime >= 3) {
        self.enterMainButton.hidden = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            self.enterMainButton.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.enterMainButton.alpha = 1;
            } completion:nil];
        });
    }
    if (currentPlayBackTime > 5) {
        //防止没有显现出来
        self.enterMainButton.alpha = 1;
        self.enterMainButton.hidden = NO;
        [self.timer invalidate];
        self.timer = nil;
    }
}
//进入主界面
- (void)enterMain {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *main = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    delegate.window.rootViewController = main;
    [delegate.window makeKeyWindow];
}

#pragma mark -- 监听以及实现方法
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];//进入前台
    if ([self isFirstLauchApp]) {
        //第二次进入app视频需要直接结束
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];//视频播放结束
    }else {
        //第一次进入app视频需要轮播
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackAgain) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];//视频播放结束
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStart) name:AVPlayerItemTimeJumpedNotification object:nil];//播放开始
}
//再一次播放视频
- (void)moviePlaybackAgain {
    self.startPlayerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lauchAgain"]];
    _startPlayerImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.contentOverlayView addSubview:_startPlayerImageView];
    [self.pausePlayerImageView removeFromSuperview];
    self.pausePlayerImageView = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"opening_long_1080*1920.mp4" ofType:nil];
    //初始化player
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    self.showsPlaybackControls = NO;
    //播放视频
    [self.player play];
}
//开始播放
- (void)moviePlaybackStart {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.startPlayerImageView removeFromSuperview];
        self.startPlayerImageView = nil;
    });
}
//视频播放完成
- (void)moviePlaybackComplete {
    //发送推送之后就删除  否则 界面显示有问题
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    [self.startPlayerImageView removeFromSuperview];
    self.startPlayerImageView = nil;
    
    [self.pausePlayerImageView removeFromSuperview];
    self.pausePlayerImageView = nil;
    
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    //进入主界面
    [self enterMain];
}
- (void)viewWillEnterForeground
{
    NSLog(@"app enter foreground");
    if (!self.player) {
        [self prepareMovie];
    }
    //播放视频
    [self.player play];
}

#pragma mark -- 是否第一次进入app
- (BOOL)isFirstLauchApp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstLauchApp];
}

- (void)setIsFirstLauchApp:(BOOL)isFirstLauchApp
{
    [[NSUserDefaults standardUserDefaults] setBool:isFirstLauchApp forKey:kIsFirstLauchApp];
}


@end
