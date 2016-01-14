//
//  VedioDetailViewController.m
//  CloudPlatform
//
//  Created by Sky on 15/9/16.
//  Copyright (c) 2015年 com.hn3l. All rights reserved.
//

#import "VedioDetailViewController.h"
#import "PlayVideoVC.h"
#import "CustomPlayVideoVC.h"
#import "KxMovieViewController.h"
@interface VedioDetailViewController ()<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    UIImage *img;
    NSArray *array;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *header;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, assign) CGFloat inOffSet;
@end

@implementation VedioDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [path objectAtIndex:0];
    documents = [NSString stringWithFormat:@"%@/Video",documents];
    NSString *filePath = [documents stringByAppendingPathComponent:_video.fileName];
    
    img = [[self class] getImage:filePath];
    if (img==nil) {
        img = [UIImage imageNamed:@"2.jpg"];
    }
    UIImageView *header = [[UIImageView alloc] initWithImage:img];
    CGFloat width = _tableView.frame.size.width;
    CGFloat height = width*2/3;
    _inOffSet = height;
    _header = header;
    
    header.frame = CGRectMake(0, -height, width, height);
    [_tableView addSubview:header];
    _tableView.contentInset = UIEdgeInsetsMake(self.inOffSet, 0, 0, 0);
    
    UINavigationBar *bar = self.navigationController.navigationBar;
    [bar setBackgroundImage:[self createPictureWithColor:[UIColor whiteColor] alpha:0 imageSize:self.navigationController.view.frame.size] forBarMetrics:UIBarMetricsDefault];
    self.navBar = bar;
}

#pragma mark tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 260;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    UILabel *vedioTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, APP_WIDTH - 40, 20)];
    vedioTitle.font = [UIFont boldSystemFontOfSize:16];
    [cell addSubview:vedioTitle];
    
    UILabel *schoolName = [[UILabel alloc] initWithFrame:CGRectMake(20, VIEW_TY(vedioTitle) + VIEW_H(vedioTitle) + 5, 45, 20)];
    schoolName.font = [UIFont systemFontOfSize:14];
    schoolName.text = @"学校：";
    [cell addSubview:schoolName];
    
    UILabel *school = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_TX(schoolName) + VIEW_W(schoolName), VIEW_TY(schoolName), APP_WIDTH - 40 - VIEW_W(schoolName), 20)];
    school.font = [UIFont systemFontOfSize:14];
    [cell addSubview:school];
    
    UILabel *lecturerName = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_TX(schoolName), VIEW_TY(schoolName) + VIEW_H(schoolName), 45, 20)];
    lecturerName.font = [UIFont systemFontOfSize:14];
    lecturerName.text = @"讲师：";
    [cell addSubview:lecturerName];
    
    UILabel *lecturer = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_TX(lecturerName) + VIEW_W(lecturerName), VIEW_TY(lecturerName), APP_WIDTH - 40 - VIEW_W(lecturerName), 20)];
    lecturer.font = [UIFont systemFontOfSize:14];
    [cell addSubview:lecturer];
    
    UILabel *classHourName = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_TX(lecturerName), VIEW_TY(lecturerName) + VIEW_H(lecturerName), 45, 20)];
    classHourName.font = [UIFont systemFontOfSize:14];
    classHourName.text = @"课时：";
    [cell addSubview:classHourName];
    
    UILabel *classHour = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_TX(classHourName) + VIEW_W(classHourName), VIEW_TY(classHourName), APP_WIDTH - 40 - VIEW_W(classHourName), 20)];
    classHour.font = [UIFont systemFontOfSize:14];
    [cell addSubview:classHour];
    
    UITextView *synopsis = [[UITextView alloc] initWithFrame:CGRectMake(15, VIEW_TY(classHour) + VIEW_H(classHour), APP_WIDTH - 30, 100)];
    synopsis.font = [UIFont systemFontOfSize:14];
    synopsis.delegate = self;
    [cell addSubview:synopsis];
    
    vedioTitle.text = @"中国茶文化的虚饰和隐秘";
    school.text = @"厦门大学";
    lecturer.text = @"郑启五";
    classHour.text = @"5";
    synopsis.text = @"简介：本系列介绍了从中国历史上探究茶文化和传承至今的差效应，国外茶文化的起源，老师自身对于品茶的重要性以及给人体带来的益处。";
    
    UIButton *playVedioBtn = [[UIButton alloc] initWithFrame:CGRectMake((APP_WIDTH - 150)/2,VIEW_TY(synopsis) + VIEW_H(synopsis)+ 20, 150, 40)];
    [playVedioBtn addTarget:self action:@selector(PlayVedioAction:) forControlEvents:UIControlEventTouchUpInside];
    [playVedioBtn setTitle:@"播放视频" forState:UIControlStateNormal];
    [playVedioBtn setBackgroundColor:RGBCOLOR(216, 80, 92)];
    [playVedioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    playVedioBtn.layer.cornerRadius = 5;
    [cell addSubview:playVedioBtn];
    return cell;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}


-(void)PlayVedioAction:(UIButton *)sender
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [path objectAtIndex:0];
    documents = [NSString stringWithFormat:@"%@/Video",documents];
    NSString *filePath = [documents stringByAppendingPathComponent:_video.fileName];
    
    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:filePath parameters:parameters];
    vc.file = _video;
    vc.shareImage = img;
    [self presentViewController:vc animated:YES completion:nil];
}

+(UIImage *)getImage:(NSString *)videoURL{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}
#pragma mark 放大图片
/**
 *  通过颜色生成图片
 *
 *  @param color 要生成图片的颜色
 *  @param alpha 图片的透明度
 *  @param size  图片大小
 *
 *  @return 图片
 */
-(UIImage *)createPictureWithColor:(UIColor *)color alpha:(CGFloat)alpha imageSize:(CGSize)size{
    UIView *pureColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    pureColorView.backgroundColor = color;
    pureColorView.alpha = alpha;
    //由上下文获取UIImage
    UIGraphicsBeginImageContext(size);
    [pureColorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *pureColorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();//结束上下文
    return pureColorImage;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yoffset = scrollView.contentOffset.y;
    CGFloat xoffset = (yoffset+self.inOffSet)/2;
    if (yoffset<-self.inOffSet) {
        CGFloat width = scrollView.frame.size.width;
        self.header.frame = CGRectMake(xoffset, yoffset, width-xoffset*2, -yoffset);
    }
    CGFloat alpha = (self.inOffSet + yoffset) / self.inOffSet;
    UIImage *navImage = [self createPictureWithColor:[UIColor whiteColor] alpha:alpha imageSize:self.navigationController.view.frame.size];
    [self.navBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}

@end
