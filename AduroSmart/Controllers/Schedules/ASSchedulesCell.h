//
//  ASSchedulesCell.h
//  AduroSmart
//
//  Created by MacBook on 16/8/8.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ASSchedulesCellDelegate <NSObject>

//aduro 回调方法
-(BOOL)taskSwitch:(BOOL)isTaskOn aduroInfo:(AduroTask *)taskInfo;
//-(void)taskShowDetailWithAduroTask:(AduroTask *)aduroTaskInfo;
//aduro 回调方法结束

@end

@interface ASSchedulesCell : UITableViewCell

@property (nonatomic,assign) id<ASSchedulesCellDelegate> delegate;
@property (nonatomic,strong) AduroTask *aduroTaskInfo;

+(CGFloat)getCellHeight;

@end
