//
//  ASSetViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSetViewController.h"
#import "ASLoginViewController.h"
#import "UIColor+String.h"
#import "ASGetwayManageViewController.h"
#import "ASDeviceManageViewController.h"
#import "ASHomeManageViewController.h"
#import "ASSceneManageViewController.h"
#import "ASSchedulesManageViewController.h"

#import "ASListCell.h"
#import "ASAboutViewController.h"
#import "ASGuideViewController.h"
#import "ASDeviceDetailViewController.h"
#import "ASSensorDetailViewController.h"
#import "ASQRCodeViewController.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "ASUserDefault.h"
#import "ASGlobalDataObject.h"
#import "ASAccountViewController.h"
#import "ASServerViewController.h"
#define CANCEL_LOGIN_SUCCESS  1111
@interface ASSetViewController ()<UITableViewDelegate,UITableViewDataSource,ASServerViewControllerDelegate>{
    UIBarButtonItem *_rightBarItem;
    UITableView *_tableView;
    NSMutableArray *_dataSourceArray;
    
    UIButton *_loginBtn;
    UIView *_accountView;
    UILabel *_accountNameLb;
    NSString *_domianAddress;
}

@end

@implementation ASSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    self.title = [ASLocalizeConfig localizedString:@"设置"];
    //登陆成功
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.isLogin) {
        [self showLoginSuccessView];
    }
    //登陆成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginSuccessView) name:@"loginSuccess" object:nil];
    //取消登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCancelLoginView) name:@"loginCancel" object:nil];
}

-(void)showLoginSuccessView{
    NSString *accountStr = [ASUserDefault loadUserNameCache];
    NSDictionary *loginDict = @{@"name":[NSString stringWithFormat:@"%@",accountStr],@"imageName":@"cloud_set",@"selector":@"loginBtnAction"};
    [_dataSourceArray replaceObjectAtIndex:0 withObject:loginDict];
    [_tableView reloadData];
}

-(void)showCancelLoginView{
    NSDictionary *accountDict = @{@"name":[ASLocalizeConfig localizedString:@"账号"],@"imageName":@"cloud_set",@"selector":@"loginBtnAction"};
    [_dataSourceArray replaceObjectAtIndex:0 withObject:accountDict];
    [_tableView reloadData];
}

-(void)showServerDomainAddress:(NSString *)serverName{
    NSDictionary *accountDict = @{@"name":serverName,@"imageName":@"server_set",@"selector":@"showSeverNameManageAction",@"showbadgevalue":@""};
    [_dataSourceArray replaceObjectAtIndex:6 withObject:accountDict];
    [_tableView reloadData];
}

//初始化tableView
-(void)initTableView{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,-64, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT)];
    [imgView setImage:[UIImage imageNamed:@"main_background"]];
    [self.view addSubview:imgView];
    
    UILabel *upLineLb = [UILabel new];
    upLineLb.backgroundColor = [UIColor whiteColor];
    upLineLb.alpha = 0.5;
    [self.view addSubview:upLineLb];
    [upLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(0.5));
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(self.view.mas_top);
    }];
    UILabel *downLineLb = [UILabel new];
    downLineLb.backgroundColor = [UIColor whiteColor];
    downLineLb.alpha = 0.5;
    [self.view addSubview:downLineLb];
    [downLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(0.5));
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    GatewayManager *gManager = [GatewayManager sharedManager];
    [gManager getGatewayServerDomain:^(NSString *domain) {
        DLog(@"domain:%@",domain);
        _domianAddress = domain;
        if ([_domianAddress isEqualToString:CHINA_DOMAIN_SERVER_ADDRESS]) {
            [self showServerDomainAddress:[ASLocalizeConfig localizedString:@"Locale China"]];
        }else if ([_domianAddress isEqualToString:EUROPE_DOMAIN_SERVER_ADDRESS]){
            [self showServerDomainAddress:[ASLocalizeConfig localizedString:@"Locale Europe"]];
        }else{
            [self showServerDomainAddress:[ASLocalizeConfig localizedString:@"Domain"]];
        }
    }];
    NSArray *dataArray = @[
@{@"name":[ASLocalizeConfig localizedString:@"账号"],@"imageName":@"cloud_set",@"selector":@"loginBtnAction"},
@{@"name":[ASLocalizeConfig localizedString:@"网关"],@"imageName":@"gateway_set",@"selector":@"getwayManageAction",@"showbadgevalue":@""},
@{@"name":[ASLocalizeConfig localizedString:@"设备"],@"imageName":@"devices_set",@"selector":@"deviceManageAction",@"showbadgevalue":@""},
@{@"name":[ASLocalizeConfig localizedString:@"房间"],@"imageName":@"home_set",@"selector":@"homeManageAction",@"showbadgevalue":@""},
@{@"name":[ASLocalizeConfig localizedString:@"场景"],@"imageName":@"scene_set",@"selector":@"sceneManageAction",@"showbadgevalue":@""},
@{@"name":[ASLocalizeConfig localizedString:@"任务"],@"imageName":@"schedules_set",@"selector":@"scheduleManageAction",@"showbadgevalue":@""},
@{@"name":[ASLocalizeConfig localizedString:@"Domain"],@"imageName":@"server_set",@"selector":@"showSeverNameManageAction",@"showbadgevalue":@""},
@{@"name":[ASLocalizeConfig localizedString:@"关于"],@"imageName":@"about_set",@"selector":@"aboutPageManageAction",@"showbadgevalue":@""}];
    _dataSourceArray = [[NSMutableArray alloc]init];
    [_dataSourceArray addObjectsFromArray:dataArray];

    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [self.view addSubview:_tableView];
        _tableView.layer.cornerRadius = 30;
        _tableView.alpha = 0.8;
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(20);
            make.leading.equalTo(self.view.mas_leading).offset(20);
            make.trailing.equalTo(self.view.mas_trailing).offset(-20);
            make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        }];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(18, 0, 18, 0);
    }
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSourceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"settingCell";
    ASListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.cellView.backgroundColor = [UIColor whiteColor];
    cell.txtLabel.text = [[_dataSourceArray objectAtIndex:indexPath.row] objectForKey:@"name"] ;
    UIImage *manageImg = [UIImage imageNamed:[[_dataSourceArray objectAtIndex:indexPath.row] objectForKey:@"imageName"]];
    cell.imgView.image = manageImg;
//    cell.textLabel.text = [[_dataSourceArray objectAtIndex:indexPath.row] objectForKey:@"name"] ;
//    UIImage *manageImg = [UIImage imageNamed:[[_dataSourceArray objectAtIndex:indexPath.row] objectForKey:@"imageName"]];
//    cell.imageView.image = manageImg;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *method = [[_dataSourceArray objectAtIndex:indexPath.row] objectForKey:@"selector"];
    SEL selector = NSSelectorFromString(method);
    if ([self respondsToSelector:selector]) {
        [self performSelector:selector];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [ASListCell getCellHeight];
}

#pragma mark - 设置管理详情页
-(void)getwayManageAction{
    ASGetwayManageViewController *getwayManagerVC = [[ASGetwayManageViewController alloc]init];

    CATransition *animation = [CATransition animation];
    animation.duration = 0.4;
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self presentModalViewController:getwayManagerVC animated:nil];
    
    
//    [self presentViewController:getwayManagerVC animated:YES completion:nil];
}
-(void)homeManageAction{
        ASHomeManageViewController *homeManagerCtrl = [[ASHomeManageViewController alloc]init];
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:homeManagerCtrl animated:YES];
        [self setHidesBottomBarWhenPushed:NO];
}
-(void)deviceManageAction{
    ASDeviceManageViewController *deviceManagerVC = [[ASDeviceManageViewController alloc]init];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:deviceManagerVC animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}
-(void)sceneManageAction{
    ASSceneManageViewController *sceneManagerCtrl = [[ASSceneManageViewController alloc]init];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:sceneManagerCtrl animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

-(void)scheduleManageAction{
    
    ASSchedulesManageViewController *schedulesManagervc = [[ASSchedulesManageViewController alloc] init];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:schedulesManagervc animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
    
}

-(void)showSeverNameManageAction{
    
    ASServerViewController *serverManagervc = [[ASServerViewController alloc] init];
    serverManagervc.delegate = self;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:serverManagervc animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
    
}

-(void)aboutPageManageAction{
    ASAboutViewController *detailvc = [[ASAboutViewController alloc] init];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailvc animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

-(void)loginBtnAction{
    if ([ASGlobalDataObject checkLogin]) {
        self.hidesBottomBarWhenPushed = YES;
        ASAccountViewController *accountvc = [[ASAccountViewController alloc] init];
        [self.navigationController pushViewController:accountvc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }else{
        self.hidesBottomBarWhenPushed = YES;
        ASLoginViewController *loginvc = [[ASLoginViewController alloc] init];
        loginvc.setPushStr = @"setPush";
        [self.navigationController pushViewController:loginvc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}

#pragma mark - ASServerViewControllerDelegate
- (void)selectViewController:(ASServerViewController *)selectedVC didSelectServer:(NSString *)serverName{

    NSString *countryName = [NSString stringWithFormat:@"Locale %@",serverName];
    NSDictionary *accountDict = @{@"name":countryName,@"imageName":@"server_set",@"selector":@"showSeverNameManageAction",@"showbadgevalue":@""};
    [_dataSourceArray replaceObjectAtIndex:6 withObject:accountDict];
    [_tableView reloadData];
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
