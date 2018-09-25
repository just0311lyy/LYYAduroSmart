//
//  ASGetwayListViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGetwayListViewController.h"
#import "ASQRCodeViewController.h"
#import "ASGetwayListTableViewCell.h"
#import "ASDeviceListViewController.h"
#import "ASRootTabBarViewController.h"
#import "ASGlobalDataObject.h"

#import "ASLocalizeConfig.h"
#import <AduroSmartLib/AduroSmartSDKManager.h>
//#import <iToast.h>

@interface ASGetwayListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    
}

@end

@implementation ASGetwayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ASLocalizeConfig localizedString:@"网关"];
    if (_globalGetwayArray !=nil) {
        [_globalGetwayArray removeAllObjects];
    }    
    [self getLocalGetway];
    [self initWithTableView];
    
}

-(void)initWithTableView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToGuideBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height-64;
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.backgroundColor = VIEW_BACKGROUND_COLOR;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
}

-(void)getLocalGetway{


    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"获取网关数据中……"]];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cancelMBProgressHUD) userInfo:nil repeats:NO];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        //查找当前局域网的网关数
        GatewayManager *gatwayManager = [GatewayManager sharedManager];
        [gatwayManager searchGateways:^(NSArray *gateways) {
//            AduroGateway *gatwayOne = [[AduroGateway alloc] init];
//            gatwayOne.gatewayID = @"aID1111";
//            gatwayOne.gatewayIPv4Address = @"aIP2222";
//            gatwayOne.gatewayName = @"网关01";
//            AduroGateway *gatwayTwo = [[AduroGateway alloc] init];
//            gatwayTwo.gatewayID = @"bID1111";
//            gatwayTwo.gatewayIPv4Address = @"bIP2222";
//            gatwayTwo.gatewayName = @"网关02";
//            [_globalGetwayArray addObjectsFromArray:@[gatwayOne,gatwayTwo]];
            if (gateways)
            {
                [_globalGetwayArray addObjectsFromArray:gateways];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回调或者说是通知主线程刷新，
                    [_tableView reloadData];
                    [self stopMBProgressHUD];
                });
            }else{
                
                
                NSLog(@"请确保10米范围内有网关");
            }
            
        }];
        
    });
    //完成后的通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        DDLogDebug(@"zllNumber = %d",(int)zllNumber);
    });
   
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _globalGetwayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";

    ASGetwayListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASGetwayListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    AduroGateway *gatway = _globalGetwayArray[indexPath.row];
    cell.getwayIpNameLb.text = gatway.gatewayIPv4Address;
    cell.getwayNumberNameLb.text = gatway.gatewayID;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _index = 0;
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    _index = (NSInteger )indexPath;
//    ASDeviceListViewController *deviceVC = [[ASDeviceListViewController alloc] init];
//    deviceVC.getway = _getway;
    //进入扫码页
    [self intoQRcodeCtrl];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASGetwayListTableViewCell getCellHeight];
}

#pragma mark - buttonAction

-(void)intoQRcodeCtrl{
    ASQRCodeViewController *qrcoderVC = [[ASQRCodeViewController alloc] init];
    
    // 扫码成功
    qrcoderVC.ASQRCodeSuncessBlock = ^(ASQRCodeViewController *aqrvc, NSString *qrString){
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *strGatwayUsername = [ud objectForKey:@"info.userName"];
        [ud setObject:qrString forKey:strGatwayUsername];
        ASRootTabBarViewController *rootvc = [[ASRootTabBarViewController alloc] init];
        [aqrvc presentViewController:rootvc animated:YES completion:nil];
    };
    
    // 扫码失败
    qrcoderVC.ASQRCodeFailBlock = ^(ASQRCodeViewController *aqrvc){
//        [[iToast makeText:@"扫描二维码失败"] show];
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    
    // 扫码取消
    qrcoderVC.ASQRCodeCancleBlock = ^(ASQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
//        [[iToast makeText:@"扫描二维码取消"] show];
    };
    
    [self.navigationController pushViewController:qrcoderVC animated:YES];

}

-(void)backToGuideBtnAction{    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancelMBProgressHUD{
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopMBProgressHUD];
    });
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
