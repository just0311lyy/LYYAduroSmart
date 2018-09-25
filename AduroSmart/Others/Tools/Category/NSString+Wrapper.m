//
//  NSString+Wrapper.m
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "NSString+Wrapper.h"

#define JavaNotFound  (-1)

@implementation NSString (Wrapper)

- (NSUInteger)indexOfString:(NSString*)str{
    NSRange range = [self rangeOfString:str];
    if (range.location == NSNotFound) {
        return JavaNotFound; //不包含该字段  return -1；
    }
    return range.location;  //包含该字段 return 该字段首字母所在位置
}

//为字符串拼接一个字符串
+(NSString *)changeGroupName:(NSString *)groupName withTypeId:(NSString *)typeId{
    NSString *newName = [groupName stringByAppendingString:@"-"];
    newName = [newName stringByAppendingString:typeId];
    return newName;
}

////将字符串还原
//+(NSString *)returnTheGroupName:(NSString *)groupName{
//    
//    
//    
//}



+(NSString *)changeName:(NSString *)old{
    if ([old isEqualToString:@"MainsOutlet"]) {
        return @"Mains Outlet";
    }
    if ([old isEqualToString:@"ToningLamp"]) {
        return @"Color lamp";
    }
    if ([old isEqualToString:@"MontionSensor"]) {
        return @"Motion Sensor";
    }
    
    if ([old isEqualToString:@"ContactSwitchSensor"]) {
        return @"Contact Switch";
    }
    if ([old isEqualToString:@"DimmableLight"]) {
        return @"Dim lamp";
    }
    if ([old isEqualToString:@"ColorTempLight"]) {
        return @"Color Temperature Lamp";
    }
    //为了适应simon购买回来的灯，网关错误识别为Switch
    if ([old isEqualToString:@"Switch"]) {
        return @"Dim lamp";
    }
    if ([old isEqualToString:@"WindowsCover"]) {
        return @"Curtain";
    }
    return old;
}

@end
