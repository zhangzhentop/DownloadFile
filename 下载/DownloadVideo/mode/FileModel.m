//
//  FileModel.m
//  YunPan
//
//  Created by Bruce Xu on 14-5-12.
//  Copyright (c) 2014年 Pansoft. All rights reserved.
//

#import "FileModel.h"
#import "DownLoadOperationManager.h"
@interface FileModel()
@end
@implementation FileModel
-(TCBlobDownloader *)targetPath:(NSString *)targetPath downUrl:(NSString *)url{
    typeof(self)newSelf = self;
    NSURL *myUrl = [NSURL URLWithString:url];
    TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:myUrl
                                                          downloadPath:targetPath
                                                         firstResponse:^(NSURLResponse *response){
//                                                             newSelf.downloader = download;
                                                          }
                                                              progress:^(uint64_t receivedLength,uint64_t totalLength,NSInteger remainingTime,float progress){
                                                                  newSelf.downloadStatus = [newSelf subtitleForDownload:download];//下载状态
                                                                  newSelf.remainingTime = remainingTime;//剩余时间
                                                                  newSelf.progress = progress;//下载进度
                                                                  newSelf.fileSize =[newSelf formatByteCount:totalLength];//文件长度
                                                                  newSelf.fileReceivedSize = [newSelf formatByteCount:receivedLength];//已下载文件长度
                                                                  
                                                                  newSelf.speed = [newSelf formatByteCount:download.speedRate];
                                                                  
                                                              }
                                                                 error:^(NSError *error){
                                                                     //下载状态
                                                                     newSelf.downloadStatus = [newSelf subtitleForDownload:download];
                                                                     //错误信息
                                                                     NSDictionary *userInfo = error.userInfo;
                                                                     newSelf.errorStr = userInfo[@"NSLocalizedDescription"];
                                                                     NSError *errorMsg = userInfo[@"NSUnderlyingError"];
                                                                     NSDictionary *dicMsg = errorMsg.userInfo;
                                                                     int errorCode = errorMsg.code;
                                                                     newSelf.errorStr = dicMsg[@"NSLocalizedDescription"];
                                                                     //是否完成
//                                                                     newSelf.isCompleted = @"YES";
                                                                     if([newSelf.delegate respondsToSelector:@selector(finishedDownload:)])
                                                                     {
                                                                         [newSelf.delegate finishedDownload:self];
                                                                     }
                                                                     //保存
                                                                     [[DownLoadOperationManager sharedFiles] saveDownloadFile:self];
                                                                 }
                                                              complete:^(BOOL downloadFinished,NSString *pathToFile){
                                                                  //下载状态
                                                                  newSelf.downloadStatus = [newSelf subtitleForDownload:download];
                                                                  if(downloadFinished){
                                                                      //是否完成
                                                                      newSelf.isCompleted = @"YES";
                                                                      
                                                                      if([newSelf.delegate respondsToSelector:@selector(finishedDownload:)])
                                                                      {
                                                                          [newSelf.delegate finishedDownload:self];
                                                                      }
                                                                      [[DownLoadOperationManager sharedFiles] saveDownloadFile:self];
                                                                  }
                                                              }];
    [[TCBlobDownloadManager sharedInstance] setMaxConcurrentDownloads:2];
    [[TCBlobDownloadManager sharedInstance] startDownload:download];
    return download;
}
/**
 *  下载状态
 *
 *  @param download 下载
 *
 *  @return 下载状态
 */
- (NSString *)subtitleForDownload:(TCBlobDownloader *)download
{
    NSString *stateString;
    
    switch (download.state) {
        case TCBlobDownloadStateReady:
            stateString = @"正在链接";
            break;
        case TCBlobDownloadStateDownloading:
            stateString = @"下载中";
            break;
        case TCBlobDownloadStateDone:
            stateString = @"完成";
            break;
        case TCBlobDownloadStateCancelled:
            stateString = @"取消";
            break;
        case TCBlobDownloadStateFailed:
            stateString = @"下载出错";
            break;
        default:
            break;
    }
    return stateString;
}

- (NSString*)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}
@end
