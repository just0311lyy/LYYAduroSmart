//
//  ASAccountViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/9/27.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASAccountViewController.h"
#import "UIImage+Circle.h"
#import "ASUserDefault.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#define CANCEL_LOGIN_SUCCESS  1111
@interface ASAccountViewController (){
    UILabel *_accountLb;
}

@end

@implementation ASAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ASLocalizeConfig localizedString:@"账号信息"];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.view.backgroundColor = UIColorFromRGB(0Xf7f7f7);
    [self initWithView];
    
   
}

-(void)initWithView{

    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    CGFloat topHeight = 120;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0,0, SCREEN_ADURO_WIDTH, topHeight)];
    [self.view addSubview:topView];
    //    topView.backgroundColor = VIEW_BACKGROUND_COLOR;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_ADURO_WIDTH, (SCREEN_ADURO_WIDTH * 698)/750)];
    [self.view addSubview:imgView];
    UIImage *image = [UIImage imageNamed:@"account_background"];
    imgView.image = image;
    
    UIImageView *headImgView = [UIImageView new];
    [imgView addSubview:headImgView];
    UIImage *headImage = [UIImage imageNamed:@"account_user"];
    headImgView.image = headImage;
    [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(imgView.mas_leading).offset(130);
        make.trailing.equalTo(imgView.mas_trailing).offset(-130);
        make.top.equalTo(imgView.mas_top).offset(40+64);
        make.height.equalTo(@((SCREEN_ADURO_WIDTH - 130*2)*177 /229));
    }];
    
    _accountLb =[UILabel new];
    [imgView addSubview:_accountLb];
    [_accountLb setTextAlignment:NSTextAlignmentCenter];
    [_accountLb setTextColor:[UIColor whiteColor]];
    [_accountLb setFont:[UIFont fontWithName:@"Helvetica Neue Light" size:13]];
    [_accountLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headImgView.mas_bottom).offset(25);
        make.centerX.equalTo(headImgView.mas_centerX);
        make.width.equalTo(@(200));
        make.height.equalTo(@(25));
    }];
    [_accountLb setText:[ASUserDefault loadUserNameCache]];
    
    UIView *pushView = [UIView new];
    [self.view addSubview:pushView];
    pushView.layer.borderWidth = 0.5;
    pushView.layer.borderColor = [UIColorFromRGB(0xe7e7e7) CGColor];
    [pushView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom).offset(25);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(50));
    }];
    
    UILabel *pushLb = [UILabel new];
    [pushView addSubview:pushLb];
    [pushLb setText:[ASLocalizeConfig localizedString:@"Push Message"]];
    [pushLb setTextColor:UIColorFromRGB(0x666666)];
    [pushLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(pushView.mas_centerY);
        make.leading.equalTo(pushView.mas_leading).offset(20);
        make.width.equalTo(@(200));
        make.height.equalTo(@(48));
    }];
    
    UIButton *setNotiBtn = [UIButton new];
    [pushView addSubview:setNotiBtn];
    [setNotiBtn setTitle:[ASLocalizeConfig localizedString:@"Go to set"] forState:UIControlStateNormal];
    setNotiBtn.backgroundColor = UIColorFromRGB(0xffffff);
    setNotiBtn.layer.cornerRadius = 15.0;
    setNotiBtn.layer.borderWidth = 0.5;
    setNotiBtn.layer.borderColor = UIColorFromRGB(0xc8c8c8).CGColor;
    [setNotiBtn setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [setNotiBtn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [setNotiBtn addTarget:self action:@selector(openOrStopPushMessage) forControlEvents:UIControlEventTouchUpInside];
    [setNotiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(pushView.mas_centerY);
        make.trailing.equalTo(pushView.mas_trailing).offset(-10);
        make.width.equalTo(@(90));
        make.height.equalTo(@(30));
    }];
    
    UILabel *pushStateLb = [UILabel new];
    [pushView addSubview:pushStateLb];
    [pushStateLb setTextAlignment:NSTextAlignmentRight];
    [pushStateLb setFont:[UIFont systemFontOfSize:15]];
    if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0f) {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone == setting.types) {
            DLog(@"推送关闭");
            [pushStateLb setText:[ASLocalizeConfig localizedString:@"Close"]];
            [pushStateLb setTextColor:[UIColor redColor]];
        }else{
            DLog(@"推送开启");
            [pushStateLb setText:[ASLocalizeConfig localizedString:@"Open"]];
            [pushStateLb setTextColor:[UIColor greenColor]];
        }
    }else{
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone == type){
            DLog(@"推送关闭");
            [pushStateLb setText:[ASLocalizeConfig localizedString:@"Close"]];
            [pushStateLb setTextColor:[UIColor redColor]];
        }else{
            DLog(@"推送开启");
            [pushStateLb setText:[ASLocalizeConfig localizedString:@"Open"]];
            [pushStateLb setTextColor:[UIColor greenColor]];
        }
    }
    [pushStateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(pushView.mas_centerY);
        make.trailing.equalTo(setNotiBtn.mas_leading).offset(-10);
        make.width.equalTo(@(110));
        make.width.equalTo(@(40));
    }];
    
    UIImageView *surfaceImgView = [UIImageView new];
    [self.view addSubview:surfaceImgView];
    UIImage *surfaceImage = [UIImage imageNamed:@"account_surface"];
    surfaceImgView.image = surfaceImage;
    [surfaceImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pushView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@(680/2.0));
        make.height.equalTo(@(437/2.0));
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.backgroundColor = UIColorFromRGB(0xffffff);
    cancelBtn.layer.cornerRadius = 22.0;
    cancelBtn.layer.borderWidth = 1.0;
    cancelBtn.layer.borderColor = UIColorFromRGB(0xc8c8c8).CGColor;
    [cancelBtn setTitle:[ASLocalizeConfig localizedString:@"注销登录"] forState:UIControlStateNormal];
    [cancelBtn setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [cancelBtn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelLoginBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(35);
        make.trailing.equalTo(self.view.mas_trailing).offset(-35);
        make.bottom.equalTo(self.view.mas_bottom).offset(-30);
        make.height.equalTo(@(44));
    }];
    
}

-(void)cancelLoginBtnPress{
    
    NSString *strUsername = _accountLb.text;
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Being logged off..."]];
    //发送注销登录的post请求
    NSDictionary *parameters = @{@"email": strUsername};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //AFNetworking框架不支持解析text/html这种格式,需要手动添加.
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //手机注销
    NSString *cancelLoginUrl = [NSString stringWithFormat:@"%@",URL_LOGIN_CANCEL_URL];
    [manager POST:cancelLoginUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self stopMBProgressHUD];
        if (responseObject != nil) {
            
            NSString *registerReturn = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *dataRegReturn = [registerReturn dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dictRegReturn = [NSJSONSerialization JSONObjectWithData:dataRegReturn options:NSJSONReadingMutableLeaves error:&error];
            NSLog(@"%@",dictRegReturn);
            NSString *sRegReturnCode = dictRegReturn[@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            NSString *echo = @"";
            if(iRegReturnCode != 0) {
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"注销失败"] message:echo delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [alert show];
            } else {
                echo = [ASLocalizeConfig localizedString:@"退出成功"];
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"退出"] message:echo delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                alert.tag = CANCEL_LOGIN_SUCCESS;
                [alert show];
            }
            
            //注销成功应该返回一个页面
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self stopMBProgressHUD];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"关闭"] otherButtonTitles:nil, nil];
        [alert show];
    }];
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CANCEL_LOGIN_SUCCESS) {
        if (buttonIndex == 0) {
            //取消登录
            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
            delegate.isLogin = NO;
            //注销登录，则断开远程服务器连接
            AduroSmartSDKManager *sdkManager = [AduroSmartSDKManager sharedManager];
            [sdkManager disconnectCloudServer:[ASUserDefault loadUserNameCache] gatewayID:[ASUserDefault loadGatewayIDCache]];
            //清空密码缓存
            [ASUserDefault saveUserPasswardCache:@""];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginCancel" object:nil];//发送注销成功的通知
            [self back];
        }
    }
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)openOrStopPushMessage{

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
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
