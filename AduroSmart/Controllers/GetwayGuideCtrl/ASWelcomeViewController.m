//
//  ASWelcomeViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASWelcomeViewController.h"
#import "ASGetwayGuideViewController.h"
#import "ASLoginViewController.h"
#import "ASGuideViewController.h"
#import <Masonry.h>
@interface ASWelcomeViewController ()

@end

@implementation ASWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"welcome";
    [self initWithView];
    
    
}

-(void)initWithView{
    
//    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcome1242*2208"]];
////    imgView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:imgView];
//    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.view.mas_centerY).offset(-70);
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.width.equalTo(@(1242/7));
//        make.height.equalTo(@(2208/7));
//    }];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    self.title = @"Adurosmart";
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.backgroundColor = LOGO_COLOR;
    loginBtn.layer.cornerRadius = 20.0;
    [loginBtn setTitle:[ASLocalizeConfig localizedString:@"登录"] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(75);
        make.trailing.equalTo(self.view.mas_trailing).offset(-75);
        make.bottom.equalTo(self.view.mas_bottom).offset(-40);
        make.height.equalTo(@(40));
    }];
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.backgroundColor = ASSIST_COLOR;
    settingBtn.layer.cornerRadius = 20.0;
    [settingBtn setTitle:[ASLocalizeConfig localizedString:@"设置"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(75);
        make.trailing.equalTo(self.view.mas_trailing).offset(-75);
        make.bottom.equalTo(loginBtn.mas_top).offset(-20);
        make.height.equalTo(@(40));
    }];
    
    
}

#pragma mark - enterMainVC
-(void)settingBtnAction:(id)sender{
    ASGetwayGuideViewController *getwayGuideVC = [[ASGetwayGuideViewController alloc] init];
    [self.navigationController pushViewController:getwayGuideVC animated:YES];
//    ASGuideViewController *getwayGuideVC = [[ASGuideViewController alloc] init];
//    [self.navigationController pushViewController:getwayGuideVC animated:YES];
}


-(void)loginBtnAction:(id)sender{
    self.hidesBottomBarWhenPushed = YES;
    ASLoginViewController *loginvc = [[ASLoginViewController alloc] init];
    [self.navigationController pushViewController:loginvc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
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
