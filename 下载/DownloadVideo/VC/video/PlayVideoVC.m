//
//  PlayVideoVC.m
//  VideoDemo
//
//  Created by myl on 15/5/14.
//  Copyright (c) 2015年 com.hn3l. All rights reserved.
//

#import "PlayVideoVC.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayVideoVC ()
{
    MPMoviePlayerController *player;
}
@end

@implementation PlayVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    player = [[MPMoviePlayerController alloc] init];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"mp4"inDirectory:nil];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [path objectAtIndex:0];
    documents = [NSString stringWithFormat:@"%@/Video",documents];
    NSString *filePath = [documents stringByAppendingPathComponent:_file.fileName];
    
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
//    NSURL *movieURL = [NSURL URLWithString:@"http://t.cn/RwqMP12"];
    player.contentURL = movieURL;
    player.controlStyle =MPMovieControlStyleFullscreen; //全屏的方式
    
    UIInterfaceOrientation toInterfaceOrientation = [self preferredInterfaceOrientationForPresentation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation); //判断是不是横屏
    if (landscape) {
        [player.view setFrame:CGRectMake(0,0,_screenHeight,_screenWidth)];
    }else{
        [player.view setFrame:CGRectMake(0,0,_screenWidth,_screenHeight)];
    }
    
    [self.view addSubview:player.view];
    
    [player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

////屏幕旋转时,会自动调用该方法,只需要在根控制器重写该方法
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    BOOL landscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation); //判断是不是横屏
//    if (landscape) {
//        [player.view setFrame:CGRectMake(0,0,_screenHeight,_screenWidth)];
//    }else{
//        [player.view setFrame:CGRectMake(0,0,_screenWidth,_screenHeight)];
//    }
//}

- (void) viewDidLayoutSubviews
{
    [player.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [player stop];
}
/*
 @method 当视频播放完毕释放对象
 */
-(void)myMovieFinishedCallback:(NSNotification*)notify
{
    //视频播放对象
    MPMoviePlayerController* theMovie = [notify object];
    //销毁播放通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    [theMovie.view removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
