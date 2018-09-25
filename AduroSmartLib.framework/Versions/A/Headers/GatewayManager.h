//
//  GatewayManager.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/5.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppEnum.h"
#import "AduroGateway.h"

typedef void (^AllGatewaysInLanBlock)(NSArray* gateways);
typedef void (^GetGatewayInLanBlock)(AduroGateway* gateway);
typedef void (^GetGatewayVersionBlock)(NSString *gatewayMac,NSString *getewayVersion,NSString *bootloaderVersion);
typedef void (^HeartbeatResultBlock)(NSString *result);
typedef void (^GetGatewayDomainResultBlock)(NSString *domain);

@class AduroGateway;
@interface GatewayManager : NSObject

+ (GatewayManager *)sharedManager;


/**
 *  @author xingman.yi, 16-07-05 15:07:22
 *
 *  @brief 查找局域网内的网关
 *
 *  @param gateways 返回一个或多个网关设备，如果未发现返回nil
 */
-(void)searchGateways:(AllGatewaysInLanBlock)gateways;

/**
 *  @author xingman.yi, 16-10-10 15:07:22
 *
 *  @brief 查找局域网内的网关
 *
 *  @param gateways 返回一个网关设备信息，如果未发现返回nil
 */
-(void)searchOneGateway:(GetGatewayInLanBlock)gateway;

/**
 *  @author xingman.yi, 16-07-05 15:07:28
 *
 *  @brief 尝试连接到指定网关
 *
 *  @param gateway           想要连接的网关
 *  @param completionHandler 连接的结果
 */
-(void)connectToGateway:(AduroGateway *)gateway completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-05 15:07:20
 *
 *  @brief 返回当前连接的网关
 *
 *  @return 网关信息
 */
-(AduroGateway *)getCurrentGateway;

/**
 *  @author xingman.yi, 16-07-05 15:07:03
 *
 *  @brief 升级网关固件
 *
 *  @param completionHandler 升级的结果
 */
-(void)upgradeGatewayCompletionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-06 23:07:00
 *
 *  @brief 更新网关的时间
 *
 *  @param date 日期对象，包含日期-时间-时区
 */
-(void)updateGatewayDatatime:(NSDate *)date completionHandler:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-06 23:07:31
 *
 *  @brief 优化网关网络速度
 *
 *  @param completionHandler 结果
 */
-(void)optimizeGatewayNetSpeed:(AduroSmartReturnCodeBlock)completionHandler;

/**
 *  @author xingman.yi, 16-07-19 15:07:53
 *
 *  @brief 更新远程服务器地址
 *
 *  @param domain 域名
 */
-(void)updateRemoteServerDomain:(NSString *)domain;

/**
 *  @author xingman.yi, 16-12-16 15:07:53
 *
 *  @brief 更新网关指向的服务器域名
 *
 *  @param domain 域名
 */
-(void)updateGatewayServerDomain:(NSString *)domain completionHandler:(GetGatewayDomainResultBlock)completionHandler;

/**
 *  @author xingman.yi, 16-12-16 15:07:53
 *
 *  @brief 获取网关指向的服务器域名
 *
 *  @param domain 返回域名
 */
-(void)getGatewayServerDomain:(GetGatewayDomainResultBlock)completionHandler;

/**
 *  @author xingman.yi, 16-10-14 15:07:53
 *
 *  @brief 设置网关网络通道
 *
 *  @param 通道
 */
-(void)setCurrentGatewayNetChannel:(Byte )netChannelType;

/**
 *  @author xingman.yi, 16-10-14 15:07:53
 *
 *  @brief 获取网关软件版本号
 *
 *  @param 网关软件版本
 */
-(void)getGatewayVersion:(GetGatewayVersionBlock)getVersion;

/**
 *  @author xingman.yi, 16-10-28 10:08:18
 *
 *  @brief 读取设备IEEE地址
 */
-(void)IEEERequest;

/**
 *  @author xingman.yi, 16-12-09 16:08:18
 *
 *  @brief 重置网关
 */
-(void)resetGatewayWithPwd:(NSString *)password;

-(void)startHeartbeat:(HeartbeatResultBlock)result;
@end
