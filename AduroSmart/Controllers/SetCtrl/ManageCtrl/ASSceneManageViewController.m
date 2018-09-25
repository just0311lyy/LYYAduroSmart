//
//  ASSceneManageViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/5.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSceneManageViewController.h"
#import "ASGlobalDataObject.h"
#import "ASDataBaseOperation.h"
#import "ASUserDefault.h"
#import <STAlertView.h>
#import <MJRefresh.h>
#define TAG_DELETE_SCENE_SUCCESS 800104
#define TAG_DELETE_SCENE_FAILD 800105
#define TAG_DELETE_SCENE_CONFIRM 800109
#define TAG_SUCCESS_EDIT_NAME 800117
@interface ASSceneManageViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *_sceneManageTableView;
    
    NSIndexPath *_indexDelete; //删除的索引
    STAlertView *_saveAlert; //保存名称的确认框
    UIView *_editSceneView;     //底部批量删除视图
    UIButton *_rightBarBtn; //导航右按钮
    NSMutableArray *_selectorSceneArray;//存放选中数据
    NSArray *_sceneArr;  //数据库中的场景
    //批量删除场景的对列
    dispatch_queue_t _deleteQueue;
    //删除单个场景命令队列
    dispatch_queue_t _deleteSceneQueue;
    NSTimer *_stopHUDTimer; //停止HUE
}

@property (nonatomic, strong) UIView *footerView;

@end

@implementation ASSceneManageViewController
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
    
    self.title = [ASLocalizeConfig localizedString:@"场景"];
    [self initWithSceneManageView];
    // 设置tableView在编辑模式下可以多选，并且只需设置一次
    _sceneManageTableView.allowsMultipleSelectionDuringEditing = YES;
}

-(void)initWithSceneManageView{
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
    [_rightBarBtn addTarget:self action:@selector(makeSceneSelecttable) forControlEvents:UIControlEventTouchUpInside];
    _rightBarBtn.frame = CGRectMake(0, 0, 58, 30);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    CGRect frame = self.view.frame;
    frame.size.height = self.view.frame.size.height-64;
    if (!_sceneManageTableView) {
        _sceneManageTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [self.view addSubview:_sceneManageTableView];
        [_sceneManageTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        _sceneManageTableView.delegate = self;
        _sceneManageTableView.dataSource = self;
        _sceneManageTableView.tableFooterView = [self footerView];
    }
    
    //下拉刷新 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    _sceneManageTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadAllScene)];
    
    //底部批量删除视图
    _editSceneView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_ADURO_HEIGHT - 64, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT)];
    _editSceneView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_editSceneView];
    
    //delete分割线
    UIView *separatorView = [[UIView alloc]init];
    [separatorView setBackgroundColor:CELL_LIEN_COLOR];
    [_editSceneView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_editSceneView.mas_leading);
        make.trailing.equalTo(_editSceneView.mas_trailing);
        make.height.equalTo(@(1));
        make.top.equalTo(_editSceneView.mas_top);
    }];

    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editSceneView addSubview:deleteBtn];
//    [deleteBtn setTitle:[ASLocalizeConfig localizedString:@"删除"] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(removeSceneSelectedCells) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_editSceneView.mas_trailing).offset(-20);
        make.centerY.equalTo(_editSceneView.mas_centerY);
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

-(void)getAllSceneData{

    SceneManager *sceneManager = [SceneManager sharedManager];
    [sceneManager getAllScenes:^(AduroScene *scene) {
        if (scene && [scene.sceneName length]>0) {

            BOOL isExist = NO;
            for (int i=0; i<[_globalSceneArray count]; i++) {
                AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
                if (myScene.sceneID == scene.sceneID) {
                    isExist = YES;
                    /*
                     * 使用场景图片路径进行场景在线不在线的标记
                     * 0x01 为在线
                     */
                    [scene setSceneIconPath:SCENE_NET_STATE_ONLINE];
                    [_globalSceneArray replaceObjectAtIndex:i withObject:scene];
                    [self changeSceneName:scene.sceneName withID:scene.sceneID];
                }
            }
            if (!isExist) {
                [self saveSceneDataObject:scene];  //存储到数据库
                [scene setSceneIconPath:SCENE_NET_STATE_ONLINE];
                [_globalSceneArray addObject:scene];
            }
            
//            for (int i=0; i<[_globalSceneArray count]; i++) {
//                AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
//                if (myScene.sceneID == scene.sceneID) {
//                    if ([_globalSceneArray count]>i) {
//                        [_globalSceneArray removeObjectAtIndex:i];
//                    }
//                }
//            }
//            DDLogInfo(@"getAllScenes = %@",scene);
//            if ([scene.sceneName length]>0) {
//                [_globalSceneArray addObject:scene];
//                [self saveSceneDataObject:scene];
//            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_sceneManageTableView reloadData];
            });
        }
    }];

}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_globalSceneArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString static *identifier = @"deviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.backgroundColor = VIEW_BACKGROUND_COLOR;
    }
    AduroScene *scene = [_globalSceneArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:scene.sceneName];
    NSString *detailGroupName = @"";
    if (_globalGroupArray.count>0) {
        for (int i=0; i<_globalGroupArray.count; i++) {
            AduroGroup *mygroup = [_globalGroupArray objectAtIndex:i];
            if (scene.groupID == mygroup.groupID) {
                NSArray *array = [mygroup.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
                NSString *name = [array firstObject];
                detailGroupName = name;
            }
        }
    }
    NSString *netStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
    if ([scene.sceneIconPath isEqualToString:SCENE_NET_STATE_ONLINE]) {
        netStateStr = @"";
    }else{
        netStateStr = [ASLocalizeConfig localizedString:@"Unreachable"];
    }    
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@          %@",detailGroupName,netStateStr]];
    [cell.imageView setImage:[UIImage imageNamed:@"scene_set"]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_sceneManageTableView.isEditing) {
        AduroScene *selectScenes = [_globalSceneArray objectAtIndex:indexPath.row];
        if (_selectorSceneArray == nil) {
            _selectorSceneArray = [[NSMutableArray alloc] init];
        }
        [_selectorSceneArray addObject:selectScenes];
    }else{
        //取消选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        AduroScene *oneScene = [_globalSceneArray objectAtIndex:indexPath.row];
        [self changeSceneName:oneScene];
    }
}

-(void)changeSceneName:(AduroScene *)selectedScene{
    
    NSString *strName = @"";
    if (selectedScene) {
        strName = selectedScene.sceneName;
    }
    _saveAlert = [[STAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"修改场景名称"] message:[ASLocalizeConfig localizedString:@"请输入名称"] textFieldHint:@"" textFieldValue:strName cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitle:[ASLocalizeConfig localizedString:@"保存"] cancelButtonBlock:^{
        
    } otherButtonBlock:^(NSString * result) {
        if ([result isEqualToString:strName]) {
            return;
        }
        
        BOOL isDeviceExist = NO;
        
        if (selectedScene) {
            for (AduroScene *sceneInfo in _globalSceneArray) {
                if ([result isEqualToString:sceneInfo.sceneName]) {
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
                
                //更新本地库里的场景名称
                for (int i=0; i<[_globalSceneArray count]; i++) {
                    AduroScene *scene = [_globalSceneArray objectAtIndex:i];
                    if (selectedScene.sceneID == scene.sceneID) {
                        scene.sceneName = result;
                    }
                }
                //更新网关里的场景名
                SceneManager *sceneManager = [SceneManager sharedManager];
                [selectedScene setSceneName:result];
                [sceneManager changeNameWithScene:selectedScene completionHandler:^(AduroSmartReturnCode code) {
                    DLog(@"方法不进来，无打印 = %d",(int)code);
                }];
                
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

#pragma mark - 删除指定场景
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
        [self startDeleteScene];
    }
}
//删除场景
-(void)startDeleteScene{
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _deleteSceneQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    _stopHUDTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(cancelMBProgressHUD) userInfo:nil repeats:NO];
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Deleting..."]];
    // 从数据源中删除
    AduroScene *deleteScene = _globalSceneArray[_indexDelete.row];
    // 从数据库通过id删除场景
    [self deleteSceneDataWithID:deleteScene.sceneID];
    //从网关场景中删除场景中的所有设备
    [self deleteSceneDevices:deleteScene];
    //从网关中删除场景
    [self deleteGatewayScene:deleteScene];
}

-(void)deleteSceneDevices:(AduroScene *)sceneInfo{
    NSMutableArray *deleteArr = [NSMutableArray array];
    for (int i=0; i<_globalDeviceArray.count; i++) {
        AduroDevice *deviceInfo = [_globalDeviceArray objectAtIndex:i];
        for (NSString *myID in sceneInfo.sceneSubDeviceIDArray) {
            if ([[deviceInfo.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                [deleteArr addObject:deviceInfo];
            }
        }
    }
    dispatch_async(_deleteSceneQueue, ^{
        [NSThread sleepForTimeInterval:0.3f];
        SceneManager *sceneManager = [SceneManager sharedManager];
        [sceneManager deleteDeviceFromScene:sceneInfo devices:deleteArr completionHandler:^(AduroSmartReturnCode code) {
            
        }];
    });
}

-(void)deleteGatewayScene:(AduroScene *)sceneInfo{
    dispatch_async(_deleteSceneQueue, ^{
        [NSThread sleepForTimeInterval:0.3f];
        SceneManager *sceneManager = [SceneManager sharedManager];
        [sceneManager deleteScene:sceneInfo completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"删除场景结果code=%d",code);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (code == AduroSmartReturnCodeSuccess) {
                    [self stopMBProgressHUD];
                    //删除场景成功
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"删除成功"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定" ]otherButtonTitles:nil, nil];
                    [alertView setTag:TAG_DELETE_SCENE_SUCCESS];
                    [alertView show];
                }
            });
        }];
    });
}

-(void)cancelMBProgressHUD{
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopMBProgressHUD];
    });
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (alertView.tag == TAG_DELETE_SCENE_CONFIRM) {
//        if (buttonIndex == 1) {
//            [self startDeleteScene];
//        }
//    }
    if (alertView.tag == TAG_DELETE_SCENE_SUCCESS) {
//        [self stopMBProgressHUD];
        if (_indexDelete) {
            [_globalSceneArray removeObjectAtIndex:_indexDelete.row];
            [_sceneManageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_indexDelete] withRowAnimation:(UITableViewRowAnimationFade)];
            [_sceneManageTableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashSceneTableView" object:nil];
        }
    }
    if (alertView.tag == TAG_DELETE_SCENE_FAILD) {
//        [self stopMBProgressHUD];
    }
    //修改设备名称成功
    if (alertView.tag == TAG_SUCCESS_EDIT_NAME) {
        if (buttonIndex == 0) {
            sleep(0.8);
            [_sceneManageTableView reloadData];
        }
    }
}

#pragma mark - 批量删除
- (void)makeSceneSelecttable
{
    [_sceneManageTableView setEditing:!_sceneManageTableView.isEditing animated:YES];
    if (_sceneManageTableView.isEditing) {
        [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"取消"] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        //为编辑状态的时候，底部浮起视图
        CGRect startFrame = CGRectMake(0, SCREEN_ADURO_HEIGHT - 64 - SELECT_DELETE_VIEW_HEIGHT, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT);
        [UIView animateWithDuration:0.1 animations:^{
            _editSceneView.frame = startFrame;
        }];
    }else{
        [_rightBarBtn setTitle:[ASLocalizeConfig localizedString:@"编辑"] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        //为非编辑状态则，底部视图消失
        CGRect endFrame = CGRectMake(0, SCREEN_ADURO_HEIGHT - 64, SCREEN_ADURO_WIDTH, SELECT_DELETE_VIEW_HEIGHT);
        [UIView animateWithDuration:0.1 animations:^{
            _editSceneView.frame = endFrame;
        }];
    }
}
//禁止左滑删除
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    AduroScene *unselectScenes = [_globalSceneArray objectAtIndex:indexPath.row];
    if (_selectorSceneArray) {
        for (int i = 0; i<[_selectorSceneArray count]; i++) {
            AduroScene *scene = [_selectorSceneArray objectAtIndex:i];
            if (scene.sceneID == unselectScenes.sceneID ) {
                //删除取消选中的room
                [_selectorSceneArray removeObject:scene];
            }
        }
    }
}

-(void)removeSceneSelectedCells{
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _deleteQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"Deleting..."]];
    DLog(@"%@",_selectorSceneArray);
    //从网关中删除选中场景
    if (_selectorSceneArray) {
        for (int i=0; i< _selectorSceneArray.count; i++) {
            AduroScene *deleteScene = [_selectorSceneArray objectAtIndex:i];
            // 从数据库删除场景
            [self deleteSceneDataWithID:deleteScene.sceneID];
            // 从网关场景管理中删除该场景
            [self deleteSceneDelayed:deleteScene];
            if (i == _selectorSceneArray.count-1) {
                dispatch_async(_deleteQueue, ^{
                    sleep(1);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self stopMBProgressHUD];
                    });
                });
            }
        }
        //从数组中删除选中场景
        [_globalSceneArray removeObjectsInArray:_selectorSceneArray];
        [_sceneManageTableView reloadData];
    }
    [self makeSceneSelecttable];
}

-(void)deleteSceneDelayed:(AduroScene *)scene{
    //从网关场景中删除改场景中的所有设备
    NSMutableArray *deleteArr = [NSMutableArray array];
    for (int i=0; i<_globalDeviceArray.count; i++) {
        AduroDevice *deviceInfo = [_globalDeviceArray objectAtIndex:i];
        for (NSString *myID in scene.sceneSubDeviceIDArray) {
            if ([[deviceInfo.deviceID lowercaseString] isEqualToString:[NSString stringWithFormat:@"0x%@",[myID lowercaseString]]]) {
                [deleteArr addObject:deviceInfo];
            }
        }
    }
    //1.先删除场景中的所有设备
    dispatch_async(_deleteQueue, ^{
        [NSThread sleepForTimeInterval:0.3f];
        SceneManager *sceneManager = [SceneManager sharedManager];
        [sceneManager deleteDeviceFromScene:scene devices:deleteArr completionHandler:^(AduroSmartReturnCode code) {
            
        }];
    });
    //2.再从网关中删除该场景
    dispatch_async(_deleteQueue, ^{
        [NSThread sleepForTimeInterval:0.8f];
        //删除场景
        SceneManager *sceneManager = [SceneManager sharedManager];
        [sceneManager deleteScene:scene completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"删除场景结果code=%d",code);
        }];
    });
}

-(void)backToSettingBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableRefreshLoadAllScene{
    [_globalSceneArray removeAllObjects];
    NSArray *sceneArr = [self getSceneDataObject];
    [_globalSceneArray addObjectsFromArray:sceneArr];
    [_sceneManageTableView reloadData];
    [self getAllSceneData];
    [_sceneManageTableView.mj_header endRefreshing];
}

#pragma mark - 保存场景数据到数据库
-(void)saveSceneDataObject:(AduroScene *)sceneDO{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveSceneData:sceneDO withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//从数据库中获取场景对象数组
-(NSArray *)getSceneDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectSceneDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}
////从数据库中删除所有场景对象
//-(void)deleteAllSceneDataObject{
//    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
//    [db openDatabase];
//    [db deleteAllScenes];
//}
//更新场景名称到数据库
-(void)changeSceneName:(NSString *)name withID:(NSInteger)sceneId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateSceneNameData:name withID:sceneId withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
-(void)deleteSceneDataWithID:(NSInteger)sceneid{
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
