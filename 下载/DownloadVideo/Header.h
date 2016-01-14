//
//  Header.h
//  DownloadVideo
//
//  Created by csip on 15/10/21.
//  Copyright (c) 2015年 zh. All rights reserved.
//

#ifndef DownloadVideo_Header_h
#define DownloadVideo_Header_h

#define IMG(name) [UIImage imageNamed:name]
#define APP_WIDTH [[UIScreen mainScreen]applicationFrame].size.width
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define VIEW_TX(view) (view.frame.origin.x)
#define VIEW_TY(view) (view.frame.origin.y)
#define VIEW_W(view)  (view.frame.size.width)
#define VIEW_H(view)  (view.frame.size.height)

#define IOS_VERSION_7_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue]<8.0)? (YES):(NO))
#define IOS_VERSION_8_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))
#endif
