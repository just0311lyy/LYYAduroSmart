//
//  ASDeviceEditViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/19.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDeviceEditViewController.h"
#import "ASDataBaseOperation.h"
#import "ASGlobalDataObject.h"
#import "NSString+Wrapper.h"
#import "ASDeviceManageViewController.h"
#define TAG_SUCCESS_EDIT_NAME 100002
@interface ASDeviceEditViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{
    UITextField *_txtOfDeviceName;
    UIImageView *_deviceImgView;
    UILabel *_deviceNameLb;
    UILabel *_deviceIdLb;
}

@end

@implementation ASDeviceEditViewController
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
    
    self.title = _editDevice.deviceName;
    if ([_editDevice.deviceName isEqualToString:@"CIE Device"]) {
        if (_editDevice.deviceZoneType == DeviceZoneTypeMotionSensor) {
            self.title = @"Motion Sensor";
        }else if (_editDevice.deviceZoneType == DeviceZoneTypeContactSwitch){
            self.title = @"Contact Switch";
        }
    }
    [self initWithNavBarBtn];
    [self initWithView];
    
}

-(void)initWithNavBarBtn{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(saveBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"完成"] forState:UIControlStateNormal];
    [rightBarBtn setFont:[UIFont systemFontOfSize:16]];
    rightBarBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
 
}

-(void)initWithView{
    UIView *txtView = [[UIView alloc] init];
    [self.view addSubview:txtView];
    [txtView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(30);
        make.leading.equalTo(self.view.mas_leading).offset(30);
        make.trailing.equalTo(self.view.mas_trailing).offset(-30);
        make.height.equalTo(@(44));
    }];
    
    _txtOfDeviceName = [[UITextField alloc] init];
    [txtView addSubview:_txtOfDeviceName];
    [_txtOfDeviceName setDelegate:self];
    [_txtOfDeviceName setPlaceholder:[ASLocalizeConfig localizedString:@"请输入自定义设备名"]];
    [_txtOfDeviceName setBorderStyle:UITextBorderStyleRoundedRect];
    [_txtOfDeviceName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(txtView.mas_top);
        make.leading.equalTo(txtView.mas_leading);
        make.trailing.equalTo(txtView.mas_trailing);
        make.bottom.equalTo(txtView.mas_bottom);
    }];
    
    UIView *topLineView = [UIView new];
    topLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:topLineView];
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(110);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(1));
    }];
    
    _deviceImgView = [[UIImageView alloc] init];
    if (_editDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
        if (_editDevice.deviceZoneType == DeviceZoneTypeContactSwitch) {
            _deviceImgView.image = [UIImage imageNamed:@"sensor_0015"];
        }else if (_editDevice.deviceZoneType == DeviceZoneTypeMotionSensor){
            _deviceImgView.image = [UIImage imageNamed:@"sensor_0014"];
        }else{
            _deviceImgView.image = [UIImage imageNamed:@"sensor"];
        }
    }else{
        _deviceImgView.image = [UIImage imageNamed:@"light"];
    }
    [self.view addSubview:_deviceImgView];
    [_deviceImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topLineView.mas_top).offset(20);
        make.leading.equalTo(topLineView.mas_leading).offset(30);
        make.width.equalTo(@(50));
        make.height.equalTo(_deviceImgView.mas_width);
    }];
    
    _deviceNameLb = [UILabel new];
    [_deviceNameLb setText:self.editDevice.deviceName];
    [self.view addSubview:_deviceNameLb];
    [_deviceNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_deviceImgView.mas_top);
        make.leading.equalTo(_deviceImgView.mas_trailing);
        make.trailing.equalTo(topLineView.mas_trailing);
        make.bottom.equalTo(_deviceImgView.mas_bottom);
    }];
    
    UILabel *idLabel = [UILabel new];
    [idLabel setText:[ASLocalizeConfig localizedString:@"模型:"]];
    [idLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:idLabel];
    [idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_deviceImgView.mas_bottom).offset(10);
        make.leading.equalTo(_deviceImgView.mas_leading);
        make.width.equalTo(@(60));
        make.height.equalTo(@(44));
    }];
    
    _deviceIdLb = [UILabel new];
    [_deviceIdLb setText:self.editDevice.deviceID];
    [self.view addSubview:_deviceIdLb];
    [_deviceIdLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(idLabel.mas_top);
        make.leading.equalTo(idLabel.mas_trailing);
        make.trailing.equalTo(topLineView.mas_trailing);
        make.bottom.equalTo(idLabel.mas_bottom);
    }];

    UIView *bottomLineView = [[UIView alloc] init];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(idLabel.mas_bottom).offset(20);
        make.leading.equalTo(topLineView.mas_leading);
        make.trailing.equalTo(topLineView.mas_trailing);
        make.height.equalTo(@(1));
    }];  
}

-(void)backBtnAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveBtnAction:(UIButton *)sender{
//    self.editDevice.deviceName = _txtOfDeviceName.text;
    //修改设备名并保存到数据库中
    [self changeNewDeviceName:self.editDevice];

}

/**
 *  @author xingman.yi, 16-04-06 17:04:01
 *
 *  @brief 修改设备名称
 *
 *  @param selectedDevice 需要修改的设备
 */
-(void)changeNewDeviceName:(AduroDevice *)selectedDevice{

    NSString *strName = @"";
//    if (selectedDevice) {
//        strName = [NSString changeName:selectedDevice.deviceName];
//        if (selectedDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
//            if ([selectedDevice.deviceName isEqualToString:@"CIE Device"]) {
//                if (selectedDevice.deviceZoneType == DeviceZoneTypeMotionSensor) {
//                    strName = @"Motion Sensor";
//                }
//                if (selectedDevice.deviceZoneType == DeviceZoneTypeContactSwitch) {
//                    strName = @"Contact Switch";
//                }
//            }
//        }
//    }
//    if ([_txtOfDeviceName.text isEqualToString:strName]) {
//        
//        return;
//    }
    //标记是否重名，NO为未重名，可用
    BOOL isDeviceExist = NO;

    for (AduroDevice *deviceInfo in _globalDeviceArray) {
        strName = [NSString changeName:deviceInfo.deviceName];
        if (deviceInfo.deviceTypeID == DeviceTypeIDHumanSensor) {
            if ([deviceInfo.deviceName isEqualToString:@"CIE Device"]) {
                if (deviceInfo.deviceZoneType == DeviceZoneTypeMotionSensor) {
                    strName = @"Motion Sensor";
                }
                if (deviceInfo.deviceZoneType == DeviceZoneTypeContactSwitch) {
                    strName = @"Contact Switch";
                }
            }
        }
        if ([_txtOfDeviceName.text isEqualToString:strName]) {
            isDeviceExist = YES; //重名了
        }
    }

    if (isDeviceExist) { //是 则重名了
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"名称已存在"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alertView show];
    }else{ //未重名 可用
        if ([_txtOfDeviceName.text length]<1||[_txtOfDeviceName.text length]>30) {
            UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"名称长度应在1到30之间"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
            [failedAlertView show];
        }else{
            [selectedDevice setDeviceName:_txtOfDeviceName.text];
            //更新的名称提交给网关
            DeviceManager *deviceManager = [DeviceManager sharedManager];
            [deviceManager updateDeviceName:selectedDevice completionHandler:^(AduroSmartReturnCode code) {
                DLog(@"更新设备(添加设备)结果code=%d",code);
            }];
            //更新数据库里的设备名称
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *device = [_globalDeviceArray objectAtIndex:i];
                if (selectedDevice.deviceID == device.deviceID) {
                    [device setDeviceName:_txtOfDeviceName.text];
                }
            }
            UIAlertView *successAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"保存成功"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
            [successAlertView setTag:TAG_SUCCESS_EDIT_NAME];
            [successAlertView setDelegate:self];
            [successAlertView show];
            
            //保存数据到数据库
//            [self saveNewDeviceData:selectedDevice];
        }
    }
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_SUCCESS_EDIT_NAME) {
        if (buttonIndex == 0) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_GROUP_TABLE object:nil];
//            [self.navigationController popToRootViewControllerAnimated:YES];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashDeviceList" object:nil];
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
