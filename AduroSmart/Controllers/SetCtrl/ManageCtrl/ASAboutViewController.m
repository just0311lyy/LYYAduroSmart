//
//  ASAboutViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/24.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASAboutViewController.h"
//#import "ASAboutCell.h"
#import "ASGlobalDataObject.h"
@interface ASAboutViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *_aboutTableView;
//    UIView *_aboutView;
    NSArray *_dataArr;
}

@end

@implementation ASAboutViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"关于"];
    self.view.backgroundColor = [UIColor darkGrayColor];
//    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    [self initAboutZigBeeView];
    [self initWithAboutData];
    
}

-(void)initAboutZigBeeView{
    
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToSettingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;

    [self initWithAboutTableView];
    
}

-(void)initWithAboutTableView{


    _aboutTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - 64) style:UITableViewStyleGrouped];
    [self.view addSubview:_aboutTableView];
//    _aboutTableView.backgroundColor = [UIColor darkGrayColor];
    [_aboutTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    _aboutTableView.delegate = self;
    _aboutTableView.dataSource = self;
  
}

-(void)initWithAboutData{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    _dataArr = @[
  @[@{@"name":@"Version",@"IDNumber":[NSString stringWithFormat:@"%@",app_Version],@"softwareVersion ":@""},
  @{@"name":@"Terms&conditions",@"IDNumber":@"",@"softwareVersion ":@""},
  @{@"name":@"Privacy policy",@"IDNumber":@"",@"softwareVersion ":@""},
  @{@"name":@"Open source licenses",@"IDNumber":@"",@"softwareVersion ":@""},
],
  @[@{@"name":@"ID",@"IDNumber":@"001788FFFE28118A",@"softwareVersion ":@""},
  @{@"name":@"Model",@"IDNumber":@"BSB001",@"softwareVersion ":@""},
  @{@"name":@"software Version",@"IDNumber":@"5.23.1.13452",@"softwareVersion ":@""}],
  @[@{@"name":@"Dome Light",@"IDNumber":@"Model:LTW001",@"softwareVersion ":@"software Version:5.50.1.16698"},
  @{@"name":@"Sensors",@"IDNumber":@"Model:LCT001",@"softwareVersion ":@"software Version:5.23.1.13452"}]];

    GatewayManager *gatewayManager = [GatewayManager sharedManager];
    [gatewayManager getGatewayVersion:^(NSString *gatewayMac, NSString *getewayVersion, NSString *bootloaderVersion) {
        DLog(@"gatewayMac = %@,getewayVersion = %@,bootloaderVersion = %@",gatewayMac,getewayVersion,bootloaderVersion);
        _dataArr = @[
  @[@{@"name":@"Version",@"IDNumber":[NSString stringWithFormat:@"%@",app_Version],@"softwareVersion ":@""},
    @{@"name":@"Terms&conditions",@"IDNumber":@"",@"softwareVersion ":@""},
    @{@"name":@"Privacy policy",@"IDNumber":@"",@"softwareVersion ":@""},
    @{@"name":@"Open source licenses",@"IDNumber":@"",@"softwareVersion ":@""},
    ],
  @[@{@"name":@"ID",@"IDNumber":@"001788FFFE28118A",@"softwareVersion ":@""},
    @{@"name":@"Model",@"IDNumber":@"BSB001",@"softwareVersion ":@""},
    @{@"name":@"software Version",@"IDNumber":[NSString stringWithFormat:@"%@",getewayVersion],@"softwareVersion ":@""}],
  @[@{@"name":@"Dome Light",@"IDNumber":@"Model:LTW001",@"softwareVersion ":@"software Version:5.50.1.16698"},@{@"name":@"Sensors",@"IDNumber":@"Model:LCT001",@"softwareVersion":@"software Version:5.23.1.13452"}]];
//        _dataArr = @[
//                     @{@"name":@"Aduro Bridge",@"IDNumber":@"ID:001788FFFE28118A",@"modelNumber":@"Model:BSB001",@"softwareVersion":[NSString stringWithFormat:@"Software version:%@",getewayVersion]},
//                     @{@"name":@"ZigBee bulbs",@"IDNumber":@"",@"modelNumber":@"Model:LTW001",@"softwareVersion":@"Software version:5.50.1.16698"},
//                     @{@"name":@"ZigBee sensors",@"IDNumber":@"",@"modelNumber":@"Model:LCT001",@"softwareVersion":@"Software version:5.23.1.13452"}];
        [_aboutTableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{    
    if (section == 0) {
        return [_dataArr[0] count];
    }else if (section == 1){
        return [_dataArr[1] count];
    }else if (section == 2){
        return [_dataArr[2] count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        if (indexPath.section == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.section == 1){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }else if (indexPath.section == 2){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        
    }

    cell.textLabel.text = [[[_dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[[_dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"IDNumber"];

    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;{
    if (section == 0) {
        return @"Smart Home";
    }else if (section == 1){
        return @"ZigBee Bridge";
    }else if (section == 2){
        return @"Devices";
    }else{
        return @"";
    }
}

-(void)termBtnAction{
    DLog(@"term");
}
-(void)privacyBtnAction{
    DLog(@"privacy");
}
-(void)licensesBtnAction{
    DLog(@"licenses");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
-(void)backToSettingBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
