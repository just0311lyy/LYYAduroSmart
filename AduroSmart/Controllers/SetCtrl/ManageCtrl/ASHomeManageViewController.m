//
//  ASHomeManageViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/3.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASHomeManageViewController.h"
#import "ASGlobalDataObject.h"
#import "ASManageCell.h"
#import "ASDataBaseOperation.h"
#import "ASNewHomeViewController.h"
#import "ASUserDefault.h"
#import <STAlertView.h>
#import <MJRefresh.h>
#define TAG_DELETE_GROUP_SUCCESS 800104
#define TAG_DELETE_GROUP_FAILD 800105
#define TAG_DELETE_GROUP_CONFIRM 800109
#define TAG_SUCCESS_EDIT_NAME 800117
@interface ASHomeManageViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *_homeManageTableView;
    //删除的索引
    NSIndexPath *_indexDelete;
    //保存名称的确认框
    STAlertView *_changeNameAlert;

    //group类型标识
    NSString *_selectGroupName;
    NSString *_groupTypeId;
    UIView *_editRoomView;     //底部批量删除视图
    UIButton *_rightBarBtn; //导航右按钮
    NSMutableArray *_selectorRoomArray;//存放选中数据
    //批量删除场景的对列
    dispatch_queue_t _deleteQueue;
    //批量删除房间的对列
    dispatch_queue_t _deleteRoomQueue;
}
@property (nonatomic, strong) UIView *footerView;

@end

@implementation ASHomeManageViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"房间"];
    [self initWithHomeManageView];
    // 设置tableView在编辑模式下可以多选，并且只需设置一次
    _homeManageTableView.allowsMultipleSelectionDuringEditing = YES;
}

-(void)initWithHomeManageView{
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
    [_rightBarBtn addTarget:self action:@selector(makeRoomSelecttable) forControlEvents:UIControlEventTouchUpInside];
    _rightBarBtn.frame = CGRectMake(0, 0, 58, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height-64;
    if (!_homeManageTableView) {
        _homeManageTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [self.view addSubview:_homeManageTableView];
        [_homeManageTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        _homeManageTableView.delegate = self;
        _homeManageTableView.dataSource = self;
        _homeManageTableView.tableFooterView = [self footerView];
    }
    
    //下拉刷新 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    _homeManageTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadAllHome)];
    
    //底部批量删除视图
    _editRoomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_ADURO_HEIGHT - 64, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT)];
    _editRoomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_editRoomView];
    
    //delete分割线
    UIView *separatorView = [[UIView alloc]init];
    [separatorView setBackgroundColor:CELL_LIEN_COLOR];
    [_editRoomView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_editRoomView.mas_leading);
        make.trailing.equalTo(_editRoomView.mas_trailing);
        make.height.equalTo(@(1));
        make.top.equalTo(_editRoomView.mas_top);
    }];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editRoomView addSubview:deleteBtn];
//    [deleteBtn setTitle:[ASLocalizeConfig localizedString:@"删除"] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(removeRoomSelectedCells) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_editRoomView.mas_trailing).offset(-20);
        make.centerY.equalTo(_editRoomView.mas_centerY);
        make.width.equalTo(@(44));
        make.height.equalTo(deleteBtn.mas_width);
    }];

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

-(void)getAllGroup{
    GroupManager *groupManager = [GroupManager sharedManager];
    [groupManager getAllGroups:^(AduroGroup *group) {
        if (group==nil) {
            NSLog(@"返回分组为空");
            return;
        }
        if ([group.groupName length]>0) {
            BOOL isExist = NO;
            for (int i=0; i<[_globalGroupArray count]; i++) {
                AduroGroup *myGroup = [_globalGroupArray objectAtIndex:i];
                if (myGroup.groupID == group.groupID) {
                    isExist = YES;
                    /*
                     * 使用房间类型进行房间在线不在线的标记
                     * 0x01 为在线
                     */
                    [group setGroupType:GROUP_NET_STATE_ONLINE];
                    [_globalGroupArray replaceObjectAtIndex:i withObject:group];
                    [self changeGroupName:group.groupName withID:group.groupID];
                }
            }
            if (!isExist) {
                [self saveRoomDataObject:group];  //存储到数据库
                [group setGroupType:GROUP_NET_STATE_ONLINE];
                [_globalGroupArray addObject:group];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_homeManageTableView reloadData];
            });
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_globalGroupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    AduroGroup *group = [_globalGroupArray objectAtIndex:indexPath.row];
    NSArray *array = [group.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
    NSString *name = [array firstObject];
    NSString *typeId = [array lastObject];
    [cell.textLabel setText:name];
    NSString *netStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
    if (group.groupType == GROUP_NET_STATE_ONLINE) {
        netStateStr = [ASLocalizeConfig localizedString:@""];
    }else{
        netStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
    }
    
    if (indexPath.row == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld devices          %@",_globalDeviceArray.count,netStateStr];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld devices          %@",group.groupSubDeviceIDArray.count,netStateStr];
    }
    if (group.groupSubDeviceIDArray.count == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld device          %@",group.groupSubDeviceIDArray.count,netStateStr];
    }
    if ([typeId isEqualToString:@"01"]) {
        [cell.imageView setImage:[UIImage imageNamed:@"living_room"]];
    }else if ([typeId isEqualToString:@"02"]){
        [cell.imageView setImage:[UIImage imageNamed:@"kitchen"]];
    }else if ([typeId isEqualToString:@"03"]){
        [cell.imageView setImage:[UIImage imageNamed:@"bedroom"]];
    }else if ([typeId isEqualToString:@"04"]){
        [cell.imageView setImage:[UIImage imageNamed:@"bathroom"]];
    }else if ([typeId isEqualToString:@"05"]){
        [cell.imageView setImage:[UIImage imageNamed:@"restaurant"]];
    }else if ([typeId isEqualToString:@"06"]){
        [cell.imageView setImage:[UIImage imageNamed:@"toilet"]];
    }
    else if ([typeId isEqualToString:@"07"]){
//        UIImage *img = [UIImage imageNamed:@"office"];
        [cell.imageView setImage:[UIImage imageNamed:@"office"]];
    }
    else if ([typeId isEqualToString:@"08"]){
        [cell.imageView setImage:[UIImage imageNamed:@"hallway"]];
    }else{
        [cell.imageView setImage:[UIImage imageNamed:@"all_lights"]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_homeManageTableView.isEditing) {
        AduroGroup *selectGroups = [_globalGroupArray objectAtIndex:indexPath.row];
        if (_selectorRoomArray == nil) {
            _selectorRoomArray = [[NSMutableArray alloc] init];
        }
        [_selectorRoomArray addObject:selectGroups];
    }else{
    //取消选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if (indexPath.row>0) {
            AduroGroup *oneGroup = [_globalGroupArray objectAtIndex:indexPath.row];
    //        [self changeGroupName:oneGroup];
            ASNewHomeViewController *editHomevc = [[ASNewHomeViewController alloc] init];
            editHomevc.editGroup = oneGroup;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:editHomevc animated:YES];
            self.hidesBottomBarWhenPushed = YES;
        }
    }
}

//-(void)changeGroupName:(AduroGroup *)selectedGroup{
//
//    NSString *strName = @"";
//    if (selectedGroup) {
//        NSArray *array = [selectedGroup.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
//        _selectGroupName = [array firstObject];
//        _groupTypeId = [array lastObject];
//        strName = _selectGroupName;
//    }
//    _changeNameAlert = [[STAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"修改房间名称"] message:[ASLocalizeConfig localizedString:@"请输入名称"] textFieldHint:@"" textFieldValue:strName cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitle:[ASLocalizeConfig localizedString:@"保存"] cancelButtonBlock:^{
//        
//    } otherButtonBlock:^(NSString * result) {
//        if ([result length]<1||[result length]>20) {
//            return;
//        }
//        NSLog(@"开始changeGroupName = %@",result);
//        //改名的标示判断
//        if ([_groupTypeId isEqualToString:_selectGroupName]) {
//            //无标示的则不作处理
//            [selectedGroup setGroupName:result];
//        }else{
//            //回复标示
//            NSString *newName = [result stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"-",_groupTypeId]];
//            [selectedGroup setGroupName:newName];
//        }
//        //更新数据库中房间名
//        [self changeGroupName:selectedGroup.groupName withID:selectedGroup.groupID];
//        //发送改名的命令到网关
//        GroupManager *groupManager = [GroupManager sharedManager];
//        [groupManager changeGroupName:selectedGroup completionHandler:^(AduroSmartReturnCode code) {
//            NSLog(@"结束changeGroupName = %@",selectedGroup.groupName);
//            
//        }];
//        UIAlertView *successAlertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"保存成功"] message:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
//        [successAlertView setTag:TAG_SUCCESS_EDIT_NAME];
//        [successAlertView setDelegate:self];
//        [successAlertView show];
//    }];
//
//    [_changeNameAlert show];
//
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ASManageCell getCellHeight];
}

#pragma mark - 删除指定group
//左滑删除可编辑模式
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * indexP =[NSIndexPath indexPathForRow:0 inSection:0];    
    if (indexP == indexPath) {
        return NO;
    }
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
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"删除"] message:[ASLocalizeConfig localizedString:@"你确定要删除该房间吗"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitles:[ASLocalizeConfig localizedString:@"确定"], nil];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"删除"] message:[ASLocalizeConfig localizedString:@"Delete the room will empty the scenes inside. Continue?"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitles:[ASLocalizeConfig localizedString:@"确定"], nil];
        [alert setTag:TAG_DELETE_GROUP_CONFIRM];
        [alert show];
    }
}

//删除房间里面的场景
-(void)deleteSceneOfRoom:(AduroGroup *)group{
    // 从数据源中删除
    NSMutableArray *deleteArrays = [NSMutableArray array];
    for (AduroScene *oneScene in _globalSceneArray) {
        if (oneScene.groupID == group.groupID) {
            //从数据库删除
            [self deleteSceneDataWithID:oneScene.sceneID];
            //从网关删除
            [self deleteSceneDelayed:oneScene];
            [deleteArrays addObject:oneScene];
        }
    }
    [_globalSceneArray removeObjectsInArray:deleteArrays];
}

//2.删除房间内的设备
-(void)deleteDeviceOfRoom:(AduroGroup *)group{
    NSMutableArray *deleteArray = [NSMutableArray array];
    for (int j=0; j<_globalDeviceArray.count; j++) {
        AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
        for (NSString *myID in group.groupSubDeviceIDArray) {
            if ([[myDevice.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                //属于房间内的设备删除
                [deleteArray addObject:myDevice];
            }
        }
    }
    dispatch_async(_deleteQueue, ^{
        [NSThread sleepForTimeInterval:1.0f];
        GroupManager *groupManager = [GroupManager sharedManager];
        [groupManager deleteDeviceFromGroup:group devices:deleteArray completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"%lu",code);
            
        }];
    });
}

//启动线程每隔1.2秒发布一个删除场景命令
-(void)deleteSceneDelayed:(AduroScene *)scene{
    dispatch_async(_deleteQueue, ^{
        [NSThread sleepForTimeInterval:1.2f];
        SceneManager *sceneManager = [SceneManager sharedManager];
        [sceneManager deleteScene:scene completionHandler:^(AduroSmartReturnCode code) {

        }];
    });
}

-(void)deleteGroup:(AduroGroup *)group{
    // 从sql数据库中删除
    [self deleteRoomWithGroupId:group.groupID];
    //从网关删除房间
    dispatch_async(_deleteQueue, ^{
        [NSThread sleepForTimeInterval:1.0f];
        // 从网关场景管理中删除该房间
        GroupManager *groupManager = [GroupManager sharedManager];
        [groupManager deleteGroup:group completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"删除房间结果code=%d",code);
            if (code == AduroSmartReturnCodeSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    sleep(1);
                    [self stopMBProgressHUD];
                    //删除分组成功
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"删除成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"]otherButtonTitles:nil, nil];
                    [alertView setTag:TAG_DELETE_GROUP_SUCCESS];
                    [alertView show];
                });
            }else{
                _indexDelete = nil;
            }
//            else{
//                //删除分组失败
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"删除失败"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
//                [alertView setTag:TAG_DELETE_GROUP_FAILD];
//                [alertView show];
//                _indexDelete = nil;
//            }
        }];
    });
}

//删除房间以及场景
-(void)startDeleteRoomWithScene{
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _deleteQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Deleting..."]];
//    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(cancelDeleteDMBProgressHUD) userInfo:nil repeats:NO];
    
    AduroGroup *deleteGroup = _globalGroupArray[_indexDelete.row];
    //1.删除房间内的场景
    [self deleteSceneOfRoom:deleteGroup];
    //2.删除房间内的设备
    [self deleteDeviceOfRoom:deleteGroup];
    //2.删除房间
    [self deleteGroup:deleteGroup];
    
    //    [_globalGroupArray removeObjectAtIndex:_indexDelete.row];
//    [_homeManageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexDelete] withRowAnimation:(UITableViewRowAnimationFade)];
}

//-(void)cancelDeleteDMBProgressHUD{
//    //通知主线程刷新
////    dispatch_async(dispatch_get_main_queue(), ^{
//        [self stopMBProgressHUD];
////    });
//}

//-(void)deleteSceneOfDeleteGroup:(AduroGroup *)deleteGroup{
//    SceneManager *sceneManager = [SceneManager sharedManager];
//    for (int i=0; i<_globalSceneArray.count; i++) {
//        AduroScene *oneScene = [_globalSceneArray objectAtIndex:i];
//        if (oneScene.groupID == deleteGroup.groupID) {
//            //从数据库删除
//            [self deleteSceneDataWithID:oneScene.sceneID];
//            //从数据源删除
//            [_globalSceneArray removeObjectAtIndex:i];
//            //从网关删除
//            [sceneManager deleteScene:oneScene completionHandler:^(AduroSmartReturnCode code) {
//                NSLog(@"删除场景结果code=%d",code);
//            }];
//        }
//    }
//}



#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_DELETE_GROUP_CONFIRM) {
        if (buttonIndex == 1) {
            //删除该房间以及房间内的场景
            [self startDeleteRoomWithScene];
        }
    }
    if (alertView.tag == TAG_DELETE_GROUP_SUCCESS) {
        
        if (_indexDelete) {
            [_globalGroupArray removeObjectAtIndex:_indexDelete.row];
            [_homeManageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexDelete] withRowAnimation:(UITableViewRowAnimationFade)];
//            [_homeManageTableView reloadData];
            [self tableRefreshLoadAllHome];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"allGroupListReloadData" object:nil];
//        [self tableRefreshLoadAllHome];
    }
    if (alertView.tag == TAG_DELETE_GROUP_FAILD) {
//        [self stopMBProgressHUD];
    }
    //修改设备名称成功
    if (alertView.tag == TAG_SUCCESS_EDIT_NAME) {
        if (buttonIndex == 0) {
            [_homeManageTableView reloadData];
        }
    }
}

#pragma mark - 批量删除
- (void)makeRoomSelecttable
{
    [_homeManageTableView setEditing:!_homeManageTableView.isEditing animated:YES];
    if (_homeManageTableView.isEditing) {
        [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"取消"] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        //为编辑状态的时候，底部浮起视图
        CGRect startFrame = CGRectMake(0, SCREEN_ADURO_HEIGHT - 64 - SELECT_DELETE_VIEW_HEIGHT, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT);
        [UIView animateWithDuration:0.1 animations:^{
            _editRoomView.frame = startFrame;
        }];
    }else{
        [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"编辑"] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        //为非编辑状态则，底部视图消失
        CGRect endFrame = CGRectMake(0, SCREEN_ADURO_HEIGHT - 64, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT);
        [UIView animateWithDuration:0.1 animations:^{
            _editRoomView.frame = endFrame;
        }];
    }
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    AduroGroup *unselectGroups = [_globalGroupArray objectAtIndex:indexPath.row];
    if (_selectorRoomArray) {
        for (int i = 0; i<[_selectorRoomArray count]; i++) {
            AduroGroup *group = [_selectorRoomArray objectAtIndex:i];
            if (group.groupID == unselectGroups.groupID ) {
                //删除取消选中的room
                [_selectorRoomArray removeObject:group];
            }
        }
    }
}

-(void)removeRoomSelectedCells{
    NSDate *dat = [NSDate date];
    NSString *datStr = [dat description];
    const char *queueName = [datStr UTF8String];
    _deleteRoomQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"%@",_selectorRoomArray);
    //从网关中删除选中room
    if (_selectorRoomArray) {
        [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Deleting..."]];
        for (int i=0; i< _selectorRoomArray.count; i++) {
            AduroGroup *deleteGroup = [_selectorRoomArray objectAtIndex:i];
            //1.删除房间内的场景
            NSMutableArray *deleteArrays = [NSMutableArray array];
            for (AduroScene *oneScene in _globalSceneArray) {
                if (oneScene.groupID == deleteGroup.groupID) {
                    //从数据库删除
                    [self deleteSceneDataWithID:oneScene.sceneID];
                    //从网关删除,启动线程每隔1.2秒发布一个删除场景命令
                    dispatch_async(_deleteRoomQueue, ^{
                        [NSThread sleepForTimeInterval:1.2f];
                        SceneManager *sceneManager = [SceneManager sharedManager];
                        [sceneManager deleteScene:oneScene completionHandler:^(AduroSmartReturnCode code) {
                            DLog(@"删除场景结果code=%d",code);
                        }];
                    });
                    [deleteArrays addObject:oneScene];
                }
            }
            // 从数据源中删除
            [_globalSceneArray removeObjectsInArray:deleteArrays];
            
            //2.删除房间内的设备
            NSMutableArray *deleteArr= [NSMutableArray array];
            for (int j=0; j<_globalDeviceArray.count; j++) {
                AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
                for (NSString *myID in deleteGroup.groupSubDeviceIDArray) {
                    if ([[myDevice.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                        //属于房间内的设备删除
                        [deleteArr addObject:myDevice];
                    }
                }
            }
            dispatch_async(_deleteRoomQueue, ^{
                [NSThread sleepForTimeInterval:1.0f];
                GroupManager *groupManager = [GroupManager sharedManager];
                [groupManager deleteDeviceFromGroup:deleteGroup devices:deleteArr completionHandler:^(AduroSmartReturnCode code) {
                }];
            });
            
            //3.删除房间
            // 从sql数据库中删除
            [self deleteRoomWithGroupId:deleteGroup.groupID];
            //从网关删除房间
            dispatch_async(_deleteRoomQueue, ^{
                [NSThread sleepForTimeInterval:1.0f];
                // 从网关场景管理中删除该房间
                GroupManager *groupManager = [GroupManager sharedManager];
                [groupManager deleteGroup:deleteGroup completionHandler:^(AduroSmartReturnCode code) {
                    DLog(@"删除房间结果code=%d",code);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (code == AduroSmartReturnCodeSuccess && i == _selectorRoomArray.count-1) {
                            [self stopMBProgressHUD];
                            //删除分组成功
                            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"删除成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"]otherButtonTitles:nil, nil];
                            [alertView setTag:TAG_DELETE_GROUP_SUCCESS];
                            [alertView show];
                        }
                    });
                }];
            });
//            //删除该房间的场景
//            [self deleteSceneOfDeleteGroup:deleteGroup];
//            //从数据库通过id删除房间
//            [self deleteRoomWithGroupId:deleteGroup.groupID];
//
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                // 从网关场景管理中删除该group
//                GroupManager *groupManager = [GroupManager sharedManager];
//                [groupManager deleteGroup:deleteGroup completionHandler:^(AduroSmartReturnCode code) {
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (code == AduroSmartReturnCodeSuccess && i==_selectorRoomArray.count-1) {
//                            //删除分组成功
//                            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"删除成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"刷新列表"]otherButtonTitles:nil, nil];
//                            [alertView setTag:TAG_DELETE_GROUP_SUCCESS];
//                            [alertView show];
//                        }
//                    });
//                }];
//
//            });
        }
        //从数组中删除选中房间
        [_globalGroupArray removeObjectsInArray:_selectorRoomArray];
        [_homeManageTableView reloadData];
    }
    [self makeRoomSelecttable];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_homeManageTableView reloadData];
}

-(void)backToSettingBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableRefreshLoadAllHome{

    NSInteger count = [_globalGroupArray count];
    if (count>1) {
        NSRange range = NSMakeRange(1, (count-1));
        [_globalGroupArray removeObjectsInRange:range];
    }
    NSArray *roomArr = [self getRoomDataObject];
    [_globalGroupArray addObjectsFromArray:roomArr];
    [_homeManageTableView reloadData];
    [self getAllGroup];
    [_homeManageTableView.mj_header endRefreshing];
}
#pragma mark - 保存房间数据到数据库
-(void)saveRoomDataObject:(AduroGroup *)groupDO{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveRoomData:groupDO withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//从数据库中获取房间对象数组
-(NSArray *)getRoomDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectRoomDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}
//从数据库通过id删除分组
-(void)deleteRoomWithGroupId:(NSInteger)groupId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db deleteRoomWithID:groupId withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//更新房间名称到数据库
-(void)changeGroupName:(NSString *)name withID:(NSInteger)groupId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateRoomNameData:name WithID:groupId withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//从数据库通过id删除场景
-(void)deleteSceneDataWithID:(NSInteger *)sceneid{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db deleteSceneWithID:sceneid withGatewayid:[ASUserDefault loadGatewayIDCache]];
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
