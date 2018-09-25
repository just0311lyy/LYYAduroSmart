//
//  DeviceManager.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/5.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppEnum.h"

@class AduroDevice;

typedef void(^GetDevicesBlock)(AduroDevice *device);
typedef void(^DeviceDataUpdateBlock)(AduroDevice *device,int updateDataType,uint16_t clusterID,uint16_t attribID,uint32_t attributeValue);
/*
 *(NSString *deviceID,uint16_t shortAddr,uint16_t sensorData,uint8_t zoneID,uint16_t clusterID,Byte sensorDataByte[],int aCFrequency,float rMSVoltage,float rMSCurrent,float activePower,float powerFactor)
 */
/**
 *  @author xingman.yi, 16-12-15 09:08:27
 *
 *  @brief 传感器或控制器数据上报
 *
 *  @param (NSString *deviceID,uint16_t shortAddr,uint16_t sensorData,uint8_t zoneID,uint16_t clusterID,Byte sensorDataByte[],int aCFrequency,float rMSVoltage,float rMSCurrent,float activePower,float powerFactor)              开关状态
 */
typedef void(^SensorDataUploadBlock)(NSString *deviceID,uint16_t shortAddr,uint16_t sensorData,uint8_t zoneID,uint16_t clusterID,Byte sensorDataByte[],int aCFrequency,float rMSVoltage,float rMSCurrent,float activePower,float powerFactor);
typedef void(^DeviceStateDataUploadBlock)(NSDictionary *deviceStateDict);


@interface DeviceManager : NSObject
+ (DeviceManager *)sharedManager;
/**
 *  @author xingman.yi, 16-07-05 15:07:08
 *
 *  @brief 发现新设备
 *
 *  @param devices 返回发现的一个或多个新设备，如果未发现新设备返回nil
 */
-(void)findNewDevices:(GetDevicesBlock)devices;

/**
 *  @author xingman.yi, 16-07-06 15:07:18
 *
 *  @brief 获取所有设备
 *
 *  @param devices 设备列表
 */
-(void)getAllDevices:(GetDevicesBlock)devices;

/**
 *  @author xingman.yi, 16-07-06 15:07:40
 *
 *  @brief 更新设备名称
 *
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)updateDeviceName:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

//Light,Lock,WindowCurtain
/**
 *  @author xingman.yi, 16-07-06 21:07:18
 *
 *  @brief 更新设备的开关状态
 *
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)updateDeviceState:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

//Light
/**
 *  @author xingman.yi, 16-07-06 21:07:30
 *
 *  @brief 更新设备的亮度
 *
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)updateDeviceLevel:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler;
/**
 *  @author xingman.yi, 16-07-06 21:07:14
 *
 *  @brief 更新设备的颜色值
 *
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)updateDeviceHueSat:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

//使用XY去更新设备颜色
-(void)updateDeviceColorToXY:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-06 21:07:04
 *
 *  @brief 更新设备的色温
 *
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)updateDeviceColorTemperature:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler;


/**
 *  @author xingman.yi, 16-07-06 21:07:51
 *
 *  @brief 获取设备属性数据
 *
 *  @param updateData 数据
 */
-(void)getDevice:(AduroDevice *)device updateData:(DeviceDataUpdateBlock)updateData updateType:(AduroSmartUpdateDataType)type;

/**
 *  @author xingman.yi, 16-08-11 20:08:45
 *
 *  @brief 传感器上传数据
 *
 *  @param uploadData 数据
 */
-(void)sensorDataUpload:(SensorDataUploadBlock)uploadData;



/**
 *  @author xingman.yi, 16-07-06 22:07:49
 *
 *  @brief 删除设备
 *
 *  @param device            设备
 *  @param completionHandler 结果
 */
-(void)deleteDevice:(AduroDevice *)device completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-08-25 14:08:18
 *
 *  @brief 激活设备端点
 *
 *  @param myDevice 设备
 */
-(void)activeEndpointRequest:(AduroDevice *)myDevice;

/**
 *  @author xingman.yi, 16-08-30 09:08:27
 *
 *  @brief 更新所有可开关设备的开关状态
 *
 *  @param isOn              开关状态
 *  @param completionHandler 命令发送结果
 */
-(void)updateAllDeviceSwitchState:(BOOL)isOn completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-08-30 09:08:17
 *
 *  @brief 更新所有可调节亮度设备的亮度
 *
 *  @param levelValue        亮度
 *  @param completionHandler 命令发送结果
 */
-(void)updateAllDeviceLevel:(Byte)levelValue completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-09-19 15:08:17
 *
 *  @brief 设备识别功能
 *
 *  @param device        需要识别的设备
 */
-(void)identify:(AduroDevice *)device;

/**
 *  @author xingman.yi, 16-11-22 15:08:17
 *
 *  @brief 设备开关亮度数据反馈
 *
 *  @param deviceStateData 反馈的状态
 */
-(void)deviceStateDataUpload:(DeviceStateDataUploadBlock)deviceStateData;

/**
 *  @author xingman.yi, 16-10-28 14:08:44
 *
 *  @brief 绑定设备
 *
 *  @param device 设备
 */
-(void)bindDevice:(AduroDevice *)myDevice;
@end
