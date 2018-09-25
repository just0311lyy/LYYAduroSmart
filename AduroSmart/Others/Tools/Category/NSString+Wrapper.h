//
//  NSString+Wrapper.h
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Wrapper)

- (NSUInteger)indexOfString:(NSString*)str;

//为字符串拼接一个字符串
+(NSString *)changeGroupName:(NSString *)groupName withTypeId:(NSString *)typeId;
//将字符串还原
+(NSString *)groupNameReturn;




+(NSString *)changeName:(NSString *)old;



@end
