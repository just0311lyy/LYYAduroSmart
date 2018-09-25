//
//  ASSchedulesViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/27.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSchedulesViewController.h"
#import "ASGlobalDataObject.h"
#import "ASTimeTaskViewController.h"
#import "ASActionTaskViewController.h"
#import "ASSchedulesCell.h"
#import "ASDataBaseOperation.h"
#import "ASGlobalDataObject.h"
#import "ASUserDefault.h"
#import <MJRefresh.h>

#define TAG_DELETE_TASK_CONFIRM 800109
@interface ASSchedulesViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,ASSchedulesCellDelegate>{
    UITableView *_schedulesTableView;
    TaskManager *_taskManager;
    NSIndexPath *_indexDelete; //删除的索引

    NSArray *_taskArr;
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@end

@implementation ASSchedulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _taskArr = [self getTaskDataObject];
    [_globalTaskInfoArray addObjectsFromArray:_taskArr];

    [self initWithSchedulesView];
    [self getTotalTask];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTaskTable) name:NOTI_REFRESH_SCHEDULES_TABLE object:nil];
}

-(void)initWithSchedulesView{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,-64, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT)];
    [imgView setImage:[UIImage imageNamed:@"main_background"]];
    [self.view addSubview:imgView];
    
    UILabel *upLineLb = [UILabel new];
    upLineLb.backgroundColor = [UIColor whiteColor];
    upLineLb.alpha = 0.5;
    [self.view addSubview:upLineLb];
    [upLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(0.5));
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(self.view.mas_top);
    }];
    UILabel *downLineLb = [UILabel new];
    downLineLb.backgroundColor = [UIColor whiteColor];
    downLineLb.alpha = 0.5;
    [self.view addSubview:downLineLb];
    [downLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(0.5));
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom);
    }];

    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarBtn setBackgroundImage:[UIImage imageNamed:@"add_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(addNewSchedulesBtnAction) forControlEvents:UIControlEventTouchUpInside];
    rightBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    UIView *backgroundView = [UIView new];
    [self.view addSubview:backgroundView];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.layer.cornerRadius = 30;
    backgroundView.alpha = 0.8;
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.leading.equalTo(self.view.mas_leading).offset(20);
        make.trailing.equalTo(self.view.mas_trailing).offset(-20);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
    
    if (!_schedulesTableView) {
        _schedulesTableView = [[UITableView alloc] init];
        _schedulesTableView.layer.cornerRadius = 8;
        _schedulesTableView.alpha = 0.8;
        [backgroundView addSubview:_schedulesTableView];
        [_schedulesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backgroundView.mas_top).offset(18);
            make.leading.equalTo(backgroundView.mas_leading);
            make.trailing.equalTo(backgroundView.mas_trailing);
            make.bottom.equalTo(backgroundView.mas_bottom).offset(-18);
        }];
        [_schedulesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _schedulesTableView.delegate = self;
        _schedulesTableView.dataSource = self;
        _schedulesTableView.tableHeaderView = [self headerView];
        _schedulesTableView.tableFooterView = [self footerView];
        //        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        _schedulesTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadAllSchedules)];
    }

}

- (UIView *)headerView
{
    CGFloat imgWidth = SCREEN_ADURO_WIDTH - 50*2;
    CGFloat imgHeight = imgWidth * 406 /502 ;
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, 55 + imgHeight)];
        UIImageView *noSceneImgView = [UIImageView new];
        [noSceneImgView setImage:[UIImage imageNamed:@"task_table_header"]];
        [_headerView addSubview:noSceneImgView];
        [noSceneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_top).offset(55);
            make.centerX.equalTo(_headerView.mas_centerX);
            make.width.equalTo(@(imgWidth));
            make.height.equalTo(@(imgHeight));
        }];
    }
    return  _headerView;
}

- (UIView *)footerView
{
    if (_footerView == nil)
    {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, 60 + 44 + 35 + 63/2 )];
        
        UIButton *timeTaskBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [timeTaskBtn.layer setMasksToBounds:YES];
        [timeTaskBtn.layer setCornerRadius:22.0];
        [timeTaskBtn setBackgroundColor:UIColorFromRGB(0xffad2c)];
        [timeTaskBtn setTitle:[ASLocalizeConfig localizedString:@"定时任务"] forState:UIControlStateNormal];
        [timeTaskBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [timeTaskBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [timeTaskBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [timeTaskBtn addTarget:self action:@selector(creatTimeTaskBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:timeTaskBtn];
        [timeTaskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_footerView.mas_top).offset(50);
            make.leading.equalTo(_footerView.mas_leading).offset(20);
            make.height.equalTo(@(44));
            make.width.equalTo(@((SCREEN_ADURO_WIDTH - 40 - 20 -20 -20)/2));
        }];
        //
        UIButton *triggerTaskBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [triggerTaskBtn.layer setMasksToBounds:YES];
        [triggerTaskBtn.layer setCornerRadius:22.0];
        [triggerTaskBtn setBackgroundColor:UIColorFromRGB(0X999999)];
        [triggerTaskBtn setTitle:[ASLocalizeConfig localizedString:@"触发任务"] forState:UIControlStateNormal];
        [triggerTaskBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [triggerTaskBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [triggerTaskBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [triggerTaskBtn addTarget:self action:@selector(creatTriggerTaskBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:triggerTaskBtn];
        [triggerTaskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeTaskBtn.mas_top);
            make.trailing.equalTo(_footerView.mas_trailing).offset(-20);
            make.height.equalTo(timeTaskBtn.mas_height);
            make.width.equalTo(timeTaskBtn.mas_width);
        }];
        
        UIImageView *downRefreshImgView = [UIImageView new];
        [downRefreshImgView setImage:[UIImage imageNamed:@"down_refresh"]];
        [_footerView addSubview:downRefreshImgView];
        [downRefreshImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeTaskBtn.mas_bottom).offset(30);
            make.centerX.equalTo(_footerView.mas_centerX);
            make.width.equalTo(@(295/2));
            make.height.equalTo(@(63/2));
        }];
    }
    return  _footerView;
}

////获取任务
//-(void)initWithTaskData{
////    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"数据获取中..."]];
////    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(cancelMBProgressHUD) userInfo:nil repeats:NO];
//    [self getTotalTask];
//    
//}

-(void)refreshTaskTable{
    [self getTotalTask];
}

//获取所有任务数据
-(void)getTotalTask{

    TaskManager *taskManager = [TaskManager sharedManager];
    [taskManager getAllTasks:^(AduroTask *task) {
        DLog(@"task = %@",task);
        if (task) {
            if (task.taskID > 0) {
                BOOL isRepeat = NO;  //不重复的
                for (int i=0; i<[_globalTaskInfoArray count]; i++) {
                    AduroTask *myTask = [_globalTaskInfoArray objectAtIndex:i];
                    if (myTask.taskID == task.taskID) {
                        isRepeat = YES;  //重复的
                        [task setTaskConditionSecond:SCHEDULES_NET_STATE_ONLINE];
                        [_globalTaskInfoArray replaceObjectAtIndex:i withObject:task];
                        //更新缓存中任务的新的任务名
                        [self changeTaskName:task.taskName withID:task.taskID];
                    }
                }
                if (!isRepeat) { //新的任务
                    [self saveTaskDataObject:task];
                    /*
                     * 使用任务时间：秒。进行场景在线不在线的标记
                     * 100 为在线
                     */
                    [task setTaskConditionSecond:SCHEDULES_NET_STATE_ONLINE];
                    [_globalTaskInfoArray addObject:task];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshTableView];
                    [self cancelRefreshTaskTable];
                });
            }
        }
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _globalTaskInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    AduroTask *myTask = [_globalTaskInfoArray objectAtIndex:indexPath.row];

    DLog(@"myTask.taskTriggeredDevice.deviceLightLevel = %d",myTask.taskTriggeredDevice.deviceLightLevel);
    DLog(@"myTask.taskTriggeredDevice.deviceLightHue = %d",myTask.taskTriggeredDevice.deviceLightHue);
    DLog(@"myTask.taskTriggeredDevice.deviceLightSat = %d",myTask.taskTriggeredDevice.deviceLightSat);
    DLog(@"myTask.taskTriggeredDevice.deviceSwitchState = %d",myTask.taskTriggeredDevice.deviceSwitchState);
    ASSchedulesCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ASSchedulesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }
    [cell setAduroTaskInfo:myTask];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AduroTask *aduroTaskInfo = [_globalTaskInfoArray objectAtIndex:indexPath.row];
    if (/* aduroTaskInfo.taskType == TaskTypeDeviceTimer || */aduroTaskInfo.taskType == TaskTypeSceneTimer) {
        self.hidesBottomBarWhenPushed = YES;
        ASTimeTaskViewController *timeTaskVC = [[ASTimeTaskViewController alloc] init];
        timeTaskVC.myAduroTask = aduroTaskInfo;
        [self.navigationController pushViewController:timeTaskVC animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }else{
        self.hidesBottomBarWhenPushed = YES;
        ASActionTaskViewController *actionTaskVC = [[ASActionTaskViewController alloc] init];
        actionTaskVC.myAduroTask = aduroTaskInfo;
        [self.navigationController pushViewController:actionTaskVC animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASSchedulesCell getCellHeight];
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
    AduroTask *deleteTask = _globalTaskInfoArray[indexPath.row];
    [_globalTaskInfoArray removeObject:deleteTask];
    // 从数据库通过id删除任务
    [self deleteTaskDataObject:deleteTask.taskID];

    //从网关中删除任务
    TaskManager *taskManager = [TaskManager sharedManager];
    [taskManager deleteTask:deleteTask completionHandler:^(AduroSmartReturnCode code) {
        DLog(@"deleteDeviceReturnCode = %d",(int)code);
    }];
    //从列表中删除
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        _indexDelete = indexPath;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"删除"] message:[ASLocalizeConfig localizedString:@"您确定要删除该任务吗"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitles:[ASLocalizeConfig localizedString:@"确定"], nil];
//        [alert setTag:TAG_DELETE_TASK_CONFIRM];
//        [alert show];
//    }
}

////删除
//-(void)startDeleteTask{
//    // 从数据源中删除
//    AduroTask *taskInfo = [_globalTaskInfoArray objectAtIndex:_indexDelete.row];
////    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"删除任务中..."]];
//    if (taskInfo) {
//        if (taskInfo.taskID<1) {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"编号小于1无法删除"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
//            [alert show];
//        }else{
//            TaskManager *taskManager = [TaskManager sharedManager];
//            [taskManager deleteTask:taskInfo completionHandler:^(AduroSmartReturnCode code) {
//                NSLog(@"deleteDeviceReturnCode = %d",(int)code);
//                sleep(2);
////                [self stopMBProgressHUD];
//                //刷新设备列表
//                //通知主线程刷新
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_globalTaskInfoArray removeObjectAtIndex:_indexDelete.row];
//                    [_schedulesTableView reloadData];
//                });
//            }];
//        }
//    }
////    else{
////        [self stopMBProgressHUD];
////    }
//}

-(void)cancelMBProgressHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopMBProgressHUD];
    });
}

#pragma mark - ASSceneDelegate
-(BOOL)taskSwitch:(BOOL)isTaskOn aduroInfo:(AduroTask *)taskInfo{
    DLog(@"%d",isTaskOn);
    isTaskOn = !isTaskOn;
    BOOL onOff = YES;
    onOff = isTaskOn ? YES : NO;
    taskInfo.taskEnable = onOff;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TaskManager *taskManage = [TaskManager sharedManager];
        [taskManage updateTask:taskInfo completionHandler:^(NSInteger taskID, AduroSmartReturnCode code) {
            DLog(@"任务开关结果返回值 = %d",code);
        }];
    });

    return isTaskOn;
}

-(void)addNewSchedulesBtnAction{
    UIAlertView *addAlert = [[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"添加"] message:[ASLocalizeConfig localizedString:@"添加一个新的任务"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitles:[ASLocalizeConfig localizedString:@"定时任务"],[ASLocalizeConfig localizedString:@"触发任务"],nil];
    [addAlert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_DELETE_TASK_CONFIRM) {
        if (buttonIndex == 1) {
//            [self startDeleteTask];
        }
    }else{
        if (buttonIndex == 0) {
            DLog(@"点击的是取消按钮");
        }else if(buttonIndex == 1){
            [self creatTimeTaskBtnClick];
            DLog(@"点击的是定时任务");
        }else{
            [self creatTriggerTaskBtnClick];
            DLog(@"点击的是联动任务");
        }
    }
}

-(void)creatTimeTaskBtnClick{
    self.hidesBottomBarWhenPushed = YES;
    ASTimeTaskViewController *timeTaskVC = [[ASTimeTaskViewController alloc] init];
    [self.navigationController pushViewController:timeTaskVC animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

-(void)creatTriggerTaskBtnClick{
    self.hidesBottomBarWhenPushed = YES;
    ASActionTaskViewController *actionTaskVC = [[ASActionTaskViewController alloc] init];
    [self.navigationController pushViewController:actionTaskVC animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

-(void)tableRefreshLoadAllSchedules{
    [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(cancelRefreshTaskTable) userInfo:nil repeats:NO];
    /* 缓存 */
    [_globalTaskInfoArray removeAllObjects];
    _taskArr = [self getTaskDataObject];
    [_globalTaskInfoArray addObjectsFromArray:_taskArr];
    [_schedulesTableView reloadData];
    [self getTotalTask];
}

-(void)cancelRefreshTaskTable{
    [_schedulesTableView.mj_header endRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshTableView];
}

- (void)refreshTableView
{
    if ([_globalTaskInfoArray count] > 0) {
        _schedulesTableView.tableHeaderView = nil;
    }
    else
    {
        _schedulesTableView.tableHeaderView = [self headerView];
    }
    [_schedulesTableView reloadData];
}

#pragma mark - 保存任务到数据库
-(void)saveTaskDataObject:(AduroTask *)data{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveTasksData:data withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//从数据库中获取任务对象数组
-(NSArray *)getTaskDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectTaskDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}

//从数据库根据id删除任务
-(void)deleteTaskDataObject:(NSInteger)taskId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db deleteTaskWithID:taskId withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//更新场景名称到数据库
-(void)changeTaskName:(NSString *)name withID:(NSInteger)taskId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateTaskNameData:name withID:taskId withGatewayid:[ASUserDefault loadGatewayIDCache]];
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
