//
//  AduroSmartManager.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/4.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppEnum.h"
#import "AduroDevice.h"
#import "AduroScene.h"
#import "AduroGroup.h"
#import "AduroTask.h"
#import "AduroGateway.h"
#import "TaskManager.h"
#import "SceneManager.h"
#import "DeviceManager.h"
#import "GatewayManager.h"
#import "GroupManager.h"

typedef void(^SDKVersionInfoBlock)(NSDictionary *verInfoDict);
@interface AduroSmartSDKManager : NSObject
+ (AduroSmartSDKManager *)sharedManager;

/**
 *  @author xingman.yi, 16-07-13 09:07:06
 *
 *  @brief 返回本地SDK版本和网络最新SDK版本
 *
 *  @param verInfo 版本字典
 */
-(void)getSDKVersion:(SDKVersionInfoBlock)verInfo;

-(void)enterForeground;

-(void)enterResignActive;

/**
 *  @author xingman.yi, 16-11-10 10:07:46
 *
 *  @brief 解析推送信息
 *
 *  @param pushMessage 推送来的数据
 */
-(NSDictionary *)analysisPushData:(NSString *)pushMessage;

/**
 *  @author xingman.yi, 16-11-16 10:07:46
 *
 *  @brief 连接远程服务器
 *
 */
-(void)connectCloudServer:(NSString *)userName gatewayID:(NSString *)gatewayID;

/**
 *  @author xingman.yi, 16-11-16 10:07:46
 *
 *  @brief 断开连接远程服务器
 *
 */
-(void)disconnectCloudServer:(NSString *)userName gatewayID:(NSString *)gatewayID;



@end
