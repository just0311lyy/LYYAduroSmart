//
//  ASTimeDeivceListViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASTimeDeivceListViewController.h"
#import "ASGlobalDataObject.h"
#import "ASTimeDeviceListCell.h"
#import "ASDeviceDetailViewController.h"

@interface ASTimeDeivceListViewController ()<UITableViewDataSource,UITableViewDelegate,ASTimeDeviceListCellDelegate,ASDeviceDetailDelegate>{
    UITableView *_taskDeviceTableView;     //可定时任务设备列表
    NSMutableArray *_canSetAttriDeviceArray;     //可以设置属性的设备
    //存储所有的可设置属性的设备和它对应的状态
    NSMutableArray *_allDeviceAndTagArray;
    AduroDevice *_seleteDevice; //选中的设备
    
    UIColor *_theColor; //显示色
    CGFloat _theLevel; //亮度
    BOOL _theSwitchOnOrOff;
}

@end

@implementation ASTimeDeivceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ASLocalizeConfig localizedString:@"定时设备"];
    if (_canSetAttriDeviceArray == nil) {
        _canSetAttriDeviceArray = [[NSMutableArray alloc]init];
    }
    if ([self.deviceType isEqualToString:@"time"]) {
        for (int i=0; i<[_globalDeviceArray count]; i++) {
            AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:i];
            if (myDevice.deviceTypeID == DeviceTypeIDHumanSensor || myDevice.deviceTypeID == DeviceTypeIDLightingRemotes) {
                continue;
            }
            [_canSetAttriDeviceArray addObject:myDevice];
        }
    }else{
        for (int i=0; i<[_globalDeviceArray count]; i++) {
            AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:i];
            if (myDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
                [_canSetAttriDeviceArray addObject:myDevice];
            }  
        }
    }
    
    if (!_allDeviceAndTagArray) {
        _allDeviceAndTagArray = [[NSMutableArray alloc]init];
    }

    for (int i=0; i<[_canSetAttriDeviceArray count]; i++) {
        AduroDevice *myDevice = [_canSetAttriDeviceArray objectAtIndex:i];
        NSDictionary *deviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:NO],@"Flag", nil];
        [_allDeviceAndTagArray addObject:deviceDict];
    }

    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToBeforeViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(didSelectDeviceBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"完成"] forState:UIControlStateNormal];
    [rightBarBtn setFont:[UIFont systemFontOfSize:16]];
    rightBarBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    _taskDeviceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - 64) style:UITableViewStylePlain];
    _taskDeviceTableView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.view addSubview:_taskDeviceTableView];
    [_taskDeviceTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _taskDeviceTableView.delegate = self;
    _taskDeviceTableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectDevice:) name:@"DID_CHANGE_DEVICE_STATE" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectDevice:) name:@"DID_CHANGE_DEVICE_STATE" object:nil];
}

-(void)updateSelectDevice:(NSNotification *)noti{
    AduroDevice *myDevice = [noti object];
    if (myDevice) {
        _seleteDevice = myDevice;
    }
    [_taskDeviceTableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 0 ;
    if (_canSetAttriDeviceArray) {
        if ([_canSetAttriDeviceArray count]>0) {
            rowCount = [_canSetAttriDeviceArray count];
        }
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    ASTimeDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASTimeDeviceListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *deviceDict = [_allDeviceAndTagArray objectAtIndex:indexPath.row];
    AduroDevice *aduroDeviceInfo = [deviceDict objectForKey:@"Device"];
    //是否被点击（选中）
    NSNumber *flag = [deviceDict objectForKey:@"Flag"];
    BOOL isCheck = [flag boolValue];
    [cell setAduroDeviceInfo:aduroDeviceInfo];
    [cell setCheckboxChecked:isCheck manual:YES];
    [cell setDelegate:self];
    [cell setClickIndex:indexPath.row];
    return cell;

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AduroDevice *aduroDevice = [[_allDeviceAndTagArray objectAtIndex:indexPath.row] objectForKey:@"Device"];
    if (aduroDevice.deviceID == nil) {
        return;
    }
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
            detailvc.delegate = self;
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:detailvc animated:NO];
            [self setHidesBottomBarWhenPushed:NO];
        }
            break;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASTimeDeviceListCell getCellHeight];
}

//-(NSString *)tableView:(UITableView * )tableView titleForHeaderInSection:(NSInteger)section{
//    return [ASLocalizeConfig localizedString:@"设备"];
//}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

#pragma mark 设备列表里点选钮触发的回调事件
-(void)selectedTimeAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{
    NSLog(@"点选了选择按钮2");
    _seleteDevice = aduroDeviceInfo;
    DeviceManager *manager = [DeviceManager sharedManager];
    [manager identify:aduroDeviceInfo];
    //遍历所有的分组
    for (int i=0; i<[_allDeviceAndTagArray count]; i++) {
        NSDictionary *deviceDict = [_allDeviceAndTagArray objectAtIndex:i];
        AduroDevice *myDevice = [deviceDict objectForKey:@"Device"];
        NSNumber *flag = [deviceDict objectForKey:@"Flag"];
        BOOL isCheck = [flag boolValue];
        if (myDevice.deviceID == _seleteDevice.deviceID) {
            isCheck = YES;
            NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
            [_allDeviceAndTagArray replaceObjectAtIndex:i withObject:tempDeviceDict];
        }else{
            if (isCheck) {
                isCheck = NO;
                NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                [_allDeviceAndTagArray replaceObjectAtIndex:i withObject:tempDeviceDict];
            }
        }
    }
    [_taskDeviceTableView reloadData];

}

//-(void)lightDeviceShowDetailWithAduroInfo:(AduroDevice *)aduroDevice{
//    if (aduroDevice.deviceID == nil) {
//        return;
//    }
//
//    switch (aduroDevice.deviceTypeID)
//    {
//        case 0x0105://可调颜色灯,有调光、开关功能
//        case 0x0102://彩灯
//        case 0x0210://飞利浦彩灯
//        case 0x0110://色温灯
//        case 0x0220:
//        case 0x0101://调光灯
//        case 0x0200://彩灯
//        {
//            ASDeviceDetailViewController *detailvc = [[ASDeviceDetailViewController alloc]init];
//            [detailvc setAduroDeviceInfo:aduroDevice];
//            [self setHidesBottomBarWhenPushed:YES];
//            [self.navigationController pushViewController:detailvc animated:NO];
//            [self setHidesBottomBarWhenPushed:NO];
//        }
//            break;
//    }
//  
//}

-(void)lightDeviceChangeAlpha:(CGFloat )value{
    _theLevel = value;
}

-(void)lightDeviceSwitchChange:(BOOL)isSwitchOn{
    _theSwitchOnOrOff = isSwitchOn;
}

#pragma mark - ASDeviceDetailDelegate
- (void)selectViewController:(ASDeviceDetailViewController *)selectedVC didSelectColor:(UIColor *)color{
    _theColor = color;
}

-(void)didSelectDeviceBtnAction{
    if (_seleteDevice == nil) {
        UIAlertView *selectAlert = [[UIAlertView alloc]initWithTitle:nil message:[ASLocalizeConfig localizedString:@"请选择一个设备"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [selectAlert show];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(selectTaskViewController:didSelectDevice:withSignString:withColor:withLevel:withIsSwitchOn:)]) {

        [self.delegate selectTaskViewController:self didSelectDevice:_seleteDevice withSignString:@"device" withColor:_theColor withLevel:_theLevel withIsSwitchOn:_theSwitchOnOrOff];
    }
    
    // 关闭当前控制器
    [self.navigationController popViewControllerAnimated:YES];  
}

-(void)backToBeforeViewBtnAction{
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
