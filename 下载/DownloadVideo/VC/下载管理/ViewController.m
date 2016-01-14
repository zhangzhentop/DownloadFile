//
//  ViewController.m
//  DownloadVideo
//
//  Created by csip on 15/10/14.
//  Copyright (c) 2015年 zh. All rights reserved.
//

#import "ViewController.h"
#import "DownloadingCell.h"
#import "DownloadComplete.h"
#import "VedioDetailViewController.h"
#import "NewTaskVC.h"
#import "DownLoadOperationManager.h"
#import "FileModel.h"
#import "TCBlobDownloader.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,DownloadDelegate>
{
    NSMutableArray *tempFileList;
    NSMutableArray *finishedList;
    UITableView *tabel;
    DownLoadOperationManager *fileDownManage;
}
@end

@implementation ViewController
- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = YES;
    int navH = IOS_VERSION_7_OR_ABOVE?64:0;
    
    [DownLoadOperationManager sharedFilesDownManage];
    tabel = [[UITableView alloc] initWithFrame:CGRectMake(0,navH, self.view.frame.size.width, self.view.frame.size.height-navH)];
    tabel.delegate = self;
    tabel.dataSource = self;
    tabel.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    
    [self.view addSubview:tabel];
    [self initNav];    
}
-(void)viewWillAppear:(BOOL)animated{
    [self reloadData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[DownLoadOperationManager sharedFiles] saveAllFill:tempFileList];
}
/**
 *  重新载入数据
 */
-(void)reloadData{
    fileDownManage = [DownLoadOperationManager sharedFiles];
    NSMutableArray *task = [[NSMutableArray alloc] init];
    task = fileDownManage.filelist;
    if (task ==nil) {
        task = [[NSMutableArray alloc] init];
    }
    [self filterFile:task];
    [tabel reloadData];
}
///划分正在下载和下载完成
-(void)filterFile:(NSMutableArray *)array{
    finishedList = [[NSMutableArray alloc] init];
    tempFileList = [[NSMutableArray alloc] init];
    for (FileModel *file in array) {
        if ([file.isCompleted isEqualToString:@"YES"]) {
            [finishedList addObject:file];
        }else{
            [tempFileList addObject:file];
        }
    }
}
-(void)initNav{
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toAddTask:)];
  
    self.navigationItem.rightBarButtonItem = leftBarButton;
}
///添加新的任务
-(void)toAddTask:(id)sender{
    NewTaskVC *new = [[NewTaskVC alloc] init];
    [self.navigationController pushViewController:new animated:YES];
}

-(void)viewDidLayoutSubviews{
    
    int navH = IOS_VERSION_7_OR_ABOVE?(APP_WIDTH==320?64:50):0;
    tabel.frame = CGRectMake(0, navH, APP_WIDTH, APP_HEIGHT-navH);
    NSLog(@"%f---%f",APP_WIDTH,APP_HEIGHT);
    [tabel reloadData];
}

#pragma mark tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return tempFileList.count;
    }else{
        return finishedList.count;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Identifier"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:@"Identifier"];
    }
    if (section == 0) {
        header.textLabel.text = [NSString stringWithFormat:@"正在下载（%lu）",(unsigned long)(tempFileList.count)];
    }else{
        header.textLabel.text = [NSString stringWithFormat:@"下载完成（%lu）",(unsigned long)finishedList.count];
    }
    return header;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellStr = @"Cell";
    if (indexPath.section == 0) {
        DownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadingCell" owner:nil options:nil] firstObject];
        }
        cell.parentVC = self;
        [cell initBtn];
        FileModel *fileInfo = [tempFileList objectAtIndex:indexPath.row];
        TCBlobDownloader *download = fileInfo.downloader;
        if (download == nil){
            cell.fileInfo = fileInfo;
            cell.fileName.text = fileInfo.fileName;
            cell.tcbDownload = download;
            if (cell.tcbDownload ==nil || download.state == TCBlobDownloadStateDownloading || download.state == TCBlobDownloadStateReady) {
                cell.progressButton.selected = YES;
                cell.state.text = @"暂停下载";
            }else{
                cell.progressButton.selected = NO;
            }
            [cell setPercent:fileInfo.progress];
            cell.speedOfProgress.text = [NSString stringWithFormat:@"%@/%@",fileInfo.fileReceivedSize,fileInfo.fileSize];
        }else{
            cell.fileName.text = fileInfo.fileName;
            cell.tcbDownload = download;
            if (cell.tcbDownload ==nil || download.state == TCBlobDownloadStateDownloading || download.state == TCBlobDownloadStateReady) {
                cell.progressButton.selected = NO;
            }else{
                cell.progressButton.selected = YES;
                cell.state.text = @"暂停下载";
            }
            if (download.state == TCBlobDownloadStateReady) {
                cell.state.text = @"正在等待...";
            }
            [cell setPercent:fileInfo.progress];
            cell.speedOfProgress.text = [NSString stringWithFormat:@"%@/%@",fileInfo.fileReceivedSize,fileInfo.fileSize];
            [self tryUnboundCell:cell];
            [self boundCell:cell forFile:fileInfo];
        }
        return cell;
    }else{
        DownloadComplete *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadComplete" owner:nil options:nil] firstObject];
        }
        FileModel *fModel=(FileModel *)[finishedList objectAtIndex:indexPath.row];
        cell.fileName.text = fModel.fileName;
        cell.fileSize.text = fModel.fileSize;
        if (fModel.errorStr.length>1) {
            cell.fileSize.text = fModel.errorStr;
        }
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        FileModel *file = [finishedList objectAtIndex:indexPath.row];
//        if ([file.fileType isEqualToString:@"Video"]) {
            VedioDetailViewController *vedioDetail = [[VedioDetailViewController alloc] init];
            vedioDetail.video = file;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            [self.navigationController pushViewController:vedioDetail animated:YES];
//        }
    }
}
#pragma mark table 滑动删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section ==0){
        FileModel *file = tempFileList[indexPath.row];
        [file.downloader cancelDownloadAndRemoveFile:YES];
        [[DownLoadOperationManager sharedFiles] removeFile:file];
    }else
    if (indexPath.section==1) {
        FileModel *file = finishedList[indexPath.row];
        [[DownLoadOperationManager sharedFiles] removeFile:file];
    }
    [self reloadData];
}
#pragma mark KVO+++用于更新下载进度
-(void)boundCell:(DownloadingCell *)cell forFile:(FileModel *)file{
    cell.fileInfo = file;
    [file addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:(__bridge void *)(file.fileName)];
    [file addObserver:self forKeyPath:@"isCompleted" options:NSKeyValueObservingOptionNew context:(__bridge void *)(file.fileName)];
    [file addObserver:self forKeyPath:@"downloadStatus" options:NSKeyValueObservingOptionNew context:(__bridge void *)(file.fileName)];
}
-(void)tryUnboundCell:(DownloadingCell *)cell{
    if (!cell.fileInfo) {
        return;
    }
    FileModel *file = cell.fileInfo;
    [file removeObserver:self forKeyPath:@"progress" context:(__bridge void *)(file.fileName)];
    [file removeObserver:self forKeyPath:@"isCompleted" context:(__bridge void *)(file.fileName)];
    [file removeObserver:self forKeyPath:@"downloadStatus" context:(__bridge void *)(file.fileName)];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"progress"]) {
        FileModel *file = (FileModel *)object;
        DownloadingCell *cell = (DownloadingCell *)[tabel cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[tempFileList indexOfObject:file] inSection:0]];
        [cell setPercent:file.progress];
        cell.speedOfProgress.text = [NSString stringWithFormat:@"%@/%@",file.fileReceivedSize,file.fileSize];
        if(file.downloader.state == TCBlobDownloadStateDownloading){
            NSRange foundObj = [[self formatByteCount:file.downloader.speedRate] rangeOfString:@"Zero" options:NSCaseInsensitiveSearch];
            if (foundObj.length>0) {
                cell.state.text = @"0KB";
            }else{
                cell.state.text = [self formatByteCount:file.downloader.speedRate];
            }
        }
    }else if([keyPath isEqualToString:@"downloadStatus"]){
        FileModel *file = (FileModel *)object;
        DownloadingCell *cell = (DownloadingCell *)[tabel cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[tempFileList indexOfObject:file] inSection:0]];
        if (file.downloader.state == TCBlobDownloadStateReady) {
            cell.state.text = @"正在等待...";
        }
        if (file.downloader.state == TCBlobDownloadStateFailed) {
            cell.state.text = @"下载出错";
        }
    }else if([keyPath isEqualToString:@"isCompleted"]){
        FileModel *file = (FileModel *)object;
        [file removeObserver:self forKeyPath:@"progress" context:(__bridge void *)(file.fileName)];
        [file removeObserver:self forKeyPath:@"isCompleted" context:(__bridge void *)(file.fileName)];
        [self reloadData];
    }
}
///计算字节大小
- (NSString*)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}
#pragma mark 下载完成
-(void)finishedDownload:(FileModel *)request{
    [self reloadData];
}
@end
