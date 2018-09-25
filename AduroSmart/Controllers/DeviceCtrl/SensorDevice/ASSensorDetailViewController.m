//
//  ASSensorDetailViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/29.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSensorDetailViewController.h"
#import "ASSensorStateCell.h"
#import "ASSensorHeaderFooterView.h"
#import "ASGlobalDataObject.h"
#import "ASSensorDataObject.h"
#import "ASDataBaseOperation.h"
#import "ASBatteryLevelView.h"

@interface ASSensorDetailViewController ()<UITableViewDelegate,UITableViewDataSource,ASSensorHeaderFooterViewDelegate>{
    UITableView *_sensorTableView;
    NSMutableArray *_globalSensorTimeArray;
    NSMutableArray *_currentSensorInfoArr; //当前传感器的信息
    NSMutableArray *_currentSensorPowerArr; //当前传感器的电量信息,范围为0-200
    NSInteger _currentPower;//当前传感器的电量
    NSInteger _index;
    
}

@end

@implementation ASSensorDetailViewController
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
    
    self.title = _aduroSensorInfo.deviceName;
    if ([self.aduroSensorInfo.deviceName isEqualToString:@"CIE Device"]) {
        if (self.aduroSensorInfo.deviceZoneType == DeviceZoneTypeMotionSensor) {
            self.title = @"Motion Sensor";
        }else if (self.aduroSensorInfo.deviceZoneType == DeviceZoneTypeContactSwitch){
            self.title = @"Contact Switch";
        }
    }

    if (_globalSensorTimeArray == nil) {
        _globalSensorTimeArray = [[NSMutableArray alloc] init];
    }
    if (_currentSensorInfoArr == nil) {
        _currentSensorInfoArr = [[NSMutableArray alloc] init];
    }
    if (_currentSensorPowerArr == nil) {
        _currentSensorPowerArr = [[NSMutableArray alloc] init];
    }
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [_globalSensorTimeArray addObjectsFromArray:[db selectSensorData]];
    
    for (int i = 0; i<_globalSensorTimeArray.count; i++) {
        ASSensorDataObject *sensorDO = _globalSensorTimeArray[i];
        if ([sensorDO.sensorID isEqualToString:_aduroSensorInfo.deviceID]) {
            if (![sensorDO.sensorData isEqualToString:@""] && sensorDO.sensorData != nil) {
                [_currentSensorInfoArr addObject:sensorDO];
            }
            if (sensorDO.sensorPower >= 0 && sensorDO.sensorPower <= 200) {
                [_currentSensorPowerArr addObject:sensorDO];
            }
        }
    }

    //当前传感器的电量为：
    if (_currentSensorPowerArr.count>0) {
        ASSensorDataObject *sensorPowerDO = [_currentSensorPowerArr firstObject];
        _currentPower = sensorPowerDO.sensorPower;
    }
    [self initWithNavAndView];

}

-(void)initWithNavAndView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backBtnPress) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    UIImageView *sensorImgView = [[UIImageView alloc] init];
    if (self.aduroSensorInfo.deviceZoneType == DeviceZoneTypeContactSwitch) {
        sensorImgView.image = [UIImage imageNamed:@"door_lock_img"];
    }else{
        sensorImgView.image = [UIImage imageNamed:@"pir_people_img"];
    }
    [self.view addSubview:sensorImgView];
    [sensorImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(10);
        make.leading.equalTo(self.view.mas_leading).offset(40);
        make.trailing.equalTo(self.view.mas_trailing).offset(-40);
        make.height.equalTo(sensorImgView.mas_width);
    }];
    
    //电量
    ASBatteryLevelView *levelView = [[ASBatteryLevelView alloc] initWithFrame:CGRectMake(SCREEN_ADURO_WIDTH - 50, 20, 40, 18)];
    levelView.backgroundColor = [UIColor whiteColor];
    
    levelView.currentNum = _currentPower;
    [levelView setNeedsDisplay];
    [self.view addSubview:levelView];

    
    UIView *historyTitleView = [UIView new];
    [self.view addSubview:historyTitleView];
    historyTitleView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [historyTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sensorImgView.mas_bottom);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(40));
    }];

    UILabel *historyLb = [UILabel new];
    [historyTitleView addSubview:historyLb];
    [historyLb setText:[ASLocalizeConfig localizedString:@"历史记录"]];
    [historyLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(historyTitleView.mas_top);
        make.leading.equalTo(historyTitleView.mas_leading).offset(10);
        make.trailing.equalTo(historyTitleView.mas_trailing);
        make.bottom.equalTo(historyTitleView.mas_bottom);
    }];
    
    UIButton *clearBtn = [UIButton new];
    [historyTitleView addSubview:clearBtn];
    clearBtn.layer.cornerRadius = 4.0;
    clearBtn.layer.borderWidth = 1.0;
    clearBtn.layer.borderColor = LOGO_COLOR.CGColor;
    [clearBtn setTitle:[ASLocalizeConfig localizedString:@"Clear record"] forState:UIControlStateNormal];
    [clearBtn setFont:[UIFont systemFontOfSize:13]];
    [clearBtn setTitleColor:LOGO_COLOR forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(historyTitleView.mas_top).offset(2);
        make.trailing.equalTo(historyTitleView.mas_trailing).offset(-10);
        make.width.equalTo(@(100));
        make.bottom.equalTo(historyTitleView.mas_bottom).offset(-2);
    }];
    
    CGRect frame = self.view.frame;
    frame.origin.y = self.view.frame.size.width - 40 - 40 + 10 + 40;
    frame.size.height = self.view.frame.size.height - (self.view.frame.size.width - 40 - 40 + 10 + 40) - 64;
    
    if (!_sensorTableView) {
        _sensorTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];

//        _sensorTableView.backgroundColor = VIEW_BACKGROUND_COLOR;
        [self.view addSubview:_sensorTableView];
        [_sensorTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _sensorTableView.delegate = self;
        _sensorTableView.dataSource = self;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _currentSensorInfoArr.count;
    
}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    ASSensorDataObject *currentSensorDO = _currentSensorInfoArr[indexPath.row];

    UIImage *img = [[UIImage alloc] init];
    if (self.aduroSensorInfo.deviceZoneType == DeviceZoneTypeMotionSensor) {
        img = [UIImage imageNamed:@"sensor_0014"];
    }else if (self.aduroSensorInfo.deviceZoneType == DeviceZoneTypeContactSwitch){
        img = [UIImage imageNamed:@"sensor_0015"];
    }else{
        img = [UIImage imageNamed:@"sensor"];
    }
    cell.imageView.image = img;    
    cell.textLabel.text = currentSensorDO.sensorDataTime;
    cell.detailTextLabel.text = currentSensorDO.sensorData;
    return cell;
}

////设置sectionHeaderView的高度
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 60;
//}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    ASSensorHeaderFooterView *secHeaderView = [ASSensorHeaderFooterView headerViewWithTableView:tableView];
//    secHeaderView.contentView.backgroundColor = [UIColor whiteColor];
//    
//    secHeaderView.sensorName = _sensorArr[section][@"name"];
//    secHeaderView.sensorImgView.image = [UIImage imageNamed:_sensorArr[section][@"imageName"]];
//    secHeaderView.delegate = self;
//    secHeaderView.index = section;
//    //点击的时候刷新表视图
//    secHeaderView.headerViewClick = ^{
//        [tableView reloadData];
//    };
//    
//    return secHeaderView;
//}

//cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASSensorStateCell getCellHeight];
}


-(void)showOrRowStateWith:(NSInteger)index{
    if (_index == index) {
        //点击相同的section时，赋一个在section之外的值，让列表不被展开
        _index = 100;
    }else{
        _index = index;
    }
}

#pragma mark - buttonAction
-(void)backBtnPress{
    if ([self.messageStr isEqualToString:@"messagePush"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)saveBtnPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clearRecordAction{
    //清除缓存
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    BOOL isClear = [db deleteSensorWithID:self.aduroSensorInfo.deviceID];
    if (isClear) {
        [_globalSensorTimeArray removeAllObjects];
        [_currentSensorInfoArr removeAllObjects];
        [_currentSensorPowerArr removeAllObjects];
        [_sensorTableView reloadData];
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
