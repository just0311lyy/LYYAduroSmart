//
//  ASValidate.h
//  AduroSmart
//
//  Created by MacBook on 16/8/6.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASValidate : NSObject
+(BOOL)telephone:(NSString *)data;
+(BOOL)email:(NSString *)data;
+(BOOL)password:(NSString *)data;
+(BOOL)username:(NSString *)data;
+(BOOL)veriEmail:(NSString *)data;

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
+(BOOL)comfirmPassword:(NSString *)password confirmPwd:(NSString *)confirmPwd;

@end
