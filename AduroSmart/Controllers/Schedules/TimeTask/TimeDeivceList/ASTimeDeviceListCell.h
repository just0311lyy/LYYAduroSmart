//
//  ASTimeDeviceListCell.h
//  AduroSmart
//
//  Created by MacBook on 16/8/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AduroGroup;

@protocol ASTimeDeviceListCellDelegate <NSObject>

-(void)selectedTimeAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo;
//-(void)lightDeviceShowDetailWithAduroInfo:(AduroDevice *)aduroDevice;
-(void)lightDeviceChangeAlpha:(CGFloat )value;
-(void)lightDeviceSwitchChange:(BOOL)isSwitchOn;
@end

@interface ASTimeDeviceListCell : UITableViewCell

@property (nonatomic,strong) AduroDevice *aduroDeviceInfo;
@property (nonatomic,assign) id<ASTimeDeviceListCellDelegate> delegate;
@property (nonatomic) NSInteger clickIndex;

+(CGFloat)getCellHeight;
-(void)setCheckboxChecked:(BOOL)isChecked manual:(BOOL )isManual;
-(void)setDeviceCheckboxHidden:(BOOL )isHidden;

@end
