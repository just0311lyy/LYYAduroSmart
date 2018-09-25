//
//  ASLoginViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/11.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASLoginViewController.h"
#import "ASMailRegisterViewController.h"
#import "ASPhoneLoginViewController.h"
#import "ASForgetViewController.h"
#import "ASValidate.h"
#import "MyTool.h"
#import "ASUserDefault.h"
#import <Masonry.h>
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "ASAESencryption.h"
#import "ASGlobalDataObject.h"
#import "ASRootTabBarViewController.h"
#import "ASServerViewController.h"

#define LOGIN_SUCCESS  1000
@interface ASLoginViewController ()<UITextFieldDelegate,ASServerViewControllerDelegate>{
    UIView *_backgroudView;
    UITextField *_txtLoginAccount;
    UITextField *_txtPassword;
    
    UIButton *_rememberBtn;
    UIButton *_countryBtn;
}

//@property (nonatomic,strong) NSString *txtAreaCode; //手机区号

@end

@implementation ASLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
//    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //导航栏背景色
    [self initWithLoginView];

}

-(void)initWithLoginView{
    if ([self.setPushStr isEqualToString:@"setPush"]) {
        //导航栏左按钮
        UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
        [leftBarBtn addTarget:self action:@selector(backToSettingPress) forControlEvents:UIControlEventTouchUpInside];
        leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
        self.navigationItem.leftBarButtonItem = leftBarItem;
    }
  
    //背景视图
    _backgroudView = [UIView new];
    //    _backgroudView.backgroundColor = LOGO_COLOR;
    [self.view addSubview:_backgroudView];
    [_backgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(((SCREEN_ADURO_WIDTH * 714)/1125) - 64 + 32 + 45 + 10 + 45));
    }];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_ADURO_WIDTH, (SCREEN_ADURO_WIDTH * 714)/1125)];
    [_backgroudView addSubview:imgView];
    UIImage *image = [UIImage imageNamed:@"login_background"];
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

    UIView *accountView = [UIView new];
    [_backgroudView addSubview:accountView];
    accountView.layer.cornerRadius = 6.0;
    accountView.layer.borderWidth = 0.7;
    accountView.layer.borderColor = UIColorFromRGB(0xc7c7cd).CGColor;
    [accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom).offset(32);
        make.leading.equalTo(_backgroudView.mas_leading).offset(40);
        make.trailing.equalTo(_backgroudView.mas_trailing).offset(-40);
        make.height.equalTo(@(44));
    }];
    
    UIImageView *emailImgView = [UIImageView new];
    [emailImgView setImage:[UIImage imageNamed:@"email"]];
    [accountView addSubview:emailImgView];
    [emailImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(accountView.mas_centerY);
        make.leading.equalTo(accountView.mas_leading).offset(10);
        make.width.equalTo(@(40/1.5));
        make.height.equalTo(@(28/1.5));
    }];
    
    //账号
    _txtLoginAccount = [UITextField new];
    [_txtLoginAccount setDelegate:self];
    [_txtLoginAccount setPlaceholder:[ASLocalizeConfig localizedString:@"邮箱账号"]];
    [accountView addSubview:_txtLoginAccount];
    if(![[ASUserDefault loadUserNameCache] isEqualToString:@""] && [ASUserDefault loadUserNameCache] != nil)_txtLoginAccount.text =[ASUserDefault loadUserNameCache];
//    [_txtLoginAccount setBorderStyle:UITextBorderStyleRoundedRect];
    _txtLoginAccount.clearButtonMode=UITextFieldViewModeAlways;
    [_txtLoginAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accountView.mas_top);
        make.leading.equalTo(accountView.mas_leading).offset(50);
        make.trailing.equalTo(accountView.mas_trailing);
        make.bottom.equalTo(accountView.mas_bottom);
    }];
    
    UIView *passwordView = [UIView new];
    [_backgroudView addSubview:passwordView];
    passwordView.layer.cornerRadius = 6.0;
    passwordView.layer.borderWidth = 0.7;
    passwordView.layer.borderColor = UIColorFromRGB(0xc7c7cd).CGColor;
    [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accountView.mas_bottom).offset(10);
        make.leading.equalTo(accountView.mas_leading);
        make.trailing.equalTo(accountView.mas_trailing);
        make.height.equalTo(accountView.mas_height);
    }];
    
    UIImageView *passwordImgView = [UIImageView new];
    [passwordImgView setImage:[UIImage imageNamed:@"password"]];
    [passwordView addSubview:passwordImgView];
    [passwordImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(passwordView.mas_centerY);
        make.centerX.equalTo(emailImgView.mas_centerX);
        make.width.equalTo(@(32/1.5));
        make.height.equalTo(@(36/1.5));
    }];
    //密码
    _txtPassword = [UITextField new];
    [passwordView addSubview:_txtPassword];
    [_txtPassword setSecureTextEntry:YES];
    [_txtPassword setDelegate:self];
    [_txtPassword setPlaceholder:[ASLocalizeConfig localizedString:@"密码"]];
    if(![[ASUserDefault loadUserPasswardCache] isEqualToString:@""] && [ASUserDefault loadUserPasswardCache] != nil)_txtPassword.text =[ASAESencryption aes256_decrypt:@"TRUSTSMART" Decrypttext:[ASUserDefault loadUserPasswardCache]];
    _txtPassword.clearButtonMode=UITextFieldViewModeAlways;
//    [_txtPassword setBorderStyle:UITextBorderStyleRoundedRect];
    [_txtPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(passwordView.mas_bottom);
        make.leading.equalTo(_txtLoginAccount.mas_leading);
        make.trailing.equalTo(passwordView.mas_trailing);
        make.top.equalTo(passwordView.mas_top);
    }];
    
    //登录按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:loginBtn];
    loginBtn.layer.cornerRadius = 20.0;
    loginBtn.backgroundColor = LOGO_COLOR;
    [loginBtn setTitle:[ASLocalizeConfig localizedString:@"登录"] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backgroudView.mas_bottom).offset(40);
        make.leading.equalTo(_backgroudView.mas_leading).offset(60);
        make.trailing.equalTo(_backgroudView.mas_trailing).offset(-60);
        make.height.equalTo(@(40));
    }];

    //忘记密码
    UIButton *forgotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:forgotBtn];
    [forgotBtn setTitle:[ASLocalizeConfig localizedString:@"忘记密码"] forState:UIControlStateNormal];
    [forgotBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    forgotBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [forgotBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [forgotBtn addTarget:self action:@selector(forgotBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [forgotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(accountView.mas_leading);
        make.trailing.equalTo(self.view.mas_centerX);
        make.height.equalTo(loginBtn.mas_height);
        make.top.equalTo(loginBtn.mas_bottom).offset(20);
    }];
    //注册
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:registerBtn];
    [registerBtn setTitle:[ASLocalizeConfig localizedString:@"创建进入"] forState:UIControlStateNormal];
    [registerBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [registerBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_centerX);
        make.trailing.equalTo(accountView.mas_trailing).offset(5);
        make.top.equalTo(loginBtn.mas_bottom).offset(20);
        make.height.equalTo(forgotBtn.mas_height);
    }];
    
//    //切换到手机登录
//    UIButton *mailLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.view addSubview:mailLoginBtn];
//    [mailLoginBtn setTitle:[ASLocalizeConfig localizedString:@"手机登录"] forState:UIControlStateNormal];
//    [mailLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    mailLoginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    //    mailLoginBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
//    [mailLoginBtn.titleLabel setTextAlignment:NSTextAlignmentRight];
//    [mailLoginBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [mailLoginBtn addTarget:self action:@selector(phoneLoginPress) forControlEvents:UIControlEventTouchUpInside];
//    [mailLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(loginBtn.mas_bottom).offset(5);
//        make.trailing.equalTo(registerBtn.mas_trailing);
//        make.leading.equalTo(registerBtn.mas_leading);
//        make.height.equalTo(registerBtn.mas_height);
//    }];
    
//    _countryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.view addSubview:_countryBtn];
//    _countryBtn.backgroundColor = UIColorFromRGB(0xffffff);
//    _countryBtn.layer.borderWidth = 0.5;
//    _countryBtn.layer.borderColor = UIColorFromRGB(0xc8c8c8).CGColor;
//    [_countryBtn setTitle:[ASLocalizeConfig localizedString:@"Locale Europe"] forState:UIControlStateNormal];
//    [_countryBtn setFont:[UIFont fontWithName:@"Helvetica" size:18]];
//    [_countryBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [_countryBtn addTarget:self action:@selector(selectDomainBtnPress) forControlEvents:UIControlEventTouchUpInside];
//    [_countryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(self.view.mas_leading).offset(-0.5);
//        make.trailing.equalTo(self.view.mas_trailing).offset(0.5);
//        make.bottom.equalTo(self.view.mas_bottom).offset(0.5);
//        make.height.equalTo(@(40));
//    }];
}

#pragma mark - buttonAction
-(void)registerBtnAction:(UIButton *)sender{
    ASMailRegisterViewController * registervc = [[ASMailRegisterViewController alloc] init];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:registervc animated:YES];
}

//-(void)selectDomainBtnPress{
//    ASServerViewController * servervc = [[ASServerViewController alloc] init];
//    servervc.delegate = self;
//    [self setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:servervc animated:YES];
//}

/**
 *  @author
 *
 *  @brief 用户登录,需要判断账号的类型,如果输入的不是邮箱则需要在输入信息前加上当前区号
 *
 *  @param sender 登录按钮
 */
-(void)loginBtnAction{
    NSString *strUsername = _txtLoginAccount.text;
    NSString *strPassword = _txtPassword.text;
    
    //验证账号密码输入格式
    if (![ASValidate veriEmail:strUsername]) {return;}
    if (![ASValidate password:strPassword]) {return;}
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"登录中..."]];
    //发送登录的post请求
    NSDictionary *parameters = @{@"email": strUsername,@"password": strPassword};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //AFNetworking框架不支持解析text/html这种格式,需要手动添加.
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //手机登录
    NSString *loginUrl = [NSString stringWithFormat:@"%@",URL_LOGIN_EMAIL_URL];
    [manager POST:loginUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        if (responseObject != nil) {
            NSString *sRegReturnCode = [responseObject objectForKey:@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            NSString *echo = @"";
            if(iRegReturnCode != 0) {
                if(iRegReturnCode == 1) {
                    echo = [ASLocalizeConfig localizedString:@"账号错误"];;
                }
                else if(iRegReturnCode == 2) {
                    echo = [ASLocalizeConfig localizedString:@"密码错误"];
                }
                else {
                    echo = [ASLocalizeConfig localizedString:@"未定义"];
                }
                [self stopMBProgressHUD];
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"登录失败"] message:echo delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [alert show];
            } else {
//                echo = [ASLocalizeConfig localizedString:@"开启远程控制"];
                NSString *returnUserId = [[responseObject objectForKey:@"result"] objectForKey:@"user_id"];
                [ASUserDefault saveUserIDCache:returnUserId];
                [self sendGetGatewayMessageRequest];
//                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"登录成功"] message:echo delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:[ASLocalizeConfig localizedString:@"取消"], nil];
//                alert.tag = LOGIN_SUCCESS;
//                [alert show];
                
            }
            //登录成功应该返回一个页面
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self stopMBProgressHUD];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"错误"] message:[ASLocalizeConfig localizedString:@"网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"关闭"] otherButtonTitles:nil, nil];
        [alert show];
        
    }];
}

-(void)forgotBtnAction{
    ASForgetViewController *forgetvc = [[ASForgetViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:forgetvc animated:YES];
    
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == LOGIN_SUCCESS) {
        if (buttonIndex == 0) {
            [ASUserDefault saveUserNameCache:_txtLoginAccount.text];
            [ASUserDefault saveUserPasswardCache:[ASAESencryption aes256_encrypt:@"TRUSTSMART" Encrypttext:_txtPassword.text]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];//发送登陆成功的通知
            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
            delegate.isLogin=YES;
//            [self sendGetGatewayMessageRequest];
            if ([self.setPushStr isEqualToString:@"setPush"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                ASRootTabBarViewController* rootvc = [[ASRootTabBarViewController alloc] init];//这里加导航栏是因为我跳转的页面带导航栏，如果跳转的页面不带导航，那这句话请省去。
                [self.view removeFromSuperview];
                app.window.rootViewController = rootvc;
            }
        }
    }
}

-(void)backToSettingPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)phoneLoginPress{
    ASPhoneLoginViewController *mailRegVC = [[ASPhoneLoginViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mailRegVC animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

-(void)sendGetGatewayMessageRequest{
    NSString *strUserID = [ASUserDefault loadUserIDCache];
    if ([strUserID isEqualToString:@""] ){return;}
    //发送获取网关信息的post请求
    NSDictionary *parameters = @{@"user_id": strUserID};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //AFNetworking框架不支持解析text/html这种格式,需要手动添加.
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //网关数据获取
    NSString *uploadUrl = [NSString stringWithFormat:@"%@",GET_GATEWAY_MESSAGE_URL];
    [manager POST:uploadUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self stopMBProgressHUD];
        if (responseObject != nil) {
            NSString *sRegReturnCode = [responseObject objectForKey:@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            NSString *echo = @"";
            if(iRegReturnCode != 0 && iRegReturnCode !=3) {
                if(iRegReturnCode == 1) {
                    echo = [ASLocalizeConfig localizedString:@"读取失败"];;
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
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"Login success.But failed to get cloud data"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                alert.tag = LOGIN_SUCCESS;
                [alert show];
            } else {
                echo = [ASLocalizeConfig localizedString:@"读取网关数据成功"];
                
                NSDictionary *sGatewayDic = [responseObject objectForKey:@"result"];
                NSArray *sKeys = [sGatewayDic allKeys];
                for (int i=0; i<sKeys.count; i++) {
                    NSDictionary *sGatewayMes = [sGatewayDic objectForKey:sKeys[i]];
                    
                    NSString *sGatewayID = [sGatewayMes objectForKey:[NSString stringWithFormat:@"gateway_num"]];
                    NSString *sGatewayKey = [sGatewayMes objectForKey:[NSString stringWithFormat:@"security_key"]];
                    AduroGateway *gateway = [[AduroGateway alloc] init];
                    gateway.gatewayID = sGatewayID;
                    gateway.gatewaySecurityKey = sGatewayKey;
                    if (_globalCloudGetwayArray.count>0) {
                        BOOL isRepeat = NO; //不重复
                        for (int j=0; j<_globalCloudGetwayArray.count; j++) {
                            AduroGateway *oneGateway = [_globalCloudGetwayArray objectAtIndex:j];
                            if ([oneGateway.gatewayID isEqualToString:sGatewayID]) {
                                isRepeat = YES;
                            }
                        }
                        if (!isRepeat) {
                            [_globalCloudGetwayArray addObject:gateway];
                        }
                    }else{
                        [_globalCloudGetwayArray addObject:gateway];
                    }
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"Login success.And you can use remote control"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                alert.tag = LOGIN_SUCCESS;
                [alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self stopMBProgressHUD];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"错误"] message:[ASLocalizeConfig localizedString:@"登录状态下获取网关数据失败:网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"关闭"] otherButtonTitles:nil, nil];
        alert.tag = LOGIN_SUCCESS;
        [alert show];
    }];
}

//#pragma mark - ASServerViewControllerDelegate
//- (void)selectViewController:(ASServerViewController *)selectedVC didSelectServer:(NSString *)serverName{
//    
//    [_countryBtn setTitle:[NSString stringWithFormat:@"Locale %@",serverName] forState:UIControlStateNormal];
//}

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
