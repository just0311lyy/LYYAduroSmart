//
//  ASValidate.m
//  AduroSmart
//
//  Created by MacBook on 16/8/6.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASValidate.h"
#import "ASLocalizeConfig.h"
@implementation ASValidate
//邮箱格式验证
+(BOOL)email:(NSString *)data{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:data];
}

+(BOOL)telephone:(NSString *)data{
    NSString *regex = @"^(0|[1-9]\\d{0,10})$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:data];
}

+(BOOL)password:(NSString *)data{
    if ([data length]<8||[data length]>18) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"密码必须由8到18位字符或数字组成"]  delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

/**
 *  @author  16-03-04 08:03:13
 *
 *  @brief 验证密码和确认密码
 *
 *  @param password   密码
 *  @param confirmPwd 确认密码
 *
 *  @return 是否通过验证
 */
+(BOOL)comfirmPassword:(NSString *)password confirmPwd:(NSString *)confirmPwd{
    if ([password length]<1||[password length]>18) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"密码必须由1到18位字符或数字组成"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }else if (![password isEqualToString:confirmPwd]){
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"两次输入的密码不一致"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"]  otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

+(BOOL)username:(NSString *)data{
    if ([data length]<1||[data length]>30) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"账号不能为空"]message:[ASLocalizeConfig localizedString:@"账号必须由1到30位字符或数字组成"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

+(BOOL)veriEmail:(NSString *)data{
    if (![ASValidate email:data]) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"您输入的邮箱有误"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

+(BOOL)checkVerifyCode:(NSString *)veriCode localVericode:(NSString *)localVericode{
    if (![veriCode isEqualToString:veriCode]){
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"验证码错误!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

@end
