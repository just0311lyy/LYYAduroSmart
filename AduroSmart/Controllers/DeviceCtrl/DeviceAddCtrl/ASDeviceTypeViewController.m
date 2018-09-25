//
//  ASDeviceTypeViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/15.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDeviceTypeViewController.h"
#import "ASDeviceSearchViewController.h"
#import "ASListCell.h"

@interface ASDeviceTypeViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
   
}

@end

@implementation ASDeviceTypeViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"分类"];
    [self initWithDeviceTypeTable];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
}

-(void)initWithDeviceTypeTable{
    NSArray *dataArray = @[
@{@"name":[ASLocalizeConfig localizedString:@"灯"],@"imageName":@"light",@"selector":@"lightManageAction"},
@{@"name":[ASLocalizeConfig localizedString:@"传感器"],@"imageName":@"sensor",@"selector":@"sensorManageAction"},
@{@"name":[ASLocalizeConfig localizedString:@"Remote control"],@"imageName":@"light_remotes",@"selector":@"remoteControlManageAction"}];
    _dataArray = [[NSMutableArray alloc]init];
    [_dataArray addObjectsFromArray:dataArray];
    
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToDeviceMineViewAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height - 64;
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.backgroundColor = VIEW_BACKGROUND_COLOR;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
  
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    ASListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

    }
    cell.txtLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    UIImage *image = [UIImage imageNamed:[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"imageName"]];
    cell.imgView.image = image;
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.hidesBottomBarWhenPushed = YES;
    ASDeviceSearchViewController *searchvc = [[ASDeviceSearchViewController alloc] init];
    searchvc.titleName = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self.navigationController pushViewController:searchvc animated:YES];
    self.hidesBottomBarWhenPushed = YES;
  
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASListCell getCellHeight];
}

-(void)backToDeviceMineViewAction{
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
