//
//  ASHelpTextViewController.m
//  Smart Home
//
//  Created by MacBook on 16/8/24.
//  Copyright © 2016年 Trust International B.V. All rights reserved.
//

#import "ASHelpTextViewController.h"

@interface ASHelpTextViewController ()

@end

@implementation ASHelpTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT);
    self.view.frame = frame;
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    UIView *heardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, 64)];
    heardView.backgroundColor = LOGO_COLOR;
    [self.view addSubview:heardView];
    
    UILabel *titleLabel = [UILabel new];
    [heardView addSubview:titleLabel];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.text =[ASLocalizeConfig localizedString:@"帮助"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(heardView.mas_top).offset(20);
        make.centerX.equalTo(heardView.mas_centerX);
        make.bottom.equalTo(heardView.mas_bottom);
        make.width.equalTo(@(80));
    }];
    
    UIButton *doneBtn = [UIButton new];
    [heardView addSubview:doneBtn];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(heardView.mas_top).offset(20);
        make.trailing.equalTo(heardView.mas_trailing).offset(-10);
        make.bottom.equalTo(heardView.mas_bottom);
        make.width.equalTo(@(50));
    }];

    //---------

    //文档
    UILabel *helpLabel = [UILabel new];
    [self.view addSubview:helpLabel];
    [helpLabel setNumberOfLines:0];
    
    
    [helpLabel setFont:[UIFont systemFontOfSize:16]];
    [helpLabel setTextColor:[UIColor blackColor]];
    [helpLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [helpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(heardView.mas_bottom).offset(20);
        make.leading.equalTo(self.view.mas_leading).offset(10);
        make.trailing.equalTo(self.view.mas_trailing).offset(-10);
        make.height.equalTo(@(100));
    }];
    [helpLabel setText:[ASLocalizeConfig localizedString:@" - 什么是配对模式？\n - 如何使Trust ZigBee智能设备进入配对模式？\n - 如何添加其他品牌的ZigBee设备？"]];
}


-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
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
