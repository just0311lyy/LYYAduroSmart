//
//  ASTypeSceneViewController.m
//  AduroSmart
//
//  Created by MacBook on 2016/11/29.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASTypeSceneViewController.h"
#import "ASHomeTypeCell.h"
@interface ASTypeSceneViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableArray *_sceneTypeMutableArr; //scene 类型
}

@end

@implementation ASTypeSceneViewController
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    //    设置导航栏背景图片为一个空的image，这样就透明了
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
//
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *navImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_ADURO_WIDTH, 64)];
    [self.view addSubview:navImgView];
    [navImgView setImage:[UIImage imageNamed:@"nav_bg"]];
    
    self.title = [ASLocalizeConfig localizedString:@"Scene names"];
    NSArray *dataArray = @[
@{@"name":[ASLocalizeConfig localizedString:@"Leaving home"],@"imageName":@"leaving_home"},
@{@"name":[ASLocalizeConfig localizedString:@"Coming home"],@"imageName":@"coming_home"},
@{@"name":[ASLocalizeConfig localizedString:@"Wake up"],@"imageName":@"wake_up"},
@{@"name":[ASLocalizeConfig localizedString:@"Go to sleep"],@"imageName":@"sleep"},
@{@"name":[ASLocalizeConfig localizedString:@"have dinner"],@"imageName":@"dinner"},
@{@"name":[ASLocalizeConfig localizedString:@"reading"],@"imageName":@"reading"},
@{@"name":[ASLocalizeConfig localizedString:@"watching_TV"],@"imageName":@"watching_TV"},
@{@"name":[ASLocalizeConfig localizedString:@"custom"],@"imageName":@"custom"}];
    _sceneTypeMutableArr = [[NSMutableArray alloc]init];
    [_sceneTypeMutableArr addObjectsFromArray:dataArray];
    [self initWithTypeGroup];
}

-(void)initWithTypeGroup{
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height - 64;
    UITableView *typeTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self.view addSubview:typeTableView];
    [typeTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    typeTableView.delegate = self;
    typeTableView.dataSource = self;
    typeTableView.tableFooterView = [[UIView alloc] init];
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _sceneTypeMutableArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    ASHomeTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASHomeTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    //    cell.textLabel.text = [_typeMutableArr[indexPath.row] objectForKey:@"name"];
    //    cell.imageView.image = [UIImage imageNamed:[_typeMutableArr[indexPath.row] objectForKey:@"imageName"]];
    cell.txtLabel.text =[_sceneTypeMutableArr[indexPath.row] objectForKey:@"name"];
    cell.imgView.image = [UIImage imageNamed:[_sceneTypeMutableArr[indexPath.row] objectForKey:@"imageName"]];
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(selectTypeSceneViewController:didSelectString:)]) {
        NSString *romeName= [_sceneTypeMutableArr[indexPath.row] objectForKey:@"name"];
        [self.delegate selectTypeSceneViewController:self didSelectString:romeName];
    }
    // 关闭当前控制器
    [self.navigationController popViewControllerAnimated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASHomeTypeCell getCellHeight];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
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
