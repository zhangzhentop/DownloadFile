//
//  DownloadCell.m
//  
//
//  Created by csip on 15/10/15.
//
//

#import "DownloadingCell.h"
@interface DownloadingCell()<CircularProgressButtonDelegate>
@end
@implementation DownloadingCell

- (void)awakeFromNib {
    _fileName.verticalAlignment = VerticalAlignmentTop;
    _fileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [self addSubview:line];
}

-(void)layoutSubviews{
    [self superview];
}
-(void)initBtn{
    _progressButton = [[CircularProgressButton alloc]initWithFrame:CGRectMake(self.frame.size.width-60, 8, 40, 40)
                                                         backColor:[UIColor lightGrayColor]
                                                     progressColor:[UIColor greenColor]
                                                         lineWidth:8];
    [_progressButton addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    _progressButton.delegate = self;
    _progressButton.selected = YES;
    [self addSubview:_progressButton];
}

- (void)btnAction
{
    if (_progressButton.selected) {//将文件状态由暂停改为下载
        _progressButton.selected = NO;
        [self downloadFile];
    }else{//将文件状态由下载改为暂停
        _progressButton.selected = YES;
        [self stopDownloadFile];
    }
}
- (void)stopDownloadFile
{
    [_tcbDownload cancelDownloadAndRemoveFile:NO];
    _state.text = @"暂停下载";
    [[DownLoadOperationManager sharedFiles] saveDownloadFile:_fileInfo];
}
/**
 *  cell中操作下载
 */
- (void)downloadFile
{
    [[DownLoadOperationManager sharedFiles]ContinueToDownload:_fileInfo.fileURL];
    [self.parentVC reloadData];
}

#pragma CircularProgressButton
-(void)updateProgressViewWithProgress:(float)progress{
    
}

-(void)setPercent:(float)per
{
    [_progressButton setProgress:per];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
