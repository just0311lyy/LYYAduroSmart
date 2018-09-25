//
//  ASGlobalDataObject.h
//  AduroSmart
//
//  Created by MacBook on 16/7/15.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @author LYY, 15-12-24 16:12:24
 *
 *  @brief 数组下标
 */
extern NSInteger *_index;


/**
 *  @author xingman.yi, 15-12-24 16:12:24
 *
 *  @brief 设备列表
 */
extern NSMutableArray *_globalDeviceArray;
///**
// *  @author xingman.yi, 15-12-24 16:12:24
// *
// *  @brief 查找新设备列表
// */
//extern NSMutableArray *_globalNewDeviceArray;

/**
 *  @author xingman.yi, 15-12-24 16:12:47
 *
 *  @brief 分组列表
 */
extern NSMutableArray *_globalGroupArray;
/**
 *  @author xingman.yi, 15-12-24 16:12:05
 *
 *  @brief 场景列表
 */
extern NSMutableArray *_globalSceneArray;
/**
 *  @author  15-12-24 16:12:21
 *
 *  @brief 网关列表
 */
extern NSMutableArray *_globalGetwayArray;
/**
 *  @author  15-12-24 16:12:21
 *
 *  @brief 云网关列表
 */
extern NSMutableArray *_globalCloudGetwayArray;
/**
 *  @author  16-03-12 17:03:47
 *
 *  @brief 设备任务列表
 */
extern NSMutableArray *_globalDeviceTaskArray;

extern NSMutableArray *_globalTaskInfoArray;



//时间任务列表
extern NSMutableArray *_globalTimeTaskArray;
//联动任务列表
extern NSMutableArray *_globalActionTaskArray;
///**
// *  @author xingman.yi, 16-03-12 17:03:47
// *
// *  @brief 传感器触发时间列表
// */
//extern NSMutableArray *_globalSensorTimeArray;

@interface ASGlobalDataObject : NSObject

+(BOOL)checkLogin;

+(BOOL)checkGatewayConnected; //检查是否有局域网网关连接
@end
