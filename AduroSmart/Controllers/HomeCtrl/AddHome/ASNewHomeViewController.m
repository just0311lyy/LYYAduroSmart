//
//  ASNewHomeViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASNewHomeViewController.h"
//#import "ASDeviceSelectTableViewCell.h" //cell
#import "ASGlobalDataObject.h"
#import "ASRoomTypeView.h"
#import "ASDataBaseOperation.h"
#import "SelectedCell.h"  //cell
#import "ASTypeGroupViewController.h"

#define TAG_SUCCESS_ADD_GROUP 8900
#define TAG_EDIT_GROUP_SUCCESS 9900
@interface ASNewHomeViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,NewSelectedDelegate,UIAlertViewDelegate,ASTypeGroupSelectedDelegate>{
    
    UITableView *_tableView;  //设备列表
    NSMutableArray *_deviceArray;   //分组内的设备列表
    UITextField *_txtHomeName;
    ASRoomTypeView *_typeView;  //房间类型默认选择
    NSString *_groupTypeId;
    
    //存储所有的设备和它对应的状态
    NSMutableArray *_allDeviceAndTagArray;
    NSMutableArray *_homeDevicesArray; //当前房间已有的设备
    NSMutableArray *_deleteArray; //从房间删除的设备
    NSMutableArray *_addDeviceArray; //添加到房间的设备
    
    NSTimer *_stopHUDTimer; //停止HUE
    //编辑房间的对列
    dispatch_queue_t _myQueue;

}


@end

@implementation ASNewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _groupTypeId = @"01";  //groupTypeId默认为living room
    if (!_deviceArray) {
        _deviceArray = [[NSMutableArray alloc]init];
    }
    if (!_allDeviceAndTagArray) {
        _allDeviceAndTagArray = [[NSMutableArray alloc]init];
    }
    for (int i=0; i<[_globalDeviceArray count]; i++) {
        AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:i];
        NSDictionary *deviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:NO],@"Flag", nil];
        [_allDeviceAndTagArray addObject:deviceDict];
    }
    if (!_deleteArray) {
        _deleteArray = [[NSMutableArray alloc]init];
    }
    if (!_addDeviceArray) {
        _addDeviceArray = [[NSMutableArray alloc]init];
    }
    
    self.title = [ASLocalizeConfig localizedString:@"新建"];
    [self initWithHomeDetail];
    
    [self setupDataByEdit];
}

//若是编辑任务，则走这里
-(void)setupDataByEdit{
    if (self.editGroup != nil) {
        self.title = [ASLocalizeConfig localizedString:@"编辑"];
        NSArray *array = [self.editGroup.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
        NSString *name = [array firstObject];
        NSString *typeId = [array lastObject];
        _groupTypeId = typeId;
        [_txtHomeName setText:name];
        if ([typeId isEqualToString:@"01"]) {
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"living_room_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"客厅"];
        }else if ([typeId isEqualToString:@"02"]){
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"kitchen_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"厨房"];
        }else if ([typeId isEqualToString:@"03"]){
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"bedroom_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"卧室"];
        }else if ([typeId isEqualToString:@"04"]){
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"bathroom_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"浴室"];
        }
        else if ([typeId isEqualToString:@"05"]){
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"restaurant_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"餐厅"];
        }
        else if ([typeId isEqualToString:@"06"]){
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"toilet_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"厕所"];
        }
        else if ([typeId isEqualToString:@"07"]){
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"office_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"办公室"];
        }
        else if ([typeId isEqualToString:@"08"]){
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"hallway_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"走廊"];
        }
        else{
            [_typeView.roomImgView setImage:[UIImage imageNamed:@"living_room_white"]];
            _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"客厅"];
        }
        //获取房间已有设备
        if (!_homeDevicesArray) {
            _homeDevicesArray = [[NSMutableArray alloc]init];
        }
        [self getDevicesOfHomeArray];
        if (_homeDevicesArray.count>0) {
            for (int i =0; i < _homeDevicesArray.count; i++) {
                AduroDevice *homeDevice = [_homeDevicesArray objectAtIndex:i];
                //遍历所有的分组
                for (int j=0; j<[_allDeviceAndTagArray count]; j++) {
                    NSDictionary *deviceDict = [_allDeviceAndTagArray objectAtIndex:j];
                    AduroDevice *myDevice = [deviceDict objectForKey:@"Device"];
                    NSNumber *flag = [deviceDict objectForKey:@"Flag"];
                    BOOL isCheck = [flag boolValue];
                    if ([myDevice.deviceID isEqualToString:homeDevice.deviceID]) {
                        isCheck = YES;
                        NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                        [_allDeviceAndTagArray replaceObjectAtIndex:j withObject:tempDeviceDict];
                    }
                }
            }
        }
 
    }
}

-(void)getDevicesOfHomeArray{
    GroupManager *groupManager = [GroupManager sharedManager];
    [groupManager getDevicesOfGroup:_editGroup devices:^(NSArray *devices) {
        [_homeDevicesArray addObjectsFromArray:devices];
    }];
}

-(void)initWithHomeDetail{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"完成"] forState:UIControlStateNormal];
    [rightBarBtn setFont:[UIFont systemFontOfSize:16]];
    rightBarBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    //-----自定义房间名
    UIView *topView = [[UIView alloc] init];
    [self.view addSubview:topView];
//    topView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(160));
    }];
    
    UIImageView *bgView = [[UIImageView alloc] init];
    [bgView setImage:[UIImage imageNamed:@"add_room_bg"]];
    [topView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(topView.mas_bottom);
        make.leading.equalTo(topView.mas_leading);
        make.trailing.equalTo(topView.mas_trailing);
        make.height.equalTo(@(SCREEN_ADURO_WIDTH * 476 /750));
    }];
    
#warning txt输入不能为空
    _txtHomeName = [[UITextField alloc] init];
    [topView addSubview:_txtHomeName];
    //    [_txtOfDeviceName setSecureTextEntry:NO];//密码形式
    _txtHomeName.layer.cornerRadius = 4;
    _txtHomeName.layer.borderWidth = 1 ;
    _txtHomeName.layer.borderColor = [UIColor whiteColor].CGColor;
    _txtHomeName.backgroundColor = [UIColor clearColor];
    _txtHomeName.textColor = [UIColor whiteColor];
    [_txtHomeName setDelegate:self];
    [_txtHomeName setPlaceholder:[ASLocalizeConfig localizedString:@"请输入房间名"]];
    [_txtHomeName setText:[ASLocalizeConfig localizedString:@"客厅"]];  //新建房间默认选择客厅
    if (self.editGroup) { //编辑房间
        [_txtHomeName setText:self.editGroup.groupName];
    }
    [_txtHomeName setBorderStyle:UITextBorderStyleRoundedRect];
    [_txtHomeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_top).offset(20);
        make.leading.equalTo(topView.mas_leading).offset(20);
        make.trailing.equalTo(topView.mas_trailing).offset(-20);
        make.height.equalTo(@(40));
    }];
    
    _typeView = [[ASRoomTypeView alloc] init];
    _typeView.typeNameLb.text = [ASLocalizeConfig localizedString:@"房间类型"];
    [_typeView.typeNameLb setTextColor:[UIColor whiteColor]];
    _typeView.roomImgView.image = [UIImage imageNamed:@"living_room_white"];
    [_typeView.roomImgView setTintColor:[UIColor whiteColor]];
    _typeView.roomNameLb.text = [ASLocalizeConfig localizedString:@"客厅"];
    [_typeView.roomNameLb setTextColor:[UIColor whiteColor]];
    [topView addSubview:_typeView];
    [_typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(topView.mas_leading);
        make.trailing.equalTo(topView.mas_trailing);
        make.bottom.equalTo(topView.mas_bottom);
        make.height.equalTo(@(80));
    }];
    
    UIButton *typeBtn = [UIButton new];
    typeBtn.backgroundColor = [UIColor clearColor];
    [typeBtn addTarget:self action:@selector(typeButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [_typeView addSubview:typeBtn];
    [typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_typeView.mas_leading);
        make.trailing.equalTo(_typeView.mas_trailing);
        make.bottom.equalTo(_typeView.mas_bottom);
        make.top.equalTo(_typeView.mas_top);
    }];
    
    //-----设备选择标题
    UIView *deviceSelectView = [UIView new];
    [self.view addSubview:deviceSelectView];
//    deviceSelectView.backgroundColor = CELL_LIEN_COLOR;
    [deviceSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(topView.mas_leading);
        make.trailing.equalTo(topView.mas_trailing);
        make.height.equalTo(@(35));
        make.top.equalTo(topView.mas_bottom);
    }];
    
    UILabel *lineLb = [[UILabel alloc] init];
    [lineLb setBackgroundColor:CELL_LIEN_COLOR];
    [deviceSelectView addSubview:lineLb];
    [lineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(deviceSelectView.mas_leading);
        make.trailing.equalTo(deviceSelectView.mas_trailing);
        make.height.equalTo(@(1));
        make.bottom.equalTo(deviceSelectView.mas_bottom);
    }];
    
    UILabel *deviceSelectLb = [[UILabel alloc] init];
    [deviceSelectView addSubview:deviceSelectLb];
    [deviceSelectLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(deviceSelectView.mas_leading).offset(23);
        make.trailing.equalTo(deviceSelectView.mas_trailing);
        make.top.equalTo(deviceSelectView.mas_top);
        make.bottom.equalTo(deviceSelectView.mas_bottom);
    }];
    deviceSelectLb.text = [ASLocalizeConfig localizedString:@"设备"];
    deviceSelectLb.font = [UIFont systemFontOfSize:16];
    [deviceSelectLb setTextColor:[UIColor darkGrayColor]];
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [self.view addSubview:_tableView];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(deviceSelectView.mas_bottom);
            make.leading.equalTo(topView.mas_leading);
            make.trailing.equalTo(topView.mas_trailing);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
//    //右下角悬浮添加设备按钮
//    UIButton *addDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.view addSubview:addDeviceBtn];
//    [addDeviceBtn setBackgroundImage:[UIImage imageNamed:@"button_fab_add"] forState:UIControlStateNormal];
//    [addDeviceBtn addTarget:self action:@selector(addHomeDeviceBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    [addDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.equalTo(_tableView.mas_trailing).offset(-25);
//        make.bottom.equalTo(_tableView.mas_bottom).offset(-79);
//        make.width.equalTo(@(50));
//        make.height.equalTo(@(50));
//    }];
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 0 ;
    if (_globalDeviceArray) {
        if ([_globalDeviceArray count]>0) {
            rowCount = [_globalDeviceArray count];
        }
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    SelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SelectedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }
    NSDictionary *deviceDict = [_allDeviceAndTagArray objectAtIndex:indexPath.row];
    AduroDevice *aduroDeviceInfo = [deviceDict objectForKey:@"Device"];
    //是否被点击（选中）
    NSNumber *flag = [deviceDict objectForKey:@"Flag"];
    BOOL isCheck = [flag boolValue];
    [cell setAduroDeviceInfo:aduroDeviceInfo];
    [cell setCheckboxChecked:isCheck];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [SelectedCell getCellHeight];
}

#pragma mark 设备列表里点选钮触发的回调事件
-(void)deviceSelected:(BOOL)isSelected WithAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{
    if (self.editGroup != nil) { //编辑房间走这里
        if (isSelected) {
            BOOL isNew = YES;
            if (_homeDevicesArray.count>0) {
                for (int i=0; i<_homeDevicesArray.count; i++) {
                    AduroDevice *homeDevice = [_homeDevicesArray objectAtIndex:i];
                    if ([aduroDeviceInfo.deviceID isEqualToString:homeDevice.deviceID]) {
                        isNew = NO;
                    }
                }
            }
            //要添加到房间的设备
            if (isNew) {
                DeviceManager *manager = [DeviceManager sharedManager];
                [manager identify:aduroDeviceInfo];
                [_addDeviceArray addObject:aduroDeviceInfo];
            }
            
            //记录当前选中未选中的状态
            for (int i=0; i<[_allDeviceAndTagArray count]; i++) {
                NSDictionary *deviceDict = [_allDeviceAndTagArray objectAtIndex:i];
                AduroDevice *myDevice = [deviceDict objectForKey:@"Device"];
                NSNumber *flag = [deviceDict objectForKey:@"Flag"];
                BOOL isCheck = [flag boolValue];
                if (myDevice.deviceID == aduroDeviceInfo.deviceID) {
                    isCheck = YES;
                    NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                    [_allDeviceAndTagArray replaceObjectAtIndex:i withObject:tempDeviceDict];
                }
            }
        
        }else{
            //要从房间删除的设备
            BOOL isDelete = NO;
            if (_homeDevicesArray.count>0) {
                for (int i=0; i<_homeDevicesArray.count; i++) {
                    AduroDevice *homeDevice = [_homeDevicesArray objectAtIndex:i];
                    if ([aduroDeviceInfo.deviceID isEqualToString:homeDevice.deviceID]) {
                        isDelete = YES;
                    }
                }
            }
            if (isDelete) {
                [_deleteArray addObject:aduroDeviceInfo];
            }
            
            //记录当前选中未选中的状态
            for (int i=0; i<[_allDeviceAndTagArray count]; i++) {
                NSDictionary *deviceDict = [_allDeviceAndTagArray objectAtIndex:i];
                AduroDevice *myDevice = [deviceDict objectForKey:@"Device"];
                NSNumber *flag = [deviceDict objectForKey:@"Flag"];
                BOOL isCheck = [flag boolValue];
                if (myDevice.deviceID == aduroDeviceInfo.deviceID) {
                    isCheck = NO;
                    NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                    [_allDeviceAndTagArray replaceObjectAtIndex:i withObject:tempDeviceDict];
                }
            }
            
        }
    }
    else
    { //新建房间走这里
        DDLogDebug(@"已经选择的设备 = %d",aduroDeviceInfo.shortAdr);
        if (aduroDeviceInfo == nil) {
            return;
        }
//        if ([_deviceArray indexOfObject:aduroDeviceInfo]!=NSNotFound) { //这个对象的索引不在这个数组中
//            [_deviceArray removeObject:aduroDeviceInfo];
//        }else{
//            DeviceManager *manager = [DeviceManager sharedManager];
//            [manager identify:aduroDeviceInfo];
//            [_deviceArray addObject:aduroDeviceInfo];
//        }
        
        //记录当前选中未选中的状态
        if (isSelected) { //选中状态，不论之前是选中还是未选中，都标记为选中
            for (int i=0; i<[_allDeviceAndTagArray count]; i++) {
                NSDictionary *deviceDict = [_allDeviceAndTagArray objectAtIndex:i];
                AduroDevice *myDevice = [deviceDict objectForKey:@"Device"];
                NSNumber *flag = [deviceDict objectForKey:@"Flag"];
                BOOL isCheck = [flag boolValue];
                if (myDevice.deviceID == aduroDeviceInfo.deviceID) {
                    isCheck = YES;
                    NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                    [_allDeviceAndTagArray replaceObjectAtIndex:i withObject:tempDeviceDict];
                }
            }
            //选中则添加到房间数组中
            DeviceManager *manager = [DeviceManager sharedManager];
            [manager identify:aduroDeviceInfo];
            BOOL isExist = YES; //去重
            for (int k=0; k<_deviceArray.count; k++) {
                AduroDevice *oneDevice = [_deviceArray objectAtIndex:k];
                if ([oneDevice.deviceID isEqualToString:aduroDeviceInfo.deviceID]) {
                    isExist = NO;
                }
            }
            if (isExist) {
                [_deviceArray addObject:aduroDeviceInfo];
            }
            
        }else{  //未选中状态 .不论之前是选中还是未选中，都标记为未选中
            for (int i=0; i<[_allDeviceAndTagArray count]; i++) {
                NSDictionary *deviceDict = [_allDeviceAndTagArray objectAtIndex:i];
                AduroDevice *myDevice = [deviceDict objectForKey:@"Device"];
                NSNumber *flag = [deviceDict objectForKey:@"Flag"];
                BOOL isCheck = [flag boolValue];
                if (myDevice.deviceID == aduroDeviceInfo.deviceID) {
                    isCheck = NO;
                    NSDictionary *tempDeviceDict = [[NSDictionary alloc]initWithObjectsAndKeys:myDevice,@"Device",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                    [_allDeviceAndTagArray replaceObjectAtIndex:i withObject:tempDeviceDict];
                }
            }
            for (int k=0; k<_deviceArray.count; k++) {
                AduroDevice *oneDevice = [_deviceArray objectAtIndex:k];
                if ([oneDevice.deviceID isEqualToString:aduroDeviceInfo.deviceID]) {
                    [_deviceArray removeObject:oneDevice];
                }
            }
        }
        
        [self.navigationItem.rightBarButtonItem setEnabled:([_deviceArray count]>0)];
    }
}

-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveBtnAction{
    //创建分组并添加设备
    if ([_txtHomeName.text length]<1||[_txtHomeName.text length]>30) {
        UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"名称长度应在1到30之间"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [failedAlertView show];
    }else{ //如果输入的房间名不为空
        NSString *newName = [_txtHomeName.text stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"-",_groupTypeId]];

        if (_deviceArray.count>0) { //如果有新添加设备
            [self saveGroupInfoWithGroupName:newName];
        }else{ //没有添加设备
            if (_editGroup != nil) {  //编辑状态
                [self saveGroupInfoWithGroupName:newName];
            }else{
                UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"Please select one device at least"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [failedAlertView show];
            }
        }
    }
}

/**
 *  @author xingman.yi, 16-03-21 14:03:53
 *
 *  @brief 保存分组数据
 *
 *  @param result 分组名称
 */
-(void)saveGroupInfoWithGroupName:(NSString *)result{
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _myQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    _stopHUDTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(cancelMBProgressHUD) userInfo:nil repeats:NO];
    if (_editGroup != nil) {
        GroupManager *groupManager = [GroupManager sharedManager];
        [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Updating..."]];
        if (![_editGroup.groupName isEqualToString:result]) {
            [_editGroup setGroupName:result];
            //改名
            dispatch_async(_myQueue, ^{
                [NSThread sleepForTimeInterval:0.8f];
                [groupManager changeGroupName:_editGroup completionHandler:^(AduroSmartReturnCode code) {
                    DLog(@"结束changeGroupName = %@",_editGroup.groupName);
                }];
            });
        }
        //删除旧的设备
        if (_deleteArray.count>0) {
            dispatch_async(_myQueue, ^{
                [NSThread sleepForTimeInterval:0.8f];
                [groupManager deleteDeviceFromGroup:_editGroup devices:_deleteArray completionHandler:^(AduroSmartReturnCode code) {
                    if (code == AduroSmartReturnCodeSuccess) {
                    }
                }];
            });
        }
        //添加新的设备
        dispatch_async(_myQueue, ^{
            [NSThread sleepForTimeInterval:0.8f];
            [groupManager addDevices:_addDeviceArray toGroup:_editGroup isEdit:YES completionHandler:^(AduroSmartReturnCode code) {
                if (code == AduroSmartReturnCodeSuccess) {
                    sleep(1);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self stopMBProgressHUD];
                        if (_stopHUDTimer) {
                            if ([_stopHUDTimer isValid]) {
                                [_stopHUDTimer invalidate];
                            }else{
                                _stopHUDTimer = nil;
                            }
                        }
                        [self editGroupSuccess];
                    });
                }
            }];
        });
    }else{
//        _stopHUDTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(cancelMBProgressHUD) userInfo:nil repeats:NO];
        [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Saving..."]];
        __weak GroupManager *groupManager = [GroupManager sharedManager];
        [groupManager addGroupByName:result andDevices:_deviceArray completionHandler:^(AduroGroup *group) {
            DLog(@"add group name = %@",group);
            [groupManager addDevices:_deviceArray toGroup:group isEdit:NO completionHandler:^(AduroSmartReturnCode code) {
                DLog(@"add device to group = %d",(int)code);
            }];
            sleep(0.8 * _deviceArray.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopMBProgressHUD];
                if (_stopHUDTimer) {
                    if ([_stopHUDTimer isValid]) {
                        [_stopHUDTimer invalidate];
                    }else{
                        _stopHUDTimer = nil;
                    }
                }
                [self saveGroupSuccess];
            });
        }];

    }
}

-(void)cancelMBProgressHUD{
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopMBProgressHUD];
    });
}

-(void)saveGroupSuccess{
    UIAlertView *saveGroupSuccessAlert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"创建房间成功"] delegate:self cancelButtonTitle:nil otherButtonTitles:[ASLocalizeConfig localizedString:@"确定"], nil];
    [saveGroupSuccessAlert setTag:TAG_SUCCESS_ADD_GROUP];
    [saveGroupSuccessAlert show];
}

-(void)editGroupSuccess{
    UIAlertView *editGroupSuccessAlert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"编辑房间成功"] delegate:self cancelButtonTitle:nil otherButtonTitles:[ASLocalizeConfig localizedString:@"确定"], nil];
    [editGroupSuccessAlert setTag:TAG_EDIT_GROUP_SUCCESS];
    [editGroupSuccessAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_SUCCESS_ADD_GROUP) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_GROUP_TABLE object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (alertView.tag == TAG_EDIT_GROUP_SUCCESS) {
//        sleep(1);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_GROUP_TABLE object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)typeButtonPress{
    ASTypeGroupViewController *typeVC = [[ASTypeGroupViewController alloc] init];
    typeVC.delegate = self;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:typeVC animated:YES];
    self.hidesBottomBarWhenPushed = YES;    
    NSLog(@"进入房间类型选择页面");
}

#pragma mark - ASTypeGroupSelectedDelegate
- (void)selectTypeGroupViewController:(ASTypeGroupViewController *)selectedVC didSelectString:(NSString *)typeName andImageName:(NSString *)imageName andTypeId:(NSString *)typeId{
    imageName = [imageName stringByAppendingString:@"_white"];
    _typeView.roomImgView.image = [UIImage imageNamed:imageName];
    _txtHomeName.text = _typeView.roomNameLb.text = typeName;
    _groupTypeId = typeId;
}

//#pragma mark - 保存房间数据到数据库
//-(void)saveRoomDataObject:(AduroGroup *)groupDO{
//    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
//    [db openDatabase];
//    [db saveRoomData:groupDO];
//}

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
