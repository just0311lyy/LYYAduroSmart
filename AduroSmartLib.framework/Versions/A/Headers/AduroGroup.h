//
//  GroupInfo.h
//  AduroSmartSDKTest
//
//  Created by Adurolight on 16/7/4.
//  Copyright © 2016年 adurolight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AduroGroup : NSObject
@property (nonatomic, assign) NSInteger groupID; //分组ID号,由网关分配,不要手动修改
@property (nonatomic, assign) NSInteger groupType;//房间类型,暂时网关不支持，采用名称后附加的形式
@property (nonatomic, strong) NSString *groupName;//分组名称
@property (nonatomic, strong) NSString *groupCoverPath;//分组封面图片URL
@property (nonatomic, strong) NSMutableArray *groupSubDeviceIDArray;//分组子设备编号集合
@end
