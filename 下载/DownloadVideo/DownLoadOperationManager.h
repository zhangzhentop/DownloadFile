//
//  DownLoadOperation.h
//  Dispatch
//
//  Created by 朱天超 on 14-8-20.
//  Copyright (c) 2014年 zhaoonline. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <Foundation/Foundation.h>
#import "FileModel.h"
@interface DownLoadOperationManager : NSObject
///已下载完成的文件列表（文件对象）
@property(nonatomic,retain)NSMutableArray *finishedlist;
///文件列表
@property(nonatomic,retain)NSMutableArray *filelist;
@property(nonatomic , strong) NSURL* url;
/**
 *  初始化下载
 *
 *  @param url 下载地址
 *
 *  @return
 */
- (instancetype)initWithUrl:(NSString*)url;
/**
 *  保存一个下载内容
 *
 *  @param fileinfo 下载实体对象
 */
-(void)saveDownloadFile:(FileModel*)fileinfo;
/**
 *  删除一个文件
 *
 *  @param file 和文件有关的FileModel文件
 */
-(void)removeFile:(FileModel *)file;
/**
 *  保存正在下载的文件
 *
 *  @param array 文件列表
 */
-(void)saveAllFill:(NSMutableArray *)array;
/**
 *  单例初始化
 *
 *  @return
 */
+(DownLoadOperationManager *) sharedFilesDownManage;
/**
 *  单例初始化
 *
 *  @return
 */
+(DownLoadOperationManager *) sharedFiles;
+(id) allocWithZone:(NSZone *)zone;
/**
 *  开始下载
 *
 *  @param url 下载地址
 */
-(void)ContinueToDownload:(NSString *)url;
@end
