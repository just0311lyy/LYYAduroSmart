//
//  ASHomeViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/23.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASHomeViewController.h"
#import "ASGlobalDataObject.h"
#import "ASHomeTableViewCell.h"
#import "ASHomeDetailViewController.h"
#import "ASNewHomeViewController.h"
#import "ASSetViewController.h"
#import "ASDataBaseOperation.h"
#import "ASDeviceListViewController.h"
#import "ASUserDefault.h"
#import "AppDelegate.h"
#import "WJStatusBarHUD.h"
#import "ASGetwayManageViewController.h"
#import "AFNetworking.h"
#import "ASAESencryption.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MJRefresh.h>
// --- 0 --
#import "LYRoomDeviceViewController.h"
#import "UIButton+ImageTitleSpacing.h"
#import "ASRoomViewCell.h"
#import "ASAddHomeSceneViewController.h"
#define TAG_SCENES 10000
#define TAG_DEVICES 10001
#define TAG_SHEET_ONE 10002
#define TAG_SHEET_TWO 10003
// --- 0 --
static SystemSoundID shake_sound_male_id = 0;
@interface ASHomeViewController ()<UITableViewDelegate,UITableViewDataSource,ASHomeDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIActionSheetDelegate>{
//    UITableView *_homeTableView;
    GroupManager *_groupManager;
    NSTimer *_stopHUETimer;
    DeviceManager *_deviceManager;
//    NSArray *_roomArr;
//    NSMutableArray *_roomShowDataArr;  //数据库中储存的房间对象数组
    BOOL isRoomOn;
    
    //获取设备属性的对列
    dispatch_queue_t _myQueue;
    //---- 0 --
    UICollectionView *_roomCollectionView;
    
    UIButton *_sceneBtn;
    UIView *_sceneView;
    UIView *_upView;
    UIView *_arrowSceneView;
    UIButton *_upViewBtn;
    UIView *_frameView;
    UITableView *_sceneTable;
    NSMutableArray *_showSceneArr;
    
    UIButton *_deviceBtn;
    UIView *_deviceView;
    UIView *_downView;

    UITableView *_deviceTable;
    NSArray *_typeArr;
    UIView *_arrowTypeView;
    //滑到哪一个房间
    NSInteger _currentIndex;
    AduroGroup *_currentRoom;
    
    NSMutableArray *_currentDeviceArr;
    UILabel *_upLineLb;
    //---- 0 --
}

//@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *sceneHeaderView;
@end

@implementation ASHomeViewController

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    //    设置导航栏背景图片为一个空的image，这样就透明了
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
//    
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshTableView];
}

- (void)refreshTableView
{
    if ([_showSceneArr count] > 0) {
        _sceneTable.tableHeaderView = nil;
    }
    else
    {
        _sceneTable.tableHeaderView = [self sceneHeaderView];
    }
    [_sceneTable reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithHomeView];
    
//    _roomArr = [self getRoomDataObject];
//    if (_globalGroupArray.count<2) {
//        [_globalGroupArray addObjectsFromArray:_roomArr];
//    }
//    NSArray *deviceArr = [self getDeviceDataObject];
//    if (_globalDeviceArray.count<1) {
//        [_globalDeviceArray addObjectsFromArray:deviceArr];
//    }
    //---- 1 ---
    _typeArr = @[
                 @{@"name":[ASLocalizeConfig localizedString:@"Lights"],@"imageName":@"light",@"deviceType":@"lamp"},
                 @{@"name":[ASLocalizeConfig localizedString:@"Sensors"],@"imageName":@"sensor",@"deviceType":@"sensor"},
                 @{@"name":[ASLocalizeConfig localizedString:@"Lighting Remotes"],@"imageName":@"light_remotes",@"deviceType":@"remote"},
                 ];
    if (_showSceneArr==nil) {
        _showSceneArr = [[NSMutableArray alloc] init];
    }
    if (_currentDeviceArr==nil) {
        _currentDeviceArr = [[NSMutableArray alloc] init];
    }
    _currentIndex = 0;
    if (_currentIndex == 0) {
        //        [_showDeviceArr addObjectsFromArray:_globalDeviceArray];
        [_showSceneArr addObjectsFromArray:_globalSceneArray];
    }
    //---- 1 ---
    
    [self initWithHomeGroup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableRefreshLoadAllHome) name:NOTI_REFRESH_GROUP_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableList) name:@"reflashList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGroupListReloadData) name:@"allGroupListReloadData" object:nil];
    //---- 2 ---
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getScenesArray) name:NOTI_REFRESH_SENCES_TABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllAduroDevice) name:@"reflashDeviceList" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteSceneTable) name:@"reflashSceneTableView" object:nil];
    //---- 2 ---
}

-(void)deleteSceneTable{
    if (_showSceneArr.count>0) {
        [_showSceneArr removeAllObjects];
    }
    if (_currentIndex != 0) {
        /* 缓存:场景 */
        for (int i=0; i<_globalSceneArray.count; i++) {
            AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
            if (myScene.groupID == _currentRoom.groupID) {
                BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
                for (int k=0; k<_showSceneArr.count; k++) {
                    AduroScene *theScene = [_showSceneArr objectAtIndex:k];
                    if (theScene.sceneID == myScene.sceneID) {
                        noExist = NO;
                    }
                }
                if (noExist) {
                    [_showSceneArr addObject:myScene];
                }
            }
        }
    }else if (_currentIndex == 0){
        if (_showSceneArr.count>0) {
            for (int i=0; i<_showSceneArr.count; i++) {
                AduroScene *myScene = [_showSceneArr objectAtIndex:i];
                BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
                for (int k=0; k<_globalSceneArray.count; k++) {
                    AduroScene *theScene = [_globalSceneArray objectAtIndex:k];
                    if (theScene.sceneID == myScene.sceneID) {
                        noExist = NO;
                    }
                }
                if (noExist) {
                    [_showSceneArr addObject:myScene];
                }
            }
        }else{
            [_showSceneArr addObjectsFromArray:_globalSceneArray];
        }
    }
    [self refreshTableView];
}

-(void)deleteDeviceReflash{
//    if (_currentDeviceArr.count>0) {
//        [_currentDeviceArr removeAllObjects];
////        if (_currentIndex !=0) {
////            [self getDeviceOfRoom];
////        }else{
////            [_currentDeviceArr addObjectsFromArray:_globalDeviceArray];
////        }
//    }else{
//        if (_currentIndex !=0) {
//            [self getDeviceOfRoom];
//        }else{
//            [_currentDeviceArr addObjectsFromArray:_globalDeviceArray];
//        }
//    }
//    [_deviceTable reloadData];
}

-(void)allGroupListReloadData{
//    [_homeTableView reloadData];
    [_roomCollectionView reloadData];
}

-(void)initWithHomeView{
    // ---- 3 ---
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,-64, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT)];
    [imgView setImage:[UIImage imageNamed:@"main_background"]];
    [self.view addSubview:imgView];
    //    [imgView setContentMode:UIViewContentModeCenter];
    //    imgView.clipsToBounds = YES;
    
    //    UIView *view = [[UIView alloc] initWithFrame:imgView.bounds];
    //    UIColor *colorOne = [UIColor colorWithRed:(253/255.0)  green:(190/255.0)  blue:(93/255.0)  alpha:0.85];
    //    UIColor *colorTwo = [UIColor colorWithRed:(255/255.0)  green:(150/255.0)  blue:(0/255.0)  alpha:0.85];
    //    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    //    CAGradientLayer *gradient = [CAGradientLayer layer];
    //    //设置开始和结束位置(设置渐变的方向)
    //    gradient.startPoint = CGPointMake(0, 0);
    //    gradient.endPoint = CGPointMake(1,0.36);
    //    gradient.colors = colors;
    //    gradient.frame = view.frame;
    //    [view.layer insertSublayer:gradient atIndex:0];
    //    [self.view addSubview:view];
    
    _upLineLb = [UILabel new];
    _upLineLb.backgroundColor = [UIColor whiteColor];
    _upLineLb.alpha = 0;
    [self.view addSubview:_upLineLb];
    [_upLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
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
    // ---- 3 ---
    
//    //导航栏左按钮
//    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"setting_nav"] forState:UIControlStateNormal];
//    [leftBarBtn addTarget:self action:@selector(settingManagerBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    leftBarBtn.frame = CGRectMake(0, 0, 22, 22);
//    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
//    self.navigationItem.leftBarButtonItem = leftBarItem;
//    //导航栏右按钮
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarBtn setBackgroundImage:[UIImage imageNamed:@"add_nav"] forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(addNewHomeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    rightBarBtn.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
//    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;    
//    CGRect frame = self.view.frame;
////    frame.origin.y = WJ_HUD_VIEW_HEIGHT;
//    frame.size.height = self.view.frame.size.height -49-64 /*-WJ_HUD_VIEW_HEIGHT*/;
//    if (!_homeTableView) {
//        _homeTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
//        _homeTableView.backgroundColor = VIEW_BACKGROUND_COLOR;
//        [self.view addSubview:_homeTableView];
//        [_homeTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//        _homeTableView.delegate = self;
//        _homeTableView.dataSource = self;
//        _homeTableView.tableFooterView = [self footerView];
//    }
//    
//    //下拉刷新 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
//    _homeTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(tableRefreshLoadAllHome)];

    // ---- 4 ---  //房间外围白色边框
    _frameView = [[UIView alloc] initWithFrame:CGRectMake(45, 45, SCREEN_ADURO_WIDTH-90, SCREEN_ADURO_HEIGHT-90-49-64)];
    [self.view addSubview:_frameView];
    _frameView.layer.cornerRadius = 30;
    _frameView.layer.borderWidth = 0.5;
    _frameView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UIButton *frameUpBtn = [[UIButton alloc] initWithFrame:CGRectMake((_frameView.frame.size.width - 100)/2,(_frameView.frame.size.height - 125)/2-100, 100, 100)];
    [_frameView addSubview:frameUpBtn];
    [frameUpBtn setTitle:@"Scenes" forState:UIControlStateNormal];
    [frameUpBtn setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
    CGFloat space = 80.0;
    [frameUpBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop
                                imageTitleSpace:space];
    [frameUpBtn addTarget:self action:@selector(showDownView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *frameDownBtn = [[UIButton alloc] initWithFrame:CGRectMake((_frameView.frame.size.width - 100)/2,(_frameView.frame.size.height - 125)/2 + 125, 100, 100)];
    [_frameView addSubview:frameDownBtn];
    [frameDownBtn setTitle:@"Type" forState:UIControlStateNormal];
    [frameDownBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [frameDownBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleBottom imageTitleSpace:space];
    [frameDownBtn addTarget:self action:@selector(showUpView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (_frameView.frame.size.height - 50/2)/2, 35/2, 50/2)];
    [leftImgView setImage:[UIImage imageNamed:@"arrows_left_white"]];
    [_frameView addSubview:leftImgView];
    
    UIImageView *rightImgView = [[UIImageView alloc] initWithFrame:CGRectMake((_frameView.frame.size.width - 35/2) - 20, (_frameView.frame.size.height - 50/2)/2, 35/2, 50/2)];
    [rightImgView setImage:[UIImage imageNamed:@"arrows_right_white"]];
    [_frameView addSubview:rightImgView];
    
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //该方法也可以设置itemSize
    layout.itemSize =CGSizeMake(_frameView.frame.size.width,145);
    
    //2.初始化collectionView
    _roomCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,(_frameView.frame.size.height - 145)/2,_frameView.frame.size.width,145) collectionViewLayout:layout];
    [_frameView addSubview:_roomCollectionView];
    
    _roomCollectionView.delegate = self;
    _roomCollectionView.dataSource =self;
    _roomCollectionView.showsHorizontalScrollIndicator = NO;
    _roomCollectionView.pagingEnabled = YES;
    [_roomCollectionView registerClass:[ASRoomViewCell class] forCellWithReuseIdentifier:@"roomsCell"];
    _roomCollectionView.backgroundColor = [UIColor clearColor];
    
    //--upview
    UISwipeGestureRecognizer *SwipeUpView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showUpView)];
    [SwipeUpView setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:SwipeUpView];
    
    _deviceView = [[UIView alloc] initWithFrame:CGRectMake(0, -SCREEN_ADURO_HEIGHT,SCREEN_ADURO_WIDTH,SCREEN_ADURO_HEIGHT - 49 - 64)];
    [self.view addSubview:_deviceView];
    
    UISwipeGestureRecognizer *swipeSceneView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenUpView)];
    [swipeSceneView setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [_deviceView addGestureRecognizer:swipeSceneView];
    
    //--下方按钮白色背景
    _arrowTypeView = [[UIView alloc] initWithFrame:CGRectMake((_deviceView.frame.size.width-120)/2,_deviceView.frame.size.height- 70,120, 70)];
    [_deviceView addSubview:_arrowTypeView];
    _arrowTypeView.alpha = 0;
    UIImageView *arrowTypeImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, _arrowTypeView.frame.size.width,_arrowTypeView.frame.size.height)];
    UIImage *bgImg = [UIImage imageNamed:@"type_btn_bg"];
    UIEdgeInsets insets = UIEdgeInsetsMake(30, 30, 0, 30);
    // 指定为拉伸模式，伸缩后重新赋值
    bgImg = [bgImg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [arrowTypeImgV setImage:bgImg];
    [_arrowTypeView addSubview:arrowTypeImgV];
  
    //向上的箭头
    UIImageView *arrowUpImgV = [[UIImageView alloc] initWithFrame:CGRectMake((120-50/2)/2,10, 50/2, 35/2)];
    arrowUpImgV.image = [UIImage imageNamed:@"arrow_up_yellow"];
    [_arrowTypeView addSubview:arrowUpImgV];
    //rooms label
    UILabel *arrowTypeLb = [[UILabel alloc] initWithFrame:CGRectMake(0,70 - 30,120,20)];
    [_arrowTypeView addSubview:arrowTypeLb];
    [arrowTypeLb setTextColor:UIColorFromRGB(0xffad2c)];
    [arrowTypeLb setTextAlignment:NSTextAlignmentCenter];
    [arrowTypeLb setText:[ASLocalizeConfig localizedString:@"Room"]];
    
    UIButton *downViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,_arrowTypeView.frame.size.width,_arrowTypeView.frame.size.height)];
    [_arrowTypeView addSubview:downViewBtn];
    [downViewBtn addTarget:self action:@selector(hiddenUpView) forControlEvents:UIControlEventTouchUpInside];
    
    //--设备类型列表---
    _deviceTable = [[UITableView alloc] initWithFrame:CGRectMake(30,30, _deviceView.frame.size.width - 60, _deviceView.frame.size.height - (90-30 + 30)-40) style:UITableViewStylePlain];
    [_deviceTable setTag:TAG_DEVICES];
    [_deviceView addSubview:_deviceTable];
    _deviceTable.alpha = 0.1;
    _deviceTable.layer.cornerRadius = 30;
    [_deviceTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    _deviceTable.delegate = self;
    _deviceTable.dataSource = self;
    [_deviceTable setBackgroundColor:[UIColor whiteColor]];
    _deviceTable.tableFooterView = [[UIView alloc] init];
    _deviceTable.contentInset = UIEdgeInsetsMake(18,0,18,0);
    //----------
    UISwipeGestureRecognizer *SwipeDownView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDownView)];
    [SwipeDownView setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:SwipeDownView];
    _sceneView = [[UIView alloc] initWithFrame:CGRectMake(0,SCREEN_ADURO_HEIGHT, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT-49-64)];
    [self.view addSubview:_sceneView];
    
    UISwipeGestureRecognizer *swipeDeviceView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenDownView)];
    [swipeDeviceView setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [_sceneView addGestureRecognizer:swipeDeviceView];
    
    _sceneTable = [[UITableView alloc] initWithFrame:CGRectMake(30,90 - 30 + 40 , _sceneView.frame.size.width - 60, _sceneView.frame.size.height - (90-30 + 30)-40) style:UITableViewStylePlain];
    [_sceneTable setTag:TAG_SCENES];
    [_sceneView addSubview:_sceneTable];
    _sceneTable.alpha = 0.1;
    _sceneTable.layer.cornerRadius = 30;
    [_sceneTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    _sceneTable.delegate = self;
    _sceneTable.dataSource = self;
    _sceneTable.tableHeaderView = [self sceneHeaderView];
    _sceneTable.tableFooterView = [[UIView alloc] init];
    [_sceneTable setBackgroundColor:[UIColor whiteColor]];
    _sceneTable.contentInset = UIEdgeInsetsMake(18,0,18,0);
    //--按钮
    _arrowSceneView = [[UIView alloc] initWithFrame:CGRectMake((_sceneView.frame.size.width-120)/2,0,120, 70)];
    [_sceneView addSubview:_arrowSceneView];
    _arrowSceneView.alpha = 0;
//    _arrowSceneView.layer.cornerRadius = 30;
//    _arrowSceneView.backgroundColor = [UIColor whiteColor];
    UIImageView *arrowSceneImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, _arrowSceneView.frame.size.width,_arrowSceneView.frame.size.height)];
    UIImage *sceneBgImg = [UIImage imageNamed:@"scene_btn_bg"];
    UIEdgeInsets sceneInsets = UIEdgeInsetsMake(0, 30, 30, 30);
    // 指定为拉伸模式，伸缩后重新赋值
    sceneBgImg = [sceneBgImg resizableImageWithCapInsets:sceneInsets resizingMode:UIImageResizingModeStretch];
    [arrowSceneImgV setImage:sceneBgImg];
    [_arrowSceneView addSubview:arrowSceneImgV];
    //向下的箭头
    UIImageView *arrowDownImgV = [[UIImageView alloc] initWithFrame:CGRectMake((120-50/2)/2,70 - 10 -  35/2, 50/2, 35/2)];
    arrowDownImgV.image = [UIImage imageNamed:@"arrow_down_yellow"];
    [_arrowSceneView addSubview:arrowDownImgV];
    //rooms label
    UILabel *arrowLb = [[UILabel alloc] initWithFrame:CGRectMake(0,70 - 10 -  35/2 -10- 20,120,20)];
    [_arrowSceneView addSubview:arrowLb];
    [arrowLb setTextColor:UIColorFromRGB(0xffad2c)];
    [arrowLb setTextAlignment:NSTextAlignmentCenter];
    [arrowLb setText:@"Room"];

    UIButton *upViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,_arrowSceneView.frame.size.width,_arrowSceneView.frame.size.height)];
    [_arrowSceneView addSubview:upViewBtn];
    [upViewBtn addTarget:self action:@selector(hiddenDownView) forControlEvents:UIControlEventTouchUpInside];
    
}
//- (UIView *)footerView
//{
//    if (_footerView == nil) {
//        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_WIDTH * 0.6)];
//        UILabel *labPromptAddCamera = [UILabel new];
//        [_footerView addSubview:labPromptAddCamera];
//        [labPromptAddCamera mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_footerView.mas_top);
//            make.leading.equalTo(_footerView).offset(50);
//            make.trailing.equalTo(_footerView).offset(-50);
//            make.height.equalTo(@(_footerView.frame.size.height/2.0f));
//        }];
//        [labPromptAddCamera setFont:[UIFont systemFontOfSize:15]];
//        [labPromptAddCamera setText:NSLocalizedString(@"Pull down to refresh", nil)];
//        [labPromptAddCamera setTextAlignment:NSTextAlignmentCenter];
//        [labPromptAddCamera setNumberOfLines:0];
//        [labPromptAddCamera setTextColor:[UIColor lightGrayColor]];
//        [labPromptAddCamera setLineBreakMode:NSLineBreakByWordWrapping];
//    }
//    return  _footerView;
//}
- (UIView *)sceneHeaderView
{
    CGFloat imgWidth = _sceneView.frame.size.width - 80*2;
    CGFloat imgHeight = imgWidth * 391 /467 ;
    if (_sceneHeaderView == nil)
    {
        _sceneHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _sceneView.frame.size.width, 80 + imgHeight + 60 + 44)];
        UIImageView *noSceneImgView = [UIImageView new];
        [noSceneImgView setImage:[UIImage imageNamed:@"scene_table_header"]];
        [_sceneHeaderView addSubview:noSceneImgView];
        [noSceneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_sceneHeaderView.mas_top).offset(80);
            make.centerX.equalTo(_sceneHeaderView.mas_centerX);
            make.width.equalTo(@(imgWidth));
            make.height.equalTo(@(imgHeight));
        }];
        
        UIButton *nowAddBtn = [UIButton new];
        [nowAddBtn.layer setCornerRadius:22];
        [nowAddBtn setBackgroundColor:LOGO_COLOR];
        [nowAddBtn.layer setBorderWidth:0.5];
        [nowAddBtn.layer setBorderColor:[BUTTON_COLOR CGColor]];
        [_sceneHeaderView addSubview:nowAddBtn];
        [nowAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(noSceneImgView.mas_bottom).offset(60);
            make.leading.trailing.equalTo(noSceneImgView);
            make.height.equalTo(@(44));
        }];
        [nowAddBtn setTitle:NSLocalizedString(@"+ Add Scenes", nil) forState:UIControlStateNormal];
        [nowAddBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nowAddBtn addTarget:self action:@selector(newSceneToHomeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _sceneHeaderView;
}


-(void)refreshGroupTable{
    [self getAllGroup];
}
-(void)refreshTableList{

    [self getAllAduroDevice];
}

-(void)initWithHomeGroup{
    AppDelegate *myDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    //是否登陆
    if (!myDelegate.isLogin) { //如果没有登陆
        if (![[ASUserDefault loadUserPasswardCache] isEqualToString:@""] && [ASUserDefault loadUserPasswardCache] != nil) { //有成功登陆过的账户
            [self autoLogin]; //自动登陆
        }
    }
    if (myDelegate.isConnect) {

        [self getAllAduroDevice];
        return;
    }
    NSArray *gatewayArr = [self getGatewayDataObject];
//    if (![[ASUserDefault loadGatewayIDCache] isEqualToString:@""] && [ASUserDefault loadGatewayIDCache] != nil)
    if (gatewayArr.count > 0)
    {
        //若存在上次登录成功后缓存的网关id。则先获取附近所有可连接网关
        [WJStatusBarHUD showLoading:[ASLocalizeConfig localizedString:@"数据获取中..."]];
        _stopHUETimer = [NSTimer scheduledTimerWithTimeInterval:24 target:self selector:@selector(cancelWJStatusBarHUD) userInfo:nil repeats:NO];
        
        GatewayManager *gatewayManager = [GatewayManager sharedManager];
        [gatewayManager searchOneGateway:^(AduroGateway *gateway) {
            BOOL isExist = NO;
            for (int i=0; i<[_globalGetwayArray count]; i++) {
                AduroGateway *myGateway = [_globalGetwayArray objectAtIndex:i];
                if ([myGateway.gatewayID isEqualToString:gateway.gatewayID]) {
                    isExist = YES;
                }
            }
            if (!isExist) {
                [_globalGetwayArray addObject:gateway];
            }

            for (int i=0; i<[_globalGetwayArray count]; i++) {
                AduroGateway *currentGateway = [_globalGetwayArray objectAtIndex:i];
                if (currentGateway.gatewayToAppNetChannelType != NetChannelTypeDisconnect) {
                    break;
                }
                BOOL isSame = NO;  //默认搜索到的网关不存在和缓存的一样
                for (AduroGateway *myGateway in gatewayArr) {
                    if ([myGateway.gatewayID isEqualToString:currentGateway.gatewayID]) {
                        isSame = YES;
                        [currentGateway setGatewaySecurityKey:myGateway.gatewaySecurityKey];
                    }
                }
                if (isSame) {
                    //若附近搜索到的网关存在和上次成功登陆后缓存的网关id一样的，则直接连接
                    GatewayManager *gatewayManager = [GatewayManager sharedManager];
                    //扫描二维码获得SecurityKey
//                        NSString *securityKey = [ASUserDefault loadGatewayKeyCache];
//                        [currentGateway setGatewaySecurityKey:securityKey];
                    [currentGateway setGatewayToAppNetChannelType:NetChannelTypeLANUDP];
                    [gatewayManager connectToGateway:currentGateway completionHandler:^(AduroSmartReturnCode code) {
                        DLog(@"网关连接结果code = %d",code);
                        if (code == AduroSmartReturnCodeSuccess) {
                            [WJStatusBarHUD hide];
                            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
                            delegate.isConnect=YES;
                            [ASUserDefault saveGatewayIDCache:currentGateway.gatewayID];
                            [self getAllAduroDevice];
                        }
                    }];
                    [gatewayManager updateGatewayDatatime:[NSDate date] completionHandler:^(AduroSmartReturnCode code) {
                        NSLog(@"update time = %d",code);
                    }];
                    goto end;
                }
                else{ //附近搜索到的网关id没有跟缓存相同的，则推出网关管理界面进行网关切换连接
                    [WJStatusBarHUD hide];
                    ASGetwayManageViewController *gatewayManVC = [[ASGetwayManageViewController alloc] init];
                    CATransition *animation = [CATransition animation];
                    animation.duration = 0.4;
                    //    animation.timingFunction = UIViewAnimationCurveEaseInOut;
                    animation.type = kCATransitionPush;
                    animation.subtype = kCATransitionFromRight;
                    [self.view.window.layer addAnimation:animation forKey:nil];
                    [self presentModalViewController:gatewayManVC animated:nil];
                    goto end;
//                    return;
                }
            }
            end:{
                DLog(@"直接连接网关，并跳出循环");
            }
        }];
    }
    else{
        ASGetwayManageViewController *gatewayManVC = [[ASGetwayManageViewController alloc] init];
        CATransition *animation = [CATransition animation];
        animation.duration = 0.4;
        //    animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromRight;
        [self.view.window.layer addAnimation:animation forKey:nil];
        [self presentModalViewController:gatewayManVC animated:nil];
    }
}

-(void)getAllAduroDevice{
    
    NSDate *da = [NSDate date];
    NSString *daStr = [da description];
    const char *queueName = [daStr UTF8String];
    _myQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    
    _deviceManager = [DeviceManager sharedManager];
    [_deviceManager getAllDevices:^(AduroDevice *device) {
        if (device) {
            BOOL isExist = NO;
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    isExist = YES;
//                    [device setDeviceNetState:DeviceNetStateOnline];
                    [device setIsCache:YES];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:device];
                    [self changeDeviceName:device.deviceName withID:device.deviceID];
                }
            }
            //            [device setEndPoint:0x01];
            if (!isExist) {
                [self saveDeviceData:device];
//                [device setDeviceNetState:DeviceNetStateOnline];
                [device setIsCache:YES];
                [_globalDeviceArray addObject:device];
            }
            [device.deviceClusterIdSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                DLog(@"cluster set 表示设备支持的功能 %x",[obj integerValue]);
            }];
        }

        
        //对传感器设备进行名称细分
        if (_globalDeviceArray.count>0) {
            for (int j = 0; j<_globalDeviceArray.count; j++) {
                AduroDevice *oneDevice = [_globalDeviceArray objectAtIndex:j];
                if (oneDevice.deviceTypeID ==  DeviceTypeIDHumanSensor && [oneDevice.deviceName isEqualToString:@"CIE Device"]) {
                    //当传感器的名称是CIE Device时。修改全局存储名称
                    if (oneDevice.deviceZoneType == DeviceZoneTypeMotionSensor) {
                        [oneDevice setDeviceName:@"Motion Sensor"];
                    }else if(oneDevice.deviceZoneType == DeviceZoneTypeContactSwitch){
                        [oneDevice setDeviceName:@"Contact Switch"];
                    }
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashTableView" object:nil];
        // --- 5 --
        if (_currentDeviceArr.count>0) {
            [_currentDeviceArr removeAllObjects];
            if (_currentIndex !=0) {
            }else{
                [_currentDeviceArr addObjectsFromArray:_globalDeviceArray];
            }
        }else{
            if (_currentIndex !=0) {
            }else{
                [_currentDeviceArr addObjectsFromArray:_globalDeviceArray];

            }
        }
        // --- 5 --
        
        if (device.deviceTypeID == DeviceTypeIDHumanSensor) {
            //读取传感器类型
            [self getZoneTypeForSensorDevice:device];
        }else{
            [self readDeviceAttribute:device];
        }
    }];
    [WJStatusBarHUD hide];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //        [self stopMBProgressHUD];
    //    });
    
    dispatch_async(_myQueue, ^{
        [NSThread sleepForTimeInterval:0.3f];
    
        [_deviceManager sensorDataUpload:^(NSString *deviceID, uint16_t shortAddr, uint16_t sensorData, uint8_t zoneID, uint16_t clusterID,Byte sensorDataByte[],int aCFrequency,float rMSVoltage,float rMSCurrent,float activePower,float powerFactor) {
            DLog(@"deviceID = %@, shortAddr = %x, sensorData = %x, zoneID = %x, clusterID = %x",deviceID,shortAddr,sensorData,zoneID,clusterID);
            //sensorData要按位解析，根据设备的ClusterID和ZoneType来解析sensorData；
            if (clusterID != ZCL_CLUSTER_ID_SS_IAS_ZONE) {
                DLog(@"sensorData Alarm1 Bit0 根据设备的ClusterID和ZoneType去判断此位代表什么含义，比如判断设备为门磁，则1=开门,0=关门,更多见传感器数据按位解析表 = %d",sensorDataByte[0]);
                DLog(@"deviceID = %@, shortAddr = %x, sensorData = %x, zoneID = %x, clusterID = %x",deviceID,shortAddr,sensorData,zoneID,clusterID);
            }
            //获取当前传感器触发的时间
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS"];
            NSString *dateString = [dateFormatter stringFromDate:currentDate];
            NSLog(@"dateString:%@",dateString);
            
            AduroDevice *myDevice = nil;
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *device = [_globalDeviceArray objectAtIndex:i];
                if (device.shortAdr == shortAddr) {
                    myDevice = device;
                }
                if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
                    myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
                }else if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
                    myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
                    [self playAlarmAudio];
                }else if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeVibrationMovementSensor)) { //震动传感器
                    myDevice.deviceSensorData = sensorDataByte[0] + HEXADECIMAL_DATA_OFFSET;
                }else if (clusterID == ZCL_CLUSTER_ID_HA_ELECTRICAL_MEASUREMENT){
                    NSLog(@"aCFrequency=%d,float rMSVoltage=%lf,float rMSCurrent=%lf,float activePower=%lf,float powerFactor=%lf",aCFrequency,rMSVoltage,rMSCurrent,activePower,powerFactor);
                    myDevice.electmeasVolatage = rMSVoltage;
                    myDevice.electmeasCurrent = rMSCurrent;
                    myDevice.electmeasPower = activePower;
                    myDevice.electmeasFrequency = aCFrequency;
                    myDevice.electmeasPowerFactor = powerFactor;
                }else{
                    myDevice.deviceSensorData = 0;
                }
                if (clusterID != ZCL_CLUSTER_ID_GEN_POWER_CFG) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reflashTableView" object:nil];
                }
            }
            NSString *showStr = @"";
            if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
                //            myDevice.deviceSensorData = sensorData +1;
                if (sensorDataByte[0]==0) {
                    showStr = [ASLocalizeConfig localizedString:@"关门"];
                }
                if (sensorDataByte[0]==1) {
                    showStr = [ASLocalizeConfig localizedString:@"开门"];
                }
            }
            if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
                //            myDevice.deviceSensorData = sensorData + 1;
                if (sensorDataByte[0]==0) {  //未触发不作处理
                    //                showStr = [ASLocalizeConfig localizedString:@"无人经过"];
                }
                if (sensorDataByte[0]==1) {
                    showStr = [ASLocalizeConfig localizedString:@"有人经过"];
                }
            }
            if ((clusterID == ZCL_CLUSTER_ID_SS_IAS_ZONE)&&(myDevice.deviceZoneType == DeviceZoneTypeVibrationMovementSensor)) { //震动传感器
                //            myDevice.deviceSensorData = sensorData + 1;
                if (sensorDataByte[0]==0) {
                    //没触发则不作处理
                }
                if (sensorDataByte[0]==1) {
                    showStr = [ASLocalizeConfig localizedString:@"有人经过"];
                }
            }
            
    //        if (clusterID == ZCL_CLUSTER_ID_GEN_POWER_CFG) {
    //            NSString *showPower = [[NSString alloc]initWithFormat:@"设备 %x 电池电量 %d ",myDevice.shortAdr,sensorData];
    //        }
            
            //将数据存储到传感器model
            ASSensorDataObject *sensorDO = [[ASSensorDataObject alloc]init];
            sensorDO.sensorID = myDevice.deviceID;
            sensorDO.sensorData = showStr;
            sensorDO.sensorDataTime = dateString;
            sensorDO.sensorPower = sensorData;
            [self saveSensorDataObject:sensorDO];
            
            if (clusterID != ZCL_CLUSTER_ID_GEN_POWER_CFG) {
                [self getZoneTypeForSensorDevice:myDevice];
            }
        }];
 
    });
    dispatch_async(_myQueue, ^{
        [NSThread sleepForTimeInterval:0.3f];
        [self getAllGroup];
    });
}

///-----------


/**
 *  @author xingman.yi, 16-09-14 14:09:20
 *
 *  @brief 使用队列来读取设备属性,每次读取前延时2S
 *
 *  @param device 要读取的设备
 */
-(void)readDeviceAttribute:(AduroDevice *)device{
    
    dispatch_async(_myQueue, ^{
        [NSThread sleepForTimeInterval:0.8f];
        //读取开关状态
        [_deviceManager getDevice:device updateData:^(AduroDevice *device, int updateDataType, uint16_t clusterID, uint16_t attribID,uint32_t attributeValue) {
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    [mydevice setDeviceNetState:DeviceNetStateOnline];
                    [mydevice setDeviceSwitchState:device.deviceSwitchState];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:mydevice];
                    [self changeDeviceSwitch:device.deviceSwitchState withID:device.deviceID];
                    
//                    [_homeTableView reloadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allGroupListReloadData" object:nil];
                }
            }
        } updateType:AduroSmartUpdateDataTypeSwitch];
    });
    
    dispatch_async(_myQueue, ^{
        [NSThread sleepForTimeInterval:0.8f];
        //读取设备亮度
        [_deviceManager getDevice:device updateData:^(AduroDevice *device, int updateDataType, uint16_t clusterID, uint16_t attribID,uint32_t attributeValue) {
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    [mydevice setDeviceNetState:DeviceNetStateOnline];
                    [mydevice setDeviceLightLevel:device.deviceLightLevel];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:mydevice];
                    [self changeDeviceLight:device.deviceLightLevel withID:device.deviceID];
                    
//                    [_homeTableView reloadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allGroupListReloadData" object:nil];
                }
            }
        } updateType:AduroSmartUpdateDataTypeLightLevel];
    });    
}

/**
 *  @author xingman.yi, 16-08-16 09:08:42
 *
 *  @brief 读取传感器的ZoneType
 *
 *  @param device 设备
 */
-(void)getZoneTypeForSensorDevice:(AduroDevice *)device{
    //读取传感器类型,如果ZoneType为0xffff或0x00,则读取;
    DeviceManager *deviceManager = [DeviceManager sharedManager];
    if ((device.deviceZoneType == DeviceZoneTypeUnidentified)||(device.deviceZoneType == DeviceZoneTypeStandardCIE)) {
        [deviceManager getDevice:device updateData:^(AduroDevice *device, int updateDataType, uint16_t clusterID, uint16_t attribID,uint32_t attributeValue) {
            DLog(@"读取传感器设备属性1 = device=%@,updateDataTyp=%d,clusterID=%d,attribID=%d",device,updateDataType,clusterID,attribID);
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *mydevice = [_globalDeviceArray objectAtIndex:i];
                if ([mydevice.deviceID isEqualToString:device.deviceID]) {
                    [mydevice setDeviceNetState:DeviceNetStateOnline];
                    [mydevice setDeviceZoneType:device.deviceZoneType];
                    [_globalDeviceArray replaceObjectAtIndex:i withObject:mydevice];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allGroupListReloadData" object:nil];
                }
            }
        } updateType:AduroSmartUpdateDataSensorZoneType];
    }
}
///-----------


-(void)getAllGroup{

    _groupManager = [GroupManager sharedManager];
    [_groupManager getAllGroups:^(AduroGroup *group) {
        if (group==nil) {
//            [self cancelRefreshTable];
            DLog(@"返回分组为空");
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
//                    [_homeTableView reloadData];
                [_roomCollectionView reloadData];

//                [self cancelRefreshTable];

            });
        }
    }];
    [self getScenesArray];
}

-(void)getScenesArray{
    SceneManager *sceneManager = [SceneManager sharedManager];
    [sceneManager getAllScenes:^(AduroScene *scene) {
        if (scene && [scene.sceneName length]>0) {
            BOOL isRep = NO;
            for (int i=0; i<[_globalSceneArray count]; i++) {
                AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
                if (myScene.sceneID == scene.sceneID) {
                    isRep = YES;
                    /*
                     * 使用场景图片路径进行场景在线不在线的标记
                     * 0x01 为在线
                     */
                    [scene setSceneIconPath:SCENE_NET_STATE_ONLINE];
                    [_globalSceneArray replaceObjectAtIndex:i withObject:scene];
                    [self changeSceneName:scene.sceneName withID:scene.sceneID];
                }
            }
            if (!isRep) {
                [self saveSceneDataObject:scene];  //存储到数据库
                [scene setSceneIconPath:SCENE_NET_STATE_ONLINE];
                [_globalSceneArray addObject:scene];
            }
            
            if (_currentIndex != 0) {
                /* 缓存:场景 */
                for (int i=0; i<_globalSceneArray.count; i++) {
                    AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
                    if (myScene.groupID == _currentRoom.groupID) {
                        BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
                        for (int k=0; k<_showSceneArr.count; k++) {
                            AduroScene *theScene = [_showSceneArr objectAtIndex:k];
                            if (theScene.sceneID == myScene.sceneID) {
                                noExist = NO;
                            }
                        }
                        if (noExist) {
                            [_showSceneArr addObject:myScene];
                        }
                    }
                }
            }else if (_currentIndex == 0){
                if (_showSceneArr.count>0) {
                    for (int i=0; i<_showSceneArr.count; i++) {
                        AduroScene *myScene = [_showSceneArr objectAtIndex:i];
                        BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
                        for (int k=0; k<_globalSceneArray.count; k++) {
                            AduroScene *theScene = [_globalSceneArray objectAtIndex:k];
                            if (theScene.sceneID == myScene.sceneID) {
                                noExist = NO;
                            }
                        }
                        if (noExist) {
                            [_showSceneArr addObject:myScene];
                        }
                    }
                }else{
                    [_showSceneArr addObjectsFromArray:_globalSceneArray];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshTableView];
            });
        }
    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return _globalGroupArray.count;
    if (tableView.tag == TAG_DEVICES) {
        return [_typeArr count];
    }else if (tableView.tag == TAG_SCENES) {
        return [_showSceneArr count];
    }else{
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString static *identifier = @"deviceCell";
//    ASHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (!cell) {
//        cell = [[ASHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        cell.delegate =self;
//    }
//    AduroGroup *aduroGroup = _globalGroupArray[indexPath.row];
//    [cell setAduroGroupInfo:nil];
//    [cell setAduroGroupInfo:aduroGroup];
//    return cell;
    if (tableView.tag == TAG_DEVICES) {
        NSString static *identifier = @"deviceCell";
        UITableViewCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!deviceCell) {
            deviceCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            deviceCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        deviceCell.textLabel.text = [_typeArr[indexPath.row] objectForKey:@"name"];
        deviceCell.imageView.image= [UIImage imageNamed:[_typeArr[indexPath.row] objectForKey:@"imageName"]];
        return deviceCell;
    }else if (tableView.tag == TAG_SCENES) {
        NSString static *identifier = @"sceneCell";
        UITableViewCell *sceneCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!sceneCell) {
            sceneCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        AduroScene *aduroScene = _showSceneArr[indexPath.row];
        sceneCell.textLabel.text = aduroScene.sceneName;
        
        return sceneCell;
    }else{
        return nil;
    }

}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    if (indexPath.row == 0) {
//        ASDeviceListViewController *deviceListvc = [[ASDeviceListViewController alloc] init];
//        [self setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:deviceListvc animated:NO];
//        [self setHidesBottomBarWhenPushed:NO];
//    }else{
//        ASHomeDetailViewController *detailvc = [[ASHomeDetailViewController alloc]init];
//        detailvc.detailGroup = _globalGroupArray[indexPath.row];
//        [self setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:detailvc animated:NO];
//        [self setHidesBottomBarWhenPushed:NO];
//    }
    if (tableView.tag == TAG_SCENES) {
        //点击激活场景
        AduroScene *scene = _showSceneArr[indexPath.row];
        SceneManager *sceneManager = [SceneManager sharedManager];
        [sceneManager useGroupIDCallScene:scene completionHandler:^(AduroSmartReturnCode code) {
            if (code == AduroSmartReturnCodeSuccess) {
                
            }
        }];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"完成"] message:[ASLocalizeConfig localizedString:@"成功开启场景"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [alert show];
    }else{
        
        LYRoomDeviceViewController *detailvc = [[LYRoomDeviceViewController alloc]init];
        detailvc.detailGroup = _currentRoom;
        detailvc.deviceType = [_typeArr[indexPath.row] objectForKey:@"deviceType"];
//            detailvc.roomDeviceArr = _currentDeviceArr;
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:detailvc animated:NO];
        [self setHidesBottomBarWhenPushed:NO];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return [ASHomeTableViewCell getCellHeight];
    return 70;
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _globalGroupArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString static *identifier = @"roomsCell";
    ASRoomViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    if (!cell) {
        NSLog(@"-----------------");
    }
    for (NSUInteger i = 0; i< _globalGroupArray.count; i++) {
        if (indexPath.row == i) {
            AduroGroup *aduroGroupInfo = [_globalGroupArray objectAtIndex:indexPath.item];
            NSArray *array = [aduroGroupInfo.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
            NSString *name = [array firstObject];
            NSString *typeId = [array lastObject];
            cell.homeNameLb.text = name;
            if ([typeId isEqualToString:@"01"]) {
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"living_room_big"]];
            }else if ([typeId isEqualToString:@"02"]){
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"kitchen_big"]];
            }else if ([typeId isEqualToString:@"03"]){
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"bedroom_big"]];
            }else if ([typeId isEqualToString:@"04"]){
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"bathroom_big"]];
            }
            else if ([typeId isEqualToString:@"05"]){
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"restaurant_big"]];
            }
            else if ([typeId isEqualToString:@"06"]){
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"toilet_big"]];
            }
            else if ([typeId isEqualToString:@"07"]){
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"office_big"]];
            }
            else if ([typeId isEqualToString:@"08"]){
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"hallway_big"]];
            }
            else{
                [cell.homeTypeImgView setImage:[UIImage imageNamed:@"all_lights_big"]];
            }
            
        }
    }
    return cell;
}

#pragma mark ---- UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return (CGSize){_frameView.frame.size.width,_frameView.frame.size.height};
//}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

#pragma mark ---- UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 点击高亮
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
}
// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - buttonAction
-(void)addNewHomeBtnAction{
//    ASNewHomeViewController *newHomeCtrl = [[ASNewHomeViewController alloc]init];
//    [self setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:newHomeCtrl animated:NO];
//    [self setHidesBottomBarWhenPushed:NO];
    if (_currentIndex != 0) {
        UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:[ASLocalizeConfig localizedString:@"Add Scene"], [ASLocalizeConfig localizedString:@"Add Room"], nil];
        [myActionSheet showInView:self.view];
        [myActionSheet setTag:TAG_SHEET_ONE];
    }else{
        UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:[ASLocalizeConfig localizedString:@"Add Room"], nil];
        [myActionSheet showInView:self.view];
        [myActionSheet setTag:TAG_SHEET_TWO];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == TAG_SHEET_ONE) {
        if (buttonIndex == 0) { //room
            [self newSceneToHomeBtnAction];
        }else if (buttonIndex == 1){  //scene
            ASNewHomeViewController *newHomeCtrl = [[ASNewHomeViewController alloc]init];
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:newHomeCtrl animated:NO];
            [self setHidesBottomBarWhenPushed:NO];
        }
    }
    if (actionSheet.tag == TAG_SHEET_TWO) {
        if (buttonIndex == 0) { //room
            ASNewHomeViewController *newHomeCtrl = [[ASNewHomeViewController alloc]init];
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:newHomeCtrl animated:NO];
            [self setHidesBottomBarWhenPushed:NO];
            
        }
    }
}

-(void)cancelWJStatusBarHUD{
    [WJStatusBarHUD hide];
//    [self stopMBProgressHUD];
}

//#pragma mark - ASHomeDelegate
//-(BOOL)homeSwitch:(BOOL)isOn aduroInfo:(AduroGroup *)aduroInfo{
//    NSLog(@"%d",isOn);
//    isOn = !isOn;
//    uint8_t onOff = 0;
//    onOff = isOn ? 1 : 0;
//    //    aduroInfo.deviceSwitchState = onOff;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (aduroInfo.groupID == MAX_GROUP_ID) {
//            DeviceManager *device = [DeviceManager sharedManager];
//            //控制所有开关设备的开关状态
//            [device updateAllDeviceSwitchState:isOn completionHandler:^(AduroSmartReturnCode code) {
//            }];
//        }else{
//            GroupManager *groupManager = [GroupManager sharedManager];
//            [groupManager ctrlGroup:aduroInfo switchOn:isOn completionHandler:^(AduroSmartReturnCode code) {
//                
//            }];
//        }
//    });
//    return isOn;
//}

//-(void)cancelRefreshTable{
//    [_homeTableView.mj_header endRefreshing];
//}

-(void)tableRefreshLoadAllHome{
//    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(cancelRefreshTable) userInfo:nil repeats:NO];

    NSInteger count = [_globalGroupArray count];    
    if (count>1) {
        NSRange range = NSMakeRange(1, (count-1));
        [_globalGroupArray removeObjectsInRange:range];
    }
    
    NSArray *roomArr = [self getRoomDataObject];
    [_globalGroupArray addObjectsFromArray:roomArr];
//    [_homeTableView reloadData];
    [self getAllGroup];
//    [self getAllAduroDevice];

}

#pragma mark - 从数据库中获取网关对象数组
-(NSArray *)getGatewayDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectGatewayData];
    return array;
}

#pragma mark - 保存设备到数据库
-(void)saveDeviceData:(AduroDevice *)data{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveDeviceData:data withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//从数据库中获取设备对象数组
-(NSArray *)getDeviceDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectDeviceDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}
//从数据库中删除所有设备对象
-(void)deleteAllDevicesData{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db deleteAllDevices];
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
////从数据库中删除所有房间对象
//-(void)deleteAllRoomData{
//    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
//    [db openDatabase];
//    [db deleteAllRooms];
//}
//更新房间名称到数据库
-(void)changeGroupName:(NSString *)name withID:(NSInteger)groupId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateRoomNameData:name WithID:groupId withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//更新设备名称到数据库
-(void)changeDeviceName:(NSString *)name withID:(NSString *)deviceId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateDeviceNameData:name WithID:deviceId];
}
//更新设备亮度到数据库
-(void)changeDeviceLight:(NSInteger)light withID:(NSString *)deviceId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateDeviceLightLevelData:light WithID:deviceId];
}
//更新设备开关状态到数据库
-(void)changeDeviceSwitch:(NSInteger)onOff withID:(NSString *)deviceId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateDeviceSwitchData:onOff WithID:deviceId];
}
#pragma mark - 保存传感器数据到数据库
-(void)saveSensorDataObject:(ASSensorDataObject *)sensorDO{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveSensorData:sensorDO];
    
}
#pragma mark - 保存场景数据到数据库
-(void)saveSceneDataObject:(AduroScene *)sceneDO{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveSceneData:sceneDO withGatewayid:[ASUserDefault loadGatewayIDCache]];
}
//更新场景名称到数据库
-(void)changeSceneName:(NSString *)name withID:(NSInteger)sceneId{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db updateSceneNameData:name withID:sceneId withGatewayid:[ASUserDefault loadGatewayIDCache]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 自动登陆
-(void)autoLogin{
    NSString *strUsername = [ASUserDefault loadUserNameCache];
    //    NSString *strPassword = [ASUserDefault loadUserPasswardCache];
    NSString *strPassword = [ASAESencryption aes256_decrypt:@"TRUSTSMART" Decrypttext:[ASUserDefault loadUserPasswardCache]];
    
    //    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"登录中..."]];
    //发送登录的post请求
    NSDictionary *parameters = @{@"email": strUsername,@"password": strPassword};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //AFNetworking框架不支持解析text/html这种格式,需要手动添加.
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //手机登录
    NSString *loginUrl = [NSString stringWithFormat:@"%@",URL_LOGIN_EMAIL_URL];
    [manager POST:loginUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //        [self stopMBProgressHUD];
        if (responseObject != nil) {
            NSString *sRegReturnCode = [responseObject objectForKey:@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            if(!(iRegReturnCode != 0)) {
                //登陆成功
                AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
                delegate.isLogin=YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
                [self sendGetGatewayMessageRequest];
            }
            
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        //登陆失败
        AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        delegate.isLogin= NO;
    }];
}

-(void)sendGetGatewayMessageRequest{
    NSString *strUserID = [ASUserDefault loadUserIDCache];
    if ([strUserID isEqualToString:@""] ){return;}
    //发送获取网关信息的post请求
    NSDictionary *parameters = @{@"user_id": strUserID};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //AFNetworking框架不支持解析text/html这种格式,需要手动添加.
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //网关数据获取
    NSString *uploadUrl = [NSString stringWithFormat:@"%@",GET_GATEWAY_MESSAGE_URL];
    [manager POST:uploadUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        [self stopMBProgressHUD];
        if (responseObject != nil) {
            NSString *sRegReturnCode = [responseObject objectForKey:@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            NSString *echo = @"";
            if(iRegReturnCode != 0 && iRegReturnCode !=3) {
                
            } else {
                echo = [ASLocalizeConfig localizedString:@"读取网关数据成功"];                
                NSDictionary *sGatewayDic = [responseObject objectForKey:@"result"];
                NSString *value = [responseObject objectForKey:@"result"];
                if ((NSNull *)value != [NSNull null]) {
                    NSArray *sKeys = [sGatewayDic allKeys];
                    for (int i=0; i<sKeys.count; i++) {
                        NSDictionary *sGatewayMes = [sGatewayDic objectForKey:sKeys[i]];
                        
                        NSString *sGatewayID = [sGatewayMes objectForKey:[NSString stringWithFormat:@"gateway_num"]];
                        NSString *sGatewayKey = [sGatewayMes objectForKey:[NSString stringWithFormat:@"security_key"]];
                        AduroGateway *gateway = [[AduroGateway alloc] init];
                        gateway.gatewayID = sGatewayID;
                        gateway.gatewaySecurityKey = sGatewayKey;
                        if (_globalCloudGetwayArray.count>0) {
                            BOOL isRepeat = NO; //不重复
                            for (int j=0; j<_globalCloudGetwayArray.count; j++) {
                                AduroGateway *oneGateway = [_globalCloudGetwayArray objectAtIndex:j];
                                if ([oneGateway.gatewayID isEqualToString:sGatewayID]) {
                                    isRepeat = YES;
                                }
                            }
                            if (!isRepeat) {
                                [_globalCloudGetwayArray addObject:gateway];
                            }
                        }else{
                            [_globalCloudGetwayArray addObject:gateway];
                        }
                    }
                }
                
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"错误"] message:[ASLocalizeConfig localizedString:@"登录状态下网关连接数据上传失败:网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"关闭"] otherButtonTitles:nil, nil];
//        [alert show];
    }];
}

-(void)playAlarmAudio{
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"mp3"]] error:nil];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"mp3"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }    
    AudioServicesPlaySystemSound(shake_sound_male_id);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UIViewAnimation
-(void)showUpView{
    
    [UIView animateWithDuration:0.5 animations:^{
        _deviceView.frame = CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - 49 - 64);
        _deviceTable.alpha = 0.8;
        
        _frameView.frame = CGRectMake(45, SCREEN_ADURO_HEIGHT + 45, SCREEN_ADURO_WIDTH-90, SCREEN_ADURO_HEIGHT-90-49-64);
        _arrowTypeView.alpha = 0.8;
        _upLineLb.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hiddenUpView{
    [UIView animateWithDuration:0.5 animations:^{
        _deviceView.frame = CGRectMake(0, -SCREEN_ADURO_HEIGHT, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT);
        _deviceTable.alpha = 0.1;
        _frameView.frame = CGRectMake(45, 45, SCREEN_ADURO_WIDTH-90, SCREEN_ADURO_HEIGHT-90-49-64);
        _arrowTypeView.alpha = 0;
        _upLineLb.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)showDownView{
    if (_currentIndex != 0) {
        /* 缓存:场景 */
        for (int i=0; i<_globalSceneArray.count; i++) {
            AduroScene *myScene = [_globalSceneArray objectAtIndex:i];
            if (myScene.groupID == _currentRoom.groupID) {
                BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
                for (int k=0; k<_showSceneArr.count; k++) {
                    AduroScene *theScene = [_showSceneArr objectAtIndex:k];
                    if (theScene.sceneID == myScene.sceneID) {
                        noExist = NO;
                    }
                }
                if (noExist) {
                    [_showSceneArr addObject:myScene];
                }
            }
        }
    }else if (_currentIndex == 0){
        if (_showSceneArr.count>0) {
            for (int i=0; i<_showSceneArr.count; i++) {
                AduroScene *myScene = [_showSceneArr objectAtIndex:i];
                BOOL noExist = YES;  //yes 不存在重复的   NO 存在重复的
                for (int k=0; k<_globalSceneArray.count; k++) {
                    AduroScene *theScene = [_globalSceneArray objectAtIndex:k];
                    if (theScene.sceneID == myScene.sceneID) {
                        noExist = NO;
                    }
                }
                if (noExist) {
                    [_showSceneArr addObject:myScene];
                }
            }
        }else{
            [_showSceneArr addObjectsFromArray:_globalSceneArray];
        }
    }
    [self refreshTableView];
    [UIView animateWithDuration:0.5 animations:^{
        _sceneView.frame = CGRectMake(0, 0, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - 49 - 64);
        _sceneTable.alpha = 0.8;
        
        _frameView.frame = CGRectMake(45, - (SCREEN_ADURO_HEIGHT-90-49-64) - 45-64, SCREEN_ADURO_WIDTH-90, SCREEN_ADURO_HEIGHT-90-49-64);
        _arrowSceneView.alpha = 0.8;
        _upLineLb.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hiddenDownView{
    [UIView animateWithDuration:0.5 animations:^{
        _sceneView.frame = CGRectMake(0, SCREEN_ADURO_HEIGHT, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT);
        _sceneTable.alpha = 0.1;
        _frameView.frame = CGRectMake(45, 45, SCREEN_ADURO_WIDTH-90, SCREEN_ADURO_HEIGHT-90-49-64);
        _arrowSceneView.alpha = 0;
        _upLineLb.alpha = 0;
    } completion:^(BOOL finished) {
        [_showSceneArr removeAllObjects];
    }];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    _currentIndex = round(offset.x / scrollView.frame.size.width);
    
    AduroGroup *aduroGroupInfo = [_globalGroupArray objectAtIndex:_currentIndex];
    NSArray *array = [aduroGroupInfo.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
    NSString *name = [array firstObject];
    self.title = name;
    
    if (_currentIndex != 0) {
        _currentRoom = [_globalGroupArray objectAtIndex:_currentIndex];
    }else{
        _currentRoom = [_globalGroupArray objectAtIndex:0];
    }
    
    if (_currentDeviceArr.count>0) {
        [_currentDeviceArr removeAllObjects];
//        if (_currentIndex !=0) {
//            [self getDeviceOfRoom];
//        }else{
//            [_currentDeviceArr addObjectsFromArray:_globalDeviceArray];
//        }
    }else{
        if (_currentIndex !=0) {
//            [self getDeviceOfRoom];
        }else{
            [_currentDeviceArr addObjectsFromArray:_globalDeviceArray];
        }
    }
}
/*
-(void)getDeviceOfRoom{
    GroupManager *groupManager = [GroupManager sharedManager];
    [groupManager getDevicesOfGroup:_currentRoom devices:^(NSArray *devices) {
        if (devices.count>0) {
            BOOL isExist = NO;
            for (AduroDevice *myDevice in devices) {
                for (int k=0; k<_currentDeviceArr.count; k++) {
                    AduroDevice *oneDevice = [_currentDeviceArr objectAtIndex:k];
                    if ([myDevice.deviceID isEqualToString:oneDevice.deviceID]) {
                        isExist = YES;
                        [myDevice setDeviceNetState:DeviceNetStateOnline];
                        [_currentDeviceArr replaceObjectAtIndex:k withObject:myDevice];
                    }
                }
                if (!isExist) {
                    [myDevice setDeviceNetState:DeviceNetStateOnline];
                    [_currentDeviceArr addObject:myDevice];
                }
            }
            [_deviceTable reloadData];
        }
    }];
}
*/
-(void)newSceneToHomeBtnAction{
    if (_currentIndex != 0) {
        ASAddHomeSceneViewController *detailvc = [[ASAddHomeSceneViewController alloc]init];
        detailvc.mySceneGroup = _currentRoom;
        //        detailvc.myDeviceArray = _currentDeviceArr;
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:detailvc animated:nil];
        [self setHidesBottomBarWhenPushed:NO];
    }else{
        UIAlertView *failView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"Reminder"] message:[ASLocalizeConfig localizedString:@"It is the default room, you can not create a scene, please go to other rooms to create the scene"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:nil, nil];
        [failView show];
    }
}

@end
