//
//  AduroTask.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/6.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AduroDevice.h"
#import "AduroScene.h"

//（0x01定时设备、0x02定时场景、0x03触发设备、0x04触发场景）
typedef enum : NSUInteger {
    TaskTypeTriggerScene = 0x00,/*传感器设备触发场景任务*/
    TaskTypeSceneTimer = 0x01/*定时场景任务*/
} TaskType;

@interface AduroTask : NSObject

@property (nonatomic,assign) NSInteger taskID;//任务编号
@property (nonatomic,strong) NSString *taskName;//任务名称
@property (nonatomic,assign) Byte taskType;//任务的类型 见TaskType
@property (nonatomic,assign) Byte taskConditionHour;//任务触发小时
@property (nonatomic,assign) Byte taskConditionMinute;//任务触发分钟
@property (nonatomic,assign) Byte taskConditionSecond;//任务触发秒钟
//0x01 周一 0x02 周二 0x04 周三 0x08 周四 0x10 周五 0x20 周六 0x40 周日
@property (nonatomic,assign) Byte taskConditionWeek;//任务触发周期
@property (nonatomic,strong) AduroDevice *taskConditionDevice;//触发的设备
@property (nonatomic,assign) Byte taskConditionDeviceAction;//触发的设备的动作(门磁传感器(Contact Switch)开0x01，门磁传感器(Contact Switch)关0x00;人体红外传感器(Motion Sensor)有人0x01，人体红外传感器(Motion Sensor)只触发0x01)
@property (nonatomic,strong) AduroDevice *taskTriggeredDevice;//被触发的设备
@property (nonatomic,strong) AduroScene *taskTriggeredScene;//被触发的场景
@property (nonatomic,assign) BOOL taskEnable;//是否启用任务


@end
