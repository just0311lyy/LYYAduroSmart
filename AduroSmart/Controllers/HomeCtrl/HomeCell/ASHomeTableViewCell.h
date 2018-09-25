//
//  ASHomeTableViewCell.h
//  AduroSmart
//
//  Created by MacBook on 16/7/23.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ASHomeDelegate <NSObject>

//aduro 回调方法
-(BOOL)homeSwitch:(BOOL)isOn aduroInfo:(AduroGroup *)aduroInfo;
//-(void)homeShowDetailWithGroupInfo:(AduroGroup *)aduroGroupInfo;
//-(void)homeDeviceChangeAlpha:(CGFloat )value;
//aduro 回调方法结束

@end
//---------------

@interface ASHomeTableViewCell : UITableViewCell
    
@property(nonatomic,strong) UILabel *homeNameLb;
@property(nonatomic,strong) UILabel *homeDescriptionLb;
//@property(nonatomic,strong) UIButton *homeSwitchBtn;
@property(nonatomic,strong) UIButton *homeShowDetailBtn;

@property(nonatomic,strong) UIImageView *homeTypeImgView;  //代表房间类型的图标
@property (nonatomic,assign) id<ASHomeDelegate> delegate;
@property (nonatomic,strong) AduroGroup *aduroGroupInfo;

+(CGFloat)getCellHeight;

@end
