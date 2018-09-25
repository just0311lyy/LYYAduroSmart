//
//  ASHomeDetailViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/23.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASHomeDetailViewController.h"
#import "ASGlobalDataObject.h"
#import "ASRoomTypeView.h"
#import "ASDeviceCell.h"
#import "ASSceneCell.h"
#import "ASDeviceDetailViewController.h"
#import "ASSensorDetailViewController.h"
#import "ASAddHomeSceneViewController.h"
#import "UIButton+WGBCustom.h"
#import "ASDataBaseOperation.h"
#import "ASUserDefault.h"
#import <MJRefresh.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
static SystemSoundID shake_sound_male_id = 0;
#define ADD_NEW_DEVICE_TO_HOME  1111
#define TAG_SCENES 10000
#define TAG_DEVICES 10001
@interface ASHomeDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,DeviceDelegate,ASSceneDelegate>{
    
    UITableView *_tableView;  //当前房间里面的设备列表
    NSMutableArray *_homeDeviceArray; //当前房间里面的设备数组
    UITableView *_sceneTableView;  //当前房间里的场景列表
    NSMutableArray *_scenesArray; //当前房间里面的场景数组
    
    GroupManager *_groupManager;
    UIView *_deviceView;
    UIView *_sceneView;
    //模块切换
    UIButton *_deviceBtn;
    UIButton *_sceneBtn;
    //获取设备属性的对列
    dispatch_queue_t _myQueue;
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;

@end

@implementation ASHomeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *array = [_detailGroup.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
    self.title = [array firstObject];
    if (_homeDeviceArray==nil) {
        _homeDeviceArray = [[NSMutableArray alloc] init];
    }
    if (_scenesArray==nil) {
        _scenesArray = [[NSMutableArray alloc] init];
    }
    [self initWithHomeDetail];
    
    /* 缓存 */
    for (int j=0; j<_globalDeviceArray.count; j++) {
        AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
        for (NSString *myID in _detailGroup.groupSubDeviceIDArray) {
//                int result = [myDevice.deviceID compare:myID options:NSCaseInsensitiveSearch | NSNumericSearch];
//                if (result == NSOrderedSame) {
//                    [_homeDeviceArray addObject:myDevice];
//                }
            if ([[myDevice.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                [_homeDeviceArray addObject:myDevice];
            }
        }
    }
    
//    NSArray *sceneArr = [self getSceneDataObject];  //数据库存储的场景
//    if (sceneArr.count>0) {
//        BOOL isRep = YES;
//        for (int k = 0; k<sceneArr.count; k++) {
//            AduroScene *scene = [sceneArr objectAtIndex:k];
//            for (int j = 0; j<_globalSceneArray.count; j++) {
//                AduroScene *globalScene = [_globalSceneArray objectAtIndex:j];
//                if (scene.sceneID == globalScene.sceneID) {
//                    isRep = NO;
//                }
//            }
//            if (isRep) {
//                [_globalSceneArray addObject:scene];
//            }
//        }
//    }
    
    for (int i=0; i<_globalSceneArray.count; i++) {
        AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
        if (myScene.groupID == _detailGroup.groupID) {
            BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
            for (int k=0; k<_scenesArray.count; k++) {
                AduroScene *theScene = [_scenesArray objectAtIndex:k];
                if (theScene.sceneID == myScene.sceneID) {
                    noExist = NO;
                }
            }
            if (noExist) {
                [_scenesArray addObject:myScene];
            }
        }
    }
    
    [self getDeviceOfHomeArray];
       
    [self getScenesOfHomeArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableRefreshLoadScenes) name:NOTI_REFRESH_SENCES_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashDeviceTableView) name:@"reflashTableView" object:nil];
}

-(void)reflashDeviceTableView{
    [_tableView reloadData];
}

-(void)initWithHomeDetail{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    //设备或场景切换
    _deviceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_deviceBtn.layer setMasksToBounds:YES];
    [_deviceBtn.layer setCornerRadius:5.0];
    [_deviceBtn setTitle:[ASLocalizeConfig localizedString:@"设备"] forState:UIControlStateNormal];
    [_deviceBtn setTitleColor:LOGO_COLOR forState:UIControlStateNormal];
    [_deviceBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_deviceBtn setImage:[UIImage imageNamed:@"devices_selected"] forState:UIControlStateNormal];
    [_deviceBtn setTintColor:LOGO_COLOR];
    [_deviceBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_deviceBtn addTarget:self action:@selector(deivceListOfRoomView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deviceBtn];
    [_deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-5);
        make.leading.equalTo(self.view).offset(30);
        make.height.equalTo(@(44));
        make.width.equalTo(@((SCREEN_ADURO_WIDTH - 80)/2.0));
    }];
    [_deviceBtn titleBelowTheImageWithSpace:0];
    //
    _sceneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_sceneBtn.layer setMasksToBounds:YES];
    [_sceneBtn.layer setCornerRadius:5.0];
    [_sceneBtn setTitle:[ASLocalizeConfig localizedString:@"场景"] forState:UIControlStateNormal];
    [_sceneBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_sceneBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_sceneBtn setImage:[UIImage imageNamed:@"scene"] forState:UIControlStateNormal];
    [_sceneBtn setTintColor:[UIColor lightGrayColor]];
    [_sceneBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_sceneBtn addTarget:self action:@selector(sceneListOfRoomView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sceneBtn];
    [_sceneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_deviceBtn.mas_bottom);
        make.trailing.equalTo(self.view).offset(-30);
        make.height.equalTo(_deviceBtn.mas_height);
        make.width.equalTo(_deviceBtn.mas_width);
    }];
    [_sceneBtn titleBelowTheImageWithSpace:0];
    
    UIView *lintView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_ADURO_HEIGHT - 64 - 50, SCREEN_ADURO_WIDTH, 1)];
    [lintView setBackgroundColor:CELL_LIEN_COLOR];
    [self.view addSubview:lintView];    //设备列表
    _deviceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - 64 - 54)];
    [self.view addSubview:_deviceView];
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, WJ_HUD_VIEW_HEIGHT, _deviceView.frame.size.width, _deviceView.frame.size.height - WJ_HUD_VIEW_HEIGHT) style:UITableViewStylePlain];
        [_tableView setTag:TAG_DEVICES];
        [_deviceView addSubview:_tableView];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    //场景列表
    _sceneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - 64 - 54)];
    [self.view addSubview:_sceneView];
    [_sceneView setHidden:YES];
    
    if (!_sceneTableView) {
        _sceneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, WJ_HUD_VIEW_HEIGHT, _sceneView.frame.size.width, _sceneView.frame.size.height - WJ_HUD_VIEW_HEIGHT) style:UITableViewStylePlain];
        [_sceneTableView setTag:TAG_SCENES];
        [_sceneView addSubview:_sceneTableView];
        [_sceneTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _sceneTableView.delegate = self;
        _sceneTableView.dataSource = self;
        _sceneTableView.tableHeaderView = [self headerView];
        _sceneTableView.tableFooterView = [self footerView];
    }
    
    //下拉刷新 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    _sceneTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadScenes)];
    
    //场景右下角悬浮创建新场景
    UIButton *addSceneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sceneView addSubview:addSceneBtn];
    [addSceneBtn setBackgroundImage:[UIImage imageNamed:@"button_fab_add"] forState:UIControlStateNormal];
    [addSceneBtn addTarget:self action:@selector(newSceneToHomeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [addSceneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_tableView.mas_trailing).offset(-20);
        make.bottom.equalTo(_tableView.mas_bottom).offset(-20);
        make.width.equalTo(@(50));
        make.height.equalTo(@(50));
    }];
}

- (UIView *)headerView
{
    CGFloat imgWidth = SCREEN_ADURO_WIDTH - 80*2;
    CGFloat imgHeight = imgWidth * 391 /467 ;
    
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, 80 + imgHeight + 60 + 44)];
        
        
//        UILabel *labPromptAddCamera = [UILabel new];
//        [_headerView addSubview:labPromptAddCamera];
//        [labPromptAddCamera mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_headerView.mas_top);
//            make.leading.equalTo(_headerView).offset(35);
//            make.trailing.equalTo(_headerView).offset(-35);
//            make.height.equalTo(@(_headerView.frame.size.height/2.0f));
//        }];
//        
//        [labPromptAddCamera setFont:[UIFont systemFontOfSize:15]];
//        [labPromptAddCamera setText:NSLocalizedString(@"Here you can setup scenes, scenes contain a sequence of actions ( e.g. turning a light on) so you can control multiple devices at once.\nPress + button at the top of the screen to add a scene.", nil)];
//        [labPromptAddCamera setTextAlignment:NSTextAlignmentCenter];
//        [labPromptAddCamera setNumberOfLines:0];
//        [labPromptAddCamera setTextColor:[UIColor lightGrayColor]];
//        [labPromptAddCamera setLineBreakMode:NSLineBreakByWordWrapping];
                
        UIImageView *noSceneImgView = [UIImageView new];
        [noSceneImgView setImage:[UIImage imageNamed:@"no_scene"]];
        [_headerView addSubview:noSceneImgView];
        [noSceneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_top).offset(80);
            make.centerX.equalTo(_headerView.mas_centerX);
            make.width.equalTo(@(imgWidth));
            make.height.equalTo(@(imgHeight));
        }];
        
        UIButton *nowAddBtn = [UIButton new];
        [nowAddBtn.layer setCornerRadius:22];
        [nowAddBtn setBackgroundColor:LOGO_COLOR];
        [nowAddBtn.layer setBorderWidth:0.5];
        [nowAddBtn.layer setBorderColor:[BUTTON_COLOR CGColor]];
        [_headerView addSubview:nowAddBtn];
        [nowAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(noSceneImgView.mas_bottom).offset(60);
            make.leading.trailing.equalTo(noSceneImgView);
            make.height.equalTo(@(44));
        }];
        [nowAddBtn setTitle:NSLocalizedString(@"+ Add Scenes", nil) forState:UIControlStateNormal];
        [nowAddBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nowAddBtn addTarget:self action:@selector(newSceneToHomeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
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

//        UILabel *labPromptAddCamera = [UILabel new];
//        [_footerView addSubview:labPromptAddCamera];
//        [labPromptAddCamera mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_footerView.mas_top);
//            make.leading.equalTo(_footerView).offset(50);
//            make.trailing.equalTo(_footerView).offset(-50);
//            make.height.equalTo(@(_footerView.frame.size.height/2.0f));
//        }];
//        [labPromptAddCamera setFont:[UIFont systemFontOfSize:15]];
//        [labPromptAddCamera setText:NSLocalizedString(@"Pull down to refresh", nil)];
//        [labPromptAddCamera setTextAlignment:NSTextAlignmentCenter];
//        [labPromptAddCamera setNumberOfLines:0];
//        [labPromptAddCamera setTextColor:[UIColor lightGrayColor]];
//        [labPromptAddCamera setLineBreakMode:NSLineBreakByWordWrapping];
    }
    return  _footerView;
}


-(void)getDeviceOfHomeArray{
    /* 缓存 */
    
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _myQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    GroupManager *groupManager = [GroupManager sharedManager];
    [groupManager getDevicesOfGroup:_detailGroup devices:^(NSArray *devices) {
        if (devices.count>0) {            //对传感器设备进行名称细分
//            if (_homeDeviceArray.count>0) {
//                for (int j = 0; j<_homeDeviceArray.count; j++) {
//                    AduroDevice *oneDevice = [_homeDeviceArray objectAtIndex:j];
//                    if (oneDevice.deviceTypeID ==  DeviceTypeIDHumanSensor && [oneDevice.deviceName isEqualToString:@"CIE Device"]) {
//                        //当传感器的名称是CIE Device时。修改全局存储名称
//                        if (oneDevice.deviceZoneType == DeviceZoneTypeMotionSensor) {
//                            [oneDevice setDeviceName:@"Motion Sensor"];
//                        }else if(oneDevice.deviceZoneType == DeviceZoneTypeContactSwitch){
//                            [oneDevice setDeviceName:@"Contact Switch"];
//                        }
//                    }
//                }
//            }
            BOOL isExist = NO;
            for (AduroDevice *myDevice in devices) {
                for (int k=0; k<_homeDeviceArray.count; k++) {
                    AduroDevice *oneDevice = [_homeDeviceArray objectAtIndex:k];
                    if ([myDevice.deviceID isEqualToString:oneDevice.deviceID]) {
                        isExist = YES;
                        [myDevice setDeviceNetState:DeviceNetStateOnline];
                        [_homeDeviceArray replaceObjectAtIndex:k withObject:myDevice];
                    }
                }
                if (!isExist) {
                    [myDevice setDeviceNetState:DeviceNetStateOnline];
                    [_homeDeviceArray addObject:myDevice];
                }
            }

            [_tableView reloadData];
            
            for (int i=0; i<_homeDeviceArray.count; i++) {
                AduroDevice *myDevice = [_homeDeviceArray objectAtIndex:i];
                if (myDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
                    //读取传感器类型
                    [self getZoneTypeForSensorDevice:myDevice];
                }else{
                    [self readDeviceAttribute:myDevice];
                }
            }
        }
    }];

//    DeviceManager *deviceManager = [DeviceManager sharedManager];
//    [deviceManager sensorDataUpload:^(NSString *deviceID, uint16_t shortAddr, uint16_t sensorData, uint8_t zoneID, uint16_t clusterID,Byte sensorDataByte[],int aCFrequency,float rMSVoltage,float rMSCurrent,float activePower,float powerFactor){
//        //sensorData要按位解析，根据设备的ClusterID和ZoneType来解析sensorData；
//        if (clusterID != ZCL_CLUSTER_ID_SS_IAS_ZONE) {
//            DLog(@"sensorData Alarm1 Bit0 根据设备的ClusterID和ZoneType去判断此位代表什么含义，比如判断设备为门磁，则1=开门,0=关门,更多见传感器数据按位解析表 = %d",sensorDataByte[0]);
//            DLog(@"deviceID = %@, shortAddr = %x, sensorData = %x, zoneID = %x, clusterID = %x",deviceID,shortAddr,sensorData,zoneID,clusterID);
//        }
//        //获取当前传感器触发的时间
//        NSDate *currentDate = [NSDate date];//获取当前时间，日期
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss"];
//        NSString *dateString = [dateFormatter stringFromDate:currentDate];
//        DLog(@"dateString:%@",dateString);
//        
//        AduroDevice *myDevice = nil;
//        for (int i=0; i<[_homeDeviceArray count]; i++) {
//            AduroDevice *device = [_homeDeviceArray objectAtIndex:i];
//            if (device.shortAdr == shortAddr) {
//                myDevice = device;
//            }
//            if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
//                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
//            }else if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
//                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
//                [self playAlarmAudio];
//            }else if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeVibrationMovementSensor)) { //震动传感器
//                myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
//            }else if(clusterID == ZCL_CLUSTER_ID_HA_ELECTRICAL_MEASUREMENT) {
//                myDevice.electmeasVolatage = rMSVoltage;
//                myDevice.electmeasCurrent = rMSCurrent;
//                myDevice.electmeasPower = activePower;
//                myDevice.electmeasFrequency = aCFrequency;
//                myDevice.electmeasPowerFactor = powerFactor;
//            }else{
//                myDevice.deviceSensorData = 0;
//            }
//            [_tableView reloadData];
//        }
//        NSString *showStr = @"";
//        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
//            //            myDevice.deviceSensorData = sensorData +1;
//            if (sensorDataByte[0]==0) {
//                showStr = [ASLocalizeConfig localizedString:@"关门"];
//            }
//            if (sensorDataByte[0]==1) {
//                showStr = [ASLocalizeConfig localizedString:@"开门"];
//            }
//        }
//        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
//            //            myDevice.deviceSensorData = sensorData + 1;
//            if (sensorDataByte[0]==0) {  //未触发不作处理
//                //                showStr = [ASLocalizeConfig localizedString:@"无人经过"];
//            }
//            if (sensorDataByte[0]==1) {
//                showStr = [ASLocalizeConfig localizedString:@"有人经过"];
//            }
//        }
//        if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeVibrationMovementSensor)) { //震动传感器
//            //            myDevice.deviceSensorData = sensorData + 1;
//            if (sensorDataByte[0]==0) {
//                //没触发则不作处理
//            }
//            if (sensorDataByte[0]==1) {
//                showStr = [ASLocalizeConfig localizedString:@"有人经过"];
//            }
//        }
//        
//        DLog(@"sensorData Alarm2 Bit1 = %d",sensorDataByte[1]);
//        DLog(@"sensorData Tamper Bit2 = %d",sensorDataByte[2]);
//        DLog(@"sensorData Battery Bit3 = %d",sensorDataByte[3]);
//        DLog(@"sensorData Supervision reports Bit4 = %d",sensorDataByte[4]);
//        DLog(@"sensorData Restore reports Bit5 = %d",sensorDataByte[5]);
//        DLog(@"sensorData Trouble Bit6 = %d",sensorDataByte[6]);
//        DLog(@"sensorData AC Bit 7 = %d",sensorDataByte[7]);
//        
////        if (clusterID == ZCL_CLUSTER_ID_GEN_POWER_CFG) {            
////            NSString *showPower = [[NSString alloc]initWithFormat:@"设备 %x 电池电量 %d ",myDevice.shortAdr,sensorData];
////        }
//      //传感器上报数据时读取传感器类型
//        [self getZoneTypeForSensorDevice:myDevice];
//    }];
}

/**
 *  @author xingman.yi, 16-09-14 14:09:20
 *
 *  @brief 使用队列来读取设备属性,每次读取前延时2S
 *
 *  @param device 要读取的设备
 */
-(void)readDeviceAttribute:(AduroDevice *)device{
    DeviceManager *deviceManager = [DeviceManager sharedManager];
    dispatch_async(_myQueue, ^{
        [NSThread sleepForTimeInterval:0.7f];
        //读取开关状态
        [deviceManager getDevice:device updateData:^(AduroDevice *device, int updateDataType, uint16_t clusterID, uint16_t attribID,uint32_t attributeValue) {
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    [mydevice setDeviceNetState:DeviceNetStateOnline];
                    [mydevice setDeviceSwitchState:device.deviceSwitchState];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:mydevice];
                    [self changeDeviceSwitch:device.deviceSwitchState withID:device.deviceID];
                    //通知主线程刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadData];
                    });
                }
            }
        } updateType:AduroSmartUpdateDataTypeSwitch];
    });
    
    dispatch_async(_myQueue, ^{
        [NSThread sleepForTimeInterval:0.7f];
        //读取设备亮度
        [deviceManager getDevice:device updateData:^(AduroDevice *device, int updateDataType, uint16_t clusterID, uint16_t attribID,uint32_t attributeValue) {
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    [mydevice setDeviceNetState:DeviceNetStateOnline];
                    [mydevice setDeviceLightLevel:device.deviceLightLevel];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:mydevice];
                    [self changeDeviceLight:device.deviceLightLevel withID:device.deviceID];
                    //通知主线程刷新
                    dispatch_async(dispatch_get_main_queue(), ^{

                        [_tableView reloadData];
                    });
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

-(void)refreshSceneTable{
    [self getScenesOfHomeArray];
}

-(void)getScenesOfHomeArray{

    SceneManager *sceneManager = [SceneManager sharedManager];
    [sceneManager getAllScenes:^(AduroScene *scene) {
        NSLog(@"scene = %@",scene);
        if (scene == nil) {
            NSLog(@"返回scene为空");
            return;
        }
        if (scene && [scene.sceneName length]>0) {
            BOOL isRep = NO;
            for (int i=0; i<[_globalSceneArray count]; i++) {
                AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
                if (myScene.sceneID == scene.sceneID) {
                    isRep = YES;
                    /*
                     * 使用场景图片路径进行场景在线不在线的标记
                     * 0x01 为在线
                     */
                    [scene setSceneIconPath:SCENE_NET_STATE_ONLINE];
                    [_globalSceneArray replaceObjectAtIndex:i withObject:scene];
                    [self changeSceneName:scene.sceneName withID:scene.sceneID];
                }
            }
            if (!isRep) {
                [self saveSceneDataObject:scene];  //存储到数据库
                [scene setSceneIconPath:SCENE_NET_STATE_ONLINE];
                [_globalSceneArray addObject:scene];
            }
            
            if (_globalSceneArray.count>0) {
                for (int j=0; j<_globalSceneArray.count; j++) {
                    AduroScene *myScene = [_globalSceneArray objectAtIndex:j];
                    if (myScene.groupID == _detailGroup.groupID) {
                        BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
                        for (int k=0; k<_scenesArray.count; k++) {
                            AduroScene *theScene = [_scenesArray objectAtIndex:k];
                            if (theScene.sceneID == myScene.sceneID) {
                                noExist = NO;
                                [myScene setSceneIconPath:SCENE_NET_STATE_ONLINE];
                                [_scenesArray replaceObjectAtIndex:k withObject:myScene];
                            }
                        }
                        if (noExist) {
                            [myScene setSceneIconPath:SCENE_NET_STATE_ONLINE];
                            [_scenesArray addObject:myScene];
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //                [_sceneTableView reloadData];
                [self refreshTableView];
                //回调或者说是通知主线程刷新，
            });

        }
    }];
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == TAG_DEVICES) {
        return [_homeDeviceArray count];
    }else if (tableView.tag == TAG_SCENES) {
        return [_scenesArray count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == TAG_DEVICES) {
        NSString static *identifier = @"deviceCell";
        ASDeviceCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!deviceCell) {
            deviceCell = [[ASDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            deviceCell.delegate = self;
        }
        AduroDevice *aduroDevice = _homeDeviceArray[indexPath.row];
        [deviceCell setAduroDeviceInfo:nil];
        [deviceCell setAduroDeviceInfo:aduroDevice];
        return deviceCell;
    }else if (tableView.tag == TAG_SCENES) {
        NSString static *identifier = @"sceneCell";
        ASSceneCell *sceneCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!sceneCell) {
            sceneCell = [[ASSceneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            sceneCell.delegate = self;
        }
        AduroScene *aduroScene = _scenesArray[indexPath.row];
        sceneCell.sceneNameLb.text = aduroScene.sceneName;
        NSString *netStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
        if ([aduroScene.sceneIconPath isEqualToString:SCENE_NET_STATE_ONLINE]) {
            netStateStr = @"";
        }else{
            netStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
        }
        sceneCell.netStateLb.text = netStateStr;        
        return sceneCell;
    }else{
        return nil;
    }

}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView.tag == TAG_SCENES) {
        //点击激活场景
        AduroScene *scene = _scenesArray[indexPath.row];
        SceneManager *sceneManager = [SceneManager sharedManager];
        [sceneManager useGroupIDCallScene:scene completionHandler:^(AduroSmartReturnCode code) {
            NSLog(@"AduroSmartReturnCode = %d",(int)code);
            if (code == AduroSmartReturnCodeSuccess) {
                
            }
        }];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"完成"] message:[ASLocalizeConfig localizedString:@"成功开启场景"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == TAG_DEVICES) {
        AduroDevice *deviceHeight = [_homeDeviceArray objectAtIndex:indexPath.row];
        CGFloat offset = 0;
        CGFloat newOffset = 0;

        switch (deviceHeight.deviceTypeID)
        {
            case 0x0105://可调颜色灯,有调光、开关功能
            case 0x0102://彩灯
            case 0x0210://飞利浦彩灯
            case 0x0200://彩灯
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
                offset = 40;
                newOffset = 40;
            }
                break;
        }
        return [ASDeviceCell getCellHeight] + offset + newOffset;
    }else{
        return [ASSceneCell getCellHeight];
    }
}

#pragma mark - cell的协议

-(BOOL)deviceSwitch:(BOOL)isOn aduroInfo:(AduroDevice *)aduroInfo{
    NSLog(@"%d",isOn);
    isOn = !isOn;
    uint8_t onOff = 0;
    onOff = isOn ? 1 : 0;
    aduroInfo.deviceSwitchState = onOff;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DeviceManager *device = [DeviceManager sharedManager];
        [device updateDeviceState:aduroInfo completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"开关返回值 = %d",code);

        }];
    });
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashDeviceList" object:nil];
    return isOn;
}

-(void)deviceShowDetailWithAduroInfo:(AduroDevice *)aduroDevice{
    DLog(@"aduroDevice.deviceID = %@",aduroDevice.deviceID);
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

-(void)deviceChangeAlpha:(CGFloat )value{
    
}

#pragma mark - ASSceneDelegate
-(BOOL)sceneSwitch:(BOOL)isSceneOn aduroInfo:(AduroScene *)sceneInfo{
    DLog(@"%d",isSceneOn);
    isSceneOn = !isSceneOn;
    return isSceneOn;
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (alertView.tag == ADD_NEW_DEVICE_TO_HOME) {
//        if (buttonIndex == 1) {
//            [self addDeviceToHomeBtnAction];
//        }
//    }
}

-(void)deivceListOfRoomView{
    [_deviceBtn setImage:[UIImage imageNamed:@"devices_selected"] forState:UIControlStateNormal];
    [_deviceBtn setTitleColor:LOGO_COLOR forState:UIControlStateNormal];
    [_deviceBtn setTintColor:LOGO_COLOR];
    [_deviceView setHidden:NO];
    [_sceneBtn setImage:[UIImage imageNamed:@"scene"] forState:UIControlStateNormal];
    [_sceneBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_sceneBtn setTintColor:[UIColor lightGrayColor]];
    [_sceneView setHidden:YES];
    
}
-(void)sceneListOfRoomView{
    [_deviceBtn setImage:[UIImage imageNamed:@"devices"] forState:UIControlStateNormal];
    [_deviceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_deviceBtn setTintColor:[UIColor lightGrayColor]];
    [_deviceView setHidden:YES];
    [_sceneBtn setImage:[UIImage imageNamed:@"scene_selected"] forState:UIControlStateNormal];
    [_sceneBtn setTitleColor:LOGO_COLOR forState:UIControlStateNormal];
    [_sceneBtn setTintColor:LOGO_COLOR];
    [_sceneView setHidden:NO];
    
}


//创建新场景
-(void)newSceneToHomeBtnAction{
    ASAddHomeSceneViewController *detailvc = [[ASAddHomeSceneViewController alloc]init];
    detailvc.mySceneGroup = self.detailGroup;
    detailvc.myDeviceArray = _homeDeviceArray;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailvc animated:NO];
    [self setHidesBottomBarWhenPushed:YES];
}

-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
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




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshTableView];
}

- (void)refreshTableView
{
    if ([_scenesArray count] > 0) {
        _sceneTableView.tableHeaderView = nil;
    }
    else
    {
        _sceneTableView.tableHeaderView = [self headerView];
    }
    [_sceneTableView reloadData];
    
}

-(void)tableRefreshLoadScenes{
    [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(cancelRefreshSceneTable) userInfo:nil repeats:NO];
    /* 缓存 */
    [_globalSceneArray removeAllObjects];
    NSArray *sceneArr = [self getSceneDataObject];
    [_globalSceneArray addObjectsFromArray:sceneArr];
    [_sceneTableView reloadData];
    [self getScenesOfHomeArray];

}

-(void)cancelRefreshSceneTable{
    [_sceneTableView.mj_header endRefreshing];
}

#pragma mark - 保存场景数据到数据库
-(void)saveSceneDataObject:(AduroScene *)sceneDO{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveSceneData:sceneDO withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//从数据库中获取场景对象数组
-(NSArray *)getSceneDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectSceneDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}
////从数据库中删除所有场景对象
//-(void)deleteAllSceneDataObject{
//    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
//    [db openDatabase];
//    [db deleteAllScenes];
//}
//更新场景名称到数据库
-(void)changeSceneName:(NSString *)name withID:(NSInteger)sceneId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateSceneNameData:name withID:sceneId withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
#pragma mark - 设备数据相关
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
