//
//  ASDeviceListViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"
#import <AduroSmartLib/AduroSmartSDKManager.h>
@interface ASDeviceListViewController : ASBaseViewController

@property (nonatomic,strong) AduroGateway *currentGetway;
@property (nonatomic,copy) NSString *securityKey;
@end
