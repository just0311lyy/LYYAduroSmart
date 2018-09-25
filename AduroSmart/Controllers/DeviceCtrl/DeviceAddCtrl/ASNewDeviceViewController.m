//
//  ASNewDeviceViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/8.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASNewDeviceViewController.h"
#import "ASGlobalDataObject.h"
#import "ASDeviceEditViewController.h"
#import "SDRotationLoopProgressView.h"
#import "ASListCell.h"
#import "ASDeviceManageViewController.h"
#import "ASDataBaseOperation.h"
#import "MBProgressHUD.h"
#import "ASUserDefault.h"
#import <MJRefresh.h>
#import <AduroSmartLib/AduroSmartSDKManager.h>

@interface ASNewDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    
    UITableView *_tableView;
    NSTimer *_stopTimer;
    NSMutableArray *_newFindDeviceArray;
}
@property (nonatomic, strong) UIView *headerView;
@end

@implementation ASNewDeviceViewController
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    //    设置导航栏背景图片为一个空的image，这样就透明了
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *navImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_ADURO_WIDTH, 64)];
    [self.view addSubview:navImgView];
    [navImgView setImage:[UIImage imageNamed:@"nav_bg"]];
    
    self.title = [ASLocalizeConfig localizedString:@"新的"];

    _newFindDeviceArray = [[NSMutableArray alloc] init];
    [self initWithTableView];
    [self initWithNewDevices];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_stopTimer) {
        if ([_stopTimer isValid]) {
            [_stopTimer invalidate];
        }else{
            _stopTimer = nil;
        }
    }
}

//初始化tableView
-(void)initWithTableView{
    //---------
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToSearchViewAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setBackgroundImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
    
    [rightBarBtn addTarget:self action:@selector(backToRootView) forControlEvents:UIControlEventTouchUpInside];
    [rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"完成"] forState:UIControlStateNormal];
    [rightBarBtn setFont:[UIFont systemFontOfSize:16]];
    rightBarBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    //-----------
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height - 64;
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self headerView];
    }
}

- (UIView *)headerView
{
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_WIDTH * 0.6)];

        UILabel *labPromptAddCamera = [UILabel new];
        [_headerView addSubview:labPromptAddCamera];
        [labPromptAddCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_top);
            make.leading.equalTo(_headerView).offset(50);
            make.trailing.equalTo(_headerView).offset(-50);
            make.height.equalTo(@(_headerView.frame.size.height/2.0f));
        }];
        [labPromptAddCamera setFont:[UIFont systemFontOfSize:15]];
        [labPromptAddCamera setText:NSLocalizedString(@"Here you can manage and view your new ZigBee devices.", nil)];
        [labPromptAddCamera setTextAlignment:NSTextAlignmentCenter];
        [labPromptAddCamera setNumberOfLines:0];
        [labPromptAddCamera setTextColor:[UIColor lightGrayColor]];
        [labPromptAddCamera setLineBreakMode:NSLineBreakByWordWrapping];
        
    }
    return  _headerView;
}


-(void)initWithNewDevices{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.labelText = [ASLocalizeConfig localizedString:@"搜索中..."];
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"搜索中..."]];
    if (_stopTimer) {
        if ([_stopTimer isValid]) {
            [_stopTimer invalidate];
        }else{
            _stopTimer = nil;
        }
    }
    _stopTimer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_NEW_DEVICE_TIME target:self selector:@selector(cancelMBProgressHUD) userInfo:nil repeats:NO];
    DeviceManager *deviceManager = [DeviceManager sharedManager];
    [deviceManager findNewDevices:^(AduroDevice *device) {
        //接收到设备要做去重动作，防止网关重发数据时导致显示异常
        BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
        BOOL isNewDevice = YES; //yes 是新设备，NO 不是新设备
        if (device) {
            for (int i = 0; i < [_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    isNewDevice = NO;
                }
            }
            if (isNewDevice) {
//                //对传感器设备进行名称细分
                if (device.deviceTypeID ==  DeviceTypeIDHumanSensor && [device.deviceName isEqualToString:@"CIE Device"]) {
                    if (device.deviceZoneType == DeviceZoneTypeMotionSensor) {
                        [device setDeviceName:@"Motion Sensor"];
                    }else{
                        [device setDeviceName:@"Contact Switch"];
                    }
                }
                [self saveDeviceDataObject:device];  //存储到数据库
//                [device setDeviceNetState:DeviceNetStateOnline];
                [device setIsCache:YES];
                [_globalDeviceArray addObject:device];
            }
            [self getZoneTypeForSensorDevice:device];
            
            if (_newFindDeviceArray == nil) {
                _newFindDeviceArray = [[NSMutableArray alloc] init];
            }
            if (_newFindDeviceArray.count > 0) {
                for (int j=0; j<[_newFindDeviceArray count]; j++) {
                    AduroDevice *mydevice = [_newFindDeviceArray objectAtIndex:j];
                    if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                        noExist = NO; //重复
                    }
                }
                if (noExist) { //不重复
//                    [device setDeviceNetState:DeviceNetStateOnline];
                    [_newFindDeviceArray addObject:device];
                }
            }else{
                [_newFindDeviceArray addObject:device];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshTableView];
                [self stopMBProgressHUD];
            });
            if (_stopTimer) {
                if ([_stopTimer isValid]) {
                    [_stopTimer invalidate];
                }else{
                    _stopTimer = nil;
                }
            }
        }
        
    }];
}

/**
 *  @author xingman.yi, 16-08-16 09:08:42
 *
 *  @brief 读取传感器的ZoneType
 *
 *  @param device 设备
 */
-(void)getZoneTypeForSensorDevice:(AduroDevice *)device{
    //读取传感器类型,如果ZoneType为0xffff或0x00,则读取;
    DeviceManager *deviceManager = [DeviceManager sharedManager];
    if ((device.deviceZoneType == DeviceZoneTypeUnidentified)||(device.deviceZoneType == DeviceZoneTypeStandardCIE)) {
        [deviceManager getDevice:device updateData:^(AduroDevice *device, int updateDataType, uint16_t clusterID, uint16_t attribID,uint32_t attributeValue) {
            DLog(@"读取传感器设备属性1 = device=%@,updateDataTyp=%d,clusterID=%d,attribID=%d",device,updateDataType,clusterID,attribID);
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    [mydevice setDeviceNetState:DeviceNetStateOnline];
                    [mydevice setDeviceZoneType:device.deviceZoneType];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:mydevice];
                    //通知主线程刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadData];
                    });
                }
            }
        } updateType:AduroSmartUpdateDataSensorZoneType];
    }
}

-(void)cancelMBProgressHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopMBProgressHUD];
    });
    if (_newFindDeviceArray.count < 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提醒"] message:[ASLocalizeConfig localizedString:@"未查找到新设备"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"返回"] otherButtonTitles:nil];
        [alert show];
    }    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _newFindDeviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    ASListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    AduroDevice *newDevice = _newFindDeviceArray[indexPath.row];
    cell.txtLabel.text = newDevice.deviceName;
    if (newDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
        if (newDevice.deviceZoneType == DeviceZoneTypeContactSwitch) {
            cell.imgView.image = [UIImage imageNamed:@"sensor_0015"];
            if ([newDevice.deviceName isEqualToString:@"CIE Device"]) {
                cell.txtLabel.text = @"Contact Switch";
            }
        }else if (newDevice.deviceZoneType == DeviceZoneTypeMotionSensor){
            cell.imgView.image = [UIImage imageNamed:@"sensor_0014"];
            if ([newDevice.deviceName isEqualToString:@"CIE Device"]) {
                cell.txtLabel.text = @"Motion Sensor";
            }
        }else{
            cell.imgView.image = [UIImage imageNamed:@"sensor"];
        }
    }else if(newDevice.deviceTypeID == DeviceTypeIDLightingRemotes){
        cell.imgView.image = [UIImage imageNamed:@"light_remotes"];
    }else if(newDevice.deviceTypeID == DeviceTypeIDSmartPlug){
        cell.imgView.image = [UIImage imageNamed:@"smart_plug"];
    }else{
        cell.imgView.image = [UIImage imageNamed:@"light"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.hidesBottomBarWhenPushed = YES;
    ASDeviceEditViewController *editvc = [[ASDeviceEditViewController alloc] init];
    editvc.editDevice = _newFindDeviceArray[indexPath.row];
    [self.navigationController pushViewController:editvc animated:YES];
    self.hidesBottomBarWhenPushed = YES;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASListCell getCellHeight];
}

-(void)backToRootView{
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_GROUP_TABLE object:nil];
//    [self.navigationController popToRootViewControllerAnimated:YES];    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashDeviceList" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshTableView];
}

- (void)refreshTableView
{
    if ([_newFindDeviceArray count] > 0) {
        _tableView.tableHeaderView = nil;
    }
    else
    {
        _tableView.tableHeaderView = [self headerView];
    }
    [_tableView reloadData];
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self backToSearchViewAction];
    }
}

-(void)backToSearchViewAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存设备数据到数据库
-(void)saveDeviceDataObject:(AduroDevice *)deviceDO{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveDeviceData:deviceDO withGatewayid:[ASUserDefault loadGatewayIDCache]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
