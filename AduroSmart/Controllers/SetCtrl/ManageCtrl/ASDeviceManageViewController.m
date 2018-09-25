//
//  ASDeviceManageViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDeviceManageViewController.h"
#import "ASGlobalDataObject.h"
#import "ASDataBaseOperation.h"
#import "MyTool.h"
#import "ASDeviceTypeViewController.h"
#import <STAlertView.h>
#import <MJRefresh.h>
#import "ASUserDefault.h"
#define TAG_DELETE_DEVICE_SUCCESS 800104
#define TAG_DELETE_DEVICE_FAILD 800105
#define TAG_DELETE_DEVICE_CONFIRM 800109 //确认删除

#define TAG_SUCCESS_EDIT_NAME 800117
#define TAG_START_DELETE_ALERT 800106
@interface ASDeviceManageViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *_deviceManageTableView;
    UIButton *_rightBarBtn; //导航右按钮
    //删除的索引
    NSIndexPath *_indexDelete;
    
    STAlertView *_saveAlert; //保存名称的确认框
    UIView *_editView;     //底部批量删除视图
    NSMutableArray *_selectorArray;//存放选中数据
    
    //批量删除设备的对列
    dispatch_queue_t _deleteQueue;
    //单个删除设备的对列
    dispatch_queue_t _deleteDeviceQueue;
}

@end

@implementation ASDeviceManageViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"设备"];
    [self initWithDeviceManageView];
    // 设置tableView在编辑模式下可以多选，并且只需设置一次
    _deviceManageTableView.allowsMultipleSelectionDuringEditing = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashDeviceManageList) name:@"reflashDeviceList" object:nil];
}

-(void)reflashDeviceManageList{
    [_deviceManageTableView reloadData];
}

-(void)initWithDeviceManageView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToSettingBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    //导航栏右按钮
    _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"编辑"] forState:UIControlStateNormal];
    [_rightBarBtn addTarget:self action:@selector(makeSelectable) forControlEvents:UIControlEventTouchUpInside];
    _rightBarBtn.frame = CGRectMake(0, 0, 58, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height-64;
    if (!_deviceManageTableView) {
        _deviceManageTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _deviceManageTableView.backgroundColor = VIEW_BACKGROUND_COLOR;
        [self.view addSubview:_deviceManageTableView];
//        [_deviceManageTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _deviceManageTableView.delegate = self;
        _deviceManageTableView.dataSource = self;
    }
    _deviceManageTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadAllDevice)];
    
    //场景右下角悬浮创建新场景
    UIButton *addDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addDeviceBtn];
    [addDeviceBtn setBackgroundImage:[UIImage imageNamed:@"button_fab_add"] forState:UIControlStateNormal];
    [addDeviceBtn addTarget:self action:@selector(newDeviceSearchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [addDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_deviceManageTableView.mas_trailing).offset(-30);
        make.bottom.equalTo(_deviceManageTableView.mas_bottom).offset(-10-SELECT_DELETE_VIEW_HEIGHT);
        make.width.equalTo(@(50));
        make.height.equalTo(@(50));
    }];
    
    //底部批量删除视图
    _editView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_ADURO_HEIGHT - 64, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT)];
    _editView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_editView];
    
    //delete分割线
    UIView *separatorView = [[UIView alloc]init];
    [separatorView setBackgroundColor:CELL_LIEN_COLOR];
    [_editView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_editView.mas_leading);
        make.trailing.equalTo(_editView.mas_trailing);
        make.height.equalTo(@(1));
        make.top.equalTo(_editView.mas_top);
    }];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editView addSubview:deleteBtn];
//    [deleteBtn setTitle:[ASLocalizeConfig localizedString:@"删除"] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(removeSelectedCells) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_editView.mas_trailing).offset(-20);
        make.centerY.equalTo(_editView.mas_centerY);
        make.width.equalTo(@(44));
        make.height.equalTo(@(44));
    }];
}

-(void)getAllAduroDevice{
    DeviceManager *deviceManager = [DeviceManager sharedManager];
    [deviceManager getAllDevices:^(AduroDevice *device) {
        if (device) {
            BOOL isExist = NO;
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    isExist = YES;
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
        [_deviceManageTableView reloadData];
        [self cancelRefreshDecviceTable];
    }];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    AduroDevice *device = [_globalDeviceArray objectAtIndex:indexPath.row];
    NSString *showName = [[NSString alloc]initWithFormat:@"%@",[MyTool changeName:device.deviceName]];
    [cell.textLabel setText:showName];
    
    NSString *netStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
    if (device.isCache == YES) {
        netStateStr = [ASLocalizeConfig localizedString:@""];
    }
    
    [cell.detailTextLabel setText:[[NSString alloc] initWithFormat:@"%@ %x          %@",[self setTypeWithDevice:device],device.shortAdr,netStateStr]];
    if (device.deviceTypeID == DeviceTypeIDHumanSensor) {
        if (device.deviceZoneType == DeviceZoneTypeMotionSensor) {
            [cell.imageView setImage:[UIImage imageNamed:@"sensor_0014"]];
            if ([device.deviceName isEqualToString:@"CIE Device"]) {
                [cell.textLabel setText:@"Motion Sensor"];
            }
        }else if(device.deviceZoneType == DeviceZoneTypeContactSwitch){
            [cell.imageView setImage:[UIImage imageNamed:@"sensor_0015"]];
            if ([device.deviceName isEqualToString:@"CIE Device"]) {
                [cell.textLabel setText:@"Contact Switch"];
            }
        }else{
            [cell.imageView setImage:[UIImage imageNamed:@"unonline"]];
        }
    }else if(device.deviceTypeID == DeviceTypeIDLightingRemotes){
        [cell.imageView setImage:[UIImage imageNamed:@"light_remotes"]];
    }else if(device.deviceTypeID == DeviceTypeIDSmartPlug){
        [cell.imageView setImage:[UIImage imageNamed:@"smart_plug"]];
    }else if(device.deviceTypeID == 0x0105 || device.deviceTypeID == 0x0102 || device.deviceTypeID == 0x0210 || device.deviceTypeID == 0x0110 || device.deviceTypeID == 0x0110 || device.deviceTypeID == 0x0220 || device.deviceTypeID == 0x0101 || device.deviceTypeID == 0x0100){
        [cell.imageView setImage:[UIImage imageNamed:@"light"]];
    }else{
        [cell.imageView setImage:[UIImage imageNamed:@"unonline"]];
    }
    return cell;
}

-(NSString *)setTypeWithDevice:(AduroDevice *)aduroDevice{
    NSString *strDeviceType = @"";
    switch (aduroDevice.deviceTypeID)
    {
        case 0x0105://可调颜色灯,有调光、开关功能
        case 0x0102://彩灯
        case 0x0210://飞利浦彩灯
        case DeviceTypeIDColorLight:
        {
            strDeviceType = [ASLocalizeConfig localizedString:@"彩灯"];
            break;
        }
        case 0x0110://色温灯
        case 0x0220:
        {
            strDeviceType = [ASLocalizeConfig localizedString:@"色温灯"];
            break;
        }
        case 0x0101://调光灯
        case 0x0100://强制改开关为灯泡
        {
            strDeviceType = [ASLocalizeConfig localizedString:@"调光灯"];
            break;
        }
        case DeviceTypeIDHumanSensor://海曼传感器
        {
            {
                switch (aduroDevice.deviceZoneType) {
                    case DeviceZoneTypeMotionSensor:
                    {
                        strDeviceType = [ASLocalizeConfig localizedString:@"人体传感器"];
                    }
                        break;
                    case DeviceZoneTypeContactSwitch:
                    {
                        strDeviceType = [ASLocalizeConfig localizedString:@"门磁传感器"];
                    }
                        break;
                    case DeviceZoneTypeVibrationMovementSensor:
                    {
                        strDeviceType = [ASLocalizeConfig localizedString:@"震动传感器"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            break;
        }
        case DeviceTypeIDSmartPlug://智能插座
        {
            strDeviceType = [ASLocalizeConfig localizedString:@"Smart plug"];
            break;
        }
        case 0x0202:
        {
            strDeviceType = [ASLocalizeConfig localizedString:@"Curtain"];
            break;
        }
        case DeviceTypeIDLightingRemotes:
        {
            strDeviceType = [ASLocalizeConfig localizedString:@"Lighting Remotes"];
            break;
        }
        default:
        {
            break;
        }
    }
    return strDeviceType;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_deviceManageTableView.isEditing) {
        AduroDevice *selectDevices = [_globalDeviceArray objectAtIndex:indexPath.row];
        if (_selectorArray == nil) {
            _selectorArray = [[NSMutableArray alloc] init];
        }
        [_selectorArray addObject:selectDevices];
    }else{
        //取消选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        AduroDevice *oneDevice = [_globalDeviceArray objectAtIndex:indexPath.row];
        DeviceManager *manager = [DeviceManager sharedManager];
        [manager identify:oneDevice];
        [self changeDeviceName:oneDevice];
    }
}

/**
 *  @author xingman.yi, 16-04-06 17:04:01
 *
 *  @brief 修改设备名称
 *
 *  @param selectedDevice 需要修改的设备
 */
-(void)changeDeviceName:(AduroDevice *)selectedDevice{
//    if (_saveAlert) {
//        [_saveAlert show];
//        //        [_saveAlert clearTextfield];
//        return;
//    }
    NSString *strName = @"";
    if (selectedDevice) {
        strName = [MyTool changeName:selectedDevice.deviceName];
        if (selectedDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
            if ([selectedDevice.deviceName isEqualToString:@"CIE Device"]) {
                if (selectedDevice.deviceZoneType == DeviceZoneTypeMotionSensor) {
                    strName = @"Motion Sensor";
                }
                if (selectedDevice.deviceZoneType == DeviceZoneTypeContactSwitch) {
                    strName = @"Contact Switch";
                }
            }
        }
    }
    _saveAlert = [[STAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"修改设备名称"] message:[ASLocalizeConfig localizedString:@"请输入名称"] textFieldHint:@"" textFieldValue:strName cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitle:[ASLocalizeConfig localizedString:@"保存"] cancelButtonBlock:^{
        
    } otherButtonBlock:^(NSString * result) {
        if ([result isEqualToString:strName]) {
            return;
        }
        
        BOOL isDeviceExist = NO;
        
        if (selectedDevice) {
            for (AduroDevice *deviceInfo in _globalDeviceArray) {
                NSString *theStrName = [MyTool changeName:deviceInfo.deviceName];
                if (deviceInfo.deviceTypeID == DeviceTypeIDHumanSensor) {
                    if ([deviceInfo.deviceName isEqualToString:@"CIE Device"]) {
                        if (deviceInfo.deviceZoneType == DeviceZoneTypeMotionSensor) {
                            theStrName = @"Motion Sensor";
                        }
                        if (deviceInfo.deviceZoneType == DeviceZoneTypeContactSwitch) {
                            theStrName = @"Contact Switch";
                        }
                    }
                }
                if ([result isEqualToString:theStrName]) {
                    isDeviceExist = YES;
                }
            }
        }
        
        if (isDeviceExist) { //是 则重名了
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"名称已存在"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
            [alertView show];
        }else{ //未重名 可用
            if ([result length]<1||[result length]>30) {
                UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"名称长度应在1到30之间"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [failedAlertView show];
            }else{
                [selectedDevice setDeviceName:result];
                //更新的名称提交给网关
                DeviceManager *deviceManager = [DeviceManager sharedManager];
                [deviceManager updateDeviceName:selectedDevice completionHandler:^(AduroSmartReturnCode code) {
                    DLog(@"更新设备(添加设备)结果code=%d",code);
                    if (code == AduroSmartReturnCodeSuccess) {

                    }
                }];
                //更新数据库里的设备名称
                for (int i=0; i<[_globalDeviceArray count]; i++) {
                    AduroDevice *device = [_globalDeviceArray objectAtIndex:i];
                    if (selectedDevice.deviceID == device.deviceID) {
                        [device setDeviceName:result];
                    }
                }
                UIAlertView *successAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"保存成功"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [successAlertView setTag:TAG_SUCCESS_EDIT_NAME];
                [successAlertView setDelegate:self];
                [successAlertView show];
            }
        }
    }];
    [_saveAlert show];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

#pragma mark - 删除指定设备
//左滑删除可编辑模式
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//左滑出现的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ASLocalizeConfig localizedString:@"删除"];
}
//删除所做的动作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _indexDelete = indexPath;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"删除"] message:[ASLocalizeConfig localizedString:@"你确定要删除该设备吗"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitles:[ASLocalizeConfig localizedString:@"确定"], nil];
        [alert setTag:TAG_DELETE_DEVICE_CONFIRM];
        [alert show];
    }
}
//删除设备
-(void)startDeleteDevice{
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _deleteDeviceQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    
    AduroDevice *deviceInfo = [_globalDeviceArray objectAtIndex:_indexDelete.row];
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Deleting..."]];
    //从网关删除设备
    [self deleteGatewayDevice:deviceInfo];

    //从缓存中删除
    [self deleteDeviceDataWithID:deviceInfo.deviceID];
    //从列表中删除
    [_globalDeviceArray removeObjectAtIndex:_indexDelete.row];
    [_deviceManageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexDelete] withRowAnimation:(UITableViewRowAnimationFade)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteDeviceReflashTableView" object:nil];
}

-(void)deleteGatewayDevice:(AduroDevice *)deviceInfo{
    //从网关场景中删除此设备
    [self deleteSceneDevice:deviceInfo];
    //从网关房间中删除此设备
    [self deleteGroupDevice:deviceInfo];
    //从网关删除设备
    dispatch_async(_deleteDeviceQueue, ^{
        [NSThread sleepForTimeInterval:0.3f];
        DeviceManager *manager = [DeviceManager sharedManager];
        [manager deleteDevice:deviceInfo completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"删除设备结果code=%d",code);
            if (code == AduroSmartReturnCodeSuccess) {
                sleep(0.5);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopMBProgressHUD];
                });
            }
        }];
    });
}

-(void)deleteSceneDevice:(AduroDevice *)deviceInfo{
    //2. 从网关场景中删除该设备
    for (int i=0;i<_globalSceneArray.count;i++) {
        AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
        for (NSString *myID in myScene.sceneSubDeviceIDArray) {
            if ([[deviceInfo.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                NSArray *deleteArr = [[NSArray alloc] initWithObjects:deviceInfo, nil];
                dispatch_async(_deleteDeviceQueue, ^{
                    [NSThread sleepForTimeInterval:0.3f];
                    SceneManager *sceneManager = [SceneManager sharedManager];
                    [sceneManager deleteDeviceFromScene:myScene devices:deleteArr completionHandler:^(AduroSmartReturnCode code) {
                    }];
                });
            }
        }
    }
}

-(void)deleteGroupDevice:(AduroDevice *)deviceInfo{
    //3. 从网关房间中删除该设备
    for (int i=0;i<_globalGroupArray.count;i++) {
        AduroGroup *myGroup = [_globalGroupArray objectAtIndex:i];
        for (NSString *myID in myGroup.groupSubDeviceIDArray) {
            if ([[deviceInfo.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                NSArray *deleteArr = [[NSArray alloc] initWithObjects:deviceInfo, nil];
                dispatch_async(_deleteDeviceQueue, ^{
                    [NSThread sleepForTimeInterval:0.3f];
                    GroupManager *groupManager = [GroupManager sharedManager];
                    [groupManager deleteDeviceFromGroup:myGroup devices:deleteArr completionHandler:^(AduroSmartReturnCode code) {
                    }];
                });
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_DELETE_DEVICE_CONFIRM) {
        if (buttonIndex == 1) {
            [self startDeleteDevice];
        }
    }
    if (alertView.tag == TAG_DELETE_DEVICE_SUCCESS) {
        [self stopMBProgressHUD];
        if (_indexDelete) {
            [_globalDeviceArray removeObjectAtIndex:_indexDelete.row];
            [_deviceManageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexDelete] withRowAnimation:(UITableViewRowAnimationFade)];
            [_deviceManageTableView reloadData];
        }        
    }
    //修改设备名称成功
    if (alertView.tag == TAG_SUCCESS_EDIT_NAME) {
        if (buttonIndex == 0) {
            [_deviceManageTableView reloadData];
        }
    }
}

#pragma mark - 批量删除
- (void)makeSelectable
{
    [_deviceManageTableView setEditing:!_deviceManageTableView.isEditing animated:YES];
    if (_deviceManageTableView.isEditing) {
        [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"取消"] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        //为编辑状态的时候，底部浮起视图
        CGRect startFrame = CGRectMake(0, SCREEN_ADURO_HEIGHT - 64 - SELECT_DELETE_VIEW_HEIGHT, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT);
        [UIView animateWithDuration:0.1 animations:^{
            _editView.frame = startFrame;
        }];
    }else{
        [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"编辑"] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        //为非编辑状态则，底部视图消失
        CGRect endFrame = CGRectMake(0, SCREEN_ADURO_HEIGHT - 64, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT);
        [UIView animateWithDuration:0.1 animations:^{
            _editView.frame = endFrame;
        }];
    }
    
    
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    AduroDevice *unselectDevices = [_globalDeviceArray objectAtIndex:indexPath.row];
    //删除取消选中的设备
    if (_selectorArray) {
        for (int i=0; i<[_selectorArray count]; i++) {
            AduroDevice *device = [_selectorArray objectAtIndex:i];
            if ([device.deviceID isEqualToString:unselectDevices.deviceID]) {
                [_selectorArray removeObject:device];
            }
        }
    }
}

-(void)removeSelectedCells{
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _deleteQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    DLog(@"%@",_selectorArray);
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"deleting..."]];
    //从网关中删除选中设备
    if (_selectorArray) {
        for (int i=0; i< _selectorArray.count; i++) {
            AduroDevice *deviceInfo = [_selectorArray objectAtIndex:i];
            //从数据库中删除该缓存
            [self deleteDeviceDataWithID:deviceInfo.deviceID];
            // 从网关场景管理中删除该设备
            [self deleteDeviceDelayed:deviceInfo];
            if (i == _selectorArray.count-1) {
                dispatch_async(_deleteQueue, ^{
                    sleep(2);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self stopMBProgressHUD];
                    });
                });
            }
        }
        //从数组中删除选中设备
        [_globalDeviceArray removeObjectsInArray:_selectorArray];
        [_deviceManageTableView reloadData];
    }
    [self makeSelectable];
}

-(void)deleteDeviceDelayed:(AduroDevice *)device{
    //从场景中删除设备
    [self deleteSceneDeviceDelayed:device];
    //从房间中删除设备
    [self deleteGroupDeviceDelayed:device];
    //从网关删除设备
    dispatch_async(_deleteQueue, ^{
        [NSThread sleepForTimeInterval:0.25f];
        DeviceManager *manager = [DeviceManager sharedManager];
        [manager deleteDevice:device completionHandler:^(AduroSmartReturnCode code) {
            if (code == AduroSmartReturnCodeSuccess) {
            }
        }];
    });
}
-(void)deleteSceneDeviceDelayed:(AduroDevice *)deviceInfo{
    //2. 从网关场景中删除该设备
    for (int i=0;i<_globalSceneArray.count;i++) {
        AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
        for (NSString *myID in myScene.sceneSubDeviceIDArray) {
            if ([[deviceInfo.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                NSArray *deleteArr = [[NSArray alloc] initWithObjects:deviceInfo, nil];
                dispatch_async(_deleteQueue, ^{
                    [NSThread sleepForTimeInterval:0.3f];
                    SceneManager *sceneManager = [SceneManager sharedManager];
                    [sceneManager deleteDeviceFromScene:myScene devices:deleteArr completionHandler:^(AduroSmartReturnCode code) {
                    }];
                });
            }
        }
    }
}
-(void)deleteGroupDeviceDelayed:(AduroDevice *)deviceInfo{
    for (int i=0;i<_globalGroupArray.count;i++) {
        AduroGroup *myGroup = [_globalGroupArray objectAtIndex:i];
        for (NSString *myID in myGroup.groupSubDeviceIDArray) {
            if ([[deviceInfo.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                NSArray *deleteArr = [[NSArray alloc] initWithObjects:deviceInfo, nil];
                dispatch_async(_deleteQueue, ^{
                    [NSThread sleepForTimeInterval:0.3f];
                    GroupManager *groupManager = [GroupManager sharedManager];
                    [groupManager deleteDeviceFromGroup:myGroup devices:deleteArr completionHandler:^(AduroSmartReturnCode code) {
                    }];
                });
            }
        }
    }
}

-(void)newDeviceSearchBtnAction{
    self.hidesBottomBarWhenPushed = YES;
    ASDeviceTypeViewController *typeVC = [[ASDeviceTypeViewController alloc] init];
    
    [self.navigationController pushViewController:typeVC animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

-(void)backToSettingBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

//从数据库中删除id对应设备
-(void)deleteDeviceDataWithID:(NSString *)deviceID{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db deleteDeviceWithID:deviceID];
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
    [_deviceManageTableView.mj_header endRefreshing];
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
    [_deviceManageTableView reloadData];
    [self getAllAduroDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
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
