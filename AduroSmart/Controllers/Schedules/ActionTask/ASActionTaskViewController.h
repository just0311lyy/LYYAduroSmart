//
//  ASActionTaskViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/8/6.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"

@interface ASActionTaskViewController : ASBaseViewController

@property (nonatomic , strong) AduroDevice  *currentDeviceInfo;
@property (nonatomic , strong) AduroScene  *currentAduroScene;
@property (nonatomic , strong) AduroTask *myAduroTask;

@end
