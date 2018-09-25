//
//  ASTypeGroupViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/4.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASTypeGroupViewController.h"
#import "ASHomeTypeCell.h"

@interface ASTypeGroupViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableArray *_typeMutableArr; //group 类型
}

@end

@implementation ASTypeGroupViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"房间类型"];
    NSArray *dataArray = @[
  @{@"name":[ASLocalizeConfig localizedString:@"客厅"],@"imageName":@"living_room",@"typeId":@"01"},
  @{@"name":[ASLocalizeConfig localizedString:@"厨房"],@"imageName":@"kitchen",@"typeId":@"02"},
  @{@"name":[ASLocalizeConfig localizedString:@"卧室"],@"imageName":@"bedroom",@"typeId":@"03"},
  @{@"name":[ASLocalizeConfig localizedString:@"浴室"],@"imageName":@"bathroom",@"typeId":@"04"},
  @{@"name":[ASLocalizeConfig localizedString:@"餐厅"],@"imageName":@"restaurant",@"typeId":@"05"},
  @{@"name":[ASLocalizeConfig localizedString:@"厕所"],@"imageName":@"toilet",@"typeId":@"06"},
  @{@"name":[ASLocalizeConfig localizedString:@"办公室"],@"imageName":@"office",@"typeId":@"07"},
  @{@"name":[ASLocalizeConfig localizedString:@"走廊"],@"imageName":@"hallway",@"typeId":@"08"}];
    _typeMutableArr = [[NSMutableArray alloc]init];
    [_typeMutableArr addObjectsFromArray:dataArray];
    
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

    return _typeMutableArr.count;
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
    cell.txtLabel.text =[_typeMutableArr[indexPath.row] objectForKey:@"name"];
    cell.imgView.image = [UIImage imageNamed:[_typeMutableArr[indexPath.row] objectForKey:@"imageName"]];
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(selectTypeGroupViewController:didSelectString:andImageName:andTypeId:)]) {
        NSString *homeName= [_typeMutableArr[indexPath.row] objectForKey:@"name"];
        NSString *homeImageName= [_typeMutableArr[indexPath.row] objectForKey:@"imageName"];
        NSString *typeId= [_typeMutableArr[indexPath.row] objectForKey:@"typeId"];
         [self.delegate selectTypeGroupViewController:self didSelectString:homeName andImageName:homeImageName andTypeId:typeId];
     }

     // 关闭当前控制器
    [self.navigationController popViewControllerAnimated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASHomeTypeCell getCellHeight];
}

//-(NSString *)tableView:(UITableView * )tableView titleForHeaderInSection:(NSInteger)section{
//    return [ASLocalizeConfig localizedString:@"房间类型"];
//}
//
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
