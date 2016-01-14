//
//  FileModel.h
//  YunPan
//
//  Created by Bruce Xu on 14-5-12.
//  Copyright (c) 2014年 Pansoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TCBlobDownloader.h"
#import "TCBlobDownloadManager.h"
@protocol DownloadDelegate <NSObject>
@optional
-(void)finishedDownload:(id)request;
@end

@interface FileModel : NSObject<DownloadDelegate>
///文件ID
@property(nonatomic,retain)NSString *fileID;
///文件名称
@property(nonatomic,retain)NSString *fileName;
///文件大小
@property(nonatomic,retain)NSString *fileSize;
///文件类型 0:@"Video" ;1:@"Audio";2:@"Image";3:@"File"4:Record
@property(nonatomic,retain)NSString *fileType;
// 0:@"Video" ;1:@"Audio";2:@"Image";3:@"File"4:Record

///是否是第一次接受数据
@property(nonatomic)BOOL isFirstReceived;//是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加
///已接收文件大小
@property(nonatomic,retain)NSString *fileReceivedSize;
///已接收到的文件
@property(nonatomic,retain)NSMutableData *fileReceivedData;//接受的数据
///文件下载地址
@property(nonatomic,retain)NSString *fileURL;
///时间
@property(nonatomic,retain)NSString *time;
///目标路径
@property(nonatomic,retain)NSString *targetPath;
///临时路径
@property(nonatomic,retain)NSString *tempPath;
///是否正在下载
@property(nonatomic)BOOL isDownloading;//是否正在下载
///将要下载
@property(nonatomic)BOOL  willDownloading;
///错误
@property(nonatomic)BOOL error;
///错误信息
@property(nonatomic,retain)NSString *errorStr;
///是否下载完成
@property(nonatomic,retain)NSString *isCompleted;
///下载进度
@property (nonatomic, assign) CGFloat progress;
///下载速度
@property (nonatomic, strong) NSString *speed;
///已下载字节
@property(nonatomic,assign) long long dataLength;
///下载任务
@property(nonatomic,strong) TCBlobDownloader *downloader;
///下载状态
@property(nonatomic,copy) NSString *downloadStatus;
///剩余时间
@property(nonatomic,assign) NSInteger remainingTime;

@property BOOL post;
@property int PostPointer;
@property(nonatomic,retain)NSString *postUrl;
@property (nonatomic,retain)NSString *fileUploadSize;
@property(nonatomic,retain)NSString *usrname;
@property(nonatomic,retain)NSString *MD5;
@property(nonatomic,retain)UIImage *fileimage;
@property(nonatomic,assign)id<DownloadDelegate> delegate;
/**
 *  实现一个下载
 *
 *  @param targetPath 目录地址
 *  @param url        现在地址
 *
 *  @return 下载实体
 */
-(TCBlobDownloader *)targetPath:(NSString *)targetPath downUrl:(NSString *)url;
@end

