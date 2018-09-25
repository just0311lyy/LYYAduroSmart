//
//  AppEnum.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/5.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppEnum : NSObject
typedef enum :NSUInteger{
    ZigbeeAddressModeBoundAddr = 0x00,
    ZigbeeAddressModeGroupAddr = 0x01,
    ZigbeeAddressModeShortAddr = 0x02,
    ZigbeeAddressModeIEEEAddr = 0x03,
    ZigbeeAddressModeBroadcast = 0x04,
    ZigbeeAddressModeNoTransmit = 0x05,
    ZigbeeAddressModeBoundNoAck = 0x06,
    ZigbeeAddressModeShortNoAck = 0x07,
    ZigbeeAddressModeIEEENoAck = 0x08
} ZigbeeAddressMode;

typedef enum : NSUInteger {
    AduroSmartReturnCodeError = 0x0001,
    AduroSmartReturnCodeSuccess = 0x0002,
    AduroSmartReturnCodeNoAccess = 0x0003,
    AduroSmartReturnCodeDeviceNameLengthError = 0x0004,
    AduroSmartReturnCodeTaskNameLengthError = 0x0005,
    AduroSmartReturnCodeTaskInfoNotAvailable = 0x0006,
    AduroSmartReturnCodeNetError = 0x0007
} AduroSmartReturnCode;

typedef enum : NSUInteger {
    AduroSmartDeviceStateClose,
    AduroSmartDeviceStateOpen,
    AduroSmartDeviceStateStop
} AduroSmartDeviceState;

typedef enum : NSUInteger {
    AduroSmartUpdateDataSensorZoneType/*获取传感器类型数据*/,
    AduroSmartUpdateDataTypeLightHuesat/*颜色值更新*/,
    AduroSmartUpdateDataTypeLightLevel/*亮度更新*/,
    AduroSmartUpdateDataTypeSwitch,/*开关状态更新*/
    AduroSmartUpdateNetState,/*设备是否在线，意思是是否与网关连接*/
    AduroSmartUpdateGroup,/*读取分组属性*/
    AduroSmartUpdateScene,/*读取场景属性*/
    AduroSmartUpdateDataDimmLight,/*调光灯，一次读取亮度和开关状态*/
    AduroSmartUpdateDataColorLight,/*彩灯，一次读取颜色、亮度、开关状态*/
    AduroSmartUpdateDataAC_FREQUENCY/*读取频率*/
} AduroSmartUpdateDataType;


typedef enum : NSUInteger {
    ClusterIDGeneralBasic,
    ClusterIDGeneralPowerConfig,
    ClusterIDGeneralTemperatureConfig,
    ClusterIDGeneralIdentify,
    ClusterIDGeneralGroups,
    ClusterIDGeneralScenes,
    ClusterIDGeneralOnOrOff,
    ClusterIDGeneralOnOrOffConfig,
    ClusterIDGeneralLevelControl,
    ClusterIDGeneralAlarms,
    ClusterIDGeneralTime,
    ClusterIDGeneralOTA,
    ClusterIDGeneralDoorLock,
    ClusterIDLightingColorControl,
    ClusterIDMeasurementTemperature,
    ClusterIDMeasurementOccupancySensing,
    ClusterIDSecuritySafetyIASZone,
    ClusterIDMiscDiagnostics,
    ClusterIDZLLCommissioning
} ClusterIDType;


typedef void (^AduroSmartReturnCodeBlock)(AduroSmartReturnCode code);


/*********************************************************************
 * Zigbee Clusters CONSTANTS Begin
 */

// General Clusters
#define ZCL_CLUSTER_ID_GEN_BASIC                             0x0000
#define ZCL_CLUSTER_ID_GEN_POWER_CFG                         0x0001
#define ZCL_CLUSTER_ID_GEN_DEVICE_TEMP_CONFIG                0x0002
#define ZCL_CLUSTER_ID_GEN_IDENTIFY                          0x0003
#define ZCL_CLUSTER_ID_GEN_GROUPS                            0x0004
#define ZCL_CLUSTER_ID_GEN_SCENES                            0x0005
#define ZCL_CLUSTER_ID_GEN_ON_OFF                            0x0006
#define ZCL_CLUSTER_ID_GEN_ON_OFF_SWITCH_CONFIG              0x0007
#define ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL                     0x0008
#define ZCL_CLUSTER_ID_GEN_ALARMS                            0x0009
#define ZCL_CLUSTER_ID_GEN_TIME                              0x000A
#define ZCL_CLUSTER_ID_GEN_LOCATION                          0x000B
#define ZCL_CLUSTER_ID_GEN_ANALOG_INPUT_BASIC                0x000C
#define ZCL_CLUSTER_ID_GEN_ANALOG_OUTPUT_BASIC               0x000D
#define ZCL_CLUSTER_ID_GEN_ANALOG_VALUE_BASIC                0x000E
#define ZCL_CLUSTER_ID_GEN_BINARY_INPUT_BASIC                0x000F
#define ZCL_CLUSTER_ID_GEN_BINARY_OUTPUT_BASIC               0x0010
#define ZCL_CLUSTER_ID_GEN_BINARY_VALUE_BASIC                0x0011
#define ZCL_CLUSTER_ID_GEN_MULTISTATE_INPUT_BASIC            0x0012
#define ZCL_CLUSTER_ID_GEN_MULTISTATE_OUTPUT_BASIC           0x0013
#define ZCL_CLUSTER_ID_GEN_MULTISTATE_VALUE_BASIC            0x0014
#define ZCL_CLUSTER_ID_GEN_COMMISSIONING                     0x0015
#define ZCL_CLUSTER_ID_GEN_PARTITION                         0x0016

#define ZCL_CLUSTER_ID_OTA                                   0x0019

#define ZCL_CLUSTER_ID_GEN_POWER_PROFILE                     0x001A
#define ZCL_CLUSTER_ID_GEN_APPLIANCE_CONTROL                 0x001B

#define ZCL_CLUSTER_ID_GEN_POLL_CONTROL                      0x0020

#define ZCL_CLUSTER_ID_GREEN_POWER_PROXY                     0x0021

// Closures Clusters
#define ZCL_CLUSTER_ID_CLOSURES_SHADE_CONFIG                 0x0100
#define ZCL_CLUSTER_ID_CLOSURES_DOOR_LOCK                    0x0101
#define ZCL_CLUSTER_ID_CLOSURES_WINDOW_COVERING              0x0102

// HVAC Clusters
#define ZCL_CLUSTER_ID_HVAC_PUMP_CONFIG_CONTROL              0x0200
#define ZCL_CLUSTER_ID_HVAC_THERMOSTAT                       0x0201
#define ZCL_CLUSTER_ID_HVAC_FAN_CONTROL                      0x0202
#define ZCL_CLUSTER_ID_HVAC_DIHUMIDIFICATION_CONTROL         0x0203
#define ZCL_CLUSTER_ID_HVAC_USER_INTERFACE_CONFIG            0x0204

// Lighting Clusters
#define ZCL_CLUSTER_ID_LIGHTING_COLOR_CONTROL                0x0300
#define ZCL_CLUSTER_ID_LIGHTING_BALLAST_CONFIG               0x0301

// Measurement and Sensing Clusters
#define ZCL_CLUSTER_ID_MS_ILLUMINANCE_MEASUREMENT            0x0400
#define ZCL_CLUSTER_ID_MS_ILLUMINANCE_LEVEL_SENSING_CONFIG   0x0401
#define ZCL_CLUSTER_ID_MS_TEMPERATURE_MEASUREMENT            0x0402
#define ZCL_CLUSTER_ID_MS_PRESSURE_MEASUREMENT               0x0403
#define ZCL_CLUSTER_ID_MS_FLOW_MEASUREMENT                   0x0404
#define ZCL_CLUSTER_ID_MS_RELATIVE_HUMIDITY                  0x0405
#define ZCL_CLUSTER_ID_MS_OCCUPANCY_SENSING                  0x0406

// Security and Safety (SS) Clusters
#define ZCL_CLUSTER_ID_SS_IAS_ZONE                           0x0500
#define ZCL_CLUSTER_ID_SS_IAS_ACE                            0x0501
#define ZCL_CLUSTER_ID_SS_IAS_WD                             0x0502

// Protocol Interfaces
#define ZCL_CLUSTER_ID_PI_GENERIC_TUNNEL                     0x0600
#define ZCL_CLUSTER_ID_PI_BACNET_PROTOCOL_TUNNEL             0x0601
#define ZCL_CLUSTER_ID_PI_ANALOG_INPUT_BACNET_REG            0x0602
#define ZCL_CLUSTER_ID_PI_ANALOG_INPUT_BACNET_EXT            0x0603
#define ZCL_CLUSTER_ID_PI_ANALOG_OUTPUT_BACNET_REG           0x0604
#define ZCL_CLUSTER_ID_PI_ANALOG_OUTPUT_BACNET_EXT           0x0605
#define ZCL_CLUSTER_ID_PI_ANALOG_VALUE_BACNET_REG            0x0606
#define ZCL_CLUSTER_ID_PI_ANALOG_VALUE_BACNET_EXT            0x0607
#define ZCL_CLUSTER_ID_PI_BINARY_INPUT_BACNET_REG            0x0608
#define ZCL_CLUSTER_ID_PI_BINARY_INPUT_BACNET_EXT            0x0609
#define ZCL_CLUSTER_ID_PI_BINARY_OUTPUT_BACNET_REG           0x060A
#define ZCL_CLUSTER_ID_PI_BINARY_OUTPUT_BACNET_EXT           0x060B
#define ZCL_CLUSTER_ID_PI_BINARY_VALUE_BACNET_REG            0x060C
#define ZCL_CLUSTER_ID_PI_BINARY_VALUE_BACNET_EXT            0x060D
#define ZCL_CLUSTER_ID_PI_MULTISTATE_INPUT_BACNET_REG        0x060E
#define ZCL_CLUSTER_ID_PI_MULTISTATE_INPUT_BACNET_EXT        0x060F
#define ZCL_CLUSTER_ID_PI_MULTISTATE_OUTPUT_BACNET_REG       0x0610
#define ZCL_CLUSTER_ID_PI_MULTISTATE_OUTPUT_BACNET_EXT       0x0611
#define ZCL_CLUSTER_ID_PI_MULTISTATE_VALUE_BACNET_REG        0x0612
#define ZCL_CLUSTER_ID_PI_MULTISTATE_VALUE_BACNET_EXT        0x0613
#define ZCL_CLUSTER_ID_PI_11073_PROTOCOL_TUNNEL              0x0614

// Advanced Metering Initiative (SE) Clusters
#define ZCL_CLUSTER_ID_SE_PRICING                            0x0700
#define ZCL_CLUSTER_ID_SE_LOAD_CONTROL                       0x0701
#define ZCL_CLUSTER_ID_SE_SIMPLE_METERING                    0x0702
#define ZCL_CLUSTER_ID_SE_MESSAGE                            0x0703
#define ZCL_CLUSTER_ID_SE_SE_TUNNELING                       0x0704
#define ZCL_CLUSTER_ID_SE_PREPAYMENT                         0x0705
#ifdef SE_UK_EXT
#define ZCL_CLUSTER_ID_SE_TOU_CALENDAR                       0x0706
#define ZCL_CLUSTER_ID_SE_DEVICE_MGMT                        0x0707
#endif  // SE_UK_EXT

#define ZCL_CLUSTER_ID_GEN_KEY_ESTABLISHMENT                 0x0800

#define ZCL_CLUSTER_ID_HA_APPLIANCE_IDENTIFICATION           0x0B00
#define ZCL_CLUSTER_ID_HA_METER_IDENTIFICATION               0x0B01
#define ZCL_CLUSTER_ID_HA_APPLIANCE_EVENTS_ALERTS            0x0B02
#define ZCL_CLUSTER_ID_HA_APPLIANCE_STATISTICS               0x0B03
#define ZCL_CLUSTER_ID_HA_ELECTRICAL_MEASUREMENT             0x0B04
#define ZCL_CLUSTER_ID_HA_DIAGNOSTIC                         0x0B05

// Light Link cluster
#define ZCL_CLUSTER_ID_LIGHT_LINK                           0x1000

/*** Frame Control bit mask ***/
#define ZCL_FRAME_CONTROL_TYPE                          0x03
#define ZCL_FRAME_CONTROL_MANU_SPECIFIC                 0x04
#define ZCL_FRAME_CONTROL_DIRECTION                     0x08
#define ZCL_FRAME_CONTROL_DISABLE_DEFAULT_RSP           0x10

/*** Frame Types ***/
#define ZCL_FRAME_TYPE_PROFILE_CMD                      0x00
#define ZCL_FRAME_TYPE_SPECIFIC_CMD                     0x01

/*** Frame Client/Server Directions ***/
#define ZCL_FRAME_CLIENT_SERVER_DIR                     0x00
#define ZCL_FRAME_SERVER_CLIENT_DIR                     0x01

/*** Chipcon Manufacturer Code ***/
#define CC_MANUFACTURER_CODE                            0x1001

/*** Foundation Command IDs ***/
#define ZCL_CMD_READ                                    0x00
#define ZCL_CMD_READ_RSP                                0x01
#define ZCL_CMD_WRITE                                   0x02
#define ZCL_CMD_WRITE_UNDIVIDED                         0x03
#define ZCL_CMD_WRITE_RSP                               0x04
#define ZCL_CMD_WRITE_NO_RSP                            0x05
#define ZCL_CMD_CONFIG_REPORT                           0x06
#define ZCL_CMD_CONFIG_REPORT_RSP                       0x07
#define ZCL_CMD_READ_REPORT_CFG                         0x08
#define ZCL_CMD_READ_REPORT_CFG_RSP                     0x09
#define ZCL_CMD_REPORT                                  0x0a
#define ZCL_CMD_DEFAULT_RSP                             0x0b
#define ZCL_CMD_DISCOVER_ATTRS                          0x0c
#define ZCL_CMD_DISCOVER_ATTRS_RSP                      0x0d
#define ZCL_CMD_DISCOVER_CMDS_RECEIVED                  0x11
#define ZCL_CMD_DISCOVER_CMDS_RECEIVED_RSP              0x12
#define ZCL_CMD_DISCOVER_CMDS_GEN                       0x13
#define ZCL_CMD_DISCOVER_CMDS_GEN_RSP                   0x14
#define ZCL_CMD_DISCOVER_ATTRS_EXT                      0x15
#define ZCL_CMD_DISCOVER_ATTRS_EXT_RSP                  0x16

#define ZCL_CMD_MAX           ZCL_CMD_DISCOVER_ATTRS_EXT_RSP

// define reporting constant
#define ZCL_REPORTING_OFF     0xFFFF  // turn off reporting (maxReportInt)

// define command direction flag masks
#define CMD_DIR_SERVER_GENERATED          0x01
#define CMD_DIR_CLIENT_GENERATED          0x02
#define CMD_DIR_SERVER_RECEIVED           0x04
#define CMD_DIR_CLIENT_RECEIVED           0x08

/*** Data Types ***/
#define ZCL_DATATYPE_NO_DATA                            0x00
#define ZCL_DATATYPE_DATA8                              0x08
#define ZCL_DATATYPE_DATA16                             0x09
#define ZCL_DATATYPE_DATA24                             0x0a
#define ZCL_DATATYPE_DATA32                             0x0b
#define ZCL_DATATYPE_DATA40                             0x0c
#define ZCL_DATATYPE_DATA48                             0x0d
#define ZCL_DATATYPE_DATA56                             0x0e
#define ZCL_DATATYPE_DATA64                             0x0f
#define ZCL_DATATYPE_BOOLEAN                            0x10
#define ZCL_DATATYPE_BITMAP8                            0x18
#define ZCL_DATATYPE_BITMAP16                           0x19
#define ZCL_DATATYPE_BITMAP24                           0x1a
#define ZCL_DATATYPE_BITMAP32                           0x1b
#define ZCL_DATATYPE_BITMAP40                           0x1c
#define ZCL_DATATYPE_BITMAP48                           0x1d
#define ZCL_DATATYPE_BITMAP56                           0x1e
#define ZCL_DATATYPE_BITMAP64                           0x1f
#define ZCL_DATATYPE_UINT8                              0x20
#define ZCL_DATATYPE_UINT16                             0x21
#define ZCL_DATATYPE_UINT24                             0x22
#define ZCL_DATATYPE_UINT32                             0x23
#define ZCL_DATATYPE_UINT40                             0x24
#define ZCL_DATATYPE_UINT48                             0x25
#define ZCL_DATATYPE_UINT56                             0x26
#define ZCL_DATATYPE_UINT64                             0x27
#define ZCL_DATATYPE_INT8                               0x28
#define ZCL_DATATYPE_INT16                              0x29
#define ZCL_DATATYPE_INT24                              0x2a
#define ZCL_DATATYPE_INT32                              0x2b
#define ZCL_DATATYPE_INT40                              0x2c
#define ZCL_DATATYPE_INT48                              0x2d
#define ZCL_DATATYPE_INT56                              0x2e
#define ZCL_DATATYPE_INT64                              0x2f
#define ZCL_DATATYPE_ENUM8                              0x30
#define ZCL_DATATYPE_ENUM16                             0x31
#define ZCL_DATATYPE_SEMI_PREC                          0x38
#define ZCL_DATATYPE_SINGLE_PREC                        0x39
#define ZCL_DATATYPE_DOUBLE_PREC                        0x3a
#define ZCL_DATATYPE_OCTET_STR                          0x41
#define ZCL_DATATYPE_CHAR_STR                           0x42
#define ZCL_DATATYPE_LONG_OCTET_STR                     0x43
#define ZCL_DATATYPE_LONG_CHAR_STR                      0x44
#define ZCL_DATATYPE_ARRAY                              0x48
#define ZCL_DATATYPE_STRUCT                             0x4c
#define ZCL_DATATYPE_SET                                0x50
#define ZCL_DATATYPE_BAG                                0x51
#define ZCL_DATATYPE_TOD                                0xe0
#define ZCL_DATATYPE_DATE                               0xe1
#define ZCL_DATATYPE_UTC                                0xe2
#define ZCL_DATATYPE_CLUSTER_ID                         0xe8
#define ZCL_DATATYPE_ATTR_ID                            0xe9
#define ZCL_DATATYPE_BAC_OID                            0xea
#define ZCL_DATATYPE_IEEE_ADDR                          0xf0
#define ZCL_DATATYPE_128_BIT_SEC_KEY                    0xf1
#define ZCL_DATATYPE_UNKNOWN                            0xff

/*** Error Status Codes ***/
#define ZCL_STATUS_SUCCESS                              0x00
#define ZCL_STATUS_FAILURE                              0x01
// 0x02-0x7D are reserved.
#define ZCL_STATUS_NOT_AUTHORIZED                       0x7E
#define ZCL_STATUS_MALFORMED_COMMAND                    0x80
#define ZCL_STATUS_UNSUP_CLUSTER_COMMAND                0x81
#define ZCL_STATUS_UNSUP_GENERAL_COMMAND                0x82
#define ZCL_STATUS_UNSUP_MANU_CLUSTER_COMMAND           0x83
#define ZCL_STATUS_UNSUP_MANU_GENERAL_COMMAND           0x84
#define ZCL_STATUS_INVALID_FIELD                        0x85
#define ZCL_STATUS_UNSUPPORTED_ATTRIBUTE                0x86
#define ZCL_STATUS_INVALID_VALUE                        0x87
#define ZCL_STATUS_READ_ONLY                            0x88
#define ZCL_STATUS_INSUFFICIENT_SPACE                   0x89
#define ZCL_STATUS_DUPLICATE_EXISTS                     0x8a
#define ZCL_STATUS_NOT_FOUND                            0x8b
#define ZCL_STATUS_UNREPORTABLE_ATTRIBUTE               0x8c
#define ZCL_STATUS_INVALID_DATA_TYPE                    0x8d
#define ZCL_STATUS_INVALID_SELECTOR                     0x8e
#define ZCL_STATUS_WRITE_ONLY                           0x8f
#define ZCL_STATUS_INCONSISTENT_STARTUP_STATE           0x90
#define ZCL_STATUS_DEFINED_OUT_OF_BAND                  0x91
#define ZCL_STATUS_INCONSISTENT                         0x92
#define ZCL_STATUS_ACTION_DENIED                        0x93
#define ZCL_STATUS_TIMEOUT                              0x94
#define ZCL_STATUS_ABORT                                0x95
#define ZCL_STATUS_INVALID_IMAGE                        0x96
#define ZCL_STATUS_WAIT_FOR_DATA                        0x97
#define ZCL_STATUS_NO_IMAGE_AVAILABLE                   0x98
#define ZCL_STATUS_REQUIRE_MORE_IMAGE                   0x99

// 0xbd-bf are reserved.
#define ZCL_STATUS_HARDWARE_FAILURE                     0xc0
#define ZCL_STATUS_SOFTWARE_FAILURE                     0xc1
#define ZCL_STATUS_CALIBRATION_ERROR                    0xc2
// 0xc3-0xff are reserved.
#define ZCL_STATUS_CMD_HAS_RSP                          0xFF // Non-standard status (used for Default Rsp)

/*** Attribute Access Control - bit masks ***/
#define ACCESS_CONTROL_READ                             0x01  // attribute can be read
#define ACCESS_CONTROL_WRITE                            0x02  // attribute can be written
#define ACCESS_REPORTABLE                               0x04  // indicate attribute is reportable
#define ACCESS_CONTROL_COMMAND                          0x08
#define ACCESS_CONTROL_AUTH_READ                        0x10
#define ACCESS_CONTROL_AUTH_WRITE                       0x20
#define ACCESS_CLIENT                                   0x80  // TI unique, indicate client side attribute

// Access Control as reported OTA via DiscoveryAttributesExtended
#define ACCESS_CONTROLEXT_MASK                          0x07  // read/write/reportable bits same as above

#define ZCL_ATTR_ID_MAX                                 0xFFFF

// Used by Configure Reporting Command
#define ZCL_SEND_ATTR_REPORTS                           0x00
#define ZCL_EXPECT_ATTR_REPORTS                         0x01

// Predefined Maximum String Length
#define MAX_UTF8_STRING_LEN                             50

// Used by zclReadWriteCB_t callback function
#define ZCL_OPER_LEN                                    0x00 // Get length of attribute value to be read
#define ZCL_OPER_READ                                   0x01 // Read attribute value
#define ZCL_OPER_WRITE                                  0x02 // Write new attribute value

/*********************************************************************
 * Zigbee Clusters CONSTANTS End
 */



/******************************************************************************
 * Light Color Control Cluster Attributes Begin
 */

/*****************************************/
/***  Color Control Cluster Attributes ***/
/*****************************************/
// Color Information attributes set
#define ATTRID_LIGHTING_COLOR_CONTROL_CURRENT_HUE                        0x0000
#define ATTRID_LIGHTING_COLOR_CONTROL_CURRENT_SATURATION                 0x0001
#define ATTRID_LIGHTING_COLOR_CONTROL_REMAINING_TIME                     0x0002
#define ATTRID_LIGHTING_COLOR_CONTROL_CURRENT_X                          0x0003
#define ATTRID_LIGHTING_COLOR_CONTROL_CURRENT_Y                          0x0004
#define ATTRID_LIGHTING_COLOR_CONTROL_DRIFT_COMPENSATION                 0x0005
#define ATTRID_LIGHTING_COLOR_CONTROL_COMPENSATION_TEXT                  0x0006
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_TEMPERATURE                  0x0007
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_MODE                         0x0008

// Defined Primaries Inofrmation attribute Set
#define ATTRID_LIGHTING_COLOR_CONTROL_NUM_PRIMARIES                      0x0010
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_1_X                        0x0011
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_1_Y                        0x0012
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_1_INTENSITY                0x0013
// 0x0014 is reserved
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_2_X                        0x0015
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_2_Y                        0x0016
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_2_INTENSITY                0x0017
// 0x0018 is reserved
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_3_X                        0x0019
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_3_Y                        0x001a
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_3_INTENSITY                0x001b

// Additional Defined Primaries Information attribute set
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_4_X                        0x0020
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_4_Y                        0x0021
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_4_INTENSITY                0x0022
// 0x0023 is reserved
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_5_X                        0x0024
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_5_Y                        0x0025
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_5_INTENSITY                0x0026
// 0x0027 is reserved
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_6_X                        0x0028
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_6_Y                        0x0029
#define ATTRID_LIGHTING_COLOR_CONTROL_PRIMARY_6_INTENSITY                0x002a

// Defined Color Points Settings attribute set
#define ATTRID_LIGHTING_COLOR_CONTROL_WHITE_POINT_X                      0x0030
#define ATTRID_LIGHTING_COLOR_CONTROL_WHITE_POINT_Y                      0x0031
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_R_X                    0x0032
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_R_Y                    0x0033
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_R_INTENSITY            0x0034
// 0x0035 is reserved
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_G_X                    0x0036
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_G_Y                    0x0037
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_B_INTENSITY            0x0038
// 0x0039 is reserved
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_B_X                    0x003a
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_B_Y                    0x003b
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_POINT_G_INTENSITY            0x003c
// 0x003d is reserved
#define ATTRID_LIGHTING_COLOR_CONTROL_ENHANCED_CURRENT_HUE               0x4000
#define ATTRID_LIGHTING_COLOR_CONTROL_ENHANCED_COLOR_MODE                0x4001
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_LOOP_ACTIVE                  0x4002
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_LOOP_DIRECTION               0x4003
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_LOOP_TIME                    0x4004
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_LOOP_START_ENHANCED_HUE      0x4005
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_LOOP_STORED_ENHANCED_HUE     0x4006
#define ATTRID_LIGHTING_COLOR_CONTROL_COLOR_CAPABILITIES                 0x400a

/***  Color Information attributes range limits   ***/
#define LIGHTING_COLOR_HUE_MAX                                           0xfe
#define LIGHTING_COLOR_SAT_MAX                                           0xfe
#define LIGHTING_COLOR_REMAINING_TIME_MAX                                0xfffe
#define LIGHTING_COLOR_CURRENT_X_MAX                                     0xfeff
#define LIGHTING_COLOR_CURRENT_Y_MAX                                     0xfeff
#define LIGHTING_COLOR_TEMPERATURE_MAX                                   0xfeff

/*** Drift Compensation Attribute values ***/
#define DRIFT_COMP_NONE                                                  0x00
#define DRIFT_COMP_OTHER_UNKNOWN                                         0x01
#define DRIFT_COMP_TEMPERATURE_MONITOR                                   0x02
#define DRIFT_COMP_OPTICAL_LUMINANCE_MONITOR_FEEDBACK                    0x03
#define DRIFT_COMP_OPTICAL_COLOR_MONITOR_FEEDBACK                        0x04

/*** Color Mode Attribute values ***/
#define COLOR_MODE_CURRENT_HUE_SATURATION                                0x00
#define COLOR_MODE_CURRENT_X_Y                                           0x01
#define COLOR_MODE_COLOR_TEMPERATURE                                     0x02

/*** Enhanced Color Mode Attribute values ***/
#define ENHANCED_COLOR_MODE_CURRENT_HUE_SATURATION                       0x00
#define ENHANCED_COLOR_MODE_CURRENT_X_Y                                  0x01
#define ENHANCED_COLOR_MODE_COLOR_TEMPERATURE                            0x02
#define ENHANCED_COLOR_MODE_ENHANCED_CURRENT_HUE_SATURATION              0x03

/*** Color Capabilities Attribute bit masks ***/
#define COLOR_CAPABILITIES_ATTR_BIT_HUE_SATURATION                       0x01
#define COLOR_CAPABILITIES_ATTR_BIT_ENHANCED_HUE                         0x02
#define COLOR_CAPABILITIES_ATTR_BIT_COLOR_LOOP                           0x04
#define COLOR_CAPABILITIES_ATTR_BIT_X_Y_ATTRIBUTES                       0x08
#define COLOR_CAPABILITIES_ATTR_BIT_COLOR_TEMPERATURE                    0x10

/*****************************************/
/***  Color Control Cluster Commands   ***/
/*****************************************/
#define COMMAND_LIGHTING_MOVE_TO_HUE                                     0x00
#define COMMAND_LIGHTING_MOVE_HUE                                        0x01
#define COMMAND_LIGHTING_STEP_HUE                                        0x02
#define COMMAND_LIGHTING_MOVE_TO_SATURATION                              0x03
#define COMMAND_LIGHTING_MOVE_SATURATION                                 0x04
#define COMMAND_LIGHTING_STEP_SATURATION                                 0x05
#define COMMAND_LIGHTING_MOVE_TO_HUE_AND_SATURATION                      0x06
#define COMMAND_LIGHTING_MOVE_TO_COLOR                                   0x07
#define COMMAND_LIGHTING_MOVE_COLOR                                      0x08
#define COMMAND_LIGHTING_STEP_COLOR                                      0x09
#define COMMAND_LIGHTING_MOVE_TO_COLOR_TEMPERATURE                       0x0a
#define COMMAND_LIGHTING_ENHANCED_MOVE_TO_HUE                            0x40
#define COMMAND_LIGHTING_ENHANCED_MOVE_HUE                               0x41
#define COMMAND_LIGHTING_ENHANCED_STEP_HUE                               0x42
#define COMMAND_LIGHTING_ENHANCED_MOVE_TO_HUE_AND_SATURATION             0x43
#define COMMAND_LIGHTING_COLOR_LOOP_SET                                  0x44
#define COMMAND_LIGHTING_STOP_MOVE_STEP                                  0x47

/***  Move To Hue Cmd payload: direction field values  ***/
#define LIGHTING_MOVE_TO_HUE_DIRECTION_SHORTEST_DISTANCE                 0x00
#define LIGHTING_MOVE_TO_HUE_DIRECTION_LONGEST_DISTANCE                  0x01
#define LIGHTING_MOVE_TO_HUE_DIRECTION_UP                                0x02
#define LIGHTING_MOVE_TO_HUE_DIRECTION_DOWN                              0x03
/***  Move Hue Cmd payload: moveMode field values   ***/
#define LIGHTING_MOVE_HUE_STOP                                           0x00
#define LIGHTING_MOVE_HUE_UP                                             0x01
#define LIGHTING_MOVE_HUE_DOWN                                           0x03
/***  Step Hue Cmd payload: stepMode field values ***/
#define LIGHTING_STEP_HUE_UP                                             0x01
#define LIGHTING_STEP_HUE_DOWN                                           0x03
/***  Move Saturation Cmd payload: moveMode field values ***/
#define LIGHTING_MOVE_SATURATION_STOP                                    0x00
#define LIGHTING_MOVE_SATURATION_UP                                      0x01
#define LIGHTING_MOVE_SATURATION_DOWN                                    0x03
/***  Step Saturation Cmd payload: stepMode field values ***/
#define LIGHTING_STEP_SATURATION_UP                                      0x01
#define LIGHTING_STEP_SATURATION_DOWN                                    0x03
/***  Color Loop Set Cmd payload: action field values  ***/
#define LIGHTING_COLOR_LOOP_ACTION_DEACTIVATE                            0x00
#define LIGHTING_COLOR_LOOP_ACTION_ACTIVATE_FROM_START_HUE               0x01
#define LIGHTING_COLOR_LOOP_ACTION_ACTIVATE_FROM_ENH_CURR_HUE            0x02
/***  Color Loop Set Cmd payload: direction field values   ***/
#define LIGHTING_COLOR_LOOP_DIRECTION_DECREMENT                          0x00
#define LIGHTING_COLOR_LOOP_DIRECTION_INCREMENT                          0x01

/*****************************************************************************/
/***          Ballast Configuration Cluster Attributes                     ***/
/*****************************************************************************/
// Ballast Information attribute set
#define ATTRID_LIGHTING_BALLAST_CONFIG_PHYSICAL_MIN_LEVEL                0x0000
#define ATTRID_LIGHTING_BALLAST_CONFIG_PHYSICAL_MAX_LEVEL                0x0001
#define ATTRID_LIGHTING_BALLAST_BALLAST_STATUS                           0x0002
/*** Ballast Status Attribute values (by bit number) ***/
#define LIGHTING_BALLAST_STATUS_NON_OPERATIONAL                          1 // bit 0 is set
#define LIGHTING_BALLAST_STATUS_LAMP_IS_NOT_IN_SOCKET                    2 // bit 1 is set
// Ballast Settings attributes set
#define ATTRID_LIGHTING_BALLAST_MIN_LEVEL                                0x0010
#define ATTRID_LIGHTING_BALLAST_MAX_LEVEL                                0x0011
#define ATTRID_LIGHTING_BALLAST_POWER_ON_LEVEL                           0x0012
#define ATTRID_LIGHTING_BALLAST_POWER_ON_FADE_TIME                       0x0013
#define ATTRID_LIGHTING_BALLAST_INTRISTIC_BALLAST_FACTOR                 0x0014
#define ATTRID_LIGHTING_BALLAST_BALLAST_FACTOR_ADJUSTMENT                0x0015
// Lamp Information attributes set
#define ATTRID_LIGHTING_BALLAST_LAMP_QUANTITY                            0x0020
// Lamp Settings attributes set
#define ATTRID_LIGHTING_BALLAST_LAMP_TYPE                                0x0030
#define ATTRID_LIGHTING_BALLAST_LAMP_MANUFACTURER                        0x0031
#define ATTRID_LIGHTING_BALLAST_LAMP_RATED_HOURS                         0x0032
#define ATTRID_LIGHTING_BALLAST_LAMP_BURN_HOURS                          0x0033
#define ATTRID_LIGHTING_BALLAST_LAMP_ALARM_MODE                          0x0034
#define ATTRID_LIGHTING_BALLAST_LAMP_BURN_HOURS_TRIP_POINT               0x0035
/*** Lamp Alarm Mode attribute values  ***/
#define LIGHTING_BALLAST_LAMP_ALARM_MODE_BIT_0_NO_ALARM                  0
#define LIGHTING_BALLAST_LAMP_ALARM_MODE_BIT_0_ALARM                     1

/*******************************************************************************
 * Light Color Control Cluster Attributes End
 */



@end
