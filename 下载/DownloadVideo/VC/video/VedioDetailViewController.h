//
//  VedioDetailViewController.h
//  CloudPlatform
//
//  Created by Sky on 15/9/16.
//  Copyright (c) 2015年 com.hn3l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface VedioDetailViewController : UIViewController
/**
 *  视频信息
 */
@property (nonatomic,retain)FileModel *video;
@end
