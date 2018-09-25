//
//  ASDeviceSelectTableViewCell.h
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeviceSelectDelegate <NSObject>

//aduro 回调方法
-(BOOL)deviceSelect:(BOOL)isSelect AduroDeviceInfo:(AduroDevice *)aduroInfo;

//aduro 回调方法结束

@end

@interface ASDeviceSelectTableViewCell : UITableViewCell

@property (nonatomic,assign) id<DeviceSelectDelegate> delegate;
@property (nonatomic,strong) AduroDevice *aduroDeviceInfo;
@property (nonatomic,strong) UILabel *txtLabel;
//@property (nonatomic,strong) UILabel *txtDetialLabel;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UIButton *selectBtn;



+(CGFloat)getCellHeight;

@end
