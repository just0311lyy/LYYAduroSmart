//
//  ASGetwayGuideViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/11.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGetwayGuideViewController.h"
#import "ASRootTabBarViewController.h"
#import "ASGetwayGuideNextViewController.h"
#import <Masonry.h>

@interface ASGetwayGuideViewController ()

@end

@implementation ASGetwayGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationController.navigationItem setHidesBackButton:YES];
    [self.navigationItem setHidesBackButton:YES];
    [self initWithView];
    [self initWithGestureRecognizer];
}

-(void)initWithView{
    self.view.backgroundColor = LOGO_COLOR;
//    self.view.backgroundColor = UIColorFromRGB(0xF7F7F7);
    self.title = @"Adurosmart";
    
    UIView *leftView = [[UIView alloc] init];
    leftView.layer.cornerRadius = 10.0;
    leftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading).offset(16);
        make.trailing.equalTo(self.view.mas_trailing).offset(-19);
        make.bottom.equalTo(self.view.mas_bottom).offset(-52);
    }];
    
    UIImageView *gatwayImageView = [[UIImageView alloc] init];
    [leftView addSubview:gatwayImageView];
    gatwayImageView.image = [UIImage imageNamed:@"gateway_guide"];
    [gatwayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftView.mas_top).offset(15);
        make.leading.equalTo(leftView.mas_leading).offset(40);
        make.trailing.equalTo(leftView.mas_trailing).offset(-40);
        make.height.equalTo(gatwayImageView.mas_width);
    }];

    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.backgroundColor = LOGO_COLOR;
    nextBtn.layer.cornerRadius = 18.0;
    [nextBtn setTitle:[ASLocalizeConfig localizedString:@"下一步"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(leftView.mas_leading).offset(22);
        make.trailing.equalTo(leftView.mas_trailing).offset(-22);
        make.bottom.equalTo(leftView.mas_bottom).offset(-15);
        make.height.equalTo(@(36));
    }];

    UILabel *deviceLb = [UILabel new];
    [leftView addSubview:deviceLb];
    [deviceLb setNumberOfLines:0];
    [deviceLb setTextColor:[UIColor lightGrayColor]];
    [deviceLb setLineBreakMode:NSLineBreakByWordWrapping];
    [deviceLb setText:[ASLocalizeConfig localizedString:@"配置网关步骤:\n请先确保网关已经接通电源"]];
    [deviceLb setFont:[UIFont systemFontOfSize:15]];
    [deviceLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gatwayImageView.mas_bottom).offset(8);
        make.leading.equalTo(leftView.mas_leading).offset(40);
        make.trailing.equalTo(leftView.mas_trailing).offset(-20);
        make.bottom.equalTo(nextBtn.mas_top).offset(-5);
    }];

    //----
    
    UIView *rightView = [[UIView alloc] init];
    rightView.layer.cornerRadius = 10.0;
    rightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(leftView.mas_trailing).offset(9);
        make.trailing.equalTo(self.view.mas_trailing).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-52);
    }];
 
}

-(void)initWithGestureRecognizer{
    UISwipeGestureRecognizer *swipeGestureRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextBtnAction:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}


#pragma mark - enterMainVC
-(void)nextBtnAction:(id)sender{
    ASGetwayGuideNextViewController *nextvc = [[ASGetwayGuideNextViewController alloc] init];
    [self.navigationController pushViewController:nextvc animated:YES];
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
