//
//  SceneManager.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/5.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppEnum.h"

@class AduroScene;
@class AduroDevice;
@class AduroGroup;

typedef void(^AllScenesBlock)(AduroScene *scene);
typedef void(^AddSceneNameBlock)(AduroScene *scene,AduroSmartReturnCode code);
typedef void(^AllDevicesOfSceneBlock)(AduroDevice *device);


@interface SceneManager : NSObject
+ (SceneManager *)sharedManager;

/**
 *  @author xingman.yi, 16-07-05 15:07:45
 *
 *  @brief 获取所有场景
 *
 *  @param scenes 返回一个或多个场景
 */
-(void)getAllScenes:(AllScenesBlock)scenes;

/**
 *  @author xingman.yi, 16-07-05 15:07:40
 *
 *  @brief 获取场景中的所有设备
 *
 *  @param scene   场景
 *  @param devices 返回一个或多个设备，无设备时返回nil
 */
-(void)getDevicesFromScene:(AduroScene*)scene devices:(AllDevicesOfSceneBlock)devices;

/**
 *  @author xingman.yi, 16-08-27 15:07:10
 *
 *  @brief 使用组ID调用场景
 *
 *  @param scene 场景
 *  @param completionHandler 结果
 */
-(void)useGroupIDCallScene:(AduroScene *)scene completionHandler:(AduroSmartReturnCodeBlock)completionHandler;
/**
 *  @author xingman.yi, 16-07-05 15:07:10
 *
 *  @brief 执行指定场景
 *
 *  @param scene 场景
 *  @param completionHandler 结果
 */
-(void)callScene:(AduroScene*)scene device:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-05 15:07:22
 *
 *  @brief 添加设备到一个场景中
 *
 *  @param scene             场景
 *  @param device            配置好参数的设备
 *  @param completionHandler 结果
 */
-(void)addDevice:(AduroDevice *)device toScene:(AduroScene *)scene andGroup:(AduroGroup *)group completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-09-02 16:09:43
 *
 *  @brief 添加多个设备到场景
 *
 *  @param devices           设备列表
 *  @param scene             场景
 *  @param group             分组
 *  @param completionHandler 结果
 */
-(void)addDevices:(NSArray *)devices toScene:(AduroScene *)scene andGroup:(AduroGroup *)group isEdit:(BOOL)createOrEdit completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-13 09:07:34
 *  modify 2016-11-22 10:56:22
 *  @brief 添加一个空场景
 *
 *  @param scene  场景
 *  @param group  分组
 *  @param result 返回场景和结果
 */
-(void)addSceneWithName:(NSString *)sceneName group:(AduroGroup *)group devices:(NSArray *)devices backScene:(AddSceneNameBlock)result;

/**
 *  @author xingman.yi, 16-07-05 15:07:27
 *
 *  @brief 更新场景名称
 *
 *  @param scene             场景
 *  @param completionHandler 结果
 */
-(void)changeNameWithScene:(AduroScene *)scene completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-13 00:07:25
 *
 *  @brief 更新场景中的一个设备
 *
 *  @param device            要更新的设备
 *  @param scene             所属场景
 *  @param completionHandler 结果
 */
-(void)updateDevice:(AduroDevice *)device toScene:(AduroScene *)scene completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-05 15:07:10
 *  modify 2016-11-22 10:55:50
 *  @brief 从场景中删除一个或多个设备
 *
 *  @param scene             场景
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)deleteDeviceFromScene:(AduroScene *)scene devices:(NSArray *)devices completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-05 15:07:04
 *
 *  @brief 删除场景
 *
 *  @param scene             场景
 *  @param completionHandler 结果
 */
-(void)deleteScene:(AduroScene*)scene completionHandler:(AduroSmartReturnCodeBlock)completionHandler;


@end
