//
//  ASSchedulesManageViewController.m
//  Smart Home
//
//  Created by MacBook on 16/8/29.
//  Copyright © 2016年 Trust International B.V. All rights reserved.
//

#import "ASSchedulesManageViewController.h"
#import "ASGlobalDataObject.h"
#import "ASDataBaseOperation.h"
#import "ASUserDefault.h"
#import <STAlertView.h>

#define TAG_DELETE_TASK_CONFIRM 800109
#define TAG_SUCCESS_EDIT_NAME 800117
@interface ASSchedulesManageViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *_manageTableView;
    
    NSIndexPath *_indexDelete; //删除的索引
    STAlertView *_saveAlert; //保存名称的确认框
    UIView *_editTaskView;     //底部批量删除视图
    UIButton *_rightBarBtn; //导航右按钮
    NSMutableArray *_selectorTaskArray;//存放选中数据
    //批量删除对列
    dispatch_queue_t _deleteQueue;
}


@end

@implementation ASSchedulesManageViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"任务"];
    [self initWithTaskManageView];
    // 设置tableView在编辑模式下可以多选，并且只需设置一次
    _manageTableView.allowsMultipleSelectionDuringEditing = YES;
    
}

-(void)initWithTaskManageView{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToSettingBtnAction) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    //导航栏右按钮
    _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"编辑"] forState:UIControlStateNormal];
    [_rightBarBtn addTarget:self action:@selector(makeTaskSelecttable) forControlEvents:UIControlEventTouchUpInside];
    _rightBarBtn.frame = CGRectMake(0, 0, 58, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height-64;
    if (!_manageTableView) {
        _manageTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [self.view addSubview:_manageTableView];
        [_manageTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        _manageTableView.delegate = self;
        _manageTableView.dataSource = self;
    }
    
    //底部批量删除视图
    _editTaskView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_ADURO_HEIGHT - 64, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT)];
    _editTaskView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_editTaskView];
    
    //delete分割线
    UIView *separatorView = [[UIView alloc]init];
    [separatorView setBackgroundColor:CELL_LIEN_COLOR];
    [_editTaskView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_editTaskView.mas_leading);
        make.trailing.equalTo(_editTaskView.mas_trailing);
        make.height.equalTo(@(1));
        make.top.equalTo(_editTaskView.mas_top);
    }];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editTaskView addSubview:deleteBtn];
//    [delateBtn setTitle:[ASLocalizeConfig localizedString:@"删除"] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(removeTaskSelectedCells) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_editTaskView.mas_trailing).offset(-20);
        make.centerY.equalTo(_editTaskView.mas_centerY);
        make.width.equalTo(@(44));
        make.height.equalTo(deleteBtn.mas_width);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_globalTaskInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.backgroundColor = VIEW_BACKGROUND_COLOR;
    }
    AduroTask *task = [_globalTaskInfoArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:task.taskName];
    [cell.imageView setImage:[UIImage imageNamed:@"schedules_set"]];
    NSString *taskNetStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
    if (task.taskConditionSecond == SCHEDULES_NET_STATE_ONLINE) {
        taskNetStateStr = @"";
    }else{
        taskNetStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
    }
    [cell.detailTextLabel setText:taskNetStateStr];    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_manageTableView.isEditing) {
        AduroTask *selectTasks = [_globalTaskInfoArray objectAtIndex:indexPath.row];
        if (_selectorTaskArray == nil) {
            _selectorTaskArray = [[NSMutableArray alloc] init];
        }
        [_selectorTaskArray addObject:selectTasks];
    }else{
        //取消选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        AduroTask *oneTask = [_globalTaskInfoArray objectAtIndex:indexPath.row];
        [self changeTaskName:oneTask];
    }
}

-(void)changeTaskName:(AduroTask *)selectedTask{
    
    NSString *strName = @"";
    if (selectedTask) {
        strName = selectedTask.taskName;
    }
    _saveAlert = [[STAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"修改任务名称"] message:[ASLocalizeConfig localizedString:@"请输入名称"] textFieldHint:@"" textFieldValue:strName cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitle:[ASLocalizeConfig localizedString:@"保存"] cancelButtonBlock:^{
        
    } otherButtonBlock:^(NSString * result) {
        if ([result isEqualToString:strName]) {
            //未更改
            return;
        }
        
        BOOL isDeviceExist = NO;
        
        if (selectedTask) {
            for (AduroTask *taskInfo in _globalTaskInfoArray) {
                if ([result isEqualToString:taskInfo.taskName]) {
                    isDeviceExist = YES;
                }
            }
        }
        
        if (isDeviceExist) { //是 则重名了
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"名称已存在"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
            [alertView show];
        }else{ //未重名 可用
            if ([result length]<1||[result length]>30) {
                UIAlertView *failedAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"名称长度应在1到30之间"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [failedAlertView show];
            }else{
                //更新本地库里的任务名称
                for (int i=0; i<[_globalTaskInfoArray count]; i++) {
                    AduroTask *task = [_globalTaskInfoArray objectAtIndex:i];
                    if (selectedTask.taskName == task.taskName) {
                        task.taskName = result;
                    }
                }
                //更新网关里的任务名
                TaskManager *taskManager = [TaskManager sharedManager];
                [selectedTask setTaskName:result];
                [taskManager changeNameWithTask:selectedTask completionHandler:^(AduroSmartReturnCode code) {
                    DLog(@"无打印结果,不进入此方法 = %@",code);
                }];
                [self changeTaskName:selectedTask.taskName withID:selectedTask.taskID];
                UIAlertView *successAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"保存成功"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
                [successAlertView setTag:TAG_SUCCESS_EDIT_NAME];
                [successAlertView setDelegate:self];
                [successAlertView show];
            }
        }
    }];
    [_saveAlert show];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

#pragma mark - 删除指定任务
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _indexDelete = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"删除"] message:[ASLocalizeConfig localizedString:@"您确定要删除该任务吗"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitles:[ASLocalizeConfig localizedString:@"确定"], nil];
        [alert setTag:TAG_DELETE_TASK_CONFIRM];
        [alert show];
    }
}
//删除设备
-(void)startDeleteTask{
    // 从数据源中删除
    AduroTask *taskInfo = [_globalTaskInfoArray objectAtIndex:_indexDelete.row];
//    if (taskInfo) {
    //从数据库通过id删除任务
    [self deleteTaskDataObjectWithID:taskInfo.taskID];
    
    //从网关中删除任务
    TaskManager *taskManager = [TaskManager sharedManager];
    [taskManager deleteTask:taskInfo completionHandler:^(AduroSmartReturnCode code) {
        NSLog(@"deleteDeviceReturnCode = %d",(int)code);
        sleep(0.8);
    }];
    
    //从列表中删除
    [_globalTaskInfoArray removeObject:taskInfo];
    [_manageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexDelete] withRowAnimation:(UITableViewRowAnimationFade)];
//    TaskManager *taskManager = [TaskManager sharedManager];
//    [taskManager deleteTask:taskInfo completionHandler:^(AduroSmartReturnCode code) {
//        NSLog(@"deleteDeviceReturnCode = %d",(int)code);
//        sleep(2);
//        [self stopMBProgressHUD];
//        //刷新设备列表
//        //通知主线程刷新
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //从数据源中删除任务
//            [_globalTaskInfoArray removeObjectAtIndex:_indexDelete.row];
//            [_manageTableView reloadData];
//        });
//    }];
    
//    }else{
//        [self stopMBProgressHUD];
//    }
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_DELETE_TASK_CONFIRM) {
        if (buttonIndex == 1) {
            [self startDeleteTask];
        }
    }

    //修改设备名称成功
    if (alertView.tag == TAG_SUCCESS_EDIT_NAME) {
        if (buttonIndex == 0) {
            [_manageTableView reloadData];
        }
    }
}

#pragma mark - 批量删除
- (void)makeTaskSelecttable
{
    [_manageTableView setEditing:!_manageTableView.isEditing animated:YES];
    if (_manageTableView.isEditing) {
        [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"取消"] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        //为编辑状态的时候，底部浮起视图
        CGRect startFrame = CGRectMake(0, SCREEN_ADURO_HEIGHT - 64 - SELECT_DELETE_VIEW_HEIGHT, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT);
        [UIView animateWithDuration:0.1 animations:^{
            _editTaskView.frame = startFrame;
        }];
    }else{
        [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"编辑"] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        //为非编辑状态则，底部视图消失
        CGRect endFrame = CGRectMake(0, SCREEN_ADURO_HEIGHT - 64, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT);
        [UIView animateWithDuration:0.1 animations:^{
            _editTaskView.frame = endFrame;
        }];
    }
}
////禁止左滑删除
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    AduroTask *unselectTasks = [_globalTaskInfoArray objectAtIndex:indexPath.row];
    if (_selectorTaskArray) {
        for (int i = 0; i<[_selectorTaskArray count]; i++) {
            AduroTask *task = [_selectorTaskArray objectAtIndex:i];
            if (task.taskID == unselectTasks.taskID ) {
                //删除取消选中的room
                [_selectorTaskArray removeObject:task];
            }
        }
    }
}

-(void)removeTaskSelectedCells{
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _deleteQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    DLog(@"%@",_selectorTaskArray);
    //从网关中删除选中任务
    if (_selectorTaskArray) {
        
        [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Deleting..."]];
        for (int i=0; i< _selectorTaskArray.count; i++) {
            AduroTask *deleteTask = [_selectorTaskArray objectAtIndex:i];
            //从本地数据库中通过id删除任务
            [self deleteTaskDataObjectWithID:deleteTask.taskID];
            //从网关删除任务
            dispatch_async(_deleteQueue, ^{
                [NSThread sleepForTimeInterval:1.0f];
                TaskManager *taskManager = [TaskManager sharedManager];
                [taskManager deleteTask:deleteTask completionHandler:^(AduroSmartReturnCode code) {
                    DLog(@"deleteDeviceReturnCode = %d",(int)code);
                    if (i == _selectorTaskArray.count-1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self stopMBProgressHUD];
                        });
                    }
                }];
            });
            
        }
        //从数组中删除选中任务
        [_globalTaskInfoArray removeObjectsInArray:_selectorTaskArray];
        [_manageTableView reloadData];
    }
    [self makeTaskSelecttable];
}

//-(void)deleteTaskDelay:(AduroTask *)task{
//    //从网关删除设备
//    dispatch_async(_deleteQueue, ^{
//        [NSThread sleepForTimeInterval:1.5f];
//        TaskManager *taskManager = [TaskManager sharedManager];
//        [taskManager deleteTask:task completionHandler:^(AduroSmartReturnCode code) {
//            NSLog(@"deleteDeviceReturnCode = %d",(int)code);
//
//        }];
//    });
//    
//}

-(void)backToSettingBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 本地数据处理
-(void)deleteTaskDataObjectWithID:(NSInteger)taskId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db deleteTaskWithID:taskId withGatewayid:[ASUserDefault loadGatewayIDCache]] ;
}
//更新场景名称到数据库
-(void)changeTaskName:(NSString *)name withID:(NSInteger)taskId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateTaskNameData:name withID:taskId withGatewayid:[ASUserDefault loadGatewayIDCache]] ;
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
