//
//  TCBlobDownloadManager.h
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class TCBlobDownloader;
@protocol TCBlobDownloaderDelegate;

/**
 `TCBlobDownloadManager` 是 `NSOperationQueue`的子类 ，用于执行 `TCBlobDownloader` 对象.
 
 它提供了启动和取消下载的方法，同时定义了最大限度的同时下载量。
 
 ## Note
 这类应作为单独使用` sharedinstance `方法。
 This class should be used as a singleton using the `sharedInstance` method.
 
 @since 1.0
 */
@interface TCBlobDownloadManager : NSObject

/**
 默认下载文件的路径，如果没有customPath属性被设定在创建的TCBlobDownloader对象。
 The default download path for a file if no `customPath` property is set at the creation of the `TCBlobDownloader` object.
 
 默认值是 ‘/tmp’。
 The default value is `/tmp`.
 设置下载路径时，请注意iOS数据存储准则。
 @warning Please be careful of the iOS Data Storage Guidelines when setting the download path.
 
 @since 1.1
 */
@property (nonatomic, copy) NSString *defaultDownloadPath;

/**
 当前队列中的下载数量
 The number of downloads currently in the queue
 
 @since 1.0
 */
@property (nonatomic, assign) NSUInteger downloadCount;

/**
 目前正在执行的下载数量（目前正在下载数据）。
 The number of downloads currently being executed by the queue (currently downloading data).
 
 @since 1.6.0
 */
@property (nonatomic, assign) NSUInteger currentDownloadsCount;

/**
 创建并返回一个` TCBlobDownloadManager `对象。如果已经创建，它只返回对象。
 Creates and returns a `TCBlobDownloadManager` object. If the singleton has already been created, it just returns the object.
 
 @since 1.5.0
*/
+ (instancetype)sharedInstance;

/**
 Instanciates and runs instantly a `TCBlobDownloadObject` with the specified URL, an optional customPath and an optional delegate. Runs in background thread the `TCBlobDownloader` object (a subclass of `NSOperation`) in the `TCBlobDownloadManager` instance.
 
 This method returns the created `TCBlobDownloader` object for further use.
 
 @see -initWithURL:downloadPath:delegate:
 
 @param url  The URL of the file to download.
 @param customPathOrNil  An optional path to override the default download path of the `TCBlobDownloadManager` instance. Can be `nil`.
 @param delegateOrNil  An optional delegate. Can be `nil`.

 @return The created and already running `TCBlobDownloadObject`.
 
 @since 1.4
*/
- (TCBlobDownloader *)startDownloadWithURL:(NSURL *)url
                                customPath:(NSString *)customPathOrNil
                                  delegate:(id<TCBlobDownloaderDelegate>)delegateOrNil;

/**
 Instanciates and runs instantly a `TCBlobDownloader` object. Provides the same functionalities than `-startDownloadWithURL:customPath:delegate:` but creates a `TCBlobDownloadObject` using blocks to update your view.
 
 @see -startDownloadWithURL:customPath:delegate:
 
 This method returns the created `TCBlobDownloader` object for further use.
 
 @see -initWithURL:downloadPath:firstResponse:progress:error:complete:
 
 @param url  下载文件的URL。
 @param customPathOrNil  一个可选路径覆盖‘TCBlobDownloadManager’实例的默认下载路径。可以是‘nil’。
 @param firstResponseBlock  从服务器第一次返回数据，可以为nil。
 @param progressBlock  这个block在下载是被调用，可以是nil。如果没有计算出剩余时间值是‘nil’
 @param errorBlock  在下载过程中出现错误时调用。如果该块被调用，则该下载将被取消。可以'nil'
 @param completeBlock  下载完成或错误时执行。 可以为nil.如果下载已取消参数‘removeFile’的值是‘YES’，‘pathToFile’为‘nil’。`TCBlobDownloader`将从`TCBlobDownloadManager`移除。
 
 @since 1.4
*/
- (TCBlobDownloader *)startDownloadWithURL:(NSURL *)url
                                customPath:(NSString *)customPathOrNil
                             firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
                                  progress:(void (^)(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress))progressBlock
                                     error:(void (^)(NSError *error))errorBlock
                                  complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock;

/**
 启动一个已经实例化 `TCBlobDownloader` 的对象.
 
 你可以实例化一个‘TCBlobDownloader’对象 用这个方法直接使用
 You can instanciate a `TCBlobDownloader` object and instead of executing it directly using `-startDownloadWithURL:customPath:delegate:` or the block equivalent, pass it to this method whenever you're ready.
 
 @param download  一个‘TCBlobDownloader’对象。
 
 @since 1.0
*/
- (void)startDownload:(TCBlobDownloader *)download;

/**
 设置`NSOperationQueue`的名字
 Name the underlying `NSOperationQueue`
 
 @param name  用名字获取`NSOperationQueue`
 
 @since 2.1.0
*/
- (void)setOperationQueueName:(NSString *)name;

/**
 指定默认下载路径。（默认的路径为` /tmp `）
 Specifies the default download path. (which is `/tmp` by default)
 
 The path can be non existant, if so, it will be created.
 
 @param pathToDL  The new default path.
 @param error  
 
 @return A boolean that is the result of [NSFileManager createDirFromPath:error:]
 
 @since 1.1
*/
- (BOOL)setDefaultDownloadPath:(NSString *)pathToDL error:(NSError *__autoreleasing *)error;

/**
 设置能同时下载最大数量，如果有更多的下载传递给‘tcblobdownloadmanager’一个下载完成之前 开始一个新的下载
 Set the maximum number of concurrent downloads allowed. If more downloads are passed to the `TCBlobDownloadManager` singleton, they will wait for an older one to end before starting.
 
 @param max  下载的最大数量。
 
 @since 1.0
*/
- (void)setMaxConcurrentDownloads:(NSInteger)max;

/**
 取消所有的下载。从磁盘上删除已下载的文件。
 Cancels all downloads. Remove already downloaded parts of the files from the disk is asked.
 
 如果'YES'，该方法将从磁盘上删除所有已下载的文件。如果设置为'NO'不删除。这将允许tcblobdownload重启下载从那里它在未来的操作结束。
 @param remove  If `YES`, this method will remove all downloaded files parts from the disk. Files parts are left untouched if set to `NO`. This will allow TCBlobDownload to restart the download from where it has ended in a future operation.
 
 @since 1.0
*/
- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;

@end
