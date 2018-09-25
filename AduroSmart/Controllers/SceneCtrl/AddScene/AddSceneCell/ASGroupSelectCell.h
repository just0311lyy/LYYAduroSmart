//
//  ASGroupSelectCell.h
//  AduroSmart
//
//  Created by MacBook on 16/8/10.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AduroGroup;

@protocol ASGroupSelectCellDelegate <NSObject>

-(void)selectedAduroGroupInfo:(AduroGroup *)aduroGroupInfo;

@end

@interface ASGroupSelectCell : UITableViewCell

@property (nonatomic,strong) AduroGroup *aduroGroupInfo;
@property (nonatomic,assign) id<ASGroupSelectCellDelegate> delegate;
@property (nonatomic) NSInteger clickIndex;
+(CGFloat)getCellHeight;
-(void)setCheckboxChecked:(BOOL)isChecked manual:(BOOL )isManual;
-(void)setGroupCheckboxHidden:(BOOL )isHidden;

@end
