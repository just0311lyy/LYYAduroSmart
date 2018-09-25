//
//  Gateway.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/4.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NetChannelTypeDisconnect = 0x00,/*连接中断*/
    NetChannelTypeLANUDP = 0x01,/*局域网UDP*/
    NetChannelTypeRemoteTCP = 0x02,/*远程TCP*/
    NetChannelTypeLANTCP = 0x03 /*局域网TCP*/
} NetChannelType;

@interface AduroGateway : NSObject
@property (nonatomic,strong) NSString *gatewayName;//网关名称
@property (nonatomic,strong) NSString *gatewayID;//网关编号
@property (nonatomic,strong) NSString *gatewaySoftwareVersion;//软件版本
@property (nonatomic,strong) NSString *gatewayHardwareVersion;//硬件版本
@property (nonatomic,strong) NSString *gatewayIPv4Address;//IP地址
@property (nonatomic,strong) NSDate *gatewayDatetime;//时间
@property (nonatomic,assign) Byte *gatewayTimeZone;//时区
@property (nonatomic,strong) NSString *gatewaySecurityKey;//安全Key,通过扫描网关背部的二维码获取
@property (nonatomic,strong) NSString *gatewayGatewayType;//网关类型
@property (nonatomic,strong) NSString *gatewayServerDomain;//服务器域名 默认为
@property (nonatomic,assign) Byte gatewayToAppNetChannelType;//网关到APP的网络通道类型
@end
