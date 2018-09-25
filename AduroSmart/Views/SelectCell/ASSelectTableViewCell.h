//
//  ASSelectTableViewCell.h
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectDeviceDelegate <NSObject>

//aduro 回调方法
-(BOOL)deviceSelect:(BOOL)isSelect aduroInfo:(AduroDevice *)aduroInfo;

//aduro 回调方法结束

@end



@interface ASSelectTableViewCell : UITableViewCell

@property (nonatomic,assign) id<SelectDeviceDelegate> delegate;

@property (nonatomic,strong) UILabel *txtLabel;
@property (nonatomic,strong) UILabel *txtDetialLabel;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UIButton *selectBtn;

+(CGFloat)getCellHeight;

@end
