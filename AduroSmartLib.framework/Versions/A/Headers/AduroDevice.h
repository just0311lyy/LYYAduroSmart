//
//  DeviceInfo.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/4.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : Byte {
    DeviceSwitchStateOff = 0x00/*设备关闭*/,
    DeviceSwitchStateOn = 0x01/*设备开启*/,
    DeviceSwitchStatePause = 0x02/*设备停止*/,
} DeviceSwitchState;

typedef enum : NSUInteger {
    DeviceTypeIDMainsPowerOutlet = 0x0009/*电源插座*/,
    DeviceTypeIDDimSwitch = 0x0105/*可调开关*/,
    DeviceTypeIDColorLamp = 0x0102/*ZHA彩灯*/,
    DeviceTypeIDColorTemperatureLamp = 0x0110/*色温灯*/,
    DeviceTypeIDHueColorLamp = 0x0210/*ZLL彩灯*/,
    DeviceTypeIDColorLight = 0x0200,/*Color light*/
    DeviceTypeIDColorTemperatureLampJZGD = 0x0220/*色温灯*/,
    DeviceTypeIDDimmableLight = 0x0100,/*调光灯*/
    DeviceTypeIDDimLamp = 0x0101/*调光灯*/,
    DeviceTypeIDHumanSensor = 0x0402/*CIE传感器类*/,
    DeviceTypeIDWindowCurtain = 0x0202/*窗帘*/,
    DeviceTypeIDPM2dot5Sensor = 0x0309/*PM2.5*/,
    DeviceTypeIDSmokingSensor = 0x0310/*烟雾传感器*/,
    DeviceTypeIDSmartPlug = 0x0051/*智能插座*/,
    DeviceTypeIDLightingRemotes = 0x0820 /*遥控器*/,
    DeviceTypeIDUnidentified = 0xffff/*获取设备Endpoint失败，则显示为未识别类型设备*/
} DeviceTypeID/*如果网关返回的DeviceTypeID不在此枚举内，则显示为未识别类型设备*/;

typedef enum : NSUInteger {
    DeviceNetStateOffline = 0x00/*设备离线*/,
    DeviceNetStateOnline = 0x01/*设备在线*/,
    DeviceNetStateRemoteOnline = 0x02/*设备远程在线*/
} DeviceNetState;

typedef enum : NSUInteger {
    DeviceZoneTypeStandardCIE = 0x0000/*标准CIE设备*/,
    DeviceZoneTypeMotionSensor = 0x000d/*人体红外传感器*/,
    DeviceZoneTypeContactSwitch = 0x0015/*门磁*/,
    DeviceZoneTypeFireSensor = 0x0028/*烟雾传感器*/,
    DeviceZoneTypeWaterSensor = 0x002a/*水浸传感器*/,
    DeviceZoneTypeGasSensor = 0x002b/*气体传感器*/,
    DeviceZoneTypeRemoteControl = 0x010f/*遥控器*/,
    DeviceZoneTypeKeypad = 0x021d,/*键盘*/
    DeviceZoneTypeVibrationMovementSensor = 0x002d, /*震动传感器*/
    DeviceZoneTypeUnidentified = 0xffff /*未识别类型的设备*/
} DeviceZoneType;



@interface AduroDevice : NSObject
@property (nonatomic, strong) NSString *deviceName; //设备名
@property (nonatomic, assign) Byte deviceNetState; //设备是否在线,见枚举DeviceNetState
@property (nonatomic, assign) Byte deviceSwitchState; //设备状态,见枚举DeviceSwitchState
@property (nonatomic, assign) Byte deviceLightLevel; //亮度(只对灯类有效0x00(最暗)~0xff(最亮))
@property (nonatomic, assign) Byte deviceLightHue; //颜色属性色相
@property (nonatomic, assign) Byte deviceLightSat; //颜色属性饱和度
@property (nonatomic, assign) UInt16 deviceLightX; //颜色属性X
@property (nonatomic, assign) UInt16 deviceLightY; //颜色属性Y
@property (nonatomic, assign) UInt16 deviceLightColorTemperature; //色温灯的色温值
@property (nonatomic, strong) NSString *deviceID;  //设备ID号,唯一标识符
@property (nonatomic, assign) NSInteger deviceTypeID; //设备种类,见枚举DeviceTypeID
@property (nonatomic, strong) NSString *deviceType;  //设备类型字符串;
@property (nonatomic, assign) uint32_t deviceSensorData; //传感器上传的数据()
@property (nonatomic, strong) NSMutableSet *deviceClusterIdSet; //簇ID集合
@property (nonatomic, assign) NSInteger deviceAttribID; //属性ID
@property (nonatomic, assign) NSInteger deviceZoneType; //见枚举DeviceZoneType
@property (nonatomic, assign) uint16_t shortAdr;        //短地址,低16位
@property (nonatomic, assign) uint8_t endPoint;         //端点,高8位
@property (nonatomic, assign) uint8_t MAIN_ENDPOINT;
@property (nonatomic, assign) uint16_t ProfileId;
@property (nonatomic, assign) Byte* IEEE;//全球唯一标识
@property (nonatomic, assign) float electmeasVolatage;//电压
@property (nonatomic, assign) float electmeasCurrent;//电流
@property (nonatomic, assign) float electmeasPower;//功率
@property (nonatomic, assign) float electmeasFrequency;//频率
@property (nonatomic, assign) float electmeasPowerFactor;//功率因素
@property (nonatomic, assign) BOOL isCache;//是否是缓存


@end
