//
//  ASGlobalDataObject.m
//  AduroSmart
//
//  Created by MacBook on 16/7/15.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGlobalDataObject.h"
#import "AppDelegate.h"

/**
 *  @author LYY, 15-12-24 16:12:24
 *
 *  @brief 数组下标
 */
NSInteger *_index;



/**
 *  @author xingman.yi, 15-12-24 16:12:24
 *
 *  @brief 设备列表
 */
NSMutableArray *_globalDeviceArray;
///**
// *  @author xingman.yi, 15-12-24 16:12:24
// *
// *  @brief 查找新设备列表
// */
//NSMutableArray *_globalNewDeviceArray;

/**
 *  @author xingman.yi, 15-12-24 16:12:47
 *
 *  @brief 分组列表
 */
NSMutableArray *_globalGroupArray;
/**
 *  @author xingman.yi, 15-12-24 16:12:05
 *
 *  @brief 场景列表
 */
NSMutableArray *_globalSceneArray;
/**
 *  @author xingman.yi, 15-12-24 16:12:21
 *
 *  @brief 网关列表
 */
NSMutableArray *_globalGetwayArray;
/**
 *  @author  15-12-24 16:12:21
 *
 *  @brief 云网关列表
 */
NSMutableArray *_globalCloudGetwayArray;
/**
 *  @author xingman.yi, 16-03-12 17:03:47
 *
 *  @brief 设备任务列表
 */
NSMutableArray *_globalDeviceTaskArray;

NSMutableArray *_globalTaskInfoArray;


//时间任务列表
NSMutableArray *_globalTimeTaskArray;
//联动任务列表
NSMutableArray *_globalActionTaskArray;
///**
// *  @author xingman.yi, 16-03-12 17:03:47
// *
// *  @brief 传感器触发时间列表
// */
//NSMutableArray *_globalSensorTimeArray;


@implementation ASGlobalDataObject

+(BOOL)checkLogin{
    BOOL checkIsLogin = NO;
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.isLogin) {
        checkIsLogin = YES;
    }
    return checkIsLogin;
}

+(BOOL)checkGatewayConnected{
    BOOL checkIsGatewayConnect = NO;
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.isConnect) {
        checkIsGatewayConnect = YES;
    }
    return checkIsGatewayConnect;
}


@end
