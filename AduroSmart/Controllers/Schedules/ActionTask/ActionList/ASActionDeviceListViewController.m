//
//  ASActionDeviceListViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/29.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASActionDeviceListViewController.h"
#import "ASGlobalDataObject.h"
@interface ASActionDeviceListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_taskSensorTableView;     //可定时任务设备列表
    NSMutableArray *_canSetAttriSensorArray;     //可以设置属性的设备
    AduroDevice *_seleteSensor; //选中的设备
}

@end

@implementation ASActionDeviceListViewController
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    //    设置导航栏背景图片为一个空的image，这样就透明了
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
//    
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *navImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_ADURO_WIDTH, 64)];
    [self.view addSubview:navImgView];
    [navImgView setImage:[UIImage imageNamed:@"nav_bg"]];
    
    self.title = [ASLocalizeConfig localizedString:@"触发设备"];
    if (_canSetAttriSensorArray == nil) {
        _canSetAttriSensorArray = [[NSMutableArray alloc]init];
    }
    
    for (int i=0; i<[_globalDeviceArray count]; i++) {
        AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:i];
        if (myDevice.deviceTypeID == DeviceTypeIDHumanSensor) {
            [_canSetAttriSensorArray addObject:myDevice];
        }
    }

    [self initWithSceneListView];
}

-(void)initWithSceneListView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToBeforeViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height-64;
    if (!_taskSensorTableView) {
        _taskSensorTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [self.view addSubview:_taskSensorTableView];
        [_taskSensorTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        _taskSensorTableView.delegate = self;
        _taskSensorTableView.dataSource = self;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _canSetAttriSensorArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    AduroDevice *sensor = _canSetAttriSensorArray[indexPath.row];
    cell.textLabel.text = sensor.deviceName;
    if (sensor.deviceZoneType == DeviceZoneTypeContactSwitch) {
        cell.imageView.image = [UIImage imageNamed:@"sensor_0015"];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"sensor_0014"];
    }
//    else{
//        cell.imageView.image = [UIImage imageNamed:@"sensor"];
//    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",sensor.shortAdr];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(selectTaskViewController:didSelectSensor:)]) {
        AduroDevice *selectSensor = _canSetAttriSensorArray[indexPath.row];
        DeviceManager *manager = [DeviceManager sharedManager];
        [manager identify:selectSensor];
        [self.delegate selectTaskViewController:self didSelectSensor:selectSensor];
    }
    // 关闭当前控制器
    [self.navigationController popViewControllerAnimated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
