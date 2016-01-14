//
//  PlayVideoVC.h
//  VideoDemo
//
//  Created by myl on 15/5/14.
//  Copyright (c) 2015年 com.hn3l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
@interface PlayVideoVC : UIViewController

@property (nonatomic, assign) int screenWidth;
@property (nonatomic, assign) int screenHeight;
@property (nonatomic, strong) FileModel *file;
@end
