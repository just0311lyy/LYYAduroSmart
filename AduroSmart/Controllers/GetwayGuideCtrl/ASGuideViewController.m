//
//  ASGuideViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/15.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGuideViewController.h"

@interface ASGuideViewController ()<UIScrollViewDelegate>


@property(nonatomic, strong)UIScrollView *mainView;
@end

@implementation ASGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LOGO_COLOR;
    [self initMainView];
  
}

-(void)initMainView{
    _mainView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 0, SCREEN_ADURO_WIDTH - 30, SCREEN_ADURO_HEIGHT - 64)];
    _mainView.backgroundColor = LOGO_COLOR;
    _mainView.contentSize = CGSizeMake((SCREEN_ADURO_WIDTH - 30)*3,SCREEN_ADURO_HEIGHT - 64);
    _mainView.delegate = self;
    _mainView.pagingEnabled = YES;
    _mainView.clipsToBounds = NO; //将其子视图超出的部分显现出来
    [self.view addSubview:_mainView];
    
    for (int i = 0; i<3; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10+(SCREEN_ADURO_WIDTH-30)*i, 0, SCREEN_ADURO_WIDTH-40, SCREEN_ADURO_HEIGHT-64 - 50)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 6.0;
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_ADURO_WIDTH-140)/2, 300, 100, 40)];
        btn.tag = i;
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 3.5;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor magentaColor].CGColor;
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor magentaColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(pageNext:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        [_mainView addSubview:view];
    }
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
