//
//  ASSchedulesCell.m
//  AduroSmart
//
//  Created by MacBook on 16/8/8.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSchedulesCell.h"

@interface ASSchedulesCell ()<UIAlertViewDelegate>{
    //开关是否开启
    BOOL isTaskOn;
    AduroTask *_aduroTaskInfo;
    UIImageView *_schedulesImgView;
    UIButton *_taskSwitchBtn;
    UIButton *_taskShowDetailBtn;
    UILabel *_taskNameLb;
    UILabel *_taskDetailLb;
}
-(void)getCellView;
@end


@implementation ASSchedulesCell

@synthesize aduroTaskInfo = _aduroTaskInfo;
-(AduroTask *)aduroTaskInfo{
    return _aduroTaskInfo;
}

-(void)setAduroTaskInfo:(AduroTask *)aduroTaskInfo{
    if (_aduroTaskInfo != aduroTaskInfo) {
        _aduroTaskInfo = nil;
        _aduroTaskInfo = aduroTaskInfo;
      
        [_taskNameLb setText:_aduroTaskInfo.taskName];
        
        if (_aduroTaskInfo.taskEnable == YES) {
            isTaskOn = YES;
        }else{
            isTaskOn = NO;
        }
        [self setSwitchButtonImage:isTaskOn switchButton:_taskSwitchBtn];
        
        [_schedulesImgView setImage:[UIImage imageNamed:@"schedules_set"]];
        NSString *taskTypeStr = @"";
//        if (_aduroTaskInfo.taskType == TaskTypeDeviceTimer) {
//            taskTypeStr = [ASLocalizeConfig localizedString:@"设备定时"];
//        }else if (_aduroTaskInfo.taskType == TaskTypeSceneTimer){
//            taskTypeStr = [ASLocalizeConfig localizedString:@"场景定时"];
//        }else if(_aduroTaskInfo.taskType == TaskTypeTriggerDevice){
//            taskTypeStr = [ASLocalizeConfig localizedString:@"设备触发"];
//        }else{
//            taskTypeStr = [ASLocalizeConfig localizedString:@"场景触发"];
//        }
        if (_aduroTaskInfo.taskType == TaskTypeSceneTimer){
            taskTypeStr = [ASLocalizeConfig localizedString:@"Timing"];
        }else{
            taskTypeStr = [ASLocalizeConfig localizedString:@"Trigger"];
        }
        
        NSString *taskNetStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
        if (_aduroTaskInfo.taskConditionSecond == SCHEDULES_NET_STATE_ONLINE) {
            taskNetStateStr = @"";
        }else{
            taskNetStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
        }

        [_taskDetailLb setText:[NSString stringWithFormat:@"%@          %@",taskTypeStr,taskNetStateStr]];
    }
    
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}

-(void)getCellView{
    
    UIView *cellView = [[UIView alloc] init];
    [self.contentView addSubview:cellView];
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASSchedulesCell getCellHeight]));
    }];
    
    //背景图
//    UIImageView *imgView = [[UIImageView alloc] init];
//    UIImage *img = [UIImage imageNamed:@"img_bg"];
//    CGFloat top = 10; // 顶端盖高度
//    CGFloat bottom = 10 ; // 底端盖高度
//    CGFloat left = 15; // 左端盖宽度
//    CGFloat right = 15; // 右端盖宽度
//    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
//    // 指定为拉伸模式，伸缩后重新赋值
//    img = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
//    imgView.image = img;
//    [cellView addSubview:imgView];
//    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(cellView.mas_top).offset(2);
//        make.leading.equalTo(cellView.mas_leading).offset(5);
//        make.trailing.equalTo(cellView.mas_trailing).offset(-5);
//        make.bottom.equalTo(cellView.mas_bottom).offset(-2);
//    }];
    
    //设备图标
    _schedulesImgView = [UIImageView new];
    [cellView addSubview:_schedulesImgView];
    [_schedulesImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cellView.mas_centerY);
        make.leading.equalTo(cellView.mas_leading).offset(20); //首部
        make.width.equalTo(@(50));
        make.height.equalTo(_schedulesImgView.mas_width);
    }];

    //任务开关按钮
    _taskSwitchBtn = [[UIButton alloc] init];
    [_taskSwitchBtn addTarget:self action:@selector(taskSwitchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cellView addSubview:_taskSwitchBtn];
    [_taskSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cellView.mas_centerY);
        make.trailing.equalTo(cellView.mas_trailing).offset(-20); //尾部
        make.height.equalTo(@(40));
        make.width.equalTo(_taskSwitchBtn.mas_height);
    }];
    
    //任务名
    _taskNameLb = [[UILabel alloc]init];
    [_taskNameLb setFont:[UIFont systemFontOfSize:18]];
    [cellView addSubview:_taskNameLb];
    [_taskNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_schedulesImgView.mas_top);
        make.leading.equalTo(_schedulesImgView.mas_trailing).offset(10);
        make.trailing.equalTo(_taskSwitchBtn.mas_leading);
        make.height.equalTo(@(30));
    }];
    
    //任务类型
    _taskDetailLb = [[UILabel alloc]init];
    [_taskDetailLb setFont:[UIFont systemFontOfSize:14]];
    [_taskDetailLb setTextColor:[UIColor lightGrayColor]];
    [cellView addSubview:_taskDetailLb];
    [_taskDetailLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_taskNameLb.mas_bottom);
        make.leading.equalTo(_taskNameLb.mas_leading);
        make.trailing.equalTo(_taskNameLb.mas_trailing);
        make.bottom.equalTo(_schedulesImgView.mas_bottom);
    }];

    UILabel *downLineLb = [UILabel new];
    downLineLb.backgroundColor = UIColorFromRGB(0xe1ddd5);
    [cellView addSubview:downLineLb];
    [downLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(0.5));
        make.leading.equalTo(cellView.mas_leading).offset(10);
        make.trailing.equalTo(cellView.mas_trailing).offset(-10);
        make.bottom.equalTo(cellView.mas_bottom);
    }];
    
}

-(void)taskSwitchBtnAction:(UIButton *)sender{
    DLog(@"%d",isTaskOn);
    isTaskOn = [self.delegate taskSwitch:isTaskOn aduroInfo:self.aduroTaskInfo];
    DLog(@"%d",isTaskOn);
    [self setSwitchButtonImage:isTaskOn switchButton:sender];

    
    DLog(@"任务状态激活结果：%@",sender);
}

-(void)setSwitchButtonImage:(BOOL )setOn switchButton:(UIButton *)sender{
    if (setOn) {
        [sender setBackgroundImage:[UIImage imageNamed:@"Button_switch_on"] forState:UIControlStateNormal];
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"Button_switch_off"] forState:UIControlStateNormal];
    }
//    if (setOn) {
//        [sender setImage:[UIImage imageNamed:@"Button_switch_on"] forState:UIControlStateNormal];
//    }else{
//        [sender setImage:[UIImage imageNamed:@"Button_switch_off"] forState:UIControlStateNormal];
//    }
}

//-(void)showDetailTaskBtnAction{
//    [self.delegate taskShowDetailWithAduroTask:self.aduroTaskInfo];
//}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        NSLog(@"cell点击的是取消按钮:index=1");
        
    }else if(0 == buttonIndex){
        
        NSLog(@"cell点击的是确定按钮:index=0");
    }
}

+(CGFloat)getCellHeight{
    return 70.f;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
