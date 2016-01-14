//
//  DownLoadOperation.m
//  Dispatch
//
//  Created by 朱天超 on 14-8-20.
//  Copyright (c) 2014年 zhaoonline. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "DownLoadOperationManager.h"
#import "FileModel.h"
#define TEMPPATH [(NSString *)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/Temp/"]
static  DownLoadOperationManager *sharedFilesDownManage = nil;
@interface DownLoadOperationManager()
@end
@implementation DownLoadOperationManager
- (instancetype)initWithUrl:(NSString*)url
{
    if(!url)
        return nil;
    
    self = [super init];
    if (!self)
        return nil;
    if (![url hasPrefix:@"http"])
    {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    self.url = [NSURL URLWithString:url];
    [self downLoadUrl:url];
    return self;
}
-(void)downLoadUrl:(NSString *)url{
    //目标地址
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath;
    NSString *fileType = [(NSArray *)[url componentsSeparatedByString:@"."] lastObject];
    if ([fileType isEqualToString:@"mp4"] || [fileType isEqualToString:@"avi"]) {
        filePath = [documents stringByAppendingPathComponent:@"Video"];
        fileType = @"Video";
    }else if([fileType isEqualToString:@"mp3"]){
        filePath = [documents stringByAppendingPathComponent:@"Sound"];
        fileType = @"Sound";
    }else if([fileType isEqualToString:@"txt"]){
        filePath = [documents stringByAppendingPathComponent:@"Text"];
        fileType = @"Text";
    }else{
        filePath = [documents stringByAppendingPathComponent:@"Other"];
        fileType = @"Other";
    }
    //文件名称
    NSString *utf8NameUrl = [(NSArray *)[url componentsSeparatedByString:@"/"] lastObject];
    NSString *fileName = [utf8NameUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //创建目标地址
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //创建缓存地址
    if (![fileManager fileExistsAtPath:TEMPPATH]) {
        [fileManager createDirectoryAtPath:TEMPPATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    FileModel *fileInfo = [[FileModel alloc] init];
    fileInfo.fileName = fileName;
    fileInfo.fileURL = url;
    NSDate *myDate = [NSDate date];
    fileInfo.time =[self dateToString:myDate];
    fileInfo.fileType = fileType;
    fileInfo.targetPath = [NSString stringWithFormat:@"%@",filePath];
    fileInfo.isDownloading = YES;
    fileInfo.error = NO;
    fileInfo.isFirstReceived = YES;
    fileInfo.tempPath = TEMPPATH;
    fileInfo.isCompleted = @"NO";
    fileInfo.fileSize = @" ";
    fileInfo.progress = 0.001;
    fileInfo.fileReceivedSize = @" ";
    fileInfo.errorStr = @" ";
    fileInfo.dataLength = 0;
    NSMutableArray * tempAllArr = _filelist;
    BOOL IsExite = NO;
    for(int i=0;i<tempAllArr.count;i++) //这里简化逻辑，正在下载的就不用在重新下载了
    {
        FileModel *fModel=[tempAllArr objectAtIndex:i];
        if([fModel.fileName isEqualToString:fileInfo.fileName])
        {
            IsExite=YES;
            fileInfo = fModel;
            break;
        }
    }
    if(!IsExite)
    {
        fileInfo.downloader = [fileInfo targetPath:[NSString stringWithFormat:@"%@",filePath] downUrl:url];
        [_filelist addObject:fileInfo];
        [self saveDownloadFile:fileInfo];
    }
    else
    {
        fileInfo.downloader = [fileInfo targetPath:[NSString stringWithFormat:@"%@",filePath] downUrl:url];
        NSString *fName=fileInfo.fileName;
        NSString *ftext=[NSString stringWithFormat:@"%@已经进入下载队列",fName] ;
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:ftext delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
}
-(void)ContinueToDownload:(NSString *)url{
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath;
    NSString *fileType = [(NSArray *)[url componentsSeparatedByString:@"."] lastObject];
    if ([fileType isEqualToString:@"mp4"]||[fileType isEqualToString:@"avi"]) {
        filePath = [documents stringByAppendingPathComponent:@"Video"];
        fileType = @"Video";
    }else if([fileType isEqualToString:@"mp3"]){
        filePath = [documents stringByAppendingPathComponent:@"Sound"];
        fileType = @"Sound";
    }else if([fileType isEqualToString:@"txt"]){
        filePath = [documents stringByAppendingPathComponent:@"Text"];
        fileType = @"Text";
    }else{
        filePath = [documents stringByAppendingPathComponent:@"Other"];
        fileType = @"Other";
    }
    
    //文件名称
    NSString *utf8NameUrl = [(NSArray *)[url componentsSeparatedByString:@"/"] lastObject];
    NSString *fileName = [utf8NameUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    FileModel *fileInfo;
    NSMutableArray * tempAllArr = _filelist;
    for(int i=0;i<tempAllArr.count;i++) //这里简化逻辑，正在下载的就不用在重新下载了
    {
        FileModel *fModel=[tempAllArr objectAtIndex:i];
        if([fModel.fileName isEqualToString:fileName])
        {
            fileInfo = fModel;
            break;
        }
    }
    fileInfo.downloader = [fileInfo targetPath:[NSString stringWithFormat:@"%@",filePath] downUrl:url];
}
#pragma mark - 监听暂停

- (NSString*)formatByteCount:(long long)size
{
    NSData *data = [[NSData alloc] init];
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}
//时间下载
-(NSString *)dateToString:(NSDate*)date{
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd HH:mm:ss"];//[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *datestr = [df stringFromDate:date];
    return datestr;
}
//保存缓存文件
-(void)saveDownloadFile:(FileModel*)fileinfo{
    if (fileinfo.errorStr==nil) {
        fileinfo.errorStr = @" ";
    }
    NSString *plistPath = [[TEMPPATH stringByAppendingString:fileinfo.fileName] stringByAppendingPathExtension:@"plist"];
    NSDictionary *filedic = @{@"filename":fileinfo.fileName,@"fileType":fileinfo.fileType,@"isCompleted":fileinfo.isCompleted,@"fileurl":fileinfo.fileURL,@"targetPath":fileinfo.targetPath,@"tempPath":plistPath,@"filesize":fileinfo.fileSize,@"filerecievesize":fileinfo.fileReceivedSize,@"time":fileinfo.time,@"progress":[NSString stringWithFormat:@"%f",fileinfo.progress],@"errorStr":fileinfo.errorStr,@"dataLength":[NSString stringWithFormat:@"%lld",fileinfo.dataLength]};
    if (![filedic writeToFile:plistPath atomically:YES]) {
        NSLog(@"write plist fail");
    }
    else{
    }
}
///保存全部文件
-(void)saveAllFill:(NSMutableArray *)array{
    if (array==nil) {
        return;
    }
    for (FileModel *file in array) {
        [self saveDownloadFile:file];
    }
}

///载入
-(void)loadTempfiles
{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *filelist=[fileManager contentsOfDirectoryAtPath:TEMPPATH error:&error];
    if(error)
    {
        NSLog(@"%@",[error description]);
    }
    NSMutableArray *filearr = [[NSMutableArray alloc]init];
    for(NSString *file in filelist)
    {
        NSString *filetype = [file  pathExtension];
        if([filetype isEqualToString:@"plist"])
            [filearr addObject:[self getTempfile:[TEMPPATH stringByAppendingPathComponent:file]]];
    }
    
    
    [_filelist addObjectsFromArray:filearr];
    
    
    //[self startLoad];
    
}
///将文件读到实例中
-(FileModel *)getTempfile:(NSString *)path{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    FileModel *file = [[FileModel alloc]init];
    file.fileName = [dic objectForKey:@"filename"];
    file.fileType = [file.fileName pathExtension ];
    file.fileURL = [dic objectForKey:@"fileurl"];
    file.fileSize = [dic objectForKey:@"filesize"];
    file.fileReceivedSize= [dic objectForKey:@"filerecievesize"];
//    NSString*  path1= dic[@"targetPath"];
    file.time = [dic objectForKey:@"time"];
    file.fileimage = [UIImage imageWithData:[dic objectForKey:@"fileimage"]];
    file.fileType = dic[@"fileType"];
    file.isCompleted = dic[@"isCompleted"];
    file.targetPath = dic[@"targetPath"];
    file.tempPath = dic[@"tempPath"];
    file.progress = [dic[@"progress"] floatValue];
    file.errorStr = dic[@"errorStr"];
    file.isDownloading=NO;
    file.isDownloading = NO;
    file.willDownloading = NO;
    NSString *dataL = dic[@"dataLength"];
    file.dataLength = [dataL longLongValue];
    // file.isFirstReceived = YES;
    file.error = NO;
    
//    NSData *fileData=[[NSFileManager defaultManager ] contentsAtPath:path1];
//    NSInteger receivedDataLength=[fileData length];
//    file.fileReceivedSize=[NSString stringWithFormat:@"%ld",(long)receivedDataLength];
    return file;
}

///删除文件
-(void)removeFile:(FileModel *)file{
    NSFileManager * fileManager = [[NSFileManager alloc]init];
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",file.fileType,file.fileName];
    NSString *filePath = [documents stringByAppendingPathComponent:fileName];
    
    NSString *tempStr = [NSString stringWithFormat:@"Temp/%@.plist",file.fileName];
    NSString *tempFile = [documents stringByAppendingPathComponent:tempStr];
    
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:tempFile error:nil];
    [self.filelist removeObject:file];
}

///单例，初始化本类
+(DownLoadOperationManager *) sharedFilesDownManage{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] initWithArray];
        }
    }
    return  sharedFilesDownManage;
}
///单例，初始化
+(DownLoadOperationManager *) sharedFiles{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] init];
        }
    }
    return  sharedFilesDownManage;
}
+(id) allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [super allocWithZone:zone];
            return  sharedFilesDownManage;
        }
    }
    return nil;
}
///初始化数组，载入已下载数据
-(id)initWithArray{
    _filelist = [[NSMutableArray alloc]init];
    [self loadTempfiles];
    _finishedlist = [[NSMutableArray alloc] init];
    return  [self init];
}
@end
