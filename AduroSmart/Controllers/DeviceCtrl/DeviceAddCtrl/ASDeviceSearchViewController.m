//
//  ASDeviceSearchViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/8.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDeviceSearchViewController.h"

#import "AppDelegate.h"
#import "ASNewDeviceViewController.h"
#import "ASLocalizeConfig.h"
#import "ASHelpTextViewController.h"
#import "ASDeviceManageViewController.h"
#import <Masonry.h>
#import <MRProgress.h> //背景模糊
#import <MBProgressHUD.h>
@interface ASDeviceSearchViewController ()<MRProgressDelegate,UIScrollViewDelegate,UIPageViewControllerDelegate>{
    //查找新设备
//    MRProgressOverlayView *_searchProgressView;
    UILabel *_describeLb;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}

@end

@implementation ASDeviceSearchViewController
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
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.title = self.titleName;
    [self initWithView];
}

-(void)initWithView{
    self.view.backgroundColor = LOGO_COLOR;
    
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToTypeViewAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    UIView *frameView = [[UIView alloc] init];
    frameView.layer.cornerRadius = 6.0;
    frameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:frameView];
    [frameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading).offset(8);
        make.trailing.equalTo(self.view.mas_trailing).offset(-8);
        make.bottom.equalTo(self.view.mas_bottom).offset(-40);
    }];
    
    UIView *showView = [[UIView alloc] init];
    [frameView addSubview:showView];
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(frameView.mas_top);
        make.leading.equalTo(frameView.mas_leading);
        make.trailing.equalTo(frameView.mas_trailing);
        make.height.equalTo(showView.mas_width);
    }];
    
    UILabel *linelb = [UILabel new];
    [showView addSubview:linelb];
    [linelb setBackgroundColor:UIColorFromRGB(0xd2d2d2)];
    [linelb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(1));
        make.leading.equalTo(showView.mas_leading).offset(20);
        make.trailing.equalTo(showView.mas_trailing).offset(-20);
        make.bottom.equalTo(showView.mas_bottom);
    }];

    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.backgroundColor = LOGO_COLOR;
    searchBtn.layer.cornerRadius = 20.0;
    [searchBtn setTitle:[ASLocalizeConfig localizedString:@"搜索"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [frameView addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(frameView.mas_leading).offset(30);
        make.trailing.equalTo(frameView.mas_trailing).offset(-30);
        make.bottom.equalTo(frameView.mas_bottom).offset(-30);
        make.height.equalTo(@(40));
    }];
    
    _describeLb = [UILabel new];
    [frameView addSubview:_describeLb];
    [_describeLb setNumberOfLines:0];
    [_describeLb setFont:[UIFont systemFontOfSize:16]];
    [_describeLb setTextColor:[UIColor lightGrayColor]];
    [_describeLb setLineBreakMode:NSLineBreakByWordWrapping];
    [_describeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(showView.mas_bottom);
        make.leading.equalTo(frameView.mas_leading).offset(30);
        make.trailing.equalTo(frameView.mas_trailing).offset(-10);
        make.bottom.equalTo(searchBtn.mas_top).offset(-10);
    }];
    
    if ([self.title isEqualToString:[ASLocalizeConfig localizedString:@"Remote control"]]) {
        [linelb setHidden:NO];
        [_describeLb setText:[ASLocalizeConfig localizedString:@"1、Long press the button 10s to reset the remote control."]];
        NSArray *images = @[@"device_remotes_first",@"device_remotes_second"];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH - 8 - 8, SCREEN_ADURO_WIDTH - 8 - 8)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        [showView addSubview:_scrollView];
        
        //显示界面
        CGSize size = _scrollView.frame.size;
        size.width *= images.count;
        _scrollView.contentSize = size; //内容界面
        for (int i = 0; i < images.count; i++) {
            UIImage *image = [UIImage imageNamed:images[i]];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            
            CGRect frame = _scrollView.frame;
            frame.origin.x = i * frame.size.width + 20;
            frame.origin.y = 20;
            frame.size.width = frame.size.width - 20 - 20;
            frame.size.height = frame.size.height - 20 - 20;
            imageView.frame = frame;
            [_scrollView addSubview:imageView];
        }
        
        //page control
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.frame = CGRectMake(0, SCREEN_ADURO_WIDTH - 8 - 8 - 20,0, 20);
        _pageControl.numberOfPages = images.count;
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0x9b9b9b);
        _pageControl.pageIndicatorTintColor = UIColorFromRGB(0xd2d2d2);
        _pageControl.userInteractionEnabled = NO; //关闭事件
        [showView addSubview:_pageControl];
    }else{
        if ([self.title isEqualToString:[ASLocalizeConfig localizedString:@"灯"]]) {
            UIImageView *lightImgView = [[UIImageView alloc] init];
            [showView addSubview:lightImgView];
            [lightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(showView.mas_top).offset(40);
                make.leading.equalTo(showView.mas_leading).offset(30);
                make.trailing.equalTo(showView.mas_centerX);
                make.height.equalTo(@(((SCREEN_ADURO_WIDTH - 8 - 8)/2- 30)*559/309));
            }];
        
            UIView *lightLbView = [UIView new];
            [showView addSubview:lightLbView];
            lightLbView.layer.cornerRadius = 8;
            lightLbView.layer.borderWidth = 1;
            lightLbView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [lightLbView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(lightImgView.mas_trailing);
                make.bottom.equalTo(lightImgView.mas_bottom);
                make.trailing.equalTo(showView.mas_trailing).offset(-20);
                make.height.equalTo(@(80));
            }];
            
            UILabel *lightLb = [UILabel new];
            [lightLbView addSubview:lightLb];
            [lightLb setNumberOfLines:0];
            [lightLb setFont:[UIFont systemFontOfSize:12]];
            [lightLb setTextColor:[UIColor lightGrayColor]];
            lightLb.text = [ASLocalizeConfig localizedString:@"Repeatedly turn on the switch 5 times in a short time."];
            [lightLb setLineBreakMode:NSLineBreakByWordWrapping];
            [lightLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(lightLbView.mas_leading).offset(5);
                make.bottom.equalTo(lightLbView.mas_bottom).offset(-5);
                make.trailing.equalTo(lightLbView.mas_trailing).offset(-5);
                make.top.equalTo(lightLbView.mas_top).offset(5);
            }];

            lightImgView.image = [UIImage imageNamed:@"search_light"];
            [_describeLb setText:[ASLocalizeConfig localizedString:@"搜索新的灯前,请先确保灯的开关已经打开,然后点击搜索按钮."]];
        }else if([self.title isEqualToString:[ASLocalizeConfig localizedString:@"传感器"]]){
            UIImageView *sensorImgView = [[UIImageView alloc] init];
            [showView addSubview:sensorImgView];
            [sensorImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(showView.mas_top).offset(34);
                make.centerX.equalTo(showView.mas_centerX);
                make.width.equalTo(@(SCREEN_ADURO_WIDTH - 8 - 8-30*2));
                make.height.equalTo(@((SCREEN_ADURO_WIDTH - 8 - 8-30*2)*426/546));
            }];
            
            UIView *sensorLbView = [UIView new];
            [showView addSubview:sensorLbView];
            sensorLbView.layer.cornerRadius = 8;
            sensorLbView.layer.borderWidth = 0.5;
            sensorLbView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [sensorLbView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(sensorImgView.mas_bottom);
                make.leading.equalTo(showView.mas_leading).offset(40);
                make.trailing.equalTo(showView.mas_trailing).offset(-40);
                make.bottom.equalTo(showView.mas_bottom).offset(-25);
            }];
            
            UILabel *sensorLb = [UILabel new];
            [sensorLbView addSubview:sensorLb];
            [sensorLb setNumberOfLines:0];
            [sensorLb setFont:[UIFont systemFontOfSize:12]];
            [sensorLb setTextColor:[UIColor lightGrayColor]];
            sensorLb.text = [ASLocalizeConfig localizedString:@"Long tie the hole 10s to reset the sensor,and then short tie to connect."];
            [sensorLb setLineBreakMode:NSLineBreakByWordWrapping];
            [sensorLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(sensorLbView.mas_leading).offset(5);
                make.bottom.equalTo(sensorLbView.mas_bottom).offset(-5);
                make.trailing.equalTo(sensorLbView.mas_trailing).offset(-5);
                make.top.equalTo(sensorLbView.mas_top).offset(5);
            }];
            sensorImgView.image = [UIImage imageNamed:@"search_sensor"];
            [_describeLb setText:[ASLocalizeConfig localizedString:@"搜索新的传感器前,请先确保传感器的开关已经打开,然后点击搜索按钮."]];
        }
    }

}

//-(void)pushToHelpViewAction{
//    ASHelpTextViewController *newDeviceVC = [[ASHelpTextViewController alloc] init];
//    [self presentViewController:newDeviceVC animated:YES completion:nil];
//}

-(void)searchBtnAction:(UIButton *)sender{
    self.hidesBottomBarWhenPushed = YES;
    ASNewDeviceViewController *newDeviceVC = [[ASNewDeviceViewController alloc] init];
    [self.navigationController pushViewController:newDeviceVC animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

-(void)backToTypeViewAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backToRootView{
//    //不能实现
//    for (UIViewController *controller in self.navigationController.viewControllers) {
//        if ([controller isKindOfClass:[ASDeviceManageViewController class]]) {
//            ASDeviceManageViewController *deviceManagevc = [[ASDeviceManageViewController alloc] init];
//            [self.navigationController popToViewController:deviceManagevc animated:YES];
//        }
//    }
    //可实现
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _pageControl.currentPage = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (_pageControl.currentPage == 1) {
        [_describeLb setText:[ASLocalizeConfig localizedString:@"2、Long press the button near the gateway.Then click the search button."]];
    }else{
        [_describeLb setText:[ASLocalizeConfig localizedString:@"1、Long press the button 10s to reset the remote control."]];
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
