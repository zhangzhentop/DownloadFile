//
//  CustomPlayVideoVC.m
//  VideoDemo
//
//  Created by myl on 15/5/14.
//  Copyright (c) 2015年 com.hn3l. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>

#import "CustomPlayVideoVC.h"
#import "AppDelegate.h"
#define CONTENT @"分享内容"
@interface CustomPlayVideoVC ()
{
    float currentTime;
    float totalTime;
    
    int width;
    int height;
    
    BOOL isPlayer;
    BOOL isHidden;
    BOOL isfirst;
    __weak IBOutlet UIButton *playOrPauseBtn;
    
}
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *bottomVIew;
- (IBAction)doneClick:(id)sender;
- (IBAction)playPauseClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayer *player;//播放器对象
@property (weak, nonatomic) IBOutlet UIView *container;

/**
 *  加载视图
 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
/**
 *  面板
 */
@property (nonatomic, strong) UIView *panelView;
@end

@implementation CustomPlayVideoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [_container addGestureRecognizer:tap];
    
    
    [self setupUI];
    [self.player play];
    isPlayer = YES;
    isfirst = YES;
    
    UIInterfaceOrientation toInterfaceOrientation = [self preferredInterfaceOrientationForPresentation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation); //判断是不是横屏
    if (landscape) {
        if (isfirst) {
            width = self.view.frame.size.height;
            height = self.view.frame.size.width;
            isfirst = NO;
        }
    }else{
        if (isfirst) {
            width = self.view.frame.size.width;
            height = self.view.frame.size.height;
            isfirst = NO;
        }
    }
    
    //加载等待视图
    self.panelView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.panelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.panelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.frame = CGRectMake((self.view.frame.size.width - self.loadingView.frame.size.width) / 2, (self.view.frame.size.height - self.loadingView.frame.size.height) / 2, self.loadingView.frame.size.width, self.loadingView.frame.size.height);
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.panelView addSubview:self.loadingView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_player pause];
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - 私有方法
-(void)setupUI{
    //创建播放器层
    _playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    CGRect frame = self.container.frame;
    NSLog(@"========hhhhh%f",frame.size.width);
    _playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //    playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;//视频填充模式
    [self.container.layer addSublayer:_playerLayer];
}


/**
 *  初始化播放器
 *
 *  @return 播放器对象
 */
-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem:0];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

/**
 *  根据视频索引取得AVPlayerItem对象
 *
 *  @param videoIndex 视频顺序索引
 *
 *  @return AVPlayerItem对象
 */
-(AVPlayerItem *)getPlayItem:(int)videoIndex{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [path objectAtIndex:0];
    documents = [NSString stringWithFormat:@"%@/Video",documents];
    NSString *filePath = [documents stringByAppendingPathComponent:_file.fileName];
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    
    //    NSString *urlStr=[NSString stringWithFormat:@"http://192.168.1.161/%i.mp4",videoIndex];
    //    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSURL *url=[NSURL URLWithString:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:movieURL];
    return playerItem;
}
#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
}

#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    UIProgressView *progress=self.progress;
    //这里设置每秒执行一次
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        currentTime = current;
        float total=CMTimeGetSeconds([playerItem duration]);
        totalTime = total;
        //        NSLog(@"当前已经播放%.2fs.",current);
        if (current) {
            [progress setProgress:(current/total) animated:YES];
        }
    }];
}

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (IBAction)playPauseClick:(UIButton *)sender
{
    if ([sender.currentTitle isEqualToString:@"暂停"]) {
        [self.player pause];
        isPlayer = NO;
        [sender setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        [self.player play];
        isPlayer = YES;
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
/**
 *  快退
 *
 *  @param sender 快退按钮
 */
- (IBAction)rewindClick:(UIButton *)sender
{
    currentTime -= 5.0f;
    if (currentTime <= 0) {
        currentTime = 0;
    }
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    [_player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish){
         if (isPlayer) {
             [_player play];
         }
     }];
}
/**
 *  快进
 *
 *  @param sender 快进按钮
 */
- (IBAction)speedClick:(UIButton *)sender
{
    currentTime += 5.0f;
    if (currentTime>=totalTime) {
        currentTime=totalTime;
    }
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    [_player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish){
         if (isPlayer) {
             [_player play];
         }
     }];
}
/**
 *  完成
 *
 *  @param sender 完成按钮
 */
- (IBAction)doneClick:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapClick:(UIGestureRecognizer *)sender
{
    [self hiddenHead];
}

- (void)hiddenHead
{
    if (isHidden) {
        [UIView animateWithDuration:.3 animations:^(){
            CGRect frame = _headView.frame;
            frame.origin.y = 0;
            _headView.frame = frame;
            
            CGRect frame1 = _bottomVIew.frame;
            frame1.origin.y = self.view.frame.size.height-frame1.size.height;
            _bottomVIew.frame = frame1;
        } completion:^(BOOL isfinish){
            isHidden = NO;
        }];
    }else{
        [UIView animateWithDuration:.3 animations:^(){
            CGRect frame = _headView.frame;
            frame.origin.y = -frame.size.height;
            _headView.frame = frame;
            
            CGRect frame1 = _bottomVIew.frame;
            frame1.origin.y = frame1.origin.y+frame.size.height+20;
            _bottomVIew.frame = frame1;
        }completion:^(BOOL isfinish){
            isHidden = YES;
        }];
    }
}

- (void) viewDidLayoutSubviews
{
    [_playerLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}
//屏幕旋转时,会自动调用该方法,只需要在根控制器重写该方法
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    isHidden = NO;
//    BOOL landscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation); //判断是不是横屏
//    NSLog(@"height = %f, width = %f", _container.frame.size.height, _container.frame.size.width);
//    if (landscape)
//    {
//        [_playerLayer setFrame:CGRectMake(0, 0, height, width)];
//    }
//    else
//    {
//        [_playerLayer setFrame:CGRectMake(0, 0, _container.frame.size.height, _container.frame.size.width)];
//    }
//}

////屏幕旋转完成时调用该方法,只需要在跟控制器重写该方法
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [_playerLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark 显示分享菜单
/**
 *  显示分享菜单
 *
 *  @param view 容器视图
 */
- (IBAction)showShareActionSheet:(id)sender
{
    [self.player pause];
    isPlayer = NO;
    [playOrPauseBtn setTitle:@"播放" forState:UIControlStateNormal];
    /**
     * 在简单分享中，只要设置共有分享参数即可分享到任意的社交平台
     **/
    __weak CustomPlayVideoVC *theController = self;
    
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[_shareImage];
    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"视频-%@",_file.fileName]
                                     images:imageArray
                                        url:[NSURL URLWithString:_file.fileURL]
                                      title:@"下载管理分享"
                                       type:SSDKContentTypeAuto];
    
    //1.2、自定义分享平台（非必要）
    NSMutableArray *activePlatforms = [NSMutableArray arrayWithArray:[ShareSDK activePlatforms]];
    //2、分享
    [ShareSDK showShareActionSheet:self.view
                             items:activePlatforms
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
                           [theController showLoadingView:YES];
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、短信应用没有设置帐号；2、设备不支持短信应用；3、短信应用在iOS 7以上才能发送带附件的短信。"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、邮件应用没有设置帐号；2、设备不支持邮件应用；"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                       default:
                           break;
                   }
                   
                   if (state != SSDKResponseStateBegin)
                   {
                       [theController showLoadingView:NO];
                       [self.player play];
                       isPlayer = YES;
                       [playOrPauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
                   }
                   
               }];
}
/**
 *  显示加载动画
 *
 *  @param flag YES 显示，NO 不显示
 */
- (void)showLoadingView:(BOOL)flag
{
    if (flag)
    {
        [self.view addSubview:self.panelView];
        [self.loadingView startAnimating];
    }
    else
    {
        [self.panelView removeFromSuperview];
    }
}
@end
