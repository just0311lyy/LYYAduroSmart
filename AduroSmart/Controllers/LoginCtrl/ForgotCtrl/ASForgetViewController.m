//
//  ASForgetViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/17.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASForgetViewController.h"
#import "ASValidate.h"

#import <AFNetworking.h>
#define FORGET_SUCCESS 1111
@interface ASForgetViewController ()<UITextFieldDelegate>{
    UIView *_backgroundView;
    UITextField *_txtMailAddress; //邮箱验地址
    UITextField *_txtVerification; //邮箱验证码
    UITextField *_txtPassword;
}


@end

@implementation ASForgetViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"重置密码"];
    [self initWithMailForgetView];
}

-(void)initWithMailForgetView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToLoginFromForgetPress) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    _backgroundView = [UIView new];
    [self.view addSubview:_backgroundView];
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_top).offset(310);
    }];
    
    //---------邮箱
    UILabel *mailLabel = [UILabel new];
    [_backgroundView addSubview:mailLabel];
    [mailLabel setNumberOfLines:3];
    [mailLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [mailLabel setText:[ASLocalizeConfig localizedString:@"邮箱:"]];
    [mailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backgroundView.mas_top).offset(10);
        make.leading.equalTo(_backgroundView.mas_leading).offset(20);
        make.width.equalTo(@(40));
        make.height.equalTo(@(44));
    }];
    
    UIButton *getCodeBtn = [UIButton new];
    [_backgroundView addSubview:getCodeBtn];
    [getCodeBtn setTitle:[ASLocalizeConfig localizedString:@"验证码"] forState:UIControlStateNormal];
    [getCodeBtn.layer setCornerRadius:5.0];
    [getCodeBtn setBackgroundColor:LOGO_COLOR];
    [getCodeBtn setTintColor:[UIColor whiteColor]];
    [getCodeBtn addTarget:self action:@selector(getMailVerCodeOfForgetAction) forControlEvents:UIControlEventTouchUpInside];
    [getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backgroundView.mas_top).offset(20);
        make.trailing.equalTo(_backgroundView.mas_trailing).offset(-10);
        make.width.equalTo(@(80));
        make.height.equalTo(@(28));
    }];
    
    _txtMailAddress = [UITextField new];
    [_txtMailAddress setPlaceholder:[ASLocalizeConfig localizedString:@"请输入邮箱地址"]];
    //    _txtPhone.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;//垂直居下
    //    [_txtPhone setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_txtMailAddress setDelegate:self];
    [_backgroundView addSubview:_txtMailAddress];
    [_txtMailAddress setBorderStyle:UITextBorderStyleNone];
    [_txtMailAddress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mailLabel.mas_top);
        make.leading.equalTo(mailLabel.mas_trailing);
        make.trailing.equalTo(getCodeBtn.mas_leading);
        make.height.equalTo(@(44));
    }];
    
    UIView *mailLineView = [UIView new];
    [_backgroundView addSubview:mailLineView];
    mailLineView.backgroundColor = [UIColor lightGrayColor];
    [mailLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mailLabel.mas_bottom).offset(2);
        make.leading.equalTo(_backgroundView.mas_leading).offset(20);
        make.trailing.equalTo(_backgroundView.mas_trailing).offset(-20);
        make.height.equalTo(@(1));
    }];
    
    //----验证码
    UILabel *verificationLb = [UILabel new];
    [_backgroundView addSubview:verificationLb];
    [verificationLb setNumberOfLines:3];
    [verificationLb setLineBreakMode:NSLineBreakByWordWrapping];
    [verificationLb setText:[ASLocalizeConfig localizedString:@"验证码:"]];
    [verificationLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mailLineView.mas_bottom).offset(5);
        make.leading.equalTo(mailLabel.mas_leading);
        make.width.equalTo(@(95));
        make.height.equalTo(mailLabel.mas_height);
    }];
    
    _txtVerification = [UITextField new];
    [_txtVerification setPlaceholder:[ASLocalizeConfig localizedString:@"请输入验证码"]];
    [_txtVerification setDelegate:self];
    [_backgroundView addSubview:_txtVerification];
    [_txtVerification setBorderStyle:UITextBorderStyleNone];
    [_txtVerification mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mailLineView.mas_bottom).offset(5);
        make.leading.equalTo(verificationLb.mas_trailing);
        make.trailing.equalTo(mailLineView.mas_trailing);
        make.height.equalTo(@(44));
    }];
    
    UIView *codeLineView = [UIView new];
    [_backgroundView addSubview:codeLineView];
    codeLineView.backgroundColor = [UIColor lightGrayColor];
    [codeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(verificationLb.mas_bottom).offset(2);
        make.leading.equalTo(mailLineView.mas_leading);
        make.trailing.equalTo(mailLineView.mas_trailing);
        make.height.equalTo(@(1));
    }];
    
    //----password
    
    UILabel *passwordLb = [UILabel new];
    [_backgroundView addSubview:passwordLb];
    [passwordLb setNumberOfLines:3];
    [passwordLb setLineBreakMode:NSLineBreakByWordWrapping];
    [passwordLb setText:[ASLocalizeConfig localizedString:@"密码:"]];
    [passwordLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(codeLineView.mas_bottom).offset(5);
        make.leading.equalTo(codeLineView.mas_leading);
        make.width.equalTo(@(90));
        make.height.equalTo(verificationLb.mas_height);
    }];
    
    _txtPassword = [UITextField new];
    [_txtPassword setPlaceholder:[ASLocalizeConfig localizedString:@"请输入密码"]];
    [_txtPassword setSecureTextEntry:YES];
    [_txtPassword setDelegate:self];
    [_backgroundView addSubview:_txtPassword];
    [_txtPassword setBorderStyle:UITextBorderStyleNone];
    [_txtPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(codeLineView.mas_bottom).offset(5);
        make.leading.equalTo(passwordLb.mas_trailing);
        make.trailing.equalTo(codeLineView.mas_trailing);
        make.height.equalTo(passwordLb.mas_height);
    }];
    
    UIView *passwordLineView = [UIView new];
    [_backgroundView addSubview:passwordLineView];
    passwordLineView.backgroundColor = [UIColor lightGrayColor];
    [passwordLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordLb.mas_bottom).offset(2);
        make.leading.equalTo(passwordLb.mas_leading);
        make.trailing.equalTo(_txtPassword.mas_trailing);
        make.height.equalTo(@(1));
    }];
    
    UIButton *createBtn = [UIButton new];
    [_backgroundView addSubview:createBtn];
    [createBtn setTitle:[ASLocalizeConfig localizedString:@"重置密码"] forState:UIControlStateNormal];
    [createBtn.layer setCornerRadius:22.0];
    [createBtn setBackgroundColor:LOGO_COLOR];
    [createBtn setTintColor:[UIColor whiteColor]];
    [createBtn addTarget:self action:@selector(createEmailAccountBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_backgroundView.mas_bottom);
        make.leading.equalTo(_backgroundView.mas_leading).offset(20);
        make.trailing.equalTo(_backgroundView.mas_trailing).offset(-20);
        make.height.equalTo(@(40));
    }];
}

//获取邮箱验证码
-(void)getMailVerCodeOfForgetAction{
    
    NSString *strEmail = _txtMailAddress.text;
    if (![ASValidate veriEmail:strEmail]) {return;}
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"数据加载中..."]];
    NSDictionary *parameters = @{@"email":strEmail};
    //customIdentifier 为自定义短信标识。需从官网申请
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *valMailForgetUrl = [NSString stringWithFormat:@"%@",URL_FORGET_VERIFICATION_EMAIL_URL];
    [manager POST:valMailForgetUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self stopMBProgressHUD];
        
        NSString *registerCode = [responseObject objectForKey:@"code"];

        NSString *echo = @"";
        NSInteger iRegReturnCode = [registerCode intValue];
        if(iRegReturnCode != 0) {
            if(iRegReturnCode == 1) {
                echo = [ASLocalizeConfig localizedString:@"用户不存在"];
            } else if(iRegReturnCode == 2) {
                echo = [ASLocalizeConfig localizedString:@"验证码发送失败"];
            } else {
                echo = [ASLocalizeConfig localizedString:@"未定义"];
            }
        }else{
            echo = [ASLocalizeConfig localizedString:@"验证码发送成功"];
        }
        
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:echo delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self stopMBProgressHUD];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
    }];
}

//邮箱密码重置
-(void)createEmailAccountBtnAction:(UIButton *)sender{
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"数据加载中..."]];
    NSString *pwd = _txtPassword.text;
    NSString *emailAddress = _txtMailAddress.text;
    NSString *verifictionCode = _txtVerification.text;
    NSDictionary *parameters = @{@"email":emailAddress,@"checkcode":verifictionCode,@"newpassword":pwd};
    [self registerMailToAduroSmart:parameters];
}

-(void)registerMailToAduroSmart:(NSDictionary *)parameters{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *regMailUrl = [NSString stringWithFormat:@"%@",URL_FORGET_EMAIL_URL];
    [manager POST:regMailUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) { // _Nonnull 表示可以为空
        [self stopMBProgressHUD];
        if (responseObject != nil) {
            NSString *sRegReturnCode = [responseObject objectForKey:@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            NSString *echo = @"";
            if(iRegReturnCode != 0) {
                if(iRegReturnCode == 1) {
                    echo = [ASLocalizeConfig localizedString:@"修改密码失败"];;
                }else if(iRegReturnCode == 5){
                    echo = [ASLocalizeConfig localizedString:@"验证码错误"];
                }else if(iRegReturnCode == 6){
                    echo = [ASLocalizeConfig localizedString:@"验证码超时"];
                }else {
                    echo = [ASLocalizeConfig localizedString:@"未定义"];
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:echo delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [alert show];
            } else {
                echo = [ASLocalizeConfig localizedString:@"修改密码成功"];
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:echo delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [alert show];
                alert.tag = FORGET_SUCCESS;
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        [self stopMBProgressHUD];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
    }];
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == FORGET_SUCCESS) {
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - navbarButton
-(void)backToLoginFromForgetPress{
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
