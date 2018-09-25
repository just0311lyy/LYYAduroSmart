//
//  ASTimeTaskViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/6.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASTimeTaskViewController.h"
#import "ASGlobalDataObject.h"
#import "MyTool.h"
#import "ASTimeTaskDeviceSelectView.h"
#import "ASTimeTaskModelView.h"
//#import "ASTimeDeivceListViewController.h"
#import "ASTimeSceneListViewController.h"
#import "NSString+Wrapper.h"
#import "ASTimeTaskSceneSelectView.h"
#import <BFPaperButton.h>

#define TAG_WEEK_BUTTON 100060
#define TAG_SUCCESS_ADD_TIME_TASK 100000

@interface ASTimeTaskViewController ()<UITextFieldDelegate/*,ASTimeDeivceListViewControllerDelegate*/,ASTimeSceneSelectedDelegate,UIActionSheetDelegate>{

    UIDatePicker *_datePicker;
    UITextField *_txtTimeTaskName;
    
//    AduroDevice *_currentDevice;
//    ASTimeTaskDeviceSelectView *_canSetDeviceView;  //类型默认选择
//    ASTimeTaskModelView *_selectModeView; //选择设备或者场景的模型视图
//    NSString *_selectSignStr;  //定义一个字符串用来记录选择的是设备还是场景
    AduroScene *_currentScene;
    ASTimeTaskSceneSelectView *_canSetSceneView; //被触发场景
    UISwitch *_switchEnable;  //是否开启任务
}

@end

@implementation ASTimeTaskViewController
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    //    设置导航栏背景图片为一个空的image，这样就透明了
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
//    
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *navImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_ADURO_WIDTH, 64)];
    [self.view addSubview:navImgView];
    [navImgView setImage:[UIImage imageNamed:@"nav_bg"]];
    
    self.title = [ASLocalizeConfig localizedString:@"新建定时任务"];

    [self initWithNewTimeView];
}

-(void)initWithNewTimeView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backSchedulesViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(saveNewTimeTaskBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"完成"] forState:UIControlStateNormal];
    [rightBarBtn setFont:[UIFont systemFontOfSize:16]];
    rightBarBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    //-----自定场景名
    UIView *txtView = [[UIView alloc] init];
    [self.view addSubview:txtView];
    [txtView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(70));
    }];
    
    _txtTimeTaskName = [[UITextField alloc] init];
    [txtView addSubview:_txtTimeTaskName];
    //    [_txtOfDeviceName setSecureTextEntry:NO];//密码形式
    [_txtTimeTaskName setTextColor:LOGO_COLOR];
//    if (self.myAduroTask) {
//        [_txtTimeTaskName setText:self.myAduroTask.taskName];
//    }
    [_txtTimeTaskName setDelegate:self];
    [_txtTimeTaskName setPlaceholder:[ASLocalizeConfig localizedString:@"任务名"]];
    [_txtTimeTaskName setBorderStyle:UITextBorderStyleRoundedRect];
    [_txtTimeTaskName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(txtView.mas_top).offset(15);
        make.leading.equalTo(txtView.mas_leading).offset(15);
        make.trailing.equalTo(txtView.mas_trailing).offset(-15);
        make.height.equalTo(@(40));
    }];
    
    //-----------选择是否开启任务
    //分割线
    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CELL_LIEN_COLOR];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(txtView.mas_bottom);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(1));
    }];
    
    //是否开启
    UILabel *labTaskEnable = [UILabel new];
    [labTaskEnable setText:[ASLocalizeConfig localizedString:@"是否开启"]];
    [self.view addSubview:labTaskEnable];
    [labTaskEnable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom).offset(5);
        make.leading.equalTo(self.view.mas_leading).offset(20);
        make.trailing.equalTo(self.view.mas_centerX);
        make.height.equalTo(@(40));
    }];
    //开启任务开关
    _switchEnable = [UISwitch new];
    [_switchEnable setOn:YES];
    if (self.myAduroTask) {
        if (self.myAduroTask.taskEnable) {
            [_switchEnable setOn:YES];
        }else{
            [_switchEnable setOn:NO];
        }
    }
    [self.view addSubview:_switchEnable];
    [_switchEnable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(labTaskEnable.mas_centerY);
        make.trailing.equalTo(line.mas_trailing).offset(-20);
        //        make.height.equalTo(@(44));
    }];
//    [_switchEnable addTarget:self action:@selector(timeSwitchEnableAction:) forControlEvents:UIControlEventValueChanged];
    
   
    UIView *timeSelectView = [UIView new];
    [self.view addSubview:timeSelectView];
    timeSelectView.backgroundColor = CELL_LIEN_COLOR;
    [timeSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labTaskEnable.mas_bottom).offset(5);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(195));
    }];
    
    UIView *detailView = [UIView new];
    [timeSelectView addSubview:detailView];
    detailView.backgroundColor = UIColorFromRGB(0xffa20a);
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeSelectView.mas_top);
        make.leading.equalTo(timeSelectView.mas_leading);
        make.trailing.equalTo(timeSelectView.mas_trailing);
        make.height.equalTo(@(35));
    }];
    
    UILabel *detailLb = [[UILabel alloc] init];
    [detailView addSubview:detailLb];
    [detailLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(timeSelectView.mas_leading).offset(20);
        make.trailing.equalTo(timeSelectView.mas_trailing);
        make.top.equalTo(timeSelectView.mas_top);
        make.height.equalTo(@(35));
    }];
    detailLb.text = [ASLocalizeConfig localizedString:@"触发时间?"];
    detailLb.font = [UIFont systemFontOfSize:16];
    [detailLb setTextColor:[UIColor whiteColor]];
    
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,35,SCREEN_ADURO_WIDTH,120)];  //初始化时间选择器
    _datePicker.backgroundColor = UIColorFromRGB(0Xffad2c);
    [_datePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    _datePicker.datePickerMode = UIDatePickerModeTime;
    [timeSelectView addSubview:_datePicker];
    
    UIView *weekSettingView = [UIView new];
    [timeSelectView addSubview:weekSettingView];
//    weekSettingView.backgroundColor = CELL_LIEN_COLOR;
    [weekSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(timeSelectView.mas_bottom);
        make.leading.equalTo(timeSelectView.mas_leading);
        make.trailing.equalTo(timeSelectView.mas_trailing);
        make.height.equalTo(@40);
    }];
    NSString *strWeekMode = @"0x00";
    if (self.myAduroTask.taskConditionWeek != 0) {
        strWeekMode = [NSString stringWithFormat:@"%x",self.myAduroTask.taskConditionWeek];
    }
    [self createWeekButton:strWeekMode inView:weekSettingView];
    
    //-----被触发场景选择
    UIView *sceneSelectView = [UIView new];
    [self.view addSubview:sceneSelectView];
    sceneSelectView.backgroundColor = CELL_LIEN_COLOR;
    [sceneSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeSelectView.mas_bottom).offset(10);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(35));
    }];
    
    UILabel *sceneSelectLb = [[UILabel alloc] init];
    [sceneSelectView addSubview:sceneSelectLb];
    [sceneSelectLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(sceneSelectView.mas_leading).offset(20);
        make.trailing.equalTo(sceneSelectView.mas_trailing);
        make.top.equalTo(sceneSelectView.mas_top);
        make.bottom.equalTo(sceneSelectView.mas_bottom);
    }];
    sceneSelectLb.text = [ASLocalizeConfig localizedString:@"选择被触发的场景"];
    sceneSelectLb.font = [UIFont systemFontOfSize:16];
    [sceneSelectLb setTextColor:[UIColor darkGrayColor]];
    //
    _canSetSceneView = [[ASTimeTaskSceneSelectView alloc] init];
    _canSetSceneView.sceneImgView.image = [UIImage imageNamed:@"scene_set"];
    _canSetSceneView.sceneNameLb.text = [ASLocalizeConfig localizedString:@"场景名称"];
    if (self.myAduroTask) {
        //标题
        NSString *sceneTitle = @"";
        for (int j=0; j<_globalSceneArray.count; j++) {
            AduroScene *taskScene = [_globalSceneArray objectAtIndex:j];
            if (taskScene.sceneID == self.myAduroTask.taskTriggeredScene.sceneID) {
                sceneTitle = taskScene.sceneName;
            }
        }
        _canSetSceneView.sceneNameLb.text = sceneTitle;
    }
    
    [self.view addSubview:_canSetSceneView];
    [_canSetSceneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(sceneSelectView.mas_leading);
        make.trailing.equalTo(sceneSelectView.mas_trailing);
        make.top.equalTo(sceneSelectView.mas_bottom);
        make.height.equalTo(@(55));
    }];
    
    UIButton *sceneSelectBtn = [UIButton new];
    sceneSelectBtn.backgroundColor = [UIColor clearColor];
    [sceneSelectBtn addTarget:self action:@selector(sceneSelectBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [_canSetSceneView addSubview:sceneSelectBtn];
    [sceneSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_canSetSceneView.mas_leading);
        make.trailing.equalTo(_canSetSceneView.mas_trailing);
        make.bottom.equalTo(_canSetSceneView.mas_bottom);
        make.top.equalTo(_canSetSceneView.mas_top);
    }];
//    //-----可定时类型选择
//    UIView *deviceSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 320, SCREEN_ADURO_WIDTH, 35)];
//    [self.view addSubview:deviceSelectView];
//    deviceSelectView.backgroundColor = CELL_LIEN_COLOR;
//    
//    UILabel *deviceSelectLb = [[UILabel alloc] init];
//    [deviceSelectView addSubview:deviceSelectLb];
//    [deviceSelectLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(deviceSelectView.mas_leading).offset(20);
//        make.trailing.equalTo(deviceSelectView.mas_trailing);
//        make.top.equalTo(deviceSelectView.mas_top);
//        make.bottom.equalTo(deviceSelectView.mas_bottom);
//    }];
//    deviceSelectLb.text = [ASLocalizeConfig localizedString:@"请点击'设备选择'或者'场景选择'按钮"];
//    deviceSelectLb.font = [UIFont systemFontOfSize:16];
//    [deviceSelectLb setTextColor:[UIColor darkGrayColor]];
//    
//    UIButton *deviceSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [deviceSelectBtn.layer setMasksToBounds:YES];
//    [deviceSelectBtn.layer setCornerRadius:5.0];
//    [deviceSelectBtn setBackgroundColor:UIColorFromRGB(0X989999)];
//    [deviceSelectBtn setTitle:[ASLocalizeConfig localizedString:@"选择设备"] forState:UIControlStateNormal];
//    [deviceSelectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [deviceSelectBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    [deviceSelectBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [deviceSelectBtn addTarget:self action:@selector(deviceSelectBtnPress) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:deviceSelectBtn];
//    [deviceSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(deviceSelectView.mas_bottom).offset(5);
//        make.leading.equalTo(self.view.mas_leading).offset(30);
//        make.width.equalTo(@((SCREEN_ADURO_WIDTH - 80)/2));
//        make.height.equalTo(@(40));
//    }];
//    //
//    UIButton *sceneSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sceneSelectBtn.layer setMasksToBounds:YES];
//    [sceneSelectBtn.layer setCornerRadius:5.0];
//    [sceneSelectBtn setBackgroundColor:UIColorFromRGB(0X989999)];
//    [sceneSelectBtn setTitle:[ASLocalizeConfig localizedString:@"选择场景"] forState:UIControlStateNormal];
//    [sceneSelectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [sceneSelectBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
//    [sceneSelectBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [sceneSelectBtn addTarget:self action:@selector(sceneSelectBtnPress) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:sceneSelectBtn];
//    [sceneSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(deviceSelectBtn.mas_bottom);
//        make.trailing.equalTo(self.view.mas_trailing).offset(-30);
//        make.width.equalTo(deviceSelectBtn.mas_width);
//        make.height.equalTo(deviceSelectBtn.mas_height);
//    }];
// 
//    //---------
//    _selectModeView = [[ASTimeTaskModelView alloc] init];
//    _selectModeView.leftImgView.image = [UIImage imageNamed:@"schedules_set"];
//    [_selectModeView.bottomView setHidden:YES];
//    if (self.myAduroTask) {
//        if (self.myAduroTask.taskType == TaskTypeDeviceTimer) {
//            _selectModeView.leftImgView.image = [UIImage imageNamed:@"light"];
//            //标题
//            NSString *deviceTitle = @"";
//            for (int j=0; j<_globalDeviceArray.count; j++) {
//                AduroDevice *lightDevice = [_globalDeviceArray objectAtIndex:j];
//                if ([lightDevice.deviceID isEqualToString:self.myAduroTask.taskTriggeredDevice.deviceID]) {
//                    deviceTitle = lightDevice.deviceName;
//                }
//            }
//            _selectModeView.nameLb.text = deviceTitle;
//            //亮度
//            [_selectModeView.bottomView setHidden:NO];
////            _selectModeView.colorView.backgroundColor = 
//            _selectModeView.levelLb.text = [NSString stringWithFormat:@"%.0f%%",(self.myAduroTask.taskTriggeredDevice.deviceLightLevel / 255.0)*100];
//            NSString *onOff = @"";
//            if (self.myAduroTask.taskTriggeredDevice.deviceSwitchState == DeviceSwitchStateOn) {
//                onOff = @"on";
//            }else{
//                onOff = @"off";
//            }
//            _selectModeView.switchLb.text = onOff;
////            _selectModeView.detailLb.text = [[NSString alloc] initWithFormat:@"Lv=%x,H=%x,S=%x,Switch=%x",self.myAduroTask.taskTriggeredDevice.deviceLightLevel,self.myAduroTask.taskTriggeredDevice.deviceLightHue,self.myAduroTask.taskTriggeredDevice.deviceLightSat,self.myAduroTask.taskTriggeredDevice.deviceSwitchState];
//        }else{
//            _selectModeView.leftImgView.image = [UIImage imageNamed:@"scene_set"];
//            //标题
//            NSString *sceneTitle = @"";
//            for (int j=0; j<_globalSceneArray.count; j++) {
//                AduroScene *taskScene = [_globalSceneArray objectAtIndex:j];
//                if (taskScene.sceneID == self.myAduroTask.taskTriggeredScene.sceneID) {
//                    sceneTitle = taskScene.sceneName;
//                }
//            }
//            _selectModeView.nameLb.text = sceneTitle;
//            //亮度
//            _selectModeView.detailLb.text = @"";
//        }
//    }else{
//        _selectModeView.nameLb.text = [ASLocalizeConfig localizedString:@"任务"];
////        _selectModeView.detailLb.text = [ASLocalizeConfig localizedString:@"任务详情"];
//    }
//    [self.view addSubview:_selectModeView];
//    [_selectModeView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(deviceSelectView.mas_leading);
//        make.trailing.equalTo(deviceSelectView.mas_trailing);
//        make.top.equalTo(deviceSelectBtn.mas_bottom).offset(5);
//        make.height.equalTo(@(100));
//    }];
//    
//    UIButton *taskTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.view addSubview:taskTypeBtn];
//    [taskTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(_selectModeView.mas_leading);
//        make.trailing.equalTo(_selectModeView.mas_trailing);
//        make.top.equalTo(_selectModeView.mas_top);
//        make.bottom.equalTo(_selectModeView.mas_bottom);
//    }];
//    [taskTypeBtn addTarget:self action:@selector(taskTypeSelectedAction) forControlEvents:UIControlEventTouchUpInside];

    [self setupData];
}

//若是编辑任务，则走这里
-(void)setupData{
    if (self.myAduroTask != nil) {
        self.title = [ASLocalizeConfig localizedString:@"编辑任务"];
//        [self.navigationItem.rightBarButtonItem setTitle:@"编辑任务" forState:UIControlStateNormal];
        //名称设置为之前已经命名的任务名
        [_txtTimeTaskName setText:self.myAduroTask.taskName];
        
        [_datePicker setDate:[self getDatatime:self.myAduroTask.taskConditionHour minute:self.myAduroTask.taskConditionMinute] animated:YES];
    }
}

-(NSDate *)getDatatime:(NSInteger )hour minute:(NSInteger )minute{
    NSString *hourStr = [[NSString alloc]initWithFormat:@"%d",hour];
    NSString *minuteStr = [[NSString alloc]initWithFormat:@"%d",minute];
    if (hour<10) {
        hourStr = [[NSString alloc]initWithFormat:@"0%d",hour];
    }
    if (minute<10) {
        minuteStr = [[NSString alloc]initWithFormat:@"0%d",minute];
    }
    NSString*string = [[NSString alloc]initWithFormat:@"20160826%@%@06",hourStr,minuteStr];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate*inputDate = [inputFormatter dateFromString:string];
    
    return inputDate;
}

/**
 *  创建周期选择按钮(已选择为[UIColor colorWithRed:0.255 green:0.827 blue:0.318 alpha:1.000]，未选择为白色)
 *
 *  @param period 已有的周期数据
 *
 *  @return 返回创建好的周期选择按钮
 */
-(void)createWeekButton:(NSString *)period inView:(UIView *)superView{
    //将16进制字符转换为2进制字符
    NSString *strBinaryPeriod = [MyTool getBinaryStrByHex:period];
    UIView *oneWeekView = [UIView new];
//    oneWeekView.backgroundColor = CELL_LIEN_COLOR;
    [superView addSubview:oneWeekView];
    [oneWeekView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView.mas_top);
        make.leading.equalTo(superView.mas_leading);
        make.trailing.equalTo(superView.mas_trailing);
        make.bottom.equalTo(superView.mas_bottom);
    }];
    
    NSMutableArray *arrSubViews = [[NSMutableArray alloc]init];
    for (int i=0 ; i<7 ; i++) {
        UIButton *oneDayButton = [UIButton new];
        [oneWeekView addSubview:oneDayButton];
        [oneDayButton setTitle:[MyTool weekConverByIday:i] forState:UIControlStateNormal];
//        [oneDayButton setBackgroundImage:[UIImage imageNamed:[MyTool weekImageConverByIday:i]] forState:UIControlStateNormal];
        [oneDayButton setBackgroundColor:CELL_LIEN_COLOR];
//        if (i==7) {
//            [oneDayButton setBackgroundColor:LOGO_COLOR];
//        }
        [oneDayButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.f]];
        [oneDayButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [oneDayButton setTag:(TAG_WEEK_BUTTON + i)];
        [oneDayButton addTarget:self action:@selector(selectDayButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([strBinaryPeriod length]>0) {
            NSRange rage;
            rage.length = 1;
            NSInteger index = i;
            if (i==0) {
                index = 7;
            }
            rage.location = 7 - index;
            
            NSString *week = [strBinaryPeriod substringWithRange:rage];
            if ([week isEqualToString:@"1"]) {
                [oneDayButton setBackgroundColor:LOGO_COLOR];
                [oneDayButton setAccessibilityValue:@"select"]; //传递区分信息
//                [oneDayButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",[MyTool weekImageConverByIday:i]]] forState:UIControlStateNormal];
            }
            else{
                [oneDayButton setBackgroundColor:CELL_LIEN_COLOR];
                [oneDayButton setAccessibilityValue:@"unselect"];
//                [oneDayButton setBackgroundImage:[UIImage imageNamed:[MyTool weekImageConverByIday:i]] forState:UIControlStateNormal];
            }

            
        }else{
            [oneDayButton setBackgroundColor:CELL_LIEN_COLOR];
            [oneDayButton setAccessibilityValue:@"unselect"];
//            [oneDayButton setBackgroundImage:[UIImage imageNamed:[MyTool weekImageConverByIday:i]] forState:UIControlStateNormal];
        }
        
        [arrSubViews addObject:oneDayButton];
        
    }
    CGFloat padding = 0.0f; //各view的左右边距
    [self makeEqualWidthViews:arrSubViews inView:oneWeekView LRpadding:padding viewPadding:0];

}

/**
 *  将若干view等宽布局于容器containerView中
 *
 *  @param views         viewArray
 *  @param containerView 容器view
 *  @param LRpadding     距容器的左右边距
 *  @param viewPadding   各view的左右边距
 */
-(void)makeEqualWidthViews:(NSArray *)views inView:(UIView *)containerView LRpadding:(CGFloat)LRpadding viewPadding :(CGFloat)viewPadding
{
    UIButton *lastView;
    for (UIButton *view in views) {
        [containerView addSubview:view];
        if (lastView) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(containerView);
                make.left.equalTo(lastView.mas_right).offset(viewPadding);
                make.width.equalTo(lastView);
            }];
        }else
        {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(containerView).offset(LRpadding);
                make.top.bottom.equalTo(containerView);
            }];
        }
        lastView=view;
    }
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-LRpadding);
    }];
}

/**
 *  选择周期按钮
 *
 *  @param sender 周期按钮
 */
-(void)selectDayButtonClickEvent:(UIButton *)sender{

    UIView *superView = sender;
    
    if ([sender.accessibilityValue isEqualToString:@"select"]) {
        if (sender.tag != TAG_WEEK_BUTTON+7) {
            [sender setBackgroundColor:CELL_LIEN_COLOR];
            [sender setAccessibilityValue:@"unselect"];
        }
    }else{
        [sender setBackgroundColor:LOGO_COLOR];
        [sender setAccessibilityValue:@"select"];
        if (sender.tag == TAG_WEEK_BUTTON+7) {
            for (int i=0; i<7; i++) {
                [[superView viewWithTag:TAG_WEEK_BUTTON+i] setBackgroundColor:CELL_LIEN_COLOR];
                [[superView viewWithTag:TAG_WEEK_BUTTON+i] setAccessibilityValue:@"unselect"];
            }
        }else{
            [[superView viewWithTag:TAG_WEEK_BUTTON+7] setBackgroundColor:CELL_LIEN_COLOR];
            [[superView viewWithTag:TAG_WEEK_BUTTON+7] setAccessibilityValue:@"unselect"];
        }
    }
}


-(void)backSchedulesViewBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveNewTimeTaskBtnAction{
    NSString *timeTaskName = [_txtTimeTaskName text];
    if ([timeTaskName length]<1||[timeTaskName length]>30) {
        UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"名称长度应在1到30之间"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [failedAlertView show];
        return;
    }
    AduroTask *myTask = nil;
    if (self.myAduroTask) {
        //
        myTask = self.myAduroTask;
        myTask.taskType = self.myAduroTask.taskType;
    }else{
        myTask = [[AduroTask alloc]init];
    }
    [myTask setTaskName:_txtTimeTaskName.text];
    [myTask setTaskEnable:_switchEnable.on];
    [myTask setTaskType:TaskTypeSceneTimer];
    [myTask setTaskTriggeredScene:_currentScene];
//    if (_selectSignStr != nil && ![_selectSignStr isEqualToString:@""]) {
//        if ([_selectSignStr isEqualToString:@"scene"]) {
//            [myTask setTaskType:TaskTypeSceneTimer];
//            [myTask setTaskTriggeredScene:_currentScene];
//        }else{
//            [myTask setTaskType:TaskTypeDeviceTimer];
//            [myTask setTaskTriggeredDevice:_currentDevice];
//        }
//    }else{
//        if (!self.myAduroTask) {
//            UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"Please select a device or a scene to set"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
//            [failedAlertView show];
//            return;
//        }        
//    }

    //周期
    NSMutableString *period = [[NSMutableString alloc]init];
    for (int i = 7; i > 0; i--) {
        NSInteger index = i;
        if (i == 7) {
            index = 0;
        }
        UIButton *oneDayButton = (UIButton*)[self.view viewWithTag:(TAG_WEEK_BUTTON + index)];
        if ([oneDayButton.accessibilityValue isEqualToString:@"select"]) {
            [period appendString:@"1"];
        }else{
            [period appendString:@"0"];
        }
    }
    //将二进制数转化为16进制
    NSString *strHexWorkMode = [MyTool getStrHexByBinary:period];
    //先以16为参数告诉strtoul字符串参数表示16进制数字，然后使用0x%X转为数字类型
    unsigned long byteWorkMode = strtoul([strHexWorkMode UTF8String],0,16); // 将字符串转化为无符号长整型。第三个参数指进制数
//    DDLogDebug(@"strHexWorkMode = %@,period=%@,byteWorkMode=%x",strHexWorkMode,period,byteWorkMode);
    [myTask setTaskConditionWeek:byteWorkMode];
    
    NSCalendar *cal = [NSCalendar currentCalendar];  //当前逻辑的日历
    [cal setTimeZone:[NSTimeZone systemTimeZone]]; //设置时区
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;  //返回单元的最大范围
    // 通过已定义的日历对象，获取某个时间点的NSDateComponents表示，并设置需要表示哪些信息（NSYearCalendarUnit, NSMonthCalendarUnit, NSDayCalendarUnit等）
    NSDateComponents *dd = [cal components:unitFlags fromDate:_datePicker.date];
    Byte hour = [dd hour];
    Byte minute = [dd minute];
    NSLog(@"hour = %d,minute = %x",hour,minute);
    [myTask setTaskConditionHour:hour];
    [myTask setTaskConditionMinute:minute];
    [myTask setTaskConditionSecond:0];

//    [myTask setTaskTriggeredDevice:_currentDevice];

    TaskManager *taskManager = [TaskManager sharedManager];
    if (self.myAduroTask) {
        [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Updating..."]];
        [taskManager updateTask:myTask completionHandler:^(NSInteger taskID, AduroSmartReturnCode code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopMBProgressHUD];
                if (code == AduroSmartReturnCodeSuccess) {
                    [self showCreatSuccessAlertView];
                }else if(code == AduroSmartReturnCodeNoAccess){
                    [self showCreatFaildAlertView];
                }
            });
        }];
    }else{
        [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Saving..."]];
        [taskManager addTask:myTask completionHandler:^(NSInteger taskID, AduroSmartReturnCode code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopMBProgressHUD];
                if (code == AduroSmartReturnCodeSuccess) {
                    [self showCreatSuccessAlertView];
                }else if(code == AduroSmartReturnCodeNoAccess){
                    [self showCreatFaildAlertView];
                }
                
            });

        }];
    }
}

-(void)showCreatSuccessAlertView{
    
    UIAlertView *saveSuccessAlert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"创建定时任务成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
    [saveSuccessAlert setTag:TAG_SUCCESS_ADD_TIME_TASK];
    [saveSuccessAlert show];
}

-(void)showCreatFaildAlertView{
    UIAlertView *saveFaildAlert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"Error"] message:[ASLocalizeConfig localizedString:@"Network anomaly"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"OK"] otherButtonTitles:nil, nil];
    [saveFaildAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_SUCCESS_ADD_TIME_TASK) {
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_SCHEDULES_TABLE object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }   
    }
}

////选择定时设备
//-(void)deviceSelectBtnPress{
//    NSLog(@"定时设备选择");
//    ASTimeDeivceListViewController *deviceVC = [[ASTimeDeivceListViewController alloc] init];
//    deviceVC.delegate = self;
//    deviceVC.deviceType = @"time";
//    self.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:deviceVC animated:YES];
//    self.hidesBottomBarWhenPushed = YES;
//}
//
//-(void)taskTypeSelectedAction{
//    if (self.myAduroTask) {
//        if (self.myAduroTask.taskType == TaskTypeDeviceTimer) {
//            [self deviceSelectBtnPress];
//        }else{
//            [self sceneSelectBtnPress];
//        }
//    }
//    else{ //新建任务时
//        if (_selectSignStr != nil && ![_selectSignStr isEqualToString:@""]) {
//            if ([_selectSignStr isEqualToString:@"scene"]) {
//                [self sceneSelectBtnPress];
//            }else{
//                [self deviceSelectBtnPress];
//            }
//        }else{
//            /**
//             Title:如果不想要title，可以设置为nil；
//             注意需要实现UIActionSheetDelegate；
//             destructiveButtonTitle:设置的按钮文字是红色的；
//             otherButtonTitles：按照按钮顺序；
//             */
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[ASLocalizeConfig localizedString:@"请点击'设备选择'或者'场景选择'按钮"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] destructiveButtonTitle:nil otherButtonTitles:[ASLocalizeConfig localizedString:@"选择设备"],[ASLocalizeConfig localizedString:@"选择场景"], nil];
//            /**
//             *
//             UIActionSheetStyleAutomatic
//             UIActionSheetStyleDefault
//             UIActionSheetStyleBlackTranslucent
//             UIActionSheetStyleBlackOpaque
//             */
//            //这里的actionSheetStyle也可以不设置；
//            //   actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
//            [actionSheet showInView:self.view];
//        }
//    }
//}

//#pragma mark - UIActionSheetDelegate
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
//    //按照按钮的顺序0-N；
//    switch (buttonIndex) {
//        case 0:
//            NSLog(@"点击了选择设备");
//            [self deviceSelectBtnPress];
//            break;
//        case 1:
//            NSLog(@"点击了选择场景");
//            [self sceneSelectBtnPress];
//            break;
////        case 2:
////            NSLog(@"点击了取消");
////            break;
//        default:
//            break;
//    }
//}

//#pragma mark - ASTimeDeivceListViewControllerDelegate
//- (void)selectTaskViewController:(ASTimeDeivceListViewController *)selectedVC didSelectDevice:(AduroDevice *)deviceInfo withSignString:(NSString *)signString withColor:(UIColor *)color withLevel:(CGFloat)level withIsSwitchOn:(BOOL)isSwitchOn{
//    _currentDevice = deviceInfo;
//    _selectModeView.leftImgView.image = [UIImage imageNamed:@"light"];
//    _selectModeView.nameLb.text = [NSString stringWithFormat:@"%@",[NSString changeName:_currentDevice.deviceName]];
////    _selectModeView.detailLb.text = [[NSString alloc] initWithFormat:@"Lv=%x,H=%x,S=%x,Switch=%x",_currentDevice.deviceLightLevel,_currentDevice.deviceLightHue,_currentDevice.deviceLightSat,_currentDevice.deviceSwitchState];
//    _selectSignStr = signString;
//    [_selectModeView.bottomView setHidden:NO];
//    _selectModeView.colorView.backgroundColor = color;
//    _selectModeView.levelLb.text = [NSString stringWithFormat:@"%.0f%%",level*100];
//    NSString *onOffStr = @"";
//    if (isSwitchOn == YES) {
//        onOffStr = @"on";
//    }else{
//        onOffStr = @"off";
//    }
//    _selectModeView.switchLb.text = onOffStr;
//}

//选择定时场景
-(void)sceneSelectBtnPress{
    NSLog(@"定时场景选择");
    ASTimeSceneListViewController *sceneTaskVC = [[ASTimeSceneListViewController alloc] init];
    sceneTaskVC.delegate = self;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sceneTaskVC animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    
}

#pragma mark - ASTimeSceneSelectedDelegate
- (void)selectTimeSceneViewController:(ASTimeSceneListViewController *)selectedVC didSelectScene:(AduroScene *)sceneInfo withSignString:(NSString *)signString{
    _currentScene = sceneInfo;
    _canSetSceneView.sceneNameLb.text = _currentScene.sceneName;
//    _selectModeView.leftImgView.image = [UIImage imageNamed:@"scene_set"];
//    _selectSignStr = signString;
//    _selectModeView.nameLb.text = _currentScene.sceneName;
//    [_selectModeView.bottomView setHidden:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
