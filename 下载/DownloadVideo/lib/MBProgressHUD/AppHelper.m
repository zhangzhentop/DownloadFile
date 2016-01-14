//
//  AppHelper.m
//  WebService
//
//  Created by aJia on 12/12/24.
//  Copyright (c) 2012年 rang. All rights reserved.
//

#import "AppHelper.h"
#import "MBProgressHUD.h"
@implementation AppHelper
static MBProgressHUD *HUD;
/**
 *  显示一个带文本的hud
 *
 *  @param msg 文本
 */
+(id)single{
    if (HUD==nil) {
        HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    }
    if (HUD.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    }
//    HUD.removeFromSuperViewOnHide = NO;
//    [HUD show:YES];
    return HUD;
}
+ (void)showHUD:(NSString *)msg{
    
    [self single];
    HUD.dimBackground = YES;
    HUD.labelText = msg;
    [HUD show:YES];
}
/**
 *  显示一个只有文本的hud
 *
 *  @param msg 文本
 */
+(void)showTextOnly:(NSString *)msg{
    [self single];
    HUD.labelText = msg;
    HUD.mode = MBProgressHUDModeText;
    [HUD show:YES];
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:2];
}
/**
 *  隐藏hud
 */
+ (void)removeHUD{
    
    [HUD hide:YES];
    [HUD removeFromSuperViewOnHide];
}
+ (void)showError:(NSString *)error{
    // 快速显示一个提示信息
    [self single];
    HUD.labelText = error;
    // 设置图片
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    // 再设置模式
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD show:YES];
    
    //    // 隐藏时候从父控件中移除
    HUD.removeFromSuperViewOnHide = YES;
    //
    //    // 1秒之后再消失
    [HUD hide:YES afterDelay:1];
}
/**
 *  显示一个最简单的hud
 */
+(void)showSimple{
    [self single];
    [HUD show:YES];
    //    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
@end
