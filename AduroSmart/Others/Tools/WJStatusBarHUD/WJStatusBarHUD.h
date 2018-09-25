//
//  WJStatusBarHUD.h
//  WJStatusBarHUD
//
//  Created by wj on 16/2/26.
//  Copyright © 2016年 wj. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface WJStatusBarHUD : NSObject

#define StatursBarHUDY (34+20)
/**
 * 显示图片和文字信息
 */
+ (void)showImage:(UIImage *)image text:(NSString *)text;

/**
 * 显示图片和文字信息
 */
+ (void)showImageName:(NSString *)imageName text:(NSString *)text;


/**
 * 显示成功信息
 */
+ (void)showSuccessImageName:(NSString *)imageName text:(NSString *)text;


/**
 * 显示失败的信息
 */
+ (void)showErrorImageName:(NSString *)imageName text:(NSString *)text;


/**
 * 显示警告的信息
 */
+ (void)showWarningImageName:(NSString *)imageName text:(NSString *)text;

/**
 * 显示正在处理的信息
 */
+ (void)showLoading:(NSString *)text;


/**
 * 隐藏HUD
 */
+ (void)hide;

@end
