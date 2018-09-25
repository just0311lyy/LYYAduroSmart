//
//  ASServerViewController.m
//  AduroSmart
//
//  Created by MacBook on 2016/12/23.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASServerViewController.h"
#import "ASServerModel.h"
@interface ASServerViewController ()<UITableViewDelegate,UITableViewDataSource>{

    UITableView *_serverTableView;
    NSMutableArray *_serverArray;

    //存储所有的域名和它对应的状态
    NSMutableArray *_allDeviceAndTagArray;
}


@end

@implementation ASServerViewController
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
    
    [self initServerTableView];
    self.title = [ASLocalizeConfig localizedString:@"Domain"];
    [self initWithServerAdress];
    
//    GatewayManager *gManager = [GatewayManager sharedManager];
//    [gManager updateGatewayServerDomain:@"120.24.242.83" completionHandler:^(NSString *domain) {
//        DLog(@"domain:%@",domain);
//        
//    }];
}

-(void)initServerTableView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backSet) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height-64;
    if (!_serverTableView) {
        _serverTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [self.view addSubview:_serverTableView];
        [_serverTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        _serverTableView.delegate = self;
        _serverTableView.dataSource = self;
    }
   
}

-(void)initWithServerAdress{
    NSArray *dataArray = @[
@{@"country":[ASLocalizeConfig localizedString:@"China"],@"address":CHINA_DOMAIN_SERVER_ADDRESS},
@{@"country":[ASLocalizeConfig localizedString:@"Europe"],@"address":EUROPE_DOMAIN_SERVER_ADDRESS}
];
    _serverArray = [NSMutableArray arrayWithArray:dataArray];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_serverArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"serverCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [[_serverArray objectAtIndex:indexPath.row] objectForKey:@"country"];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self updateGatewayServerDomain:[[_serverArray objectAtIndex:indexPath.row] objectForKey:@"address"]];
    if ([self.delegate respondsToSelector:@selector(selectViewController:didSelectServer:)]) {
        NSString *country = [[_serverArray objectAtIndex:indexPath.row] objectForKey:@"country"];
        [self.delegate selectViewController:self didSelectServer:country];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateGatewayServerDomain:(NSString *)address{
    
    GatewayManager *gManager = [GatewayManager sharedManager];
    [gManager updateGatewayServerDomain:address completionHandler:^(NSString *domain) {
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)backSet{
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
