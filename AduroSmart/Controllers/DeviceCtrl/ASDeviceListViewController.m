//
//  ASDeviceListViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.


#import "ASDeviceListViewController.h"
#import "ASLocalizeConfig.h"
#import "ASGlobalDataObject.h"
#import "ASDeviceCell.h"
#import "ASSensorDataObject.h"
#import "ASDeviceTypeViewController.h"
#import "ASDeviceDetailViewController.h"
#import "ASSensorDetailViewController.h"
#import "ASDataBaseOperation.h"
#import <MJRefresh.h>
#import "ASGetwayManageViewController.h"
#import "ASUserDefault.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

static SystemSoundID shake_sound_male_id = 0;
@interface ASDeviceListViewController ()<DeviceDelegate,UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *_tableView;

    DeviceManager *_deviceManager;
//    NSMutableArray *_lampArr;
    NSMutableArray *_sensorArr;
    NSArray *_deviceArr;  //数据库中的设备数组
    //添加设备描述
    UIView *_addDescribeView;
    UILabel *_addDescribeLb;
    
    BOOL _isInGetDevices;
    //获取设备属性的对列
    dispatch_queue_t _myQueue;
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@end

@implementation ASDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self initAddDeviceBtn]; //导航栏右按钮

    if (_globalDeviceArray.count<1) {
        [self getAllAduroDevice];
    }

    self.title = [ASLocalizeConfig localizedString:@"所有设备"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllAduroDevice) name:@"reflashDeviceList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashTableView) name:@"reflashTableView" object:nil];
}

-(void)reflashTableView{
    [_tableView reloadData];
}

//初始化tableView
-(void)initTableView{
    
    //设备列表视图
    CGRect frame = self.view.frame;
    frame.origin.y = WJ_HUD_VIEW_HEIGHT;
    frame.size.height = self.view.frame.size.height - 64 - WJ_HUD_VIEW_HEIGHT;
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self headerView];
        _tableView.tableFooterView = [self footerView];
    }
    //下拉刷新 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadAllDevice)];
}

- (UIView *)headerView
{
    CGFloat imgWidth = SCREEN_ADURO_WIDTH - 31*2;
    CGFloat imgHeight = imgWidth * 342 /627 ;
    
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, 80 + imgHeight + 40 + 40 + 45 +44)];
                
        UIImageView *noSceneImgView = [UIImageView new];
        [noSceneImgView setImage:[UIImage imageNamed:@"no_device"]];
        [_headerView addSubview:noSceneImgView];
        [noSceneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_top).offset(80);
            make.centerX.equalTo(_headerView.mas_centerX);
            make.width.equalTo(@(imgWidth));
            make.height.equalTo(@(imgHeight));
        }];
        
        UILabel *labAddDevice = [UILabel new];
        [_headerView addSubview:labAddDevice];
        [labAddDevice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(noSceneImgView.mas_bottom).offset(40);
            make.leading.equalTo(_headerView).offset(70);
            make.trailing.equalTo(_headerView).offset(-70);
            make.height.equalTo(@(40));
        }];
        [labAddDevice setFont:[UIFont systemFontOfSize:12]];
        [labAddDevice setText:NSLocalizedString(@"Press + button at the middle of the screen to add the device to your account.", nil)];
        [labAddDevice setTextAlignment:NSTextAlignmentCenter];
        [labAddDevice setNumberOfLines:0];
//        [labAddDevice setTextColor:UIColorFromRGB(0X878787)];
        [labAddDevice setTextColor:[UIColor lightGrayColor]];
        [labAddDevice setLineBreakMode:NSLineBreakByWordWrapping];
        
        UIButton *nowAddBtn = [UIButton new];
        [nowAddBtn.layer setCornerRadius:22];
        [nowAddBtn setBackgroundColor:LOGO_COLOR];
        [nowAddBtn.layer setBorderWidth:0.5];
        [nowAddBtn.layer setBorderColor:[BUTTON_COLOR CGColor]];
        [_headerView addSubview:nowAddBtn];
        [nowAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(labAddDevice.mas_bottom).offset(45);
            make.leading.equalTo(_headerView).offset(65);
            make.trailing.equalTo(_headerView).offset(-65);
            make.height.equalTo(@(44));
        }];
        [nowAddBtn setFont:[UIFont systemFontOfSize:18]];
        [nowAddBtn setTitle:NSLocalizedString(@"+ Add Devices", nil) forState:UIControlStateNormal];
        [nowAddBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nowAddBtn addTarget:self action:@selector(findNewDeviceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return  _headerView;
}

- (UIView *)footerView
{
    if (_footerView == nil)
    {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, 70)];
        UIImageView *downRefreshImgView = [UIImageView new];
        [downRefreshImgView setImage:[UIImage imageNamed:@"down_refresh"]];
        [_footerView addSubview:downRefreshImgView];
        [downRefreshImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_footerView.mas_top).offset(35);
            make.centerX.equalTo(_footerView.mas_centerX);
            make.width.equalTo(@(295/2));
            make.height.equalTo(@(63/2));
        }];
    }
    return  _footerView;
}

//导航栏右按钮
-(void)initAddDeviceBtn{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
//    //导航栏右按钮
//    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setBackgroundImage:[UIImage imageNamed:@"add_nav"] forState:UIControlStateNormal];
//    [rightBarBtn addTarget:self action:@selector(findNewDeviceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    rightBarBtn.frame = CGRectMake(0, 0, 35, 35);
//    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
//    self.navigationItem.rightBarButtonItem = rightBarItem;
}

-(void)initWithDeviceData{
    AppDelegate *myDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myDelegate.isConnect) {
        [self getAllAduroDevice];
        return;
    }
    
    if (![[ASUserDefault loadGatewayIDCache] isEqualToString:@""] && [ASUserDefault loadGatewayIDCache] != nil) {
        //若存在上次登录成功后缓存的网关id。则先获取附近所有可连接网关
        [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"数据获取中..."]];
        [NSTimer scheduledTimerWithTimeInterval:24 target:self selector:@selector(cancelDMBProgressHUD) userInfo:nil repeats:NO];
        
        GatewayManager *gatewayManager = [GatewayManager sharedManager];
        [gatewayManager searchGateways:^(NSArray *gateways) {
            if (gateways)
            {                
                for (int j = 0; j<[gateways count]; j++) {
                    AduroGateway *oneGateway = [gateways objectAtIndex:j];
                    BOOL isExist = NO;
                    for (int i=0; i<[_globalGetwayArray count]; i++) {
                        AduroGateway *myGateway = [_globalGetwayArray objectAtIndex:i];
                        if ([myGateway.gatewayID isEqualToString:oneGateway.gatewayID]) {
                            isExist = YES;
                        }
                    }
                    if (!isExist) {
                        [_globalGetwayArray addObject:oneGateway];
                    }
                }
                for (int i=0; i<[_globalGetwayArray count]; i++) {
                    AduroGateway *currentGateway = [_globalGetwayArray objectAtIndex:i];
                    if ([currentGateway.gatewayID isEqualToString: [ASUserDefault loadGatewayIDCache]]) {
                        //若附近搜索到的网关存在和上次成功登陆后缓存的网关id一样的，则直接连接
                        GatewayManager *gatewayManager = [GatewayManager sharedManager];
                        //扫描二维码获得SecurityKey
                        NSString *securityKey = @"1234567812345678";
                        [currentGateway setGatewaySecurityKey:securityKey];
                        [gatewayManager connectToGateway:currentGateway completionHandler:^(AduroSmartReturnCode code) {
                            NSLog(@"网关连接结果code = %d",code);
                            if (code == AduroSmartReturnCodeSuccess) {
                                [self getAllAduroDevice];
                                
                            }
//                            else{
//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"网关连接失败"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil];
//                                [alert show];
//                            }
                        }];
                        [gatewayManager updateGatewayDatatime:[NSDate date] completionHandler:^(AduroSmartReturnCode code) {
                            DLog(@"update time = %lu",code);
                        }];
                        return ;
                    }
                    else{ //附近搜索到的网关id没有跟缓存相同的，则推出网关管理界面进行网关切换连接
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self stopMBProgressHUD];
                        });
                        ASGetwayManageViewController *gatewayManVC = [[ASGetwayManageViewController alloc] init];
                        
                        CATransition *animation = [CATransition animation];
                        animation.duration = 0.4;
                        //    animation.timingFunction = UIViewAnimationCurveEaseInOut;
                        animation.type = kCATransitionPush;
                        animation.subtype = kCATransitionFromRight;
                        [self.view.window.layer addAnimation:animation forKey:nil];
                        [self presentModalViewController:gatewayManVC animated:nil];
                        
//                        [self presentViewController:gatewayManVC animated:nil completion:nil];
                    }
                }
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"请确保10米范围内有已经建立连接的网关,然后重试"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else{
        ASGetwayManageViewController *gatewayManVC = [[ASGetwayManageViewController alloc] init];
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.4;
        //    animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromRight;
        [self.view.window.layer addAnimation:animation forKey:nil];
        [self presentModalViewController:gatewayManVC animated:nil];
    }
}

-(void)getAllAduroDevice{
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _myQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    _deviceManager = [DeviceManager sharedManager];
    [_deviceManager getAllDevices:^(AduroDevice *device) {
        if (device) {
            BOOL isExist = NO;
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    isExist = YES;
//                    [device setDeviceNetState:DeviceNetStateOnline];
                    [device setIsCache:YES];  //从网关得到设备
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:device];
                    [self changeDeviceName:device.deviceName withID:device.deviceID];
                }
            }
            if (!isExist) {
                [self saveDeviceData:device];  //存储到数据库
//                [device setDeviceNetState:DeviceNetStateOnline];
                [device setIsCache:YES]; //从网关得到设备
                [_globalDeviceArray addObject:device];
            }
            [device.deviceClusterIdSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
//                DLog(@"cluster set 表示设备支持的功能 %x",[obj integerValue]);
            }];
        }
        //对传感器设备进行名称细分
        if (_globalDeviceArray.count>0) {
            for (int j = 0; j<_globalDeviceArray.count; j++) {
                AduroDevice *oneDevice = [_globalDeviceArray objectAtIndex:j];
                if (oneDevice.deviceTypeID ==  DeviceTypeIDHumanSensor && [oneDevice.deviceName isEqualToString:@"CIE Device"]) {
                    //当传感器的名称是CIE Device时。修改全局存储名称
                    if (oneDevice.deviceZoneType == DeviceZoneTypeMotionSensor) {
                        [oneDevice setDeviceName:@"Motion Sensor"];
                    }else if(oneDevice.deviceZoneType == DeviceZoneTypeContactSwitch){
                        [oneDevice setDeviceName:@"Contact Switch"];
                    }
                }
            }
        }
        
        [self refreshTableView];
        [self cancelRefreshDecviceTable];
        
        if (device.deviceTypeID == DeviceTypeIDHumanSensor) {
            //读取传感器类型
            [self getZoneTypeForSensorDevice:device];
        }else{
            [self readDeviceAttribute:device];
        }
    }];

    /*
    [_deviceManager sensorDataUpload:^(NSString *deviceID, uint16_t shortAddr, uint16_t sensorData, uint8_t zoneID, uint16_t clusterID,Byte sensorDataByte[],int aCFrequency,float rMSVoltage,float rMSCurrent,float activePower,float powerFactor) {
        //sensorData要按位解析，根据设备的ClusterID和ZoneType来解析sensorData；
        if (clusterID != ZCL_CLUSTER_ID_SS_IAS_ZONE) {
            DLog(@"sensorData Alarm1 Bit0 根据设备的ClusterID和ZoneType去判断此位代表什么含义，比如判断设备为门磁，则1=开门,0=关门,更多见传感器数据按位解析表 = %d",sensorDataByte[0]);
            DLog(@"deviceID = %@, shortAddr = %x, sensorData = %x, zoneID = %x, clusterID = %x",deviceID,shortAddr,sensorData,zoneID,clusterID);
        }
        //获取当前传感器触发的时间
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        DLog(@"dateString:%@",dateString);
        
        AduroDevice *myDevice = nil;
        for (int i=0; i<[_globalDeviceArray count]; i++) {
            AduroDevice *device = [_globalDeviceArray objectAtIndex:i];
            if (device.shortAdr == shortAddr) {
                myDevice = device;
            }
            if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
            }else if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
                [self playAlarmAudio];
            }else if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeVibrationMovementSensor)) { //震动传感器
                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
            }else if (clusterID == ZCL_CLUSTER_ID_HA_ELECTRICAL_MEASUREMENT){
                NSLog(@"aCFrequency=%d,float rMSVoltage=%lf,float rMSCurrent=%lf,float activePower=%lf,float powerFactor=%lf",aCFrequency,rMSVoltage,rMSCurrent,activePower,powerFactor);
                myDevice.electmeasVolatage = rMSVoltage;
                myDevice.electmeasCurrent = rMSCurrent;
                myDevice.electmeasPower = activePower;
                myDevice.electmeasFrequency = aCFrequency;
                myDevice.electmeasPowerFactor = powerFactor;
            }else{
                myDevice.deviceSensorData = 0;
            }
            if (clusterID != ZCL_CLUSTER_ID_GEN_POWER_CFG) {
                [_tableView reloadData];
            }            
        }
        
        NSLog(@"aCFrequency=%d,float rMSVoltage=%lf,float rMSCurrent=%lf,float activePower=%lf,float powerFactor=%lf",aCFrequency,rMSVoltage,rMSCurrent,activePower,powerFactor);
        
        NSString *showStr = @"";
        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
//            myDevice.deviceSensorData = sensorData +1;
            if (sensorDataByte[0]==0) {
                showStr = [ASLocalizeConfig localizedString:@"关门"];
            }
            if (sensorDataByte[0]==1) {
                showStr = [ASLocalizeConfig localizedString:@"开门"];
            }
        }
        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
//            myDevice.deviceSensorData = sensorData + 1;
            if (sensorDataByte[0]==0) {  //未触发不作处理
//                showStr = [ASLocalizeConfig localizedString:@"无人经过"];
            }
            if (sensorDataByte[0]==1) {
                showStr = [ASLocalizeConfig localizedString:@"有人经过"];
            }
        }
        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeVibrationMovementSensor)) { //震动传感器
//            myDevice.deviceSensorData = sensorData + 1;
            if (sensorDataByte[0]==0) {
                //没触发则不作处理
            }
            if (sensorDataByte[0]==1) {
                showStr = [ASLocalizeConfig localizedString:@"有人经过"];
            }
        }
        
        DLog(@"sensorData Alarm2 Bit1 = %d",sensorDataByte[1]);
        DLog(@"sensorData Tamper Bit2 = %d",sensorDataByte[2]);
        DLog(@"sensorData Battery Bit3 = %d",sensorDataByte[3]);
        DLog(@"sensorData Supervision reports Bit4 = %d",sensorDataByte[4]);
        DLog(@"sensorData Restore reports Bit5 = %d",sensorDataByte[5]);
        DLog(@"sensorData Trouble Bit6 = %d",sensorDataByte[6]);
        DLog(@"sensorData AC Bit 7 = %d",sensorDataByte[7]);
        
        //电量消息
//        if (clusterID == ZCL_CLUSTER_ID_GEN_POWER_CFG) {
//            NSString *showPower = [[NSString alloc]initWithFormat:@"设备 %x 电池电量 %d ",myDevice.shortAdr,sensorData];
//        }
        
        //将数据存储到传感器model
        ASSensorDataObject *sensorDO = [[ASSensorDataObject alloc]init];
        sensorDO.sensorID = myDevice.deviceID;
        sensorDO.sensorData = showStr;
        sensorDO.sensorDataTime = dateString;
        sensorDO.sensorPower = sensorData;
        [self saveSensorDataObject:sensorDO];

        if (clusterID != ZCL_CLUSTER_ID_GEN_POWER_CFG) {
            [self getZoneTypeForSensorDevice:myDevice];
        }
    
    }];
     */

    //接收设备状态反馈
    [_deviceManager deviceStateDataUpload:^(NSDictionary *deviceStateDict) {
        NSLog(@"%@",deviceStateDict);
        NSNumber *numShortAddr = [deviceStateDict objectForKey:@"shortAddr"];
        int shortAddr = [numShortAddr intValue];
        NSNumber *numStatusCode = [deviceStateDict objectForKey:@"statusCode"];
        int statusCode = [numStatusCode intValue];
        for (int i=0; i<[_globalDeviceArray count]; i++) {
            AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:i];
            
            if (myDevice.shortAdr == shortAddr) {
                //设置为在线
                [myDevice setDeviceNetState:DeviceNetStateOnline];
                //设置开关状态
                if (statusCode == 1 || statusCode == 0) {
                    [myDevice setDeviceSwitchState:statusCode];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:myDevice];
//                    [self changeDeviceSwitch:statusCode withID:myDevice.deviceID];
//                    //通知主线程刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_tableView ) {
                            [_tableView reloadData];
                        }
                    });
                }
            }
        }
    }];
}

-(void)readSensorAttribute{
    [_deviceManager sensorDataUpload:^(NSString *deviceID, uint16_t shortAddr, uint16_t sensorData, uint8_t zoneID, uint16_t clusterID,Byte sensorDataByte[],int aCFrequency,float rMSVoltage,float rMSCurrent,float activePower,float powerFactor) {
        //sensorData要按位解析，根据设备的ClusterID和ZoneType来解析sensorData；
        if (clusterID != ZCL_CLUSTER_ID_SS_IAS_ZONE) {
            DLog(@"sensorData Alarm1 Bit0 根据设备的ClusterID和ZoneType去判断此位代表什么含义，比如判断设备为门磁，则1=开门,0=关门,更多见传感器数据按位解析表 = %d",sensorDataByte[0]);
            DLog(@"deviceID = %@, shortAddr = %x, sensorData = %x, zoneID = %x, clusterID = %x",deviceID,shortAddr,sensorData,zoneID,clusterID);
        }
        //获取当前传感器触发的时间
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        DLog(@"dateString:%@",dateString);
        
        AduroDevice *myDevice = nil;
        for (int i=0; i<[_globalDeviceArray count]; i++) {
            AduroDevice *device = [_globalDeviceArray objectAtIndex:i];
            if (device.shortAdr == shortAddr) {
                myDevice = device;
            }
            if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
            }else if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
                [self playAlarmAudio];
            }else if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeVibrationMovementSensor)) { //震动传感器
                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
            }else if (clusterID == ZCL_CLUSTER_ID_HA_ELECTRICAL_MEASUREMENT){
                NSLog(@"aCFrequency=%d,float rMSVoltage=%lf,float rMSCurrent=%lf,float activePower=%lf,float powerFactor=%lf",aCFrequency,rMSVoltage,rMSCurrent,activePower,powerFactor);
                myDevice.electmeasVolatage = rMSVoltage;
                myDevice.electmeasCurrent = rMSCurrent;
                myDevice.electmeasPower = activePower;
                myDevice.electmeasFrequency = aCFrequency;
                myDevice.electmeasPowerFactor = powerFactor;
            }else{
                myDevice.deviceSensorData = 0;
            }
            if (clusterID != ZCL_CLUSTER_ID_GEN_POWER_CFG) {
                [_tableView reloadData];
            }
        }
        
        DLog(@"aCFrequency=%d,float rMSVoltage=%lf,float rMSCurrent=%lf,float activePower=%lf,float powerFactor=%lf",aCFrequency,rMSVoltage,rMSCurrent,activePower,powerFactor);
        
        NSString *showStr = @"";
        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
            //            myDevice.deviceSensorData = sensorData +1;
            if (sensorDataByte[0]==0) {
                showStr = [ASLocalizeConfig localizedString:@"关门"];
            }
            if (sensorDataByte[0]==1) {
                showStr = [ASLocalizeConfig localizedString:@"开门"];
            }
        }
        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
            //            myDevice.deviceSensorData = sensorData + 1;
            if (sensorDataByte[0]==0) {  //未触发不作处理
                //                showStr = [ASLocalizeConfig localizedString:@"无人经过"];
            }
            if (sensorDataByte[0]==1) {
                showStr = [ASLocalizeConfig localizedString:@"有人经过"];
            }
        }
        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeVibrationMovementSensor)) { //震动传感器
            //            myDevice.deviceSensorData = sensorData + 1;
            if (sensorDataByte[0]==0) {
                //没触发则不作处理
            }
            if (sensorDataByte[0]==1) {
                showStr = [ASLocalizeConfig localizedString:@"有人经过"];
            }
        }
        
        DLog(@"sensorData Alarm2 Bit1 = %d",sensorDataByte[1]);
        DLog(@"sensorData Tamper Bit2 = %d",sensorDataByte[2]);
        DLog(@"sensorData Battery Bit3 = %d",sensorDataByte[3]);
        DLog(@"sensorData Supervision reports Bit4 = %d",sensorDataByte[4]);
        DLog(@"sensorData Restore reports Bit5 = %d",sensorDataByte[5]);
        DLog(@"sensorData Trouble Bit6 = %d",sensorDataByte[6]);
        DLog(@"sensorData AC Bit 7 = %d",sensorDataByte[7]);
        
        //电量消息
        //        if (clusterID == ZCL_CLUSTER_ID_GEN_POWER_CFG) {
        //            NSString *showPower = [[NSString alloc]initWithFormat:@"设备 %x 电池电量 %d ",myDevice.shortAdr,sensorData];
        //        }
        
        //将数据存储到传感器model
        ASSensorDataObject *sensorDO = [[ASSensorDataObject alloc]init];
        sensorDO.sensorID = myDevice.deviceID;
        sensorDO.sensorData = showStr;
        sensorDO.sensorDataTime = dateString;
        sensorDO.sensorPower = sensorData;
        [self saveSensorDataObject:sensorDO];
        
        if (clusterID != ZCL_CLUSTER_ID_GEN_POWER_CFG) {
            [self getZoneTypeForSensorDevice:myDevice];
        }
        
    }];
}

/**
 *  @author xingman.yi, 16-09-14 14:09:20
 *
 *  @brief 使用队列来读取设备属性,每次读取前延时0.3S
 *
 *  @param device 要读取的设备
 */
-(void)readDeviceAttribute:(AduroDevice *)device{
    
    dispatch_async(_myQueue, ^{
        [NSThread sleepForTimeInterval:0.8f];
        //读取开关状态
        [_deviceManager getDevice:device updateData:^(AduroDevice *device, int updateDataType, uint16_t clusterID, uint16_t attribID,uint32_t attributeValue) {
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    [mydevice setDeviceNetState:DeviceNetStateOnline];
                    [mydevice setDeviceSwitchState:device.deviceSwitchState];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:mydevice];
                    [self changeDeviceSwitch:device.deviceSwitchState withID:device.deviceID];
                    //通知主线程刷新
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (_tableView != nil) {
//                            [_tableView reloadData];
//                        }
//                    });
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashTableView" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allGroupListReloadData" object:nil];
                }
            }
        } updateType:AduroSmartUpdateDataTypeSwitch];
    });
    
    dispatch_async(_myQueue, ^{
        [NSThread sleepForTimeInterval:0.8f];
        //读取设备亮度
        [_deviceManager getDevice:device updateData:^(AduroDevice *device, int updateDataType, uint16_t clusterID, uint16_t attribID,uint32_t attributeValue) {
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    [mydevice setDeviceNetState:DeviceNetStateOnline];
                    [mydevice setDeviceLightLevel:device.deviceLightLevel];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:mydevice];
                    [self changeDeviceLight:device.deviceLightLevel withID:device.deviceID];
                    //通知主线程刷新
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (_tableView != nil) {
//                            [_tableView reloadData];
//                        }
//                    });
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashTableView" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allGroupListReloadData" object:nil];
                }
            }
        } updateType:AduroSmartUpdateDataTypeLightLevel];
    });
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

- (NSString *) turn10to2:(uint16_t)sensorData{
    uint16_t num = sensorData;
    
    NSMutableString * result = [[NSMutableString alloc]init];
    while (num > 0) {
        NSString * reminder = [NSString stringWithFormat:@"%d",num % 2];
        [result insertString:reminder atIndex:0];
        num = num / 2;
    }
    return result;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_globalDeviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    ASDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }

    AduroDevice *aduroLamp = _globalDeviceArray[indexPath.row];
    [cell setAduroDeviceInfo:nil];
    [cell setAduroDeviceInfo:aduroLamp];

    return cell;

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AduroDevice *device = [_globalDeviceArray objectAtIndex:indexPath.row];
    CGFloat offset = 0;
    switch (device.deviceTypeID)
    {
        case 0x0105://可调颜色灯,有调光、开关功能
        case 0x0102://彩灯
        case 0x0210://飞利浦彩灯
        case 0x0200:
        case 0x0110://色温灯
        case 0x0220:
        case 0x0101://调光灯
        case 0x0100://强制改开关为灯泡
        {
            offset = 40;
        }
            break;
        case DeviceTypeIDSmartPlug:
        {
            offset = 80;
        }
            break;        
    }
    return [ASDeviceCell getCellHeight] + offset;
}

#pragma mark - buttonAction
-(void)findNewDeviceBtnAction:(UIButton *)sender{

    self.hidesBottomBarWhenPushed = YES;
    ASDeviceTypeViewController *typeVC = [[ASDeviceTypeViewController alloc] init];
    
    [self.navigationController pushViewController:typeVC animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark 设备列表里开关按钮触发的回调事件
-(BOOL)deviceSwitch:(BOOL)isOn aduroInfo:(AduroDevice *)aduroInfo{
    NSLog(@"%d",isOn);
    isOn = !isOn;
    uint8_t onOff = 0;
    onOff = isOn ? 1 : 0;
    aduroInfo.deviceSwitchState = onOff;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DeviceManager *device = [DeviceManager sharedManager];
        if (aduroInfo.shortAdr == 0xff) {  //控制所有开关设备的开关状态
            [device updateAllDeviceSwitchState:isOn completionHandler:^(AduroSmartReturnCode code) {
                
            }];
        }else{ //控制单个设备的开关
            
            [device updateDeviceState:aduroInfo completionHandler:^(AduroSmartReturnCode code) {
                NSLog(@"开关返回值 = %d",(int)code);
            }];
        }

    });
    return isOn;
}

-(void)deviceShowDetailWithAduroInfo:(AduroDevice *)aduroDevice{
    
    NSLog(@"aduroDevice.deviceID = %@",aduroDevice.deviceID);
    if (aduroDevice.deviceID == nil) {
        return;
    }
    
    if (aduroDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
        //传感器
        ASSensorDetailViewController *sensorDetailvc = [[ASSensorDetailViewController alloc] init];
        [sensorDetailvc setAduroSensorInfo:aduroDevice];
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:sensorDetailvc animated:NO];
        [self setHidesBottomBarWhenPushed:YES];
       
    }else{
        switch (aduroDevice.deviceTypeID)
        {
            case 0x0105://可调颜色灯,有调光、开关功能
            case 0x0102://彩灯
            case 0x0210://飞利浦彩灯
            case 0x0110://色温灯
            case 0x0220:
            case 0x0101://调光灯
            case 0x0200://彩灯
            {
                ASDeviceDetailViewController *detailvc = [[ASDeviceDetailViewController alloc]init];
                [detailvc setAduroDeviceInfo:aduroDevice];
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:detailvc animated:NO];
                [self setHidesBottomBarWhenPushed:YES];
            }
                break;
        }
    }
}

#pragma mark - 保存传感器数据到数据库
-(void)saveSensorDataObject:(ASSensorDataObject *)sensorDO{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveSensorData:sensorDO];
    
}

#pragma mark - 保存设备到数据库
-(void)saveDeviceData:(AduroDevice *)data{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveDeviceData:data withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//从数据库中获取设备对象数组
-(NSArray *)getDeviceDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectDeviceDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}

//更新设备名称到数据库
-(void)changeDeviceName:(NSString *)name withID:(NSString *)deviceId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateDeviceNameData:name WithID:deviceId];
}
//更新设备亮度到数据库
-(void)changeDeviceLight:(NSInteger)light withID:(NSString *)deviceId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateDeviceLightLevelData:light WithID:deviceId];
}
//更新设备开关状态到数据库
-(void)changeDeviceSwitch:(NSInteger)onOff withID:(NSString *)deviceId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateDeviceSwitchData:onOff WithID:deviceId];
}
/**
 *  @author xingman.yi, 16-01-14 13:01:07
 *
 *  @brief 取消设备列表刷新
 */
-(void)cancelRefreshDecviceTable{
    [_tableView.mj_header endRefreshing];
}

-(void)cancelDMBProgressHUD{
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopMBProgressHUD];
    });
}

-(void)tableRefreshLoadAllDevice{
    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(cancelRefreshDecviceTable) userInfo:nil repeats:NO];
    /* 缓存 */
    [_globalDeviceArray removeAllObjects];
    NSArray *deviceArr = [self getDeviceDataObject];
    [_globalDeviceArray addObjectsFromArray:deviceArr];
    [_tableView reloadData];
    [self getAllAduroDevice];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_globalDeviceArray.count) {
        for (int i = 0; i<_globalDeviceArray.count; i++) {
            AduroDevice *device = _globalDeviceArray[i];
            device.deviceSensorData=0;
        }
    }
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshTableView];
}

- (void)refreshTableView
{
    if ([_globalDeviceArray count] > 0) {
        _tableView.tableHeaderView = nil;
    }
    else
    {
        _tableView.tableHeaderView = [self headerView];
    }
    [_tableView reloadData];
}

-(void)playAlarmAudio{
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"mp3"]] error:nil];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"mp3"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
    
    AudioServicesPlaySystemSound(shake_sound_male_id);
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
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
