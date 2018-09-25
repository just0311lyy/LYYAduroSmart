//
//  ASGatewayInfoViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/9/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGatewayInfoViewController.h"
#import "ASUserDefault.h"
#import "ASDataBaseOperation.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#define SURE_TAG 100000
#define SUCCESS_TAG 100001
@interface ASGatewayInfoViewController (){
    UIButton *_deleteBtn;  //删除当前网关按钮
}

@end

@implementation ASGatewayInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0Xf7f7f7);
    [self initWithGatewayView];
    
}

-(void)initWithGatewayView{
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH,64)];
    barView.backgroundColor = LOGO_COLOR;
    [self.view addSubview:barView];
    
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backToGatewayList) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:leftBarBtn];
    leftBarBtn.frame = CGRectMake(10, 20, 34, 34);
    //标题
    UILabel *titleLabel = [UILabel new];
    [barView addSubview:titleLabel];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(barView.mas_top).offset(10);
        make.centerX.equalTo(barView.mas_centerX);
        make.width.equalTo(@(110));
        make.bottom.equalTo(barView.mas_bottom);
    }];
    [titleLabel setText:[ASLocalizeConfig localizedString:@"网关"]];
//-------
    //网关详情描述
    UIView *messageView = [UIView new];
    [self.view addSubview:messageView];
    messageView.layer.cornerRadius = 20;
    messageView.layer.shadowColor = UIColorFromRGB(0x492d00).CGColor;//阴影颜色
    messageView.layer.shadowOffset = CGSizeMake(0, 0);//偏移距离
    messageView.layer.shadowOpacity = 0.5;//不透明度
    messageView.layer.shadowRadius = 2.0;//半径
    messageView.backgroundColor = [UIColor whiteColor];
    [messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(barView.mas_bottom).offset(20);
        make.leading.equalTo(self.view.mas_leading).offset(20);
        make.trailing.equalTo(self.view.mas_trailing).offset(-20);
        make.height.equalTo(@(240));
    }];

    //status
    UILabel *statusTitleLb = [UILabel new];
    [messageView addSubview:statusTitleLb];
    [statusTitleLb setFont:[UIFont fontWithName:@"HouseGothicHG23Text Light" size:18]];
    [statusTitleLb setText:@"Status:"];
    [statusTitleLb setTextColor:UIColorFromRGB(0x707070)];
//    [statusTitleLb setLineBreakMode:NSLineBreakByWordWrapping];
    [statusTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(messageView.mas_leading).offset(20);
        make.width.equalTo(@(58));
        make.top.equalTo(messageView.mas_top).offset(20);
        make.height.equalTo(@(25));
    }];
    //连接或者未连接
    UILabel *statusLb = [UILabel new];
    [messageView addSubview:statusLb];
    [statusLb setFont:[UIFont fontWithName:@"HouseGothicHG23Text Light" size:18]];
//    [statusLb setTextColor:UIColorFromRGB(0x8bdd8b)];
    [statusLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(statusTitleLb.mas_trailing).offset(2);
        make.centerY.equalTo(statusTitleLb.mas_centerY);
        make.trailing.equalTo(messageView.mas_trailing).offset(-20);
        make.height.equalTo(statusTitleLb.mas_height);
    }];
    AppDelegate *myDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *statusStr = @"";
    if (myDelegate.isConnect && [self.currentGateway.gatewayID isEqualToString:[ASUserDefault loadGatewayIDCache]]) {
        statusStr = [ASLocalizeConfig localizedString:@"已连接"];
        [statusLb setTextColor:UIColorFromRGB(0x8bdd8b)];
    }else{
        statusStr = [ASLocalizeConfig localizedString:@"未连接"];
        [statusLb setTextColor:[UIColor redColor]];
    }
    [statusLb setText:[NSString stringWithFormat:@"%@",statusStr]];
    //line 01
    UIView *lineOne = [UIView new];
    [messageView addSubview:lineOne];
    [lineOne setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [lineOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageView.mas_top).offset(50);
        make.leading.equalTo(messageView.mas_leading).offset(20);
        make.trailing.equalTo(messageView.mas_trailing).offset(-20);
        make.height.equalTo(@(1));
    }];
 //----
    //ID
    UILabel *idLb = [UILabel new];
    [messageView addSubview:idLb];
    [idLb setFont:[UIFont fontWithName:@"HouseGothicHG23Text Light" size:18]];
    [idLb setText:@"ID:"];
    [idLb setTextColor:UIColorFromRGB(0x707070)];
    //    [statusTitleLb setLineBreakMode:NSLineBreakByWordWrapping];
    [idLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(lineOne.mas_leading);
        make.width.equalTo(@(25));
        make.top.equalTo(lineOne.mas_bottom).offset(20);
        make.height.equalTo(@(25));
    }];
    
    UILabel *gatewayidLb = [UILabel new];
    [messageView addSubview:gatewayidLb];
    [gatewayidLb setFont:[UIFont fontWithName:@"HouseGothicHG23Text Light" size:18]];
    [gatewayidLb setText:[NSString stringWithFormat:@"%@",self.currentGateway.gatewayID]];
    [gatewayidLb setTextColor:UIColorFromRGB(0xbcbcbc)];
    [gatewayidLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(idLb.mas_trailing);
        make.trailing.equalTo(lineOne.mas_trailing);
        make.top.equalTo(idLb.mas_top);
        make.height.equalTo(idLb.mas_height);
    }];
//line 02
    UIView *lineTwo = [UIView new];
    [messageView addSubview:lineTwo];
    [lineTwo setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [lineTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageView.mas_top).offset(100);
        make.leading.equalTo(lineOne.mas_leading);
        make.trailing.equalTo(lineOne.mas_trailing);
        make.height.equalTo(@(1));
    }];
        
    //Mac address
    UILabel *addressLb = [UILabel new];
    [messageView addSubview:addressLb];
    [addressLb setFont:[UIFont fontWithName:@"HouseGothicHG23Text Light" size:18]];
    [addressLb setText:[NSString stringWithFormat:@"MAC address:"]];
    [addressLb setTextColor:UIColorFromRGB(0x707070)];
    [addressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(lineOne.mas_leading);
        make.width.equalTo(@(110));
        make.top.equalTo(lineTwo.mas_bottom).offset(20);
        make.height.equalTo(@(25));
    }];
    //gateway address
    UILabel *gatewayAddressLb = [UILabel new];
    [messageView addSubview:gatewayAddressLb];
    [gatewayAddressLb setFont:[UIFont fontWithName:@"HouseGothicHG23Text Light" size:18]];
    [gatewayAddressLb setText:[NSString stringWithFormat:@"%@",self.currentGateway.gatewayIPv4Address]];
    [gatewayAddressLb setTextColor:UIColorFromRGB(0xbcbcbc)];
    [gatewayAddressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(addressLb.mas_trailing);
        make.trailing.equalTo(lineTwo.mas_trailing);
        make.centerY.equalTo(addressLb.mas_centerY);
        make.height.equalTo(addressLb.mas_height);
    }];
    
//line 02
    UIView *lineThree = [UIView new];
    [messageView addSubview:lineThree];
    [lineThree setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [lineThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageView.mas_top).offset(150);
        make.leading.equalTo(lineOne.mas_leading);
        make.trailing.equalTo(lineOne.mas_trailing);
        make.height.equalTo(@(1));
    }];
    //software
//    UILabel *versionLb = [UILabel new];
//    [messageView addSubview:versionLb];
//    [versionLb setFont:[UIFont fontWithName:@"HouseGothicHG23Text Light" size:18]];
//    [versionLb setText:@"Software version:"];
//    [versionLb setTextColor:UIColorFromRGB(0x707070)];
//    [versionLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(lineOne.mas_leading);
//        make.width.equalTo(@(135));
//        make.top.equalTo(lineThree.mas_bottom).offset(20);
//        make.height.equalTo(@(25));
//    }];
//    //gateway software
//    UILabel *gatewayVersionLb = [UILabel new];
//    [messageView addSubview:gatewayVersionLb];
//    [gatewayVersionLb setFont:[UIFont fontWithName:@"HouseGothicHG23Text Light" size:18]];
//    if ([self.currentGateway.gatewaySoftwareVersion isEqualToString:@""] || self.currentGateway.gatewaySoftwareVersion == nil) {
//        [gatewayVersionLb setText:@""];
//    }else{
//        [gatewayVersionLb setText:[NSString stringWithFormat:@"%@",self.currentGateway.gatewaySoftwareVersion]];
//    }
//    [gatewayVersionLb setText:@""];
//    [gatewayVersionLb setTextColor:UIColorFromRGB(0xbcbcbc)];
//    [gatewayVersionLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(versionLb.mas_trailing);
//        make.trailing.equalTo(lineOne.mas_trailing);
//        make.centerY.equalTo(versionLb.mas_centerY);
//        make.height.equalTo(versionLb.mas_height);
//    }];
    
    UIButton *updateBtn = [UIButton new];
    updateBtn.layer.cornerRadius = 22.0;
    [updateBtn setTitle:[ASLocalizeConfig localizedString:@"update"] forState:UIControlStateNormal];
    [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [updateBtn setBackgroundColor:UIColorFromRGB(0xfe682c)];
    [updateBtn setBackgroundColor:[UIColor orangeColor]];
    [updateBtn addTarget:self action:@selector(updateGateway) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateBtn];
    [updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(40);
        make.trailing.equalTo(self.view.mas_trailing).offset(-40);
        make.top.equalTo(messageView.mas_bottom).offset(60);
        make.height.equalTo(@(44));
    }];
    
    _deleteBtn = [UIButton new];
    _deleteBtn.layer.cornerRadius = 22.0;
    [_deleteBtn setTitle:[ASLocalizeConfig localizedString:@"delete"] forState:UIControlStateNormal];
    [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundColor:UIColorFromRGB(0xfe682c)];
    [_deleteBtn addTarget:self action:@selector(deleteCurrentGatewayCache) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(40);
        make.trailing.equalTo(self.view.mas_trailing).offset(-40);
        make.top.equalTo(updateBtn.mas_bottom).offset(30);
        make.height.equalTo(@(44));
    }];
    
    [self changeDeleteButtonState];
}

-(void)changeDeleteButtonState{
    AppDelegate *myDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myDelegate.isConnect && [self.currentGateway.gatewayID isEqualToString:[ASUserDefault loadGatewayIDCache]]) {
        //如果是当前正在连接的网关
        [_deleteBtn setEnabled:NO];
    }
}

-(void)deleteCurrentGatewayCache{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"delete"] message:[ASLocalizeConfig localizedString:@"sure to remove the ZigBee Birdge? After that, you will not be able to control it"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"cancel"] otherButtonTitles:[ASLocalizeConfig localizedString:@"sure"], nil];
    alertView.tag = SURE_TAG;
    [alertView show];
}

-(void)updateGateway{
    GatewayManager *gManager = [GatewayManager sharedManager];
    [gManager upgradeGatewayCompletionHandler:^(AduroSmartReturnCode code) {
        if (code == AduroSmartReturnCodeSuccess) {
            [self showUpdateSuccessAlertView];
        }
    }];
}

-(void)showUpdateSuccessAlertView{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"success"] message:[ASLocalizeConfig localizedString:@"Gateway firmware upgrade success"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"OK"] otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SURE_TAG) {
        if (buttonIndex == 1) {
            [self deleteRBtnAction];
        }
    }else if(alertView.tag == SUCCESS_TAG){
        if(buttonIndex == 0){
            //从全局网关变量数组中删除该网关
            if ([self.delegate respondsToSelector:@selector(deleteAduroGatewayCache:)]) {
                [self.delegate deleteAduroGatewayCache:self.currentGateway];
            }
            //从本地缓存中删除该网关
            [self deleteGatewayDataByGatewayID:self.currentGateway.gatewayID];
            
            [self dismissViewControllerAnimated:NO completion:nil];
    //        [[NSNotificationCenter defaultCenter] postNotificationName:@"gatewayManageTableRefresh" object:nil];
        }
    }
}

//从数据库中通过ID删除网关对象
-(void)deleteGatewayDataByGatewayID:(NSString *)GatewayID{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db deleteGatewayWithID:GatewayID];
}

//发送删除网关编号和KEY的请求
-(void)deleteRBtnAction{
    NSString *strUserID = [ASUserDefault loadUserIDCache];

    NSString *gatewayNum = self.currentGateway.gatewayID;
    if ([strUserID isEqualToString:@""] || [gatewayNum isEqualToString:@""]) {return;}
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"删除中..."]];
    //发送登录的post请求
    NSDictionary *parameters = @{@"user_id": strUserID,@"gateway_num": gatewayNum};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //AFNetworking框架不支持解析text/html这种格式,需要手动添加.
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *loginUrl = [NSString stringWithFormat:@"%@",DELETE_GATEWAY_MESSAGE_URL];
    [manager POST:loginUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self stopMBProgressHUD];
        if (responseObject != nil) {
            NSString *sRegReturnCode = [responseObject objectForKey:@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            if(iRegReturnCode == 0){
                //删除成功
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"Success"] message:[ASLocalizeConfig localizedString:@"The ZigBee Birdge has been deleted"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"Sure"] otherButtonTitles:nil, nil];
                alert.tag = SUCCESS_TAG;
                [alert show];
            }
        }else{
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"错误"] message:[ASLocalizeConfig localizedString:@"delete failed"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"关闭"] otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self stopMBProgressHUD];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"错误"] message:[ASLocalizeConfig localizedString:@"网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"关闭"] otherButtonTitles:nil, nil];
        [alert show];
        
    }];
}


-(void)backToGatewayList{
    [self dismissViewControllerAnimated:NO completion:nil];
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
