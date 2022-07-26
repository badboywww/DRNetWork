//
//  MBProgressHUD+Progress.m
//  AFNetworking
//
//  Created by DevWang on 2022/7/25.
//

#import "MBProgressHUD+Progress.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define isIpad [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define ScreenWidthRatio (isIpad?(ScreenWidth / 768.0):(ScreenWidth / 320.0))
#define dr_Size(R) ScreenWidthRatio * R
#define dr_FontSize(R) [UIFont systemFontOfSize: ScreenWidthRatio * R]

@implementation MBProgressHUD (Progress)

/**
 *  显示MBProgressHUD透明层遮盖
 *
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)showHUDtoView:(UIView *)view {
    
    if (view == nil)
        view                      = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *HUD            = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    HUD.bezelView.hidden = YES;
    // 隐藏时候从父控件中移除
    HUD.removeFromSuperViewOnHide = YES;
    
    return HUD;
}

/**
 *  显示小菊花MBProgressHUD
 *
 *  @param message 信息内容
 *  @param view    需要显示信息的视图
 *
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)showHUDAndMessage:(NSString *)message toView:(UIView *)view {
    
    if (view == nil)
        view                      = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *HUD            = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    HUD.bezelView.backgroundColor = [UIColor blackColor];
    HUD.contentColor              = [UIColor whiteColor];
    // 隐藏时候从父控件中移除
    HUD.removeFromSuperViewOnHide = YES;
    // 提示信息显示样式
    HUD.mode = MBProgressHUDModeIndeterminate;
    // 提示信息显示位置
    HUD.offset = CGPointMake(0.f, - 32.f);
    
    HUD.label.text = message;
    HUD.label.font = dr_FontSize(12.0);
    
    return HUD;
}

/**
 *  显示Toast。MBProgressHUD
 *
 *  @param message 信息内容
 *  @param places  0 居中    1 居底部
 *  @param view    需要显示信息的视图
 *
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)showToastAndMessage:(NSString *)message places:(NSInteger)places toView:(nullable UIView *)view {
    
    if (view == nil)
        view                          = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *HUD                = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    HUD.bezelView.backgroundColor     = [UIColor blackColor];
    HUD.contentColor                  = [UIColor whiteColor];
    // 提示信息显示样式
    HUD.mode                          = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    HUD.removeFromSuperViewOnHide     = YES;
    // 提示信息显示位置
    if (places == 0) {     HUD.offset = CGPointMake(0.f, 0.f);}
    else if (places == 1) {HUD.offset = CGPointMake(0.f, MBProgressMaxOffset);}
    // 1秒之后再消失
    [HUD hideAnimated:YES afterDelay:1.2];
    
    HUD.label.text = message;
    HUD.label.numberOfLines = 0;
    HUD.label.font = dr_FontSize(11.0);
    
    return HUD;
}

/**
 *  显示Toast。MBProgressHUD
 *
 *  @param message 信息内容
 *  @param places  0 居中    1 居底部
 *  @param delay   消失的时间
 *  @param view    需要显示信息的视图
 *
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)showToastAndMessage:(NSString *)message places:(NSInteger)places afterDelay:(NSTimeInterval)delay toView:(UIView *)view {
    
    if (view == nil)
        view                          = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *HUD                = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.bezelView.backgroundColor     = [UIColor blackColor];
    HUD.contentColor                  = [UIColor whiteColor];
    // 提示信息显示样式
    HUD.mode                          = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    HUD.removeFromSuperViewOnHide     = YES;
    // 提示信息显示位置
    if (places == 0) {     HUD.offset = CGPointMake(0.f, 0.f);}
    else if (places == 1) {HUD.offset = CGPointMake(0.f, MBProgressMaxOffset);}
    // 1秒之后再消失
    [HUD hideAnimated:YES afterDelay:delay];
    
    HUD.label.text = message;
    HUD.label.numberOfLines = 0;
    HUD.label.font = dr_FontSize(12.0);
    
    return HUD;
}

/**
 *  关闭小菊花MBProgressHUD
 *
 *  @param view    显示MBProgressHUD的视图
 */
+ (void)hideHUDForView:(nullable UIView *)view {
    
    if (view == nil)
        view = [UIApplication sharedApplication].keyWindow;
    
    [self hideHUDForView:view animated:YES];
}

+ (UIWindow *)getWindow {
    return  [UIApplication sharedApplication].delegate.window;
}


@end
