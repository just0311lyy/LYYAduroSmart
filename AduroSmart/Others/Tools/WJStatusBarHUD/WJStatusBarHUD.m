//
//  WJStatusBarHUD.m
//  WJStatusBarHUD
//
//  Created by wj on 16/2/26.
//  Copyright © 2016年 wj. All rights reserved.
//

#import "WJStatusBarHUD.h"

@implementation WJStatusBarHUD

static UIWindow *window_;
static NSTimer *timer_;

/** HUD控件的高度 */
static CGFloat const WJWindowH = 19;

/** HUD控件的动画持续时间 */
static CGFloat const WJAnimationDuration = 0.25;

/** HUD控件默认会停留多长时间 */
static CGFloat const WJHUDStayDuration = 100.5;

+ (void)showImage:(UIImage *)image text:(NSString *)text{
    
    
    // 停止定时器
    [timer_ invalidate];
    timer_ = nil;
    
    // 创建窗口
    window_.hidden = YES;
    window_ = [[UIWindow alloc]init];
//    window_.backgroundColor = [UIColor grayColor];
//    window_.backgroundColor = UIColorFromRGB(0xff4444);
    window_.backgroundColor = UIColorFromRGB(0xfe9d04);
    window_.windowLevel = UIWindowLevelAlert;
    window_.frame = CGRectMake(0, StatursBarHUDY, [UIScreen mainScreen].bounds.size.width, WJWindowH);
    window_.hidden = NO;
    
    // 创建按钮
    UIButton *button = [self createButtonWithText:text];
    
    // 图片
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    }
    [window_ addSubview:button];
    
    // 动画
    [UIView animateWithDuration:WJAnimationDuration animations:^{
        CGRect frame = window_.frame;
        frame.origin.y = StatursBarHUDY;
        window_.frame = frame;
    }];
    
    // 启动定时器
    timer_ = [NSTimer scheduledTimerWithTimeInterval:WJHUDStayDuration target:self selector:@selector(hide) userInfo:nil repeats:NO];
    
}

+ (void)showImageName:(NSString *)imageName text:(NSString *)text{
    
    [self showImage:[UIImage imageNamed:imageName] text:text];
}

+ (void)showSuccessImageName:(NSString *)imageName text:(NSString *)text{
    
    [self showImage:[UIImage imageNamed:[self cheakSuccessImageName:imageName]] text:[self cheakSuccessText:text]];

}

+ (void)showErrorImageName:(NSString *)imageName text:(NSString *)text{
    
    [self showImage:[UIImage imageNamed:[self cheakErrorImageName:imageName]] text:[self cheakErrorText:text]];
}

+ (void)showWarningImageName:(NSString *)imageName text:(NSString *)text{
    
    [self showImage:[UIImage imageNamed:[self cheakWarningImageName:imageName]] text:[self cheakWarningText:text]];
}

+ (void)showLoading:(NSString *)text{
    
    
    // 检查text
    if (text.length < 1 || text == nil || text == NULL) {
        text = @"loading";
    }
    
    // 停止定时器
    [timer_ invalidate];
    timer_ = nil;
    
    window_.hidden = YES;
    window_ = [[UIWindow alloc]init];
//    window_.backgroundColor = [UIColor grayColor];
//    window_.backgroundColor = UIColorFromRGB(0xff4444);
    window_.backgroundColor = UIColorFromRGB(0xfe9d04);
    window_.windowLevel = UIWindowLevelAlert;
    window_.frame = CGRectMake(0, StatursBarHUDY, [UIScreen mainScreen].bounds.size.width, WJWindowH);
    window_.hidden = NO;
    

    UIButton *button = [self createButtonWithText:text];


    
    [window_ addSubview:button];
    button.userInteractionEnabled = NO;
    
    // 菊花
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingView startAnimating];
    loadingView.center = CGPointMake(button.titleLabel.frame.origin.x-20, WJWindowH*0.5);
    [window_ addSubview:loadingView];
    
    // 动画
    [UIView animateWithDuration:WJAnimationDuration animations:^{
        CGRect frame = window_.frame;
        frame.origin.y = StatursBarHUDY;
        window_.frame = frame;
    }];
    
}

+ (NSString *)cheakSuccessText:(NSString *)text{
    
    if (text.length < 1 || text == nil || text == NULL) {
        text = @"加载数据成功";
    }
    return text;
    
}

+ (NSString *)cheakSuccessImageName:(NSString *)imageName{
    
    if (imageName.length < 1 || imageName == nil || imageName == NULL) {
        imageName = @"WJStatusBarHUD_success";
    }
    return imageName;
}


+ (NSString *)cheakErrorText:(NSString *)text{
    
    if (text.length < 1 || text == nil || text == NULL) {
        text = @"加载数据失败";
    }
    return text;
    
}

+ (NSString *)cheakErrorImageName:(NSString *)imageName{
    
    if (imageName.length < 1 || imageName == nil || imageName == NULL) {
        imageName = @"WJStatusBarHUD_error";
    }
    return imageName;
}

+ (NSString *)cheakWarningImageName:(NSString *)imageName{
    
    if (imageName.length < 1 || imageName == nil || imageName == NULL) {
        imageName = @"WJStatusBarHUD_warning";
    }
    return imageName;
}

+ (NSString *)cheakWarningText:(NSString *)text{
    
    if (text.length < 1 || text == nil || text == NULL) {
        text = @"警告";
    }
    return text;
}

+ (UIButton *)createButtonWithText:(NSString *)text{
    
    // 添加按钮
    UIButton *button = [[UIButton alloc] init];
    button.frame = window_.bounds;
    
    // 文字
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.imageView.backgroundColor = [UIColor clearColor];
    [window_ addSubview:button];
    button.userInteractionEnabled = NO;
    return button;
}

+ (void)hide{
    [timer_ invalidate];
    timer_ = nil;
    [UIView animateWithDuration:WJAnimationDuration animations:^{
        CGRect frame = window_.frame;
        frame.origin.y = frame.origin.y - WJWindowH;
        frame.size.height = 0;
        window_.frame = frame;
    }completion:^(BOOL finished) {
        window_ = nil;
    }];
}

@end
