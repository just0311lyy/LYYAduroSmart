//
//  SelectedCell.h
//  AduroSmart
//
//  Created by MacBook on 16/8/3.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AduroDevice;

@protocol NewSelectedDelegate <NSObject>

// 回调方法
-(void)deviceSelected:(BOOL)isSelected WithAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo;
// 回调方法结束

@end


@interface SelectedCell : UITableViewCell

@property (nonatomic,assign) id<NewSelectedDelegate> delegate;
@property (nonatomic,strong) AduroDevice *aduroDeviceInfo;

+(CGFloat)getCellHeight;
-(void)setCheckboxChecked:(BOOL)isChecked;

@end
