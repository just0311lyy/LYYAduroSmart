//
//  LYRoomDeviceViewController.m
//  AduroSmart
//
//  Created by MacBook on 2017/1/5.
//  Copyright © 2017年 MacBook. All rights reserved.
//

#import "LYRoomDeviceViewController.h"
#import "ASDeviceCell.h"
#import "ASDeviceDetailViewController.h"
#import "ASSensorDetailViewController.h"
#import "ASGlobalDataObject.h"
@interface LYRoomDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,DeviceDelegate>{
    UITableView *_deviceTable;  //当前房间里面的设备列表
    NSMutableArray *_showDeviceArr; //显示出来的设备
//    NSMutableArray *_roomDeviceArr; //当前房间里的设备
}

@end

@implementation LYRoomDeviceViewController
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    //    设置导航栏背景图片为一个空的image
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *navImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_ADURO_WIDTH, 64)];
    [self.view addSubview:navImgView];
    [navImgView setImage:[UIImage imageNamed:@"nav_bg"]];
    
    NSArray *array = [_detailGroup.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
    self.title = [array firstObject];
    if (_roomDeviceArr ==nil) {
        _roomDeviceArr = [[NSMutableArray alloc] init];
    }
    if (_showDeviceArr ==nil) {
        _showDeviceArr = [[NSMutableArray alloc] init];
    }
    
    /* 缓存 */
    if (_detailGroup.groupID  == MAX_GROUP_ID) {
        [_roomDeviceArr addObjectsFromArray:_globalDeviceArray];
    }else{
        for (int j=0; j<_globalDeviceArray.count; j++) {
            AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
            for (NSString *myID in _detailGroup.groupSubDeviceIDArray) {
                //                int result = [myDevice.deviceID compare:myID options:NSCaseInsensitiveSearch | NSNumericSearch];
                //                if (result == NSOrderedSame) {
                //                    [_homeDeviceArray addObject:myDevice];
                //                }
                if ([[myDevice.deviceID lowercaseString] isEqualToString:[myID lowercaseString]]) {
                    //                [_showDeviceArr addObject:myDevice];
                    [_roomDeviceArr addObject:myDevice];
                }
            }
        }
    }

    if ([_deviceType isEqualToString:@"sensor"]) {
        for (AduroDevice *myDevice in _roomDeviceArr) {
            if (myDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
                [_showDeviceArr addObject:myDevice];
            }
        }
    }else if ([_deviceType isEqualToString:@"remote"]) {
        for (AduroDevice *myDevice in _roomDeviceArr) {
            if (myDevice.deviceTypeID == DeviceTypeIDLightingRemotes) {
                [_showDeviceArr addObject:myDevice];
            }
        }
    }else{
        for (AduroDevice *myDevice in _roomDeviceArr) {
            if (myDevice.deviceTypeID != DeviceTypeIDHumanSensor && myDevice.deviceTypeID != DeviceTypeIDLightingRemotes) {
                [_showDeviceArr addObject:myDevice];
            }
        }
    }
    [self initWithRoomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashTableView) name:@"reflashTableView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashTableView) name:@"allGroupListReloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteReflashTableView) name:@"deleteDeviceReflashTableView" object:nil];
}

-(void)reflashTableView{
    [_deviceTable reloadData];
}
-(void)deleteReflashTableView{
    if (_showDeviceArr.count>0) {
        [_showDeviceArr removeAllObjects];
    }
    /* 缓存 */
    if (_detailGroup.groupID  == MAX_GROUP_ID) {
        [_roomDeviceArr addObjectsFromArray:_globalDeviceArray];
    }else{
        for (int j=0; j<_globalDeviceArray.count; j++) {
            AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
            for (NSString *myID in _detailGroup.groupSubDeviceIDArray) {
                //                int result = [myDevice.deviceID compare:myID options:NSCaseInsensitiveSearch | NSNumericSearch];
                //                if (result == NSOrderedSame) {
                //                    [_homeDeviceArray addObject:myDevice];
                //                }
                if ([[myDevice.deviceID lowercaseString] isEqualToString:[myID lowercaseString]]) {
                    //                [_showDeviceArr addObject:myDevice];
                    [_roomDeviceArr addObject:myDevice];
                }
            }
        }
    }
    
    if ([_deviceType isEqualToString:@"sensor"]) {
        for (AduroDevice *myDevice in _roomDeviceArr) {
            if (myDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
                [_showDeviceArr addObject:myDevice];
            }
        }
    }else if ([_deviceType isEqualToString:@"remote"]) {
        for (AduroDevice *myDevice in _roomDeviceArr) {
            if (myDevice.deviceTypeID == DeviceTypeIDLightingRemotes) {
                [_showDeviceArr addObject:myDevice];
            }
        }
    }else{
        for (AduroDevice *myDevice in _roomDeviceArr) {
            if (myDevice.deviceTypeID != DeviceTypeIDHumanSensor && myDevice.deviceTypeID != DeviceTypeIDLightingRemotes) {
                [_showDeviceArr addObject:myDevice];
            }
        }
    }    
}

-(void)initWithRoomView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    if (!_deviceTable) {
        _deviceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_ADURO_WIDTH,SCREEN_ADURO_HEIGHT - 64) style:UITableViewStylePlain];
        [self.view addSubview:_deviceTable];
        [_deviceTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _deviceTable.delegate = self;
        _deviceTable.dataSource = self;
    }
}

-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _showDeviceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        NSString static *identifier = @"deviceCell";
    ASDeviceCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!deviceCell) {
        deviceCell = [[ASDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        deviceCell.delegate = self;
    }
    AduroDevice *aduroDevice = _showDeviceArr[indexPath.row];
    [deviceCell setAduroDeviceInfo:nil];
    [deviceCell setAduroDeviceInfo:aduroDevice];
    return deviceCell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AduroDevice *deviceHeight = [_showDeviceArr objectAtIndex:indexPath.row];
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
