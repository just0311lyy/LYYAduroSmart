//
//  ASGetwayManageViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGetwayManageViewController.h"
#import "ASGlobalDataObject.h"
#import "ASGetwayListViewController.h"
#import "ASQRCodeViewController.h"
#import "ASDeviceListViewController.h"
#import "ASUserDefault.h"
#import "AppDelegate.h"
#import "ASRootTabBarViewController.h"
#import "ASGetwayManageCell.h"
#import "ASGatewayInfoViewController.h"
#import "ASDataBaseOperation.h"
#import <STAlertView.h>
#import <MJRefresh.h>
#import <AFNetworking.h>
#define TAG_GATEWAY_SUCCESS_CONNECT 11111
@interface ASGetwayManageViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,ASGetwayManageCellDelegate,ASGatewayInfoDelegate>{
    UITableView *_gatwayManageTableView;
    //删除的索引
    NSIndexPath *_indexDelete;
    //保存名称的确认框
    STAlertView *_saveGetNameAlert;
    NSTimer *_stopTimer;
//    NSMutableArray *_allGatewayAndTagArr;
    NSMutableArray *_gatewayShowArr;
    BOOL _isVisiable; //是否停止显示HUE：是为停止。NO不用操作
    //
    dispatch_queue_t _deleteQueue;
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;

@end

@implementation ASGetwayManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    if (_allGatewayAndTagArr == nil) {
//        _allGatewayAndTagArr = [[NSMutableArray alloc]init];
//    }
    if (_gatewayShowArr == nil) {
        _gatewayShowArr = [[NSMutableArray alloc]init];
    }
    [self initWithLocalGetway];
    [self initWithGatewayManageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGatewayManageWithNoti) name:@"gatewayManageTableRefresh" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _isVisiable = NO;
    if (_stopTimer) {
        
        if ([_stopTimer isValid]) {
            [_stopTimer invalidate];
        }else{
            _stopTimer = nil;
        }
    }
    [self stopMBProgressHUD];
}

-(void)initWithGatewayManageView{
//    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH,64)];
    UIView *barView = [UIView new];
    barView.backgroundColor = LOGO_COLOR;
    [self.view addSubview:barView];
    [barView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(64));
    }];
    
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToSettingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:leftBarBtn];
//    leftBarBtn.frame = CGRectMake(10, 20, 34, 34);
    [leftBarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(barView.mas_centerY).offset(5);
        make.leading.equalTo(barView.mas_leading).offset(10);
        make.width.equalTo(@(34));
        make.height.equalTo(leftBarBtn.mas_width);
    }];
//标题
    UILabel *titleLabel = [UILabel new];
    [barView addSubview:titleLabel];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(barView.mas_centerY).offset(5);
        make.centerX.equalTo(barView.mas_centerX);
        make.width.equalTo(@(110));
        make.height.equalTo(leftBarBtn.mas_height);
    }];
    [titleLabel setText:[ASLocalizeConfig localizedString:@"网关"]];

    CGRect frame = self.view.frame;
    frame.origin.y = 64 + WJ_HUD_VIEW_HEIGHT;
    frame.size.height = self.view.frame.size.height - 64 - WJ_HUD_VIEW_HEIGHT;
    if (!_gatwayManageTableView) {
        _gatwayManageTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self.view addSubview:_gatwayManageTableView];
        [_gatwayManageTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        _gatwayManageTableView.delegate = self;
        _gatwayManageTableView.dataSource = self;
        _gatwayManageTableView.tableHeaderView = [self headerView];
        _gatwayManageTableView.tableFooterView = [self footerView];
    }
    //下拉刷新 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    _gatwayManageTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadAllGateway)];
}

- (UIView *)headerView
{
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_WIDTH * 0.6)];
        
        UILabel *heardLabel = [UILabel new];
        [_headerView addSubview:heardLabel];
        [heardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_top);
            make.leading.equalTo(_headerView).offset(50);
            make.trailing.equalTo(_headerView).offset(-50);
            make.height.equalTo(@(_headerView.frame.size.height/2.0f));
        }];
        [heardLabel setFont:[UIFont systemFontOfSize:15]];
        [heardLabel setText:NSLocalizedString(@"Here you can manage and view your ZigBee bridges.\nPlease power on device, make sure the device is ready to connect", nil)];
        [heardLabel setTextAlignment:NSTextAlignmentCenter];
        [heardLabel setNumberOfLines:0];
        [heardLabel setTextColor:[UIColor lightGrayColor]];
        [heardLabel setLineBreakMode:NSLineBreakByWordWrapping];
        
    }
    return  _headerView;
}

- (UIView *)footerView
{
    if (_footerView == nil)
    {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_WIDTH * 0.6)];
        UILabel *labPromptAddCamera = [UILabel new];
        [_footerView addSubview:labPromptAddCamera];
        [labPromptAddCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_footerView.mas_top);
            make.leading.equalTo(_footerView).offset(50);
            make.trailing.equalTo(_footerView).offset(-50);
            make.height.equalTo(@(_footerView.frame.size.height/2.0f));
        }];
        [labPromptAddCamera setFont:[UIFont systemFontOfSize:15]];
        [labPromptAddCamera setText:NSLocalizedString(@"Pull down to refresh", nil)];
        [labPromptAddCamera setTextAlignment:NSTextAlignmentCenter];
        [labPromptAddCamera setNumberOfLines:0];
        [labPromptAddCamera setTextColor:[UIColor lightGrayColor]];
        [labPromptAddCamera setLineBreakMode:NSLineBreakByWordWrapping];
    }
    return  _footerView;
}

-(void)initWithLocalGetway{
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"获取网关数据中……"]];
    _stopTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(cancelGatewayMBProgressHUD) userInfo:nil repeats:NO];
    [self getAllGateway];
}

//-(void)refreshGatewayManageWithNoti{
//
//    if (_gatewayShowArr.count>0) {
//        [_gatewayShowArr removeAllObjects];
//    }
//    
//}

-(void)getAllGateway{
    NSArray *array = [self getGatewayDataObject];
    if (array.count > 0) {
        [_gatewayShowArr addObjectsFromArray:array];
        if (_globalCloudGetwayArray.count>0) {  //云端存储网关
            for (AduroGateway *cloudGateway in _globalCloudGetwayArray) {
                BOOL isInArr = YES;  //无重复
                for (AduroGateway *showGateway in _gatewayShowArr){
                    if ([showGateway.gatewayID isEqualToString:cloudGateway.gatewayID]) {
                        isInArr = NO;  //重复
                    }
                }
                if (isInArr) {
                    [_gatewayShowArr addObject:cloudGateway];
                }
            }
        }
    }else{
        if (_globalCloudGetwayArray.count>0) {
            for (AduroGateway *cloudGateway in _globalCloudGetwayArray) {
                BOOL isInArr = YES;  //无重复
                for (AduroGateway *showGateway in _gatewayShowArr){
                    if ([showGateway.gatewayID isEqualToString:cloudGateway.gatewayID]) {
                        isInArr = NO;  //重复
                    }
                }
                if (isInArr) {
                    [_gatewayShowArr addObject:cloudGateway];
                }
            }
        }
    }
    GatewayManager *gatwayManager = [GatewayManager sharedManager];
    [gatwayManager searchOneGateway:^(AduroGateway *gateway)  {
        BOOL isExist = NO; //是否重复
        for (int i=0; i<[_globalGetwayArray count]; i++) {
            AduroGateway *myGateway = [_globalGetwayArray objectAtIndex:i];
            if ([myGateway.gatewayID isEqualToString:gateway.gatewayID]) {
                isExist = YES; //重复
            }
        }
        if (!isExist) {
            //_globalGetwayArray存储当前局域网搜到的网关
            [_globalGetwayArray addObject:gateway]; //不重复，添加
        }
        
        for (AduroGateway *myGateway in _globalGetwayArray) {
            BOOL noExist = YES;  //无重复
            for (int k = 0;k<_gatewayShowArr.count; k++){
                AduroGateway *oneGateway = [_gatewayShowArr objectAtIndex:k];
                if ([oneGateway.gatewayID isEqualToString:myGateway.gatewayID]) {
                    noExist = NO;  //重复
                    [_gatewayShowArr replaceObjectAtIndex:k withObject:myGateway];
                }
            }
            if (noExist) {
                [_gatewayShowArr addObject:myGateway];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            [self refreshTableView];
            if (_isVisiable) {
                [self stopMBProgressHUD];
                if (_stopTimer) {
                    if ([_stopTimer isValid]) {
                        [_stopTimer invalidate];
                    }else{
                        _stopTimer = nil;
                    }
                }
            }
            
            //            [_gatwayManageTableView reloadData];
        });
    }];
}

-(void)cancelGatewayMBProgressHUD{
    [self stopMBProgressHUD];
    if (_stopTimer) {
        if ([_stopTimer isValid]) {
            [_stopTimer invalidate];
        }else{
            _stopTimer = nil;
        }
    }
    if (_globalGetwayArray.count < 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"当前局域网未查找到可连接的网关,请重试。"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [_gatewayShowArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    ASGetwayManageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASGetwayManageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }
    AduroGateway *gatway = [_gatewayShowArr objectAtIndex:indexPath.row];
    [cell setAduroGatewayInfo:nil];
    [cell setAduroGatewayInfo:gatway];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASGetwayManageCell getCellHeight];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //若是已经登录成功的网关，则不用进入扫二维码界面，而是直接登录
    AduroGateway *gateway = _gatewayShowArr[indexPath.row];
    if (![gateway.gatewaySecurityKey isEqualToString:@""] && gateway.gatewaySecurityKey != nil) {
        GatewayManager *gatewayManager = [GatewayManager sharedManager];
        [gatewayManager connectToGateway:gateway completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"网关连接结果code = %d",code);
            if (code == AduroSmartReturnCodeSuccess) {
                AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
                delegate.isConnect=YES;
                [self saveGatewayDataObject:gateway];
                [ASUserDefault saveGatewayIDCache:gateway.gatewayID];
                [ASUserDefault saveGatewayKeyCache:gateway.gatewaySecurityKey];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"网关连接成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil];
                [alert setTag:TAG_GATEWAY_SUCCESS_CONNECT];
                [alert show];
            }
        }];
        [gatewayManager updateGatewayDatatime:[NSDate date] completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"update time = %d",code);
        }];
    }else{ //无Key则扫描二维码
        [self codeViewByGateway:gateway];
    }

    
//    NSArray *array = [self getGatewayDataObject];
//    if (array.count>0)
//    {
//        BOOL isCache = NO;  //选中的网关是否有成功登陆的缓存 默认为NO
//        for (AduroGateway *theGateway in array) {
//            if ([gateway.gatewayID isEqualToString:theGateway.gatewayID]) {
//                isCache = YES;
//                [gateway setGatewaySecurityKey:theGateway.gatewaySecurityKey];
//            }
//        }
//        if (isCache) {
//            //若有连接网关成功的缓存，则直接连接
//            GatewayManager *gatewayManager = [GatewayManager sharedManager];
//            //扫描二维码获得SecurityKey
////            NSString *securityKey = [ASUserDefault loadGatewayKeyCache];
////            [gateway setGatewaySecurityKey:securityKey];
//            [gatewayManager connectToGateway:gateway completionHandler:^(AduroSmartReturnCode code) {
//                DLog(@"网关连接结果code = %d",code);
//                if (code == AduroSmartReturnCodeSuccess) {
//                    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
//                    delegate.isConnect=YES;
//                    [ASUserDefault saveGatewayIDCache:gateway.gatewayID];
//                    [ASUserDefault saveGatewayKeyCache:gateway.gatewaySecurityKey];
//                  
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"网关连接成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil];
//                    [alert setTag:TAG_GATEWAY_SUCCESS_CONNECT];
//                    [alert show];
//                }
//            }];
//            [gatewayManager updateGatewayDatatime:[NSDate date] completionHandler:^(AduroSmartReturnCode code) {
//                DLog(@"update time = %d",code);
//            }];
//        }else{ //无成功登陆的缓存,则进入二维码扫描连接
//            [self codeViewByGateway:gateway];
//        }
//    }
//    else{ //不同则进入二维码扫描连接
//        [self codeViewByGateway:gateway];
//    }
}

-(void)codeViewByGateway:(AduroGateway *)gateway{
    ASQRCodeViewController *qrcoderVC = [[ASQRCodeViewController alloc] init];
    [self presentViewController:qrcoderVC animated:YES completion:nil];
    // 扫码成功
    qrcoderVC.ASQRCodeSuncessBlock = ^(ASQRCodeViewController *aqrvc, NSString *qrString){
        //        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        //        //记录扫描成功后获得的key
        
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
        
        GatewayManager *gatewayManager = [GatewayManager sharedManager];
        //扫描二维码获得SecurityKey
        NSString *securityKey = @"1234567812345678";
        [gateway setGatewaySecurityKey:securityKey];
        [gatewayManager connectToGateway:gateway completionHandler:^(AduroSmartReturnCode code) {
            if (code == AduroSmartReturnCodeSuccess) {
                [self saveGatewayDataObject:gateway];
                AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
                delegate.isConnect=YES;
                [ASUserDefault saveGatewayIDCache:gateway.gatewayID];
                [ASUserDefault saveGatewayKeyCache:gateway.gatewaySecurityKey];
                //记录当前连接的状态
//                [self reloadCurrentGatewayConnect:gateway];
//                for (int i=0; i<[_allGatewayAndTagArr count]; i++) {
//                    NSDictionary *gatewayDict = [_allGatewayAndTagArr objectAtIndex:i];
//                    AduroGateway *myGateway = [gatewayDict objectForKey:@"Gateway"];
//                    NSNumber *flag = [gatewayDict objectForKey:@"Connect"];
//                    BOOL isConnect = [flag boolValue];
//                    if (myGateway.gatewayID == gateway.gatewayID) {
//                        isConnect = YES;
//                        NSDictionary *tempGatewayDict = [[NSDictionary alloc]initWithObjectsAndKeys:myGateway,@"Gateway",[NSNumber numberWithBool:isConnect],@"Connect", nil];
//                        [_allGatewayAndTagArr replaceObjectAtIndex:i withObject:tempGatewayDict];
//                    }else{
//                        if (isConnect) {
//                            isConnect = NO;
//                            NSDictionary *tempGatewayDict = [[NSDictionary alloc]initWithObjectsAndKeys:myGateway,@"Gateway",[NSNumber numberWithBool:isConnect],@"Connect", nil];
//                            [_allGatewayAndTagArr replaceObjectAtIndex:i withObject:tempGatewayDict];
//                        }
//                    }
//                }
                sleep(2.5);  //0.3秒第一次安装则不可读取到数据，1.0秒可以
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"网关连接成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil];
                [alert setTag:TAG_GATEWAY_SUCCESS_CONNECT];
                [alert show];
            }
        }];
        //更新网关时间
        [gatewayManager updateGatewayDatatime:[NSDate date] completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"update time = %d",code);
        }];
    };
    // 扫码失败
    qrcoderVC.ASQRCodeFailBlock = ^(ASQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    // 扫码取消
    qrcoderVC.ASQRCodeCancleBlock = ^(ASQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };

}

//-(void)reloadCurrentGatewayConnect:(AduroGateway *)aduroGateway{
//    for (int i=0; i<[_allGatewayAndTagArr count]; i++) {
//        NSDictionary *gatewayDict = [_allGatewayAndTagArr objectAtIndex:i];
//        AduroGateway *myGateway = [gatewayDict objectForKey:@"Gateway"];
//        NSNumber *flag = [gatewayDict objectForKey:@"Connect"];
//        BOOL isConnect = [flag boolValue];
//        if (myGateway.gatewayID == aduroGateway.gatewayID) {
//            isConnect = YES;
//            NSDictionary *tempGatewayDict = [[NSDictionary alloc]initWithObjectsAndKeys:myGateway,@"Gateway",[NSNumber numberWithBool:isConnect],@"Connect", nil];
//            [_allGatewayAndTagArr replaceObjectAtIndex:i withObject:tempGatewayDict];
//        }else{
//            if (isConnect) {
//                isConnect = NO;
//                NSDictionary *tempGatewayDict = [[NSDictionary alloc]initWithObjectsAndKeys:myGateway,@"Gateway",[NSNumber numberWithBool:isConnect],@"Connect", nil];
//                [_allGatewayAndTagArr replaceObjectAtIndex:i withObject:tempGatewayDict];
//            }
//        }
//    }
//    [_gatwayManageTableView reloadData];
//}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_GATEWAY_SUCCESS_CONNECT) {
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashList" object:nil];
            if ([ASGlobalDataObject checkLogin]) {
                [self sendGatewayIDAndKeyToSevice];
                //网关连接成功，并登录了，则连接远程服务器
                AduroSmartSDKManager *sdkManager = [AduroSmartSDKManager sharedManager];
                [sdkManager connectCloudServer:[ASUserDefault loadUserNameCache] gatewayID:[ASUserDefault loadGatewayIDCache]];
            }
            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [self.view removeFromSuperview];
            [self dismissViewControllerAnimated:YES completion:nil];
            ASRootTabBarViewController *mainVC = [[ASRootTabBarViewController alloc]init];
            app.window.rootViewController = mainVC;

            [app.window makeKeyAndVisible];
            
        }
    }
}

//发送请求上传网关编号和key
-(void)sendGatewayIDAndKeyToSevice{
    NSString *strUserID = [ASUserDefault loadUserIDCache];
    NSString *strGatewayID = [ASUserDefault loadGatewayIDCache];
    NSString *strGatewayKey = [ASUserDefault loadGatewayKeyCache];
    if ([strUserID isEqualToString:@""] || [strGatewayID isEqualToString:@""] || [strGatewayKey isEqualToString:@""]) {return;}
    //发送上传网关的post请求
    NSDictionary *parameters = @{@"user_id": strUserID,@"gateway_num": strGatewayID,@"security_key":strGatewayKey};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //AFNetworking框架不支持解析text/html这种格式,需要手动添加.
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //网关数据上传
    NSString *uploadUrl = [NSString stringWithFormat:@"%@",UPDATE_GATEWAY_MESSAGE_URL];
    [manager POST:uploadUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (responseObject != nil) {
            NSString *sRegReturnCode = [responseObject objectForKey:@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            NSString *echo = @"";
            if(iRegReturnCode != 0 && iRegReturnCode !=3) {
                if(iRegReturnCode == 1) {
                    echo = [ASLocalizeConfig localizedString:@"上传失败"];;
                }
                else if(iRegReturnCode == 2) {
                    echo = [ASLocalizeConfig localizedString:@"未登录"];
                }
                //                else if(iRegReturnCode == 3) {
                //                    echo = [ASLocalizeConfig localizedString:@"该网关已存在"];
                //                }
                else {
                    echo = [ASLocalizeConfig localizedString:@"未定义"];
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"错误"] message:[ASLocalizeConfig localizedString:@"登录状态下,网关连接数据上传失败,请登录后重新连接网关."] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [alert show];
            } else {
                echo = [ASLocalizeConfig localizedString:@"网关数据上传成功"];
                //                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"成功"] message:echo delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                //                alert.tag = SEND_SUCCESS;
                //                [alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"错误"] message:[ASLocalizeConfig localizedString:@"登录状态下,网关连接数据上传失败,请登录后重新连接网关."] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"关闭"] otherButtonTitles:nil, nil];
        [alert show];        
    }];   
}

-(void)tableRefreshLoadAllGateway{
    [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(cancelRefreshGatewayTable) userInfo:nil repeats:NO];
    [_globalGetwayArray removeAllObjects];
    [_gatewayShowArr removeAllObjects];
    [_gatwayManageTableView reloadData];
    [self getAllGateway];
}

-(void)cancelRefreshGatewayTable{
    [_gatwayManageTableView.mj_header endRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isVisiable = YES;
    [self refreshTableView];
}

- (void)refreshTableView
{
    if ([_gatewayShowArr count] > 0) {
        _gatwayManageTableView.tableHeaderView = nil;
    }
    else
    {
        _gatwayManageTableView.tableHeaderView = [self headerView];
    }
    [_gatwayManageTableView reloadData];
}


-(void)backToSettingBtnClick{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - ASGetwayManageCellDelegate
-(void)gatewayShowDetailWithAduroGateway:(AduroGateway *)aduroGateway{
    ASGatewayInfoViewController *getwayVC = [[ASGatewayInfoViewController alloc]init];
    getwayVC.currentGateway = aduroGateway;
    getwayVC.delegate = self;
    [self presentViewController:getwayVC animated:NO completion:nil];
    
}
#pragma mark - ASGetwayInfoViewDelegate
-(void)deleteAduroGatewayCache:(AduroGateway *)aduroGateway{
    for (int i=0 ; i<_globalGetwayArray.count; i++) {
        AduroGateway *globalGateway = [_globalGetwayArray objectAtIndex:i];
        if ([globalGateway.gatewayID isEqualToString:aduroGateway.gatewayID]) {
            [_globalGetwayArray removeObjectAtIndex:i];
        }
    }
    for (int i=0 ; i<_gatewayShowArr.count; i++) {
        AduroGateway *showGateway = [_gatewayShowArr objectAtIndex:i];
        if ([showGateway.gatewayID isEqualToString:aduroGateway.gatewayID]) {
            [_gatewayShowArr removeObjectAtIndex:i];
        }
    }
    for (int i=0 ; i<_gatewayShowArr.count; i++) {
        AduroGateway *cloudGateway = [_gatewayShowArr objectAtIndex:i];
        if ([cloudGateway.gatewayID isEqualToString:aduroGateway.gatewayID]) {
            [_globalCloudGetwayArray removeObjectAtIndex:i];
        }
    }
    [_gatwayManageTableView reloadData];
}

#pragma mark - 保存网关数据到数据库
-(void)saveGatewayDataObject:(AduroGateway *)gateway{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveGatewayData:gateway];
}
#pragma mark - 网关数据库
-(NSArray *)getGatewayDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectGatewayData];
    return array;
}
//更新网关软件版本号
-(void)changeGatewayVersionData:(NSString *)softwareVersion with:(AduroGateway *)gateway{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateGatewayVersionData:softwareVersion WithID:gateway.gatewayID];
}

@end
