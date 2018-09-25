//
//  ASDeviceSelectCell.h
//  AduroSmart
//
//  Created by MacBook on 16/8/10.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AduroDevice;

@protocol ASDeviceSelectCellDelegate <NSObject>

-(void)sceneDeviceSelected:(BOOL)isSelected WithAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo;
//-(void)lightDeviceChangeAlpha:(CGFloat )value;
-(void)lightDeviceSwitchChange:(BOOL)isSwitchOn;
@end

@interface ASDeviceSelectCell : UITableViewCell

@property (nonatomic,strong) AduroDevice *aduroDeviceInfo;
@property (nonatomic,assign) id<ASDeviceSelectCellDelegate> delegate;
//@property (nonatomic) NSInteger clickIndex;
+(CGFloat)getCellHeight;
-(void)setCheckboxChecked:(BOOL)isChecked;
//-(void)setCheckboxChecked:(BOOL)isChecked manual:(BOOL )isManual;
//-(void)setDeviceCheckboxHidden:(BOOL )isHidden;

@end
