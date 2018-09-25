//
//  LYRoomDeviceViewController.h
//  AduroSmart
//
//  Created by MacBook on 2017/1/5.
//  Copyright © 2017年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"

@interface LYRoomDeviceViewController : ASBaseViewController

@property (nonatomic,strong) AduroGroup *detailGroup;
@property (nonatomic,copy) NSString *deviceType;
@property (nonatomic,strong) NSMutableArray *roomDeviceArr;

@end
