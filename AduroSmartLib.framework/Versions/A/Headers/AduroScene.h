//
//  AduroScene.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/5.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AduroScene : NSObject
@property (nonatomic, assign) Byte sceneID; //分组ID号,由网关分配,不要手动修改
@property (nonatomic, strong) NSString *sceneName;
@property (nonatomic, assign) NSInteger groupID;
@property (nonatomic, strong) NSString *sceneIconPath;
@property (nonatomic, strong) NSMutableArray *sceneSubDeviceIDArray;//场景子设备编号集合
@end
