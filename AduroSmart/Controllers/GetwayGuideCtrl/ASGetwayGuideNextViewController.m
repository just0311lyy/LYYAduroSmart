//
//  ASGetwayGuideNextViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGetwayGuideNextViewController.h"
#import "ASGetwayGuideLastViewController.h"
#import <Masonry.h>
@interface ASGetwayGuideNextViewController ()

@end

@implementation ASGetwayGuideNextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithView];
    [self.navigationItem setHidesBackButton:YES];
    [self initWithGestureRecognizer];
}

-(void)initWithView{
    self.view.backgroundColor = LOGO_COLOR;
//    self.view.backgroundColor = UIColorFromRGB(0xF7F7F7);
    self.title = @"Adurosmart";
    
    UIView *mainView = [[UIView alloc] init];
    mainView.layer.cornerRadius = 10.0;
    mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading).offset(18);
        make.trailing.equalTo(self.view.mas_trailing).offset(-18);
        make.bottom.equalTo(self.view.mas_bottom).offset(-52);
    }];
    
    UIImageView *gatwayImageView = [[UIImageView alloc] init];
    [mainView addSubview:gatwayImageView];
    gatwayImageView.image = [UIImage imageNamed:@"wifi"];
    [gatwayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainView.mas_top);
        make.leading.equalTo(mainView.mas_leading).offset(20);
        make.trailing.equalTo(mainView.mas_trailing).offset(-20);
        make.height.equalTo(gatwayImageView.mas_width);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.backgroundColor = LOGO_COLOR;
    nextBtn.layer.cornerRadius = 18.0;
    [nextBtn setTitle:[ASLocalizeConfig localizedString:@"下一步"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(mainView.mas_leading).offset(22);
        make.trailing.equalTo(mainView.mas_trailing).offset(-22);
        make.bottom.equalTo(mainView.mas_bottom).offset(-15);
        make.height.equalTo(@(36));
    }];
    
    UILabel *deviceLb = [UILabel new];
    [mainView addSubview:deviceLb];
    [deviceLb setNumberOfLines:0];
    [deviceLb setTextColor:[UIColor lightGrayColor]];
    [deviceLb setLineBreakMode:NSLineBreakByWordWrapping];
    [deviceLb setText:[ASLocalizeConfig localizedString:@"配置网关步骤:\n然后将网关接入路由器"]];
    [deviceLb setFont:[UIFont systemFontOfSize:15]];
    [deviceLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gatwayImageView.mas_bottom);
        make.leading.equalTo(mainView.mas_leading).offset(40);
        make.trailing.equalTo(mainView.mas_trailing).offset(-20);
        make.bottom.equalTo(nextBtn.mas_top);
    }];
    
    //---
    
    UIView *leftView = [[UIView alloc] init];
    leftView.layer.cornerRadius = 10.0;
    leftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading).offset(-10);
        make.trailing.equalTo(mainView.mas_leading).offset(-9);
        make.bottom.equalTo(self.view.mas_bottom).offset(-52);
    }];

    UIView *rightView = [[UIView alloc] init];
    rightView.layer.cornerRadius = 10.0;
    rightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(mainView.mas_trailing).offset(9);
        make.trailing.equalTo(self.view.mas_trailing).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-52);
    }];
    
}

-(void)initWithGestureRecognizer{
    UISwipeGestureRecognizer *swipeGestureRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextBtnPress:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

#pragma mark - enterMainVC
-(void)nextBtnPress:(id)sender{
    ASGetwayGuideLastViewController *lastvc = [[ASGetwayGuideLastViewController alloc] init];
    [self.navigationController pushViewController:lastvc animated:YES];
    
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
