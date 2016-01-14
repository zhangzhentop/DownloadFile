//
//  AppHelper.h
//  WebService
//
//  Created by aJia on 12/12/24.
//  Copyright (c) 2012年 rang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppHelper : NSObject
typedef void (^execution_block)(void);
typedef void (^complete_block)(void);
+ (void)showHUD:(NSString *)msg;
+ (void)removeHUD;
+ (void)showError:(NSString *)error;
+(void)showTextOnly:(NSString *)msg;
+(void)showSimple;
@end
