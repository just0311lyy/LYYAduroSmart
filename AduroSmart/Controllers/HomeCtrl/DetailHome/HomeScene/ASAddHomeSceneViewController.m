//
//  ASAddHomeSceneViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/9/14.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASAddHomeSceneViewController.h"
#import "ASGlobalDataObject.h"
#import "ASDeviceSelectCell.h"
#import "ASTypeSceneViewController.h"
#import "ASRoomTypeView.h"
#import "ASDeviceDetailViewController.h"
#define TAG_SUCCESS_ADD_SCENE 8900  //添加场景成功
@interface ASAddHomeSceneViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ASDeviceSelectCellDelegate,ASTypeSceneSelectedDelegate>{

    UITableView *_sceneDeviceTableView;  //设备列表
    UITextField *_txtSceneNameLb;  //场景名
    NSMutableArray *_devicesSelectedArray; //场景内设备列表
    NSTimer *_stopHUDTimer; //停止HUE
    //存储所有的设备和它对应的状态
    NSMutableArray *_allHomeDeviceAndTagArray;
    BOOL _isSuccess; //场景创建是否成功
    
    ASRoomTypeView *_sceneTypeView;
}
@end

@implementation ASAddHomeSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isSuccess = NO;
    self.title = [ASLocalizeConfig localizedString:@"新建场景"];
    if (!_allHomeDeviceAndTagArray) {
        _allHomeDeviceAndTagArray = [[NSMutableArray alloc]init];
    }

    if (!_myDeviceArray) {
        _myDeviceArray = [[NSMutableArray alloc] init];
    }
    for (int j=0; j<_globalDeviceArray.count; j++) {
        AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
        for (NSString *myID in _mySceneGroup.groupSubDeviceIDArray) {
            
            if ([[myDevice.deviceID lowercaseString] isEqualToString:[myID lowercaseString]] && myDevice.deviceTypeID != DeviceTypeIDHumanSensor ){
                [_myDeviceArray addObject:myDevice];
            }
        }
    }

    for (int i=0; i<[_myDeviceArray count]; i++) {
        AduroDevice *myDevice = [_myDeviceArray objectAtIndex:i];
        NSDictionary *deviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:NO],@"Flag", nil];
        [_allHomeDeviceAndTagArray addObject:deviceDict];
    }

    if (!_devicesSelectedArray) {
        _devicesSelectedArray = [[NSMutableArray alloc]init];
    }

    [self initWithNewSceneView];   
}

-(void)initWithNewSceneView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backRoomViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(saveNewSceneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"完成"] forState:UIControlStateNormal];
    [rightBarBtn setFont:[UIFont systemFontOfSize:16]];
    rightBarBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    //-----自定场景名
    UIView *txtView = [[UIView alloc] init];
    [self.view addSubview:txtView];
//    txtView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [txtView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(160));
    }];
    
    UIImageView *bgView = [[UIImageView alloc] init];
    [bgView setImage:[UIImage imageNamed:@"add_room_bg"]];
    [txtView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(txtView.mas_bottom);
        make.leading.equalTo(txtView.mas_leading);
        make.trailing.equalTo(txtView.mas_trailing);
        make.height.equalTo(@(SCREEN_ADURO_WIDTH * 476 /750));
    }];

    _txtSceneNameLb = [[UITextField alloc] init];
    [txtView addSubview:_txtSceneNameLb];
    //    [_txtOfDeviceName setSecureTextEntry:NO];//密码形式
    _txtSceneNameLb.layer.cornerRadius = 4;
    _txtSceneNameLb.layer.borderWidth = 1 ;
    _txtSceneNameLb.layer.borderColor = [UIColor whiteColor].CGColor;
    _txtSceneNameLb.backgroundColor = [UIColor clearColor];
    _txtSceneNameLb.textColor = [UIColor whiteColor];
    [_txtSceneNameLb setDelegate:self];
    [_txtSceneNameLb setPlaceholder:[ASLocalizeConfig localizedString:@"请输入场景名"]];
    [_txtSceneNameLb setText:[ASLocalizeConfig localizedString:@"Leaving home"]];  //新建房间默认选择客厅
    [_txtSceneNameLb setBorderStyle:UITextBorderStyleRoundedRect];
    [_txtSceneNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(txtView.mas_top).offset(20);
        make.leading.equalTo(txtView.mas_leading).offset(20);
        make.trailing.equalTo(txtView.mas_trailing).offset(-20);
        make.height.equalTo(@(40));
    }];
    
    _sceneTypeView = [[ASRoomTypeView alloc] init];
    _sceneTypeView.typeNameLb.text = [ASLocalizeConfig localizedString:@"Scenes"];
//    _sceneTypeView.roomImgView.image = [UIImage imageNamed:@"living_room"];
    _sceneTypeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"Type"];
    [txtView addSubview:_sceneTypeView];
    [_sceneTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(txtView.mas_leading);
        make.trailing.equalTo(txtView.mas_trailing);
        make.bottom.equalTo(txtView.mas_bottom);
        make.height.equalTo(@(80));
    }];
    
    UIButton *typeBtn = [UIButton new];
    typeBtn.backgroundColor = [UIColor clearColor];
    [typeBtn addTarget:self action:@selector(sceneTypeButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [_sceneTypeView addSubview:typeBtn];
    [typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_sceneTypeView.mas_leading);
        make.trailing.equalTo(_sceneTypeView.mas_trailing);
        make.bottom.equalTo(_sceneTypeView.mas_bottom);
        make.top.equalTo(_sceneTypeView.mas_top);
    }];
    
    //设备列表 标题
    UIView *deviceTitleView = [UIView new];
//    deviceTitleView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.view addSubview:deviceTitleView];
    [deviceTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(txtView.mas_bottom);
        make.leading.equalTo(txtView.mas_leading);
        make.trailing.equalTo(txtView.mas_trailing);
        make.height.equalTo(@(35));
    }];
    
    UILabel *lineLb = [[UILabel alloc] init];
    [lineLb setBackgroundColor:CELL_LIEN_COLOR];
    [deviceTitleView addSubview:lineLb];
    [lineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(deviceTitleView.mas_leading);
        make.trailing.equalTo(deviceTitleView.mas_trailing);
        make.height.equalTo(@(1));
        make.bottom.equalTo(deviceTitleView.mas_bottom);
    }];
    
    UILabel *deviceTitleLb = [UILabel new];
    [deviceTitleLb setText:[ASLocalizeConfig localizedString:@"设备列表"]];
    [deviceTitleView addSubview:deviceTitleLb];
    [deviceTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(deviceTitleView.mas_top);
        make.bottom.equalTo(deviceTitleView.mas_bottom);
        make.leading.equalTo(deviceTitleView.mas_leading).offset(22);
        make.trailing.equalTo(deviceTitleView.mas_trailing);
    }];
    
    if (!_sceneDeviceTableView) {
        _sceneDeviceTableView = [[UITableView alloc] init];
        [self.view addSubview:_sceneDeviceTableView];
        [_sceneDeviceTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_sceneDeviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(deviceTitleView.mas_bottom);
            make.leading.equalTo(deviceTitleView.mas_leading);
            make.trailing.equalTo(deviceTitleView.mas_trailing);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
        _sceneDeviceTableView.delegate = self;
        _sceneDeviceTableView.dataSource = self;
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _myDeviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString static *identifier = @"devicecell";
    ASDeviceSelectCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!deviceCell) {
        deviceCell = [[ASDeviceSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [deviceCell setDelegate:self];
    }
    
//    AduroDevice *aduroDeviceInfo = [_myDeviceArray objectAtIndex:indexPath.row];
//    [deviceCell setAduroDeviceInfo:aduroDeviceInfo];
    
    NSDictionary *deviceDict = [_allHomeDeviceAndTagArray objectAtIndex:indexPath.row];
    AduroDevice *aduroDeviceInfo = [deviceDict objectForKey:@"Device"];
    //是否被点击（选中）
    NSNumber *flag = [deviceDict objectForKey:@"Flag"];
    BOOL isCheck = [flag boolValue];
    [deviceCell setAduroDeviceInfo:aduroDeviceInfo];
    [deviceCell setCheckboxChecked:isCheck];
    
    return deviceCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AduroDevice *aduroDevice = [[_allHomeDeviceAndTagArray objectAtIndex:indexPath.row] objectForKey:@"Device"];
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
//            detailvc.delegate = self;
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:detailvc animated:NO];
            [self setHidesBottomBarWhenPushed:YES];
        }
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASDeviceSelectCell getCellHeight];
}

#pragma mark - ASDeviceSelectCellDelegate
-(void)sceneDeviceSelected:(BOOL)isSelected WithAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{

    //记录当前选中未选中的状态
    if (isSelected) { //选中状态，不论之前是选中还是未选中，都标记为选中
        for (int i=0; i<[_allHomeDeviceAndTagArray count]; i++) {
            NSDictionary *deviceDict = [_allHomeDeviceAndTagArray objectAtIndex:i];
            AduroDevice *myDevice = [deviceDict objectForKey:@"Device"];
            NSNumber *flag = [deviceDict objectForKey:@"Flag"];
            BOOL isCheck = [flag boolValue];
            if (myDevice.deviceID == aduroDeviceInfo.deviceID) {
                isCheck = YES;
                NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                [_allHomeDeviceAndTagArray replaceObjectAtIndex:i withObject:tempDeviceDict];
            }
        }
        //选中则添加到房间数组中
        DeviceManager *manager = [DeviceManager sharedManager];
        [manager identify:aduroDeviceInfo];
        BOOL isExist = YES; //去重
        for (int k=0; k<_devicesSelectedArray.count; k++) {
            AduroDevice *oneDevice = [_devicesSelectedArray objectAtIndex:k];
            if ([oneDevice.deviceID isEqualToString:aduroDeviceInfo.deviceID]) {
                isExist = NO;
            }
        }
        if (isExist) {
            [_devicesSelectedArray addObject:aduroDeviceInfo];
        }

    }else{  //未选中状态 .不论之前是选中还是未选中，都标记为未选中
        for (int i=0; i<[_allHomeDeviceAndTagArray count]; i++) {
            NSDictionary *deviceDict = [_allHomeDeviceAndTagArray objectAtIndex:i];
            AduroDevice *myDevice = [deviceDict objectForKey:@"Device"];
            NSNumber *flag = [deviceDict objectForKey:@"Flag"];
            BOOL isCheck = [flag boolValue];
            if (myDevice.deviceID == aduroDeviceInfo.deviceID) {
                isCheck = NO;
                NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                [_allHomeDeviceAndTagArray replaceObjectAtIndex:i withObject:tempDeviceDict];
            }
        }
        for (int k=0; k<_devicesSelectedArray.count; k++) {
            AduroDevice *oneDevice = [_devicesSelectedArray objectAtIndex:k];
            if ([oneDevice.deviceID isEqualToString:aduroDeviceInfo.deviceID]) {
                [_devicesSelectedArray removeObject:oneDevice];
            }
        }
    }
}

-(void)saveNewSceneBtnAction{
    NSString *sceneName = [_txtSceneNameLb text];
    if ([sceneName length]<1||[sceneName length]>20) {
        UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"场景名称长度应在1到20之间"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [failedAlertView show];
        return;
    }
    if (_devicesSelectedArray.count<1) {
        UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"A device should be selected at least"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"Sure"] otherButtonTitles:nil, nil];
        [failedAlertView show];
        return;
    }
    DLog(@"devices = %@",_devicesSelectedArray);
    DLog(@"group = %@",_mySceneGroup);
    
    _stopHUDTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(cancelMBProgressHUD) userInfo:nil repeats:NO];
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Saving..."]];
    
    __weak SceneManager *sceneManager = [SceneManager sharedManager];
    [sceneManager addSceneWithName:sceneName group:_mySceneGroup devices:_devicesSelectedArray backScene:^(AduroScene *scene, AduroSmartReturnCode code) {
        if (code == AduroSmartReturnCodeSuccess) {
            [sceneManager addDevices:_devicesSelectedArray toScene:scene andGroup:_mySceneGroup isEdit:NO completionHandler:^(AduroSmartReturnCode code) {
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                sleep(0.8 * _devicesSelectedArray.count);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopMBProgressHUD];
                    if (_stopHUDTimer) {
                        if ([_stopHUDTimer isValid]) {
                            [_stopHUDTimer invalidate];
                        }else{
                            _stopHUDTimer = nil;
                        }
                    }
                    [self saveSceneSuccess];
                });
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopMBProgressHUD];
                if (_stopHUDTimer) {
                    if ([_stopHUDTimer isValid]) {
                        [_stopHUDTimer invalidate];
                    }else{
                        _stopHUDTimer = nil;
                    }
                }
                [self showCreatSceneFaildAlertView];
            });
        }
    }];
}

-(void)cancelMBProgressHUD{
    //通知主线程刷新   
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopMBProgressHUD];
    });
}

-(void)saveSceneSuccess{
    UIAlertView *successAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"保存场景成功"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
    [successAlertView setTag:TAG_SUCCESS_ADD_SCENE];
    [successAlertView setDelegate:self];
    [successAlertView show];
}

-(void)showCreatSceneFaildAlertView{
    UIAlertView *saveFaildAlert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"Error"] message:[ASLocalizeConfig localizedString:@"Network anomaly"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"OK"] otherButtonTitles:nil, nil];
    [saveFaildAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_SUCCESS_ADD_SCENE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_SENCES_TABLE object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)backRoomViewBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sceneTypeButtonPress{
    ASTypeSceneViewController *typeVC = [[ASTypeSceneViewController alloc] init];
    typeVC.delegate = self;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:typeVC animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    DLog(@"进入场景类型名称选择页面");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_stopHUDTimer) {
        if ([_stopHUDTimer isValid]) {
            [_stopHUDTimer invalidate];
        }else{
            _stopHUDTimer = nil;
        }
    }
}

#pragma mark - ASTypeSceneSelectedDelegate
- (void)selectTypeSceneViewController:(ASTypeSceneViewController *)selectedVC didSelectString:(NSString *)typeName{
    _txtSceneNameLb.text = typeName;
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
