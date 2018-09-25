//
//  ASDataBaseOperation.h
//  AduroSmart
//
//  Created by MacBook on 16/7/18.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASPushNotiModel.h"
#import "ASSensorDataObject.h"


@interface ASDataBaseOperation : NSObject

-(BOOL)openDatabase;
+(ASDataBaseOperation *)sharedManager;

-(BOOL)excuteSqlString:(NSString *)sqlString;

#pragma mark - 传感器数据相关
/**
 *  保存传感器数据
 *
 *  @param model 传感器数据
 *
 *  @return 是否保存成功
 */
-(BOOL)saveSensorData:(ASSensorDataObject *)model;
/**
 *  查询设备数据存相关信息
 *
 *  @return 返回的设备数据存对象数组
 */
-(NSArray *)selectSensorData;

-(BOOL)deleteSensorWithID:(NSString *)deviceId;
#pragma mark -设备数据相关
/**
 *  保存设备数据
 *
 *  @param model 设备数据
 *
 *  @return 是否保存成功
 */
-(BOOL)saveDeviceData:(AduroDevice *)model withGatewayid:(NSString *)gatewayID;
/**
 *  查询设备数据存相关信息
 *
 *  @return 返回的设备数据存对象数组
 */
-(NSArray *)selectDeviceDataWithGatewayid:(NSString *)gatewayID;
/**
 *  通过id更新某个设备名称
 */
-(BOOL)updateDeviceNameData:(NSString *)deviceName WithID:(NSString *)deviceID;
/** 通过id更新某个设备亮度 */
-(BOOL)updateDeviceLightLevelData:(NSInteger)deviceLight WithID:(NSString *)deviceID;
/** 通过id更新某个设备开关 */
-(BOOL)updateDeviceSwitchData:(NSInteger)onOff WithID:(NSString *)deviceID;
/**
 *  通过文件的id去删除本地数据
 *
 *  @param 文件的id
 *
 *  @return 返回是否删除成功
 */
-(BOOL)deleteDeviceWithID:(NSString *)deviceId;
/**
 *  删除device表中的所有数据 是否成功
 */
-(BOOL)deleteAllDevices;

/**
 *  更新文件数据
 *
 *  @param 文件对象
 *
 *  @return 是否更新成功
 */
-(BOOL)updateDeviceInfo:(AduroDevice *)model;

-(NSInteger )selectDeviceSortNumberWithDeviceID:(NSString *)deviceID;

#pragma mark - 房间数据相关
/**
 *  保存房间数据
 *
 *  @param model 房间数据
 *
 *  @return 是否保存成功
 */
-(BOOL)saveRoomData:(AduroGroup *)model withGatewayid:(NSString *)gatewayID;
/**
 *  通过id更新某个房间名称
 *
 *  @param model 房间id
 *
 *  @return 是否更新成功
 */
-(BOOL)updateRoomNameData:(NSString *)groupName WithID:(NSInteger)groupID withGatewayid:(NSString *)gatewayID;
/**
 *  查询房间数据存相关信息
 *
 *  @return 返回的房间数据存对象数组
 */
-(NSArray *)selectRoomDataWithGatewayid:(NSString *)gatewayID;

/**
 *  删除group表中的所有数据 是否成功
 */
-(BOOL)deleteAllRooms;

/**
 *  通过group的id去删除单条本地数据 是否成功
 */
-(BOOL)deleteRoomWithID:(NSInteger)groupId withGatewayid:(NSString *)gatewayID;

#pragma mark - 场景数据相关
/**
 *  保存场景数据
 *
 *  @param model 场景数据
 *
 *  @return 是否保存成功
 */
-(BOOL)saveSceneData:(AduroScene *)model withGatewayid:(NSString *)gatewayID;

/**
 *  查询场景数据存相关信息
 *
 *  @return 返回的场景数据存对象数组
 */
-(NSArray *)selectSceneDataWithGatewayid:(NSString *)gatewayID;
/** 
 *  通过id更新某个场景名称
 */
-(BOOL)updateSceneNameData:(NSString *)sceneName withID:(NSInteger)sceneID withGatewayid:(NSString *)gatewayID;
/**
 *  通过scene的id去删除本地数据 是否删除成功
 */
-(BOOL)deleteSceneWithID:(NSInteger)sceneId withGatewayid:(NSString *)gatewayID;
/**
 *  删除全部scene数据 是否删除成功
 */
-(BOOL)deleteAllScenes;

/**
 *  保存任务数据 是否保存成功
 */
-(BOOL)saveTasksData:(AduroTask *)model withGatewayid:(NSString *)gatewayID;
/**
 *  查询任务数据对象数组
 */
-(NSArray *)selectTaskDataWithGatewayid:(NSString *)gatewayID;
/** 
 *通过id更新某个任务名称 
 */
-(BOOL)updateTaskNameData:(NSString *)taskName withID:(NSInteger)taskID withGatewayid:(NSString *)gatewayID;
/**
 *  通过task的id去删除本地数据 是否删除成功
 */
-(BOOL)deleteTaskWithID:(NSInteger)taskId withGatewayid:(NSString *)gatewayID;
/**
 *  删除全部task数据 是否删除成功
 */
-(BOOL)deleteAllTasks;

#pragma mark - 网关数据文件
/**
 *  保存网关数据是否保存成功
 */
-(BOOL)saveGatewayData:(AduroGateway *)model;
/*
 * 通过网关的id更新某个网关的版本号 
 */
-(BOOL)updateGatewayVersionData:(NSString *)softwareVersion WithID:(NSString *)gatewayID;
/**
 *  通过网关的id去删除本地数据
 *   是否删除成功
 */
-(BOOL)deleteGatewayWithID:(NSString *)gatewayID;
/**
 *  查询网关数据对象数组
 */
-(NSArray *)selectGatewayData;
#pragma mark -推送通知相关
/**
 *  保存推送过来的数据
 *
 *  @param model 推送消息数据
 *
 *  @return 是否保存成功
 */
-(BOOL)savePushData:(ASPushNotiModel *)model;

/**
 *  通过推送消息的id去删除本地数据
 *
 *  @param 推送消息的id
 *
 *  @return 返回是否删除成功
 */
-(BOOL)deletePushMsgWithMsgID:(NSString *)msgid;

/**
 *  更新推送通知的阅读状态为已经阅读
 *
 *  @param msgid 推送通知的编号
 *
 *  @return 是否更新成功
 */
-(BOOL)updatePushDataToReadWithPushMsgID:(NSString *)msgid;

/**
 *  查询本地存储的所有推送通知
 *
 *  @return 返回的推送通知对象数组
 */
-(NSArray *)selectAllPushMsgData;

/**
 *  查询本地存储的未阅读的通知数量
 *
 *  @return 返回的未阅读的通知数量
 */
-(NSInteger)selectNoReadCount;

@end
