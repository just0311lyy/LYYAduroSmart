//
//  ASActionDeviceListViewController.h
//  AduroSmart
//
//  Created by MacBook on 16/8/29.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASBaseViewController.h"

@class ASActionDeviceListViewController;

@protocol ASActionDeviceListViewControllerDelegate <NSObject>

@optional

- (void)selectTaskViewController:(ASActionDeviceListViewController *)selectedVC didSelectSensor:(AduroDevice *)sensorInfo;

@end

@interface ASActionDeviceListViewController : ASBaseViewController

@property (nonatomic, weak) id<ASActionDeviceListViewControllerDelegate> delegate;

@end
