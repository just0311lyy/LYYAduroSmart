//
//  ASSceneViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSceneViewController.h"
#import "ASGlobalDataObject.h"
#import "ASSceneCell.h"
//#import "ASSceneDetailViewController.h"
#import "ASAddSceneViewController.h"
#import <MJRefresh.h>

@interface ASSceneViewController ()<UITableViewDelegate,UITableViewDataSource,ASSceneDelegate>{
    UITableView *_sceneTableView;
    SceneManager *_sceneManager;
}

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@end

@implementation ASSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithSceneView];
    [self initWithSceneData];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSceneTable) name:NOTI_REFRESH_SENCES_TABLE object:nil];
}

-(void)initWithSceneView{
//    //导航栏左按钮
//    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"setting_nav"] forState:UIControlStateNormal];
//    [leftBarBtn addTarget:self action:@selector(settingManagerBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    leftBarBtn.frame = CGRectMake(0, 0, 22, 22);
//    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
//    self.navigationItem.leftBarButtonItem = leftBarItem;
    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarBtn setBackgroundImage:[UIImage imageNamed:@"add_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(addNewSceneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    rightBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height -49-64;
    if (!_sceneTableView) {
        _sceneTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self.view addSubview:_sceneTableView];
        [_sceneTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _sceneTableView.delegate = self;
        _sceneTableView.dataSource = self;
        _sceneTableView.tableHeaderView = [self headerView];
        _sceneTableView.tableFooterView = [self footerView];
    }
    
    //下拉刷新 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    _sceneTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadAllScene)];

}

- (UIView *)headerView
{
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_WIDTH * 0.8)];
        
        
        UILabel *labPromptAddCamera = [UILabel new];
        [_headerView addSubview:labPromptAddCamera];
        [labPromptAddCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_top);
            make.leading.equalTo(_headerView).offset(35);
            make.trailing.equalTo(_headerView).offset(-35);
            make.height.equalTo(@(_headerView.frame.size.height/2.0f));
        }];
        
        [labPromptAddCamera setFont:[UIFont systemFontOfSize:15]];
        [labPromptAddCamera setText:NSLocalizedString(@"Here you can setup scenes, scenes contain a sequence of actions ( e.g. turning a light on) so you can control multiple devices at once.\nPress + button at the top of the screen to add a scene.", nil)];
        [labPromptAddCamera setTextAlignment:NSTextAlignmentCenter];
        [labPromptAddCamera setNumberOfLines:0];
        [labPromptAddCamera setTextColor:[UIColor lightGrayColor]];
        [labPromptAddCamera setLineBreakMode:NSLineBreakByWordWrapping];
        
        UIButton *nowAddBtn = [UIButton new];
        [_headerView addSubview:nowAddBtn];
        [nowAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(labPromptAddCamera.mas_bottom);
            make.leading.trailing.equalTo(_headerView);
            make.height.equalTo(@(44));
        }];
        [nowAddBtn setTitle:NSLocalizedString(@"+ Add Scene", nil) forState:UIControlStateNormal];
        [nowAddBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [nowAddBtn addTarget:self action:@selector(addNewSceneBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return  _headerView;
}

- (UIView *)footerView
{
    if (_footerView == nil)
    {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_WIDTH * 0.6)];
        
        
        UILabel *labPromptAddCamera = [UILabel new];
        [_footerView addSubview:labPromptAddCamera];
        [labPromptAddCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_footerView.mas_top);
            make.leading.equalTo(_footerView).offset(50);
            make.trailing.equalTo(_footerView).offset(-50);
            make.height.equalTo(@(_footerView.frame.size.height/2.0f));
        }];
        [labPromptAddCamera setFont:[UIFont systemFontOfSize:15]];
        [labPromptAddCamera setText:NSLocalizedString(@"Pull down to refresh", nil)];
        [labPromptAddCamera setTextAlignment:NSTextAlignmentCenter];
        [labPromptAddCamera setNumberOfLines:0];
        [labPromptAddCamera setTextColor:[UIColor lightGrayColor]];
        [labPromptAddCamera setLineBreakMode:NSLineBreakByWordWrapping];
    }
    return  _footerView;
}

-(void)refreshSceneTable{
    [self getAllSceneData];
}

-(void)initWithSceneData{
//    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"数据获取中..."]];
//    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(cancelSceneMBProgressHUD) userInfo:nil repeats:NO];
    [self getAllSceneData];
}

-(void)getAllSceneData{
    _sceneManager = [SceneManager sharedManager];
    [_sceneManager getAllScenes:^(AduroScene *scene) {
        NSLog(@"scene = %@",scene);
        if (scene == nil) {
            NSLog(@"返回scene为空");
            return;
        }
        for (int i=0; i<[_globalSceneArray count]; i++) {
            AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
            if (myScene.sceneID == scene.sceneID) {
                if ([_globalSceneArray count]>i) {
                    [_globalSceneArray removeObjectAtIndex:i];
                }
            }
        }
        DDLogInfo(@"getAllScenes = %@",scene);
        if ([scene.sceneName length]>0) {
            [_globalSceneArray addObject:scene];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//            [_sceneTableView reloadData];
            [self refreshTableView];
            //回调或者说是通知主线程刷新，
//            [self stopMBProgressHUD];
        });
    }];
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _globalSceneArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    ASSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASSceneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }
    AduroScene *aduroScene = _globalSceneArray[indexPath.row];
    cell.sceneNameLb.text = aduroScene.sceneName;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //点击激活场景
    AduroScene *scene = _globalSceneArray[indexPath.row];
    SceneManager *sceneManager = [SceneManager sharedManager];
    [sceneManager useGroupIDCallScene:scene completionHandler:^(AduroSmartReturnCode code) {
        NSLog(@"AduroSmartReturnCode = %d",(int)code);
        if (code == AduroSmartReturnCodeSuccess) {
            
        }
    }];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"完成"] message:[ASLocalizeConfig localizedString:@"成功开启场景"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
    [alert show];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASSceneCell getCellHeight];
}

//左滑删除可编辑模式
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//左滑出现的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ASLocalizeConfig localizedString:@"删除"];
}
//删除所做的动作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 从数据源中删除
    AduroScene *deleteScene = _globalSceneArray[indexPath.row];
    [_globalSceneArray removeObjectAtIndex:indexPath.row];
    // 从网关场景管理中删除该场景
    [_sceneManager deleteScene:deleteScene completionHandler:^(AduroSmartReturnCode code) {
        NSLog(@"删除场景返回 = %d",(int)code);
        if (code == AduroSmartReturnCodeSuccess) {

        }
    }];
    // 从列表中删除
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - ASSceneDelegate
-(BOOL)sceneSwitch:(BOOL)isSceneOn aduroInfo:(AduroScene *)sceneInfo{
    NSLog(@"%d",isSceneOn);
    isSceneOn = !isSceneOn;
    return isSceneOn;
}

//-(void)sceneShowDetailWithGroupInfo:(AduroScene *)aduroSceneInfo{
//    ASSceneDetailViewController *detailvc = [[ASSceneDetailViewController alloc]init];
//    detailvc.detailScene = aduroSceneInfo;
//    [self setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:detailvc animated:NO];
//    [self setHidesBottomBarWhenPushed:NO];
//}

-(void)addNewSceneBtnAction{
    ASAddSceneViewController *addSceneCtrl = [[ASAddSceneViewController alloc]init];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:addSceneCtrl animated:NO];
    [self setHidesBottomBarWhenPushed:NO];
}

-(void)cancelSceneMBProgressHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self stopMBProgressHUD];
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_sceneTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshTableView];
}

- (void)refreshTableView
{
    if ([_globalSceneArray count] > 0) {
        _sceneTableView.tableHeaderView = nil;
    }
    else
    {
        _sceneTableView.tableHeaderView = [self headerView];
    }
    [_sceneTableView reloadData];
}

-(void)tableRefreshLoadAllScene{
    [_globalSceneArray removeAllObjects];
    [self getAllSceneData];
    [_sceneTableView.mj_header endRefreshing];
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
