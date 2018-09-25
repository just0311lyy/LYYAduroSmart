//
//  ASAddSceneViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/24.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASAddSceneViewController.h"
#import "ASGlobalDataObject.h"
//#import "ASAddHomeDeviceViewController.h"
#import "ASGroupSelectCell.h"
#import "ASDeviceSelectCell.h"

#define TAG_SUCCESS_ADD_SCENE 8900  //添加场景成功
//#define TAG_SAVE_SENCE_HEAD_FAIL 9910

#define TAG_GROUPS 10000
#define TAG_DEVICES 10001
@interface ASAddSceneViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ASGroupSelectCellDelegate,ASDeviceSelectCellDelegate>{
    UITableView *_sceneDeviceTableView;
    UITableView *_sceneGroupTableView;
    UITextField *_txtSceneNameLb;

    //场景内的选定的单个分组
    AduroGroup *_theGroupOfScene;
    NSMutableArray *_deviceOfGroupArray;
    //场景内设备列表
    NSMutableArray *_devicesOfSceneArray;
    //点击了哪一行
    NSInteger clickIndex;
    //存储所有的分组和它对应的状态
    NSMutableArray *_allGroupAndTagArray;
}

@end

@implementation ASAddSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ASLocalizeConfig localizedString:@"新建"];
    if (!_devicesOfSceneArray) {
        _devicesOfSceneArray = [[NSMutableArray alloc]init];
    }
    if (!_deviceOfGroupArray) {
        _deviceOfGroupArray = [[NSMutableArray alloc]init];
    }
    if (!_allGroupAndTagArray) {
        _allGroupAndTagArray = [[NSMutableArray alloc]init];
    }

    for (int i=0; i<[_globalGroupArray count]; i++) {
        AduroGroup *myGroup = [_globalGroupArray objectAtIndex:i];
        NSDictionary *groupDict = [[NSDictionary alloc]initWithObjectsAndKeys:myGroup,@"Group",[NSNumber numberWithBool:NO],@"Flag", nil];
        [_allGroupAndTagArray addObject:groupDict];
    }
    
    [self initWithNewSceneView];
    
    //勾选了的数据
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectDeviceOrGroupIntoScene:) name:@"selectDeviceOrGroupIntoScene" object:nil];
}

-(void)initWithNewSceneView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backSceneViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarBtn setImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(saveNewSceneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    rightBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    //-----自定场景名
    UIView *txtView = [[UIView alloc] init];
    [self.view addSubview:txtView];
    [txtView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(50));
    }];
    
//    UILabel *sceneNameLb = [UILabel new];
//    [sceneNameLb setText:[ASLocalizeConfig localizedString:@"名称"]];
//    [txtView addSubview:sceneNameLb];
//    [sceneNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(txtView.mas_leading).offset(20);
//        make.centerY.equalTo(txtView.mas_centerY);
//        make.width.equalTo(@(50));
//        make.height.equalTo(@(40));
//    }];
    
#warning txt输入不能为空
    _txtSceneNameLb = [[UITextField alloc] init];
    [txtView addSubview:_txtSceneNameLb];
    //    [_txtOfDeviceName setSecureTextEntry:NO];//密码形式
    [_txtSceneNameLb setDelegate:self];
    [_txtSceneNameLb setPlaceholder:[ASLocalizeConfig localizedString:@"请输入场景名"]];
    [_txtSceneNameLb setBorderStyle:UITextBorderStyleNone];
    [_txtSceneNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(txtView.mas_top).offset(5);
        make.leading.equalTo(txtView.mas_leading).offset(10);
        make.trailing.equalTo(txtView.mas_trailing).offset(-10);
        make.height.equalTo(@(42));
    }];

    //cell分割线
    UIView *separatorView = [[UIView alloc]init];
    separatorView.backgroundColor = LOGO_COLOR;
    [txtView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(txtView.mas_leading).offset(10);
        make.trailing.equalTo(txtView.mas_trailing).offset(-10);
        make.height.equalTo(@(1));
        make.bottom.equalTo(txtView.mas_bottom);
    }];
    //group 标题
    UIView *groupTitleView = [UIView new];
    groupTitleView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.view addSubview:groupTitleView];
    [groupTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(txtView.mas_bottom);
        make.leading.equalTo(txtView.mas_leading);
        make.trailing.equalTo(txtView.mas_trailing);
        make.height.equalTo(@(35));
    }];
    
    UILabel *groupTitleLb = [UILabel new];
    [groupTitleLb setText:[ASLocalizeConfig localizedString:@"房间列表"]];
    [groupTitleView addSubview:groupTitleLb];
    [groupTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(groupTitleView.mas_top);
        make.bottom.equalTo(groupTitleView.mas_bottom);
        make.leading.equalTo(groupTitleView.mas_leading).offset(20);
        make.trailing.equalTo(groupTitleView.mas_trailing);
    }];
    
    if (!_sceneGroupTableView) {
        _sceneGroupTableView = [[UITableView alloc] init];
        [self.view addSubview:_sceneGroupTableView];
        [_sceneGroupTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_sceneGroupTableView setTag:TAG_GROUPS];
        [_sceneGroupTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(groupTitleView.mas_bottom);
            make.leading.equalTo(groupTitleView.mas_leading);
            make.trailing.equalTo(groupTitleView.mas_trailing);
            make.height.equalTo(@((SCREEN_ADURO_HEIGHT - 50 - 64)/2.0 - 35));
        }];
        _sceneGroupTableView.delegate = self;
        _sceneGroupTableView.dataSource = self;
    }
    
    //device 标题  ----------
    UIView *deviceTitleView = [UIView new];
    deviceTitleView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.view addSubview:deviceTitleView];
    [deviceTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_sceneGroupTableView.mas_bottom);
        make.leading.equalTo(_sceneGroupTableView.mas_leading);
        make.trailing.equalTo(_sceneGroupTableView.mas_trailing);
        make.height.equalTo(@(35));
    }];
    
    UILabel *deviceTitleLb = [UILabel new];
    [deviceTitleLb setText:[ASLocalizeConfig localizedString:@"设备列表"]];
    [deviceTitleView addSubview:deviceTitleLb];
    [deviceTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(deviceTitleView.mas_top);
        make.bottom.equalTo(deviceTitleView.mas_bottom);
        make.leading.equalTo(deviceTitleView.mas_leading).offset(20);
        make.trailing.equalTo(deviceTitleView.mas_trailing);
    }];

    if (!_sceneDeviceTableView) {
        _sceneDeviceTableView = [[UITableView alloc] init];
        [self.view addSubview:_sceneDeviceTableView];
        [_sceneDeviceTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_sceneDeviceTableView setTag:TAG_DEVICES];
        [_sceneDeviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(deviceTitleView.mas_bottom);
            make.leading.equalTo(_sceneGroupTableView.mas_leading);
            make.trailing.equalTo(_sceneGroupTableView.mas_trailing);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
        _sceneDeviceTableView.delegate = self;
        _sceneDeviceTableView.dataSource = self;
    }
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == TAG_DEVICES) {
        return [_deviceOfGroupArray count];
    }else if (tableView.tag == TAG_GROUPS) {
        return [_globalGroupArray count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == TAG_DEVICES) {
        NSString static *identifier = @"devicecell";
        ASDeviceSelectCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!deviceCell) {
            deviceCell = [[ASDeviceSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [deviceCell setDelegate:self];
        }
        
        AduroDevice *aduroDeviceInfo = [_deviceOfGroupArray objectAtIndex:indexPath.row];
        [deviceCell setAduroDeviceInfo:aduroDeviceInfo];
//        [deviceCell setCheckboxChecked:NO manual:YES];
//        [deviceCell setClickIndex:indexPath.row];
        return deviceCell;
    }else if (tableView.tag == TAG_GROUPS) {
        NSString static *identifier = @"groupcell";
        ASGroupSelectCell *groupCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!groupCell) {
            groupCell = [[ASGroupSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        NSDictionary *groupDict = [_allGroupAndTagArray objectAtIndex:indexPath.row];
        AduroGroup *aduroGroupInfo = [groupDict objectForKey:@"Group"];
        //是否被点击（选中）
        NSNumber *flag = [groupDict objectForKey:@"Flag"];
        BOOL isCheck = [flag boolValue];
        [groupCell setAduroGroupInfo:aduroGroupInfo];
        [groupCell setCheckboxChecked:isCheck manual:YES];
        [groupCell setDelegate:self];
        [groupCell setClickIndex:indexPath.row];
        return groupCell;
    }else{
        return nil;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //保存用户点击的设备的索引
    clickIndex = indexPath.row;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASGroupSelectCell getCellHeight];
}

#pragma mark - NSNotification 点选的设备和房间
-(void)selectDeviceOrGroupIntoScene:(NSNotification *)noti{
    
    NSDictionary *dataDict = [noti userInfo];
    if ([[dataDict objectForKey:@"dataType"] isEqualToString:@"device"]) {
        AduroDevice *aduroInfo = [dataDict objectForKey:@"data"];
        [_devicesOfSceneArray addObject:aduroInfo];
        DDLogDebug(@"已经选择的设备2 = %@,_sencesDataArray = %@",aduroInfo.deviceID,_devicesOfSceneArray);
        [_sceneDeviceTableView reloadData];
    }
    if ([[dataDict objectForKey:@"dataType"] isEqualToString:@"group"]) {
        
    }
 
    [self changeSaveButtonState];
}
-(void)changeSaveButtonState{
    if (_theGroupOfScene==nil) {
        //如果没有选择任何设备则禁用保存按钮
        [self.navigationItem.rightBarButtonItem setEnabled:([_devicesOfSceneArray count]>0)];
    }
}

#pragma mark - ASDeviceSelectCellDelegate
-(void)deviceSelectedWithAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{
    BOOL noExist = YES;
    for (int i=0; i<[_devicesOfSceneArray count]; i++) {
        AduroDevice *myDevice = [_devicesOfSceneArray objectAtIndex:i];
        if ([myDevice.deviceID isEqualToString:aduroDeviceInfo.deviceID]) {
            noExist = NO;
            [_devicesOfSceneArray removeObjectAtIndex:i];
        }
    }
    if (noExist) {
        [_devicesOfSceneArray addObject:aduroDeviceInfo];
    }
}

#pragma mark - ASGroupSelectCellDelegate
-(void)selectedAduroGroupInfo:(AduroGroup *)aduroGroupInfo{
//    if (_deviceOfGroupArray == nil) {
//        _deviceOfGroupArray = [[NSMutableArray alloc]init];
//    }
    [_deviceOfGroupArray removeAllObjects];
    _theGroupOfScene = aduroGroupInfo;
    for (int j=0; j<[_theGroupOfScene.groupSubDeviceIDArray count]; j++) {
        NSString *deviceID = [_theGroupOfScene.groupSubDeviceIDArray objectAtIndex:j];
        for (int i=0; i<[_globalDeviceArray count]; i++) {
            AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:i];
            //hasSuffix：string 是否以string结尾
            if ([[myDevice.deviceID lowercaseString] hasSuffix:[deviceID lowercaseString]]) {
                [_deviceOfGroupArray addObject:myDevice];
            }
        }
    }
    [_sceneDeviceTableView reloadData];
    
    //遍历所有的分组
    for (int i=0; i<[_allGroupAndTagArray count]; i++) {
        NSDictionary *groupDict = [_allGroupAndTagArray objectAtIndex:i];
        AduroGroup *myGroup = [groupDict objectForKey:@"Group"];
        NSNumber *flag = [groupDict objectForKey:@"Flag"];
        BOOL isCheck = [flag boolValue];
        if (myGroup.groupID == _theGroupOfScene.groupID) {
            isCheck = YES;
            NSDictionary *tempGroupDict = [[NSDictionary alloc]initWithObjectsAndKeys:myGroup,@"Group",[NSNumber numberWithBool:isCheck],@"Flag", nil];
            [_allGroupAndTagArray replaceObjectAtIndex:i withObject:tempGroupDict];
        }else{
            if (isCheck) {
                isCheck = NO;
                NSDictionary *tempGroupDict = [[NSDictionary alloc]initWithObjectsAndKeys:myGroup,@"Group",[NSNumber numberWithBool:isCheck],@"Flag", nil];
                [_allGroupAndTagArray replaceObjectAtIndex:i withObject:tempGroupDict];
            }
        }
    }
    [_sceneGroupTableView reloadData];
}


//#pragma mark - buttomAction
//- (void)addDeviceBtnAction {
//    self.hidesBottomBarWhenPushed = YES;
//    ASAddHomeDeviceViewController *sceneDeVC = [[ASAddHomeDeviceViewController alloc] init];
//    sceneDeVC.title = _txtSceneNameLb.text;
//    [self.navigationController pushViewController:sceneDeVC animated:YES];
//    self.hidesBottomBarWhenPushed = YES;
//}

-(void)backSceneViewBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveNewSceneBtnAction{
    NSString *sceneName = [_txtSceneNameLb text];
    if ([sceneName length]<1||[sceneName length]>20) {
        UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"场景名称长度应在1到20之间"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [failedAlertView show];
        return;
    }
    
    NSLog(@"devices = %@",_devicesOfSceneArray);
    NSLog(@"group = %@",_theGroupOfScene);
    
    __weak SceneManager *sceneManager = [SceneManager sharedManager];
//    [sceneManager addSceneWithName:sceneName group:_theGroupOfScene backScene:^(AduroScene *scene, AduroSmartReturnCode code) {
//        NSLog(@"添加场景名词返回 = %@,%lu",scene,(unsigned long)code);
////        for (int i = 0; i<[_devicesOfSceneArray count]; i++) {
////            AduroDevice *myDevice = [_devicesOfSceneArray objectAtIndex:i];
////            [sceneManager addDevice:myDevice toScene:scene andGroup:_theGroupOfScene completionHandler:^(AduroSmartReturnCode code) {
////                NSLog(@"添加设备到场景返回 = %lu",(unsigned long)code);
////            }];
////        }
//        [sceneManager addDevices:_devicesOfSceneArray toScene:scene andGroup:_theGroupOfScene completionHandler:^(AduroSmartReturnCode code) {
//            NSLog(@"添加设备到场景返回 = %lu",(unsigned long)code);
//        }];
//
//    }];
    UIAlertView *successAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"保存场景成功"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
    [successAlertView setTag:TAG_SUCCESS_ADD_SCENE];
    [successAlertView setDelegate:self];
    [successAlertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_SUCCESS_ADD_SCENE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_SENCES_TABLE object:nil];
        [self.navigationController popViewControllerAnimated:YES];
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
