//
//  ASBaseViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASBaseViewController : UIViewController

/**
 *  @author Yangyang.Li, 16-07-07 10:02:16
 *
 *  @brief 启动进度条
 *
 *  @param text 显示的提示文字
 */
-(void)startMBProgressHUDWithText:(NSString *)text;

/**
 *  @author Yangyang.Li, 16-07-07 10:02:38
 *
 *  @brief 关闭进度条
 */
-(void)stopMBProgressHUD;



@end
