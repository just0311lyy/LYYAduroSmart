//
//  ASGetwayGuideLastViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGetwayGuideLastViewController.h"
#import "ASRootTabBarViewController.h"
#import "ASGetwayListViewController.h"
#import <Masonry.h>
@interface ASGetwayGuideLastViewController ()

@end

@implementation ASGetwayGuideLastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithView];
    [self.navigationItem setHidesBackButton:YES];
    [self initWithGestureRecognizer];
}

-(void)initWithView{
    self.view.backgroundColor = LOGO_COLOR;

    UIView *leftView = [[UIView alloc] init];
    leftView.layer.cornerRadius = 10.0;
    leftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading).offset(-10);
        make.trailing.equalTo(self.view.mas_leading).offset(9);
        make.bottom.equalTo(self.view.mas_bottom).offset(-52);
    }];
    
    UIView *rightView = [[UIView alloc] init];
    rightView.layer.cornerRadius = 10.0;
    rightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(leftView.mas_trailing).offset(9);
        make.trailing.equalTo(self.view.mas_trailing).offset(-10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-52);
    }];
    
    UIImageView *gatwayImageView = [[UIImageView alloc] init];
    [rightView addSubview:gatwayImageView];
    gatwayImageView.image = [UIImage imageNamed:@"gateway_guide"];
    [gatwayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rightView.mas_top).offset(15);
        make.leading.equalTo(rightView.mas_leading).offset(40);
        make.trailing.equalTo(rightView.mas_trailing).offset(-40);
        make.height.equalTo(gatwayImageView.mas_width);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.backgroundColor = LOGO_COLOR;
    nextBtn.layer.cornerRadius = 18.0;
    [nextBtn setTitle:[ASLocalizeConfig localizedString:@"搜索"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(rightView.mas_leading).offset(22);
        make.trailing.equalTo(rightView.mas_trailing).offset(-22);
        make.bottom.equalTo(rightView.mas_bottom).offset(-15);
        make.height.equalTo(@(36));
    }];
    
    UILabel *deviceLb = [UILabel new];
    [rightView addSubview:deviceLb];
    [deviceLb setNumberOfLines:0];
    [deviceLb setTextColor:[UIColor lightGrayColor]];
    [deviceLb setLineBreakMode:NSLineBreakByWordWrapping];
    [deviceLb setText:[ASLocalizeConfig localizedString:@"配置网关步骤:\n点击下面的搜索按钮,开始搜索网关"]];
    [deviceLb setFont:[UIFont systemFontOfSize:15]];
    [deviceLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gatwayImageView.mas_bottom).offset(8);
        make.leading.equalTo(rightView.mas_leading).offset(40);
        make.trailing.equalTo(rightView.mas_trailing).offset(-20);
        make.bottom.equalTo(nextBtn.mas_top).offset(-5);
    }];
    
}

-(void)initWithGestureRecognizer{
    UISwipeGestureRecognizer *swipeGestureRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextBtnPress:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

#pragma mark - enterMainVC
-(void)nextBtnPress:(id)sender{
    ASGetwayListViewController *getwayListvc = [[ASGetwayListViewController alloc] init];
    [self.navigationController pushViewController:getwayListvc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
