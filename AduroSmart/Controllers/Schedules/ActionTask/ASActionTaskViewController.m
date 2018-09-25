//
//  ASActionTaskViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/6.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASActionTaskViewController.h"
#import "ASGlobalDataObject.h"
#import "ASTimeTaskSceneSelectView.h"
#import "MyTool.h"
#import "ASActionDeviceListViewController.h"
#import "ASTimeSceneListViewController.h"

#define TAG_WEEK_BUTTON 100060
#define TAG_SUCCESS_ADD_ACTION_TASK 10011
@interface ASActionTaskViewController ()<UITextFieldDelegate,ASTimeSceneSelectedDelegate,ASActionDeviceListViewControllerDelegate>{

    UITextField *_txtActionTaskName;
    UISegmentedControl *_segCondition; //选择触发条件
    UISwitch *_switchEnable;  //是否开启任务
    NSInteger _taskConditionDeviceAction;
    AduroDevice *_currentDevice; //选定的触发设备
    AduroScene *_currentScene; // 选择被触发的场景
    ASTimeTaskSceneSelectView *_canSetDeviceView; //触发设备
    ASTimeTaskSceneSelectView *_canSetSceneView; //被触发场景
}
@end

@implementation ASActionTaskViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"新建触发任务"];
    [self initWithNewActionView];
}

-(void)initWithNewActionView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToSchedulesViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(saveNewActionTaskBtnAction) forControlEvents:UIControlEventTouchUpInside];
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
    
    _txtActionTaskName = [[UITextField alloc] init];
    [txtView addSubview:_txtActionTaskName];
    //    [_txtOfDeviceName setSecureTextEntry:NO];//密码形式
    [_txtActionTaskName setDelegate:self];
    [_txtActionTaskName setPlaceholder:[ASLocalizeConfig localizedString:@"任务名"]];
    [_txtActionTaskName setBorderStyle:UITextBorderStyleRoundedRect];
    [_txtActionTaskName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(txtView.mas_top).offset(14);
        make.leading.equalTo(txtView.mas_leading).offset(10);
        make.trailing.equalTo(txtView.mas_trailing).offset(-10);
        make.height.equalTo(@(42));
    }];
    
    //txt分割线
    UIView *separatorView = [[UIView alloc]init];
    separatorView.backgroundColor = CELL_LIEN_COLOR;
    [txtView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(txtView.mas_leading).offset(10);
        make.trailing.equalTo(txtView.mas_trailing);
        make.height.equalTo(@(1));
        make.bottom.equalTo(txtView.mas_bottom);
    }];
    //--------
    //-----触发设备选择
    UIView *deviceSelectView = [UIView new];
    [self.view addSubview:deviceSelectView];
    deviceSelectView.backgroundColor = CELL_LIEN_COLOR;
    [deviceSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(txtView.mas_leading);
        make.trailing.equalTo(txtView.mas_trailing);
        make.height.equalTo(@(35));
        make.top.equalTo(txtView.mas_bottom);
    }];

    UILabel *deviceSelectLb = [[UILabel alloc] init];
    [deviceSelectView addSubview:deviceSelectLb];
    [deviceSelectLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(deviceSelectView.mas_leading).offset(20);
        make.trailing.equalTo(deviceSelectView.mas_trailing);
        make.top.equalTo(deviceSelectView.mas_top);
        make.bottom.equalTo(deviceSelectView.mas_bottom);
    }];
    deviceSelectLb.text = [ASLocalizeConfig localizedString:@"传感器类型选择"];
    deviceSelectLb.font = [UIFont systemFontOfSize:16];
    [deviceSelectLb setTextColor:[UIColor darkGrayColor]];
    //
    _canSetDeviceView = [[ASTimeTaskSceneSelectView alloc] init];
    _canSetDeviceView.sceneImgView.image = [UIImage imageNamed:@"sensor"];
    _canSetDeviceView.sceneNameLb.text = [ASLocalizeConfig localizedString:@"传感器名"];
    if (self.myAduroTask != nil) {
        _canSetDeviceView.sceneNameLb.text = self.myAduroTask.taskConditionDevice.deviceName;
        if (self.myAduroTask.taskConditionDevice.deviceZoneType == DeviceZoneTypeContactSwitch) {
            _canSetDeviceView.sceneImgView.image = [UIImage imageNamed:@"sensor_0015"];
        }else{
            _canSetDeviceView.sceneImgView.image = [UIImage imageNamed:@"sensor_0014"];
        }
    }
    [self.view addSubview:_canSetDeviceView];
    [_canSetDeviceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(deviceSelectView.mas_leading);
        make.trailing.equalTo(deviceSelectView.mas_trailing);
        make.top.equalTo(deviceSelectView.mas_bottom);
        make.height.equalTo(@(55));
    }];

    UIButton *deviceSelectBtn = [UIButton new];
    deviceSelectBtn.backgroundColor = [UIColor clearColor];
    [deviceSelectBtn addTarget:self action:@selector(deviceSelectAction) forControlEvents:UIControlEventTouchUpInside];
    [_canSetDeviceView addSubview:deviceSelectBtn];
    [deviceSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_canSetDeviceView.mas_leading);
        make.trailing.equalTo(_canSetDeviceView.mas_trailing);
        make.bottom.equalTo(_canSetDeviceView.mas_bottom);
        make.top.equalTo(_canSetDeviceView.mas_top);
    }];

//-----------选择触发动作
    UILabel *triggerLb = [UILabel new];
    [self.view addSubview:triggerLb];
    [triggerLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_canSetDeviceView.mas_leading).offset(10);
        make.trailing.equalTo(_canSetDeviceView.mas_centerX);
        make.top.equalTo(_canSetDeviceView.mas_bottom).offset(5);
        make.height.equalTo(@(40));
    }];
    triggerLb.text = [ASLocalizeConfig localizedString:@"触发动作:"];
   
    if (!_segCondition) {
        _segCondition = [UISegmentedControl new];
        if (self.myAduroTask) {
            NSArray *segDataArray = nil;
            switch (self.myAduroTask.taskConditionDevice.deviceZoneType) {
                case DeviceZoneTypeMotionSensor:
                {
                    //红外
                    segDataArray = @[[ASLocalizeConfig localizedString:@"有人"]];
                    [_segCondition insertSegmentWithTitle:[segDataArray objectAtIndex:0] atIndex:0 animated:YES];
                }
                    break;
                case DeviceZoneTypeContactSwitch:
                {
                    //门磁
                    segDataArray = @[[ASLocalizeConfig localizedString:@"开门"],[ASLocalizeConfig localizedString:@"关门"]];
                    [_segCondition insertSegmentWithTitle:[segDataArray objectAtIndex:0] atIndex:0 animated:YES];
                    [_segCondition insertSegmentWithTitle:[segDataArray objectAtIndex:1] atIndex:1 animated:YES];
                }
                    break;
            }
//            [_segCondition insertSegmentWithTitle:[segDataArray objectAtIndex:0] atIndex:0 animated:YES];
//            [_segCondition insertSegmentWithTitle:[segDataArray objectAtIndex:1] atIndex:1 animated:YES];
            
            if (self.myAduroTask.taskConditionDeviceAction == 0x01) {
                [_segCondition setSelectedSegmentIndex:0];
            }else{
                [_segCondition setSelectedSegmentIndex:1];
            }
        }
        [_segCondition setTintColor:LOGO_COLOR];
        [_segCondition addTarget:self action:@selector(changeConditionAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_segCondition];
        [_segCondition mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(triggerLb.mas_centerY);
            make.trailing.equalTo(_canSetDeviceView.mas_trailing).offset(-20);
            make.width.equalTo(@(150));
            make.height.equalTo(@(35));
        }];
    }
//-----------选择是否开启任务
    //分割线
    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CELL_LIEN_COLOR];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(triggerLb.mas_bottom).offset(5);
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
        make.leading.equalTo(triggerLb.mas_leading);
        make.trailing.equalTo(triggerLb.mas_trailing);
        make.height.equalTo(triggerLb.mas_height);
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
//    [_switchEnable addTarget:self action:@selector(switchEnableAction:) forControlEvents:UIControlEventValueChanged];
    
    UIView *bottomLine = [UIView new];
    [self.view addSubview:bottomLine];
    [bottomLine setBackgroundColor:CELL_LIEN_COLOR];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labTaskEnable.mas_bottom).offset(5);
        make.leading.equalTo(line.mas_leading);
        make.trailing.equalTo(line.mas_trailing);
        make.height.equalTo(@(1));
    }];

//-----被触发场景选择
    UIView *sceneSelectView = [UIView new];
    [self.view addSubview:sceneSelectView];
    sceneSelectView.backgroundColor = CELL_LIEN_COLOR;
    [sceneSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomLine.mas_bottom).offset(10);
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
    [sceneSelectBtn addTarget:self action:@selector(sceneSelectAction) forControlEvents:UIControlEventTouchUpInside];
    [_canSetSceneView addSubview:sceneSelectBtn];
    [sceneSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_canSetSceneView.mas_leading);
        make.trailing.equalTo(_canSetSceneView.mas_trailing);
        make.bottom.equalTo(_canSetSceneView.mas_bottom);
        make.top.equalTo(_canSetSceneView.mas_top);
    }];
    
    [self setupActionData];
}

//若是编辑任务，则走这里
-(void)setupActionData{
    if (self.myAduroTask != nil) {
        self.title = [ASLocalizeConfig localizedString:@"编辑任务"];
        //名称设置为之前已经命名的任务名
        [_txtActionTaskName setText:self.myAduroTask.taskName];
    }
}

-(void)deviceSelectAction{
    NSLog(@"device");
    ASActionDeviceListViewController *sensorvc = [[ASActionDeviceListViewController alloc] init];
    sensorvc.delegate = self;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sensorvc animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    
}
#pragma mark - ASTimeDeivceListViewControllerDelegate
- (void)selectTaskViewController:(ASActionDeviceListViewController *)selectedVC didSelectSensor:(AduroDevice *)sensorInfo{
    _currentDevice = sensorInfo;
    if (_currentDevice.deviceZoneType == DeviceZoneTypeContactSwitch) {
        _canSetDeviceView.sceneImgView.image = [UIImage imageNamed:@"sensor_0015"];
    }else{
        _canSetDeviceView.sceneImgView.image = [UIImage imageNamed:@"sensor_0014"];
    }
    
    _canSetDeviceView.sceneNameLb.text = [NSString stringWithFormat:@"%@",_currentDevice.deviceName];
    //触发动作选择
    NSArray *segDataArray = nil;
    switch (_currentDevice.deviceZoneType) {
        case DeviceZoneTypeMotionSensor:
        {
            //红外
            segDataArray = @[[ASLocalizeConfig localizedString:@"有人"]];
            if (_segCondition) {
                [_segCondition removeAllSegments];
            }
            [_segCondition insertSegmentWithTitle:[segDataArray objectAtIndex:0] atIndex:0 animated:YES];
        }
            break;
        case DeviceZoneTypeContactSwitch:
        {
            //门磁
            segDataArray = @[[ASLocalizeConfig localizedString:@"开门"],[ASLocalizeConfig localizedString:@"关门"]];
            if (_segCondition) {
                [_segCondition removeAllSegments];
            }
            [_segCondition insertSegmentWithTitle:[segDataArray objectAtIndex:0] atIndex:0 animated:YES];
            [_segCondition insertSegmentWithTitle:[segDataArray objectAtIndex:1] atIndex:1 animated:YES];
        }
            break;
    }
}

-(void)sceneSelectAction{
    NSLog(@"scene");
    ASTimeSceneListViewController *scenevc = [[ASTimeSceneListViewController alloc] init];
    scenevc.delegate = self;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scenevc animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - ASTimeSceneSelectedDelegate
- (void)selectTimeSceneViewController:(ASTimeSceneListViewController *)selectedVC didSelectScene:(AduroScene *)sceneInfo withSignString:(NSString *)signString{
    _currentScene = sceneInfo;
    //    _canSetSceneView.sceneNameLb.text = sceneInfo.sceneName;
    _canSetSceneView.sceneNameLb.text = _currentScene.sceneName;
}

-(void)backToSchedulesViewBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveNewActionTaskBtnAction{
    NSString *strTaskName = _txtActionTaskName.text;
    if ([strTaskName length]<1 || [strTaskName length]>30) {
        UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"名称长度应在1到30之间"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [failedAlertView show];
        return;
    }
    
    AduroTask *myTask = nil;
    if (self.myAduroTask) {
        //
        myTask = self.myAduroTask;
        //        myTask.taskType = self.myAduroTask.taskType;
    }else{
        myTask = [[AduroTask alloc]init];
    }
    [myTask setTaskName:strTaskName];
//    [myTask setTaskEnable:YES];
    [myTask setTaskEnable:_switchEnable.on];
    if (_taskConditionDeviceAction) {
        [myTask setTaskConditionDeviceAction:_taskConditionDeviceAction - HEXADECIMAL_DATA_OFFSET]; //触发设备条件
    }else{
        if (_myAduroTask) {
            [myTask setTaskConditionDeviceAction:_myAduroTask.taskConditionDeviceAction];
        }
    }
    
    if (_currentDevice==nil) {
        if (_myAduroTask) {
            [myTask setTaskConditionDevice:self.myAduroTask.taskConditionDevice];
        }
    }else{
        [myTask setTaskConditionDevice:_currentDevice];
    }
    
    if (_currentScene==nil) {
        if (_myAduroTask) {
            [myTask setTaskTriggeredScene:self.myAduroTask.taskTriggeredScene];
        }
    }else{
        [myTask setTaskTriggeredScene:_currentScene];
    }
    [myTask setTaskType:TaskTypeTriggerScene];
    
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
    UIAlertView *saveGroupSuccessAlert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"创建触发任务成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
    [saveGroupSuccessAlert setTag:TAG_SUCCESS_ADD_ACTION_TASK];
    [saveGroupSuccessAlert show];
}

-(void)showCreatFaildAlertView{
    UIAlertView *saveFaildAlert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"Error"] message:[ASLocalizeConfig localizedString:@"Network anomaly"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"OK"] otherButtonTitles:nil, nil];
    [saveFaildAlert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_SUCCESS_ADD_ACTION_TASK) {
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_SCHEDULES_TABLE object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)changeConditionAction:(UISegmentedControl *)segment{
    if (segment.selectedSegmentIndex==0) {
        self.myAduroTask.taskConditionDeviceAction  = 0x01;
        _taskConditionDeviceAction = 0x01  + HEXADECIMAL_DATA_OFFSET;
    }
    if (segment.selectedSegmentIndex==1) {
        self.myAduroTask.taskConditionDeviceAction  = 0x00;
        _taskConditionDeviceAction = 0x00  + HEXADECIMAL_DATA_OFFSET;
    }
}

-(void)switchEnableAction:(UISwitch *)sender{
    [self.myAduroTask setTaskEnable:sender.on];
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
