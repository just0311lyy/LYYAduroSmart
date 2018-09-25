//
//  ASDeviceCell.h
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeviceDelegate <NSObject>

//aduro 回调方法
-(BOOL)deviceSwitch:(BOOL)isOn aduroInfo:(AduroDevice *)aduroInfo;
-(void)deviceShowDetailWithAduroInfo:(AduroDevice *)aduroDevice;
-(void)deviceChangeAlpha:(CGFloat )value;
//aduro 回调方法结束

@end
//---------------

@interface ASDeviceCell : UITableViewCell

@property (nonatomic,assign) id<DeviceDelegate> delegate;
@property (nonatomic,strong) AduroDevice *aduroDeviceInfo;

+(CGFloat)getCellHeight;

@end
