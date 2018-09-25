//
//  GroupManager.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/5.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppEnum.h"

@class AduroGroup;
@class AduroDevice;

typedef void (^AllGroupsInGatewayBlock)(AduroGroup* group);
typedef void (^DevicesOfGroupBlock)(NSArray *devices);
typedef void (^AddGroupNameBlock)(AduroGroup *group);
@interface GroupManager : NSObject
+ (GroupManager *)sharedManager;

/**
 *  @author xingman.yi, 16-07-06 22:07:39
 *  modify 2016-11-21 15:29:46
 *
 *  @brief 添加一个空的分组,返回添加的分组名和分组ID，用于后续将设备添加到分组
 *
 *  @param groupName         分组名
 *  @param completionHandler 返回已经添加的分组
 */
-(void)addGroupByName:(NSString *)groupName completionHandler:(AddGroupNameBlock)group __attribute__((deprecated("此方法已过期, 使用addGroupByName:(NSString *)groupName andDevices:(NSArray *)devices completionHandler:(AddGroupNameBlock)group")));

/**
 *  @author xingman.yi, 16-07-06 22:07:29
 *
 *  @brief 添加设备到分组
 *
 *  @param group             分组
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)addDeviceToGroup:(AduroGroup *)group device:(AduroDevice *)device completionHandler:(void (^)(AduroSmartReturnCode code))completionHandler;


/**
 *  @author xingman.yi, 16-07-06 22:07:29
 *  modify 16-11-21
 *  @brief 添加一组设备到分组
 *
 *  @param group             分组
 *  @param devices           设备列表
 *  @param completionHandler 结果
 */
-(void)addDevices:(NSArray *)devices toGroup:(AduroGroup *)group isEdit:(BOOL)createOredit completionHandler:(void (^)(AduroSmartReturnCode code))completionHandler;


/**
 *  @author xingman.yi, 16-07-06 22:07:20
 *
 *  @brief 获取所有分组
 *
 *  @param groups 分组列表
 */
-(void)getAllGroups:(AllGroupsInGatewayBlock)groups;
/**
 *  @author xingman.yi, 16-07-06 22:07:55
 *
 *  @brief 获取指定分组内的所有设备
 *
 *  @param group   分组
 *  @param devices 设备列表
 */
-(void)getDevicesOfGroup:(AduroGroup *)group devices:(DevicesOfGroupBlock)devices;
/**
 *  @author xingman.yi, 16-07-06 22:07:26
 *
 *  @brief 删除指定分组
 *
 *  @param group             分组
 *  @param completionHandler 结果
 */
-(void)deleteGroup:(AduroGroup *)group completionHandler:(void (^)(AduroSmartReturnCode code))completionHandler;
/**
 *  @author xingman.yi, 16-07-06 22:07:51
 *   modify 2016年11月21日11:49:26
 *
 *  @brief 从指定分组中删除指定设备
 *
 *  @param group             分组
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)deleteDeviceFromGroup:(AduroGroup *)group device:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler __attribute__((deprecated("此方法已过期, 使用deleteDeviceFromGroup:(AduroGroup *)group devices:(NSArray *)devices completionHandler:(AduroSmartReturnCodeBlock)completionHandler")));
/**
 *  @author xingman.yi, 16-07-29 20:07:57
 *
 *  @brief 改变分组的名称
 *
 *  @param group             分组
 *  @param completionHandler 结果
 */
-(void)changeGroupName:(AduroGroup *)group completionHandler:(void (^)(AduroSmartReturnCode code))completionHandler;

/**
 *  @author xingman.yi, 16-08-29 18:08:03
 *
 *  @brief 控制分组内所有设备的开关
 *
 *  @param group 分组
 *  @param isOn  YES为开
 */
-(void)ctrlGroup:(AduroGroup *)group switchOn:(BOOL)isOn completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-08-29 18:08:51
 *
 *  @brief 控制分组的亮度
 *
 *  @param group      分组
 *  @param alphaValue 亮度
 */
-(void)ctrlGroup:(AduroGroup *)group alphaValue:(Byte )alphaValue completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-09-09 13:09:40
 *
 *  @brief 更改分组的颜色
 *
 *  @param group             分组
 *  @param xValue            颜色X值
 *  @param yValue            颜色Y值
 *  @param completionHandler
 */
-(void)ctrlGroup:(AduroGroup *)group xValue:(uint16_t)xValue yValue:(uint16_t)yValue completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-11-19 18:08:51
 *
 *  @brief 添加分组到网关
 *
 *  @param groupName      分组名称
 *  @param devices        要添加的设备
 */
-(void)addGroupByName:(NSString *)groupName andDevices:(NSArray *)devices completionHandler:(AddGroupNameBlock)group;

/**
 *  @author xingman.yi, 16-11-21 15:07:14
 *
 *  @brief 从分组中删除设备
 *
 *  @param group             指定group
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)deleteDeviceFromGroup:(AduroGroup *)group devices:(NSArray *)devices completionHandler:(AduroSmartReturnCodeBlock)completionHandler;
@end
