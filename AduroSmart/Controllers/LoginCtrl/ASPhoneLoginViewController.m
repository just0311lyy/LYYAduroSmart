//
//  ASPhoneLoginViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/8/10.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASPhoneLoginViewController.h"
#import "ASPhoneRegisterViewController.h"
#import "SectionsViewController.h"
#import "YJLocalCountryData.h"
#import "ASValidate.h"
#import "MyTool.h"
#import "ASLoginViewController.h"

#import <Masonry.h>
#import <AFNetworking.h>
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/Extend/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/Extend/SMSSDK+DeprecatedMethods.h>
#import <SMS_SDK/Extend/SMSSDKUserInfo.h>//信息
#import <SMS_SDK/Extend/SMSSDK+AddressBookMethods.h>//好有
#import <SMS_SDK/Extend/SMSSDK+ExtexdMethods.h>
#import <MOBFoundation/MOBFoundation.h>

#define LOGIN_SUCCESS  1000
@interface ASPhoneLoginViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,SecondViewControllerDelegate>{
    UIView *_backgroudView;
    UITextField *_txtLoginAccount;
    UITextField *_txtPassword;
    
    SMSSDKCountryAndAreaCode* _data2; //国家名称和编码的类
    NSString* _defaultCode;  //当前国家代码
    NSString* _defaultCountryName; //当前国家名
    UITableView *_areaTableView; //手机区号选择
    NSMutableArray* _areaArray;
}

@property (nonatomic,strong) NSString *txtAreaCode; //手机区号

@end

@implementation ASPhoneLoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithLoginView];
    self.title = [ASLocalizeConfig localizedString:@"手机登录"];
    //设置本地区号
    [self setTheLocalAreaCode];
}

-(void)initWithLoginView{
    //背景视图
    _backgroudView = [UIView new];
    //    _backgroudView.backgroundColor = LOGO_COLOR;
    [self.view addSubview:_backgroudView];
    [_backgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(260));
    }];
    
    UIImageView *headImgView = [UIImageView new];
    headImgView.image = [UIImage imageNamed:@"AppIcon40x40"];
    headImgView.layer.cornerRadius = 10.0;
    [_backgroudView addSubview:headImgView];
    [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(25);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
    }];
    
    [self selectAreaView];

    //账号
    _txtLoginAccount = [UITextField new];
    
    [_txtLoginAccount setDelegate:self];
    [_txtLoginAccount setPlaceholder:[ASLocalizeConfig localizedString:@"手机账号"]];
    [_backgroudView addSubview:_txtLoginAccount];
    [_txtLoginAccount setBorderStyle:UITextBorderStyleRoundedRect];
    [_txtLoginAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_areaTableView.mas_bottom).offset(10);
        make.leading.equalTo(_backgroudView.mas_leading).offset(40);
        make.trailing.equalTo(_backgroudView.mas_trailing).offset(-40);
        make.height.equalTo(@(40));
    }];
    //密码
    _txtPassword = [UITextField new];
    [_backgroudView addSubview:_txtPassword];
    [_txtPassword setSecureTextEntry:YES];
    [_txtPassword setDelegate:self];
    [_txtPassword setPlaceholder:[ASLocalizeConfig localizedString:@"密码"]];
    [_txtPassword setBorderStyle:UITextBorderStyleRoundedRect];
    [_txtPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_txtLoginAccount.mas_bottom).offset(10);
        make.leading.equalTo(_txtLoginAccount.mas_leading);
        make.trailing.equalTo(_txtLoginAccount.mas_trailing);
        make.height.equalTo(_txtLoginAccount.mas_height);
    }];
    //登录按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:loginBtn];
    loginBtn.layer.cornerRadius = 20.0;
    loginBtn.backgroundColor = LOGO_COLOR;
    [loginBtn setTitle:[ASLocalizeConfig localizedString:@"登录"] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backgroudView.mas_bottom).offset(20);
        make.leading.equalTo(_backgroudView.mas_leading).offset(60);
        make.trailing.equalTo(_backgroudView.mas_trailing).offset(-60);
        make.height.equalTo(@(40));
    }];

    //忘记密码
    UIButton *forgotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:forgotBtn];
    [forgotBtn setTitle:[ASLocalizeConfig localizedString:@"忘记密码"] forState:UIControlStateNormal];
    [forgotBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    forgotBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [forgotBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [forgotBtn addTarget:self action:@selector(forgotBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [forgotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(20);
        make.trailing.equalTo(self.view.mas_centerX).offset(-15);
        make.height.equalTo(loginBtn.mas_height);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    //注册
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:registerBtn];
    [registerBtn setTitle:[ASLocalizeConfig localizedString:@"创建进入"] forState:UIControlStateNormal];
    [registerBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [registerBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_centerX).offset(15);
        make.trailing.equalTo(self.view.mas_trailing).offset(-20);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
        make.height.equalTo(forgotBtn.mas_height);
        
    }];
    
    //切换到邮箱登录
    UIButton *mailLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:mailLoginBtn];
    [mailLoginBtn setTitle:[ASLocalizeConfig localizedString:@"邮箱登录"] forState:UIControlStateNormal];
    [mailLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    mailLoginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    mailLoginBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [mailLoginBtn.titleLabel setTextAlignment:NSTextAlignmentRight];
    [mailLoginBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [mailLoginBtn addTarget:self action:@selector(emailLoginPress) forControlEvents:UIControlEventTouchUpInside];
    [mailLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(loginBtn.mas_bottom).offset(5);
        make.trailing.equalTo(registerBtn.mas_trailing);
        make.leading.equalTo(registerBtn.mas_leading);
        make.height.equalTo(registerBtn.mas_height);
    }];
}

-(void)selectAreaView{
    //选择区域码的表格
    _areaTableView = [[UITableView alloc]init];
    _areaTableView.layer.cornerRadius = 4;
    _areaTableView.layer.borderWidth = 1;
    _areaTableView.layer.borderColor = [CELL_LIEN_COLOR CGColor];
    [_backgroudView addSubview:_areaTableView];
    [_areaTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backgroudView.mas_top).offset(115);
        make.leading.equalTo(_backgroudView.mas_leading).offset(40);
        make.trailing.equalTo(_backgroudView.mas_trailing).offset(-40);
        make.height.equalTo(@(40));
    }];
    _areaTableView.dataSource = self;
    _areaTableView.delegate = self;
    _areaTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    _areaArray = [[NSMutableArray alloc]init];
    
    //设置本地区号
    [self setTheLocalAreaCode];  //当前国家代码和国家名
    //获取支持的地区列表
    NSString *saveTimeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveDate"];
    
    NSDateComponents *dateComponents = nil;
    
    if (saveTimeString.length != 0) {
        //当前日期的天数差
        dateComponents = [YJLocalCountryData compareTwoDays:saveTimeString]; //saveTimeString 待确定的时间
    }
    
    if (dateComponents.day >= 1 || saveTimeString.length == 0) { //day = 0 ,代表今天，day = 1  代表昨天  day >= 1 表示至少过了一天  saveTimeString.length == 0表示从未进行过缓存
        //获取支持的地区列表
        [SMSSDK getCountryZone:^(NSError *error, NSArray *zonesArray) {
            
            if (!error) {
                
                NSLog(@"get the area code sucessfully");
                //区号数据
                _areaArray = [NSMutableArray arrayWithArray:zonesArray];
                //获取到国家列表数据后对进行缓存
                [[MOBFDataService sharedInstance] setCacheData:_areaArray forKey:@"countryCodeArray" domain:nil];
                //设置缓存时间
                NSDate *saveDate = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:[MOBFDate stringByDate:saveDate withFormat:@"yyyy-MM-dd"] forKey:@"saveDate"];
                
                NSLog(@"_areaArray_%@",_areaArray);
            }
            else
            {
                NSLog(@"failed to get the area code _%@______error_%@",[error.userInfo objectForKey:@"getZone"],error);
            }
        }];
    }
    else
    {
        _areaArray = [[MOBFDataService sharedInstance] cacheDataForKey:@"countryCodeArray" domain:nil];
    }
}

#pragma mark - areaTableView的协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] ;
        
    }
    //    cell.textLabel.text = NSLocalizedString(@"countrylable", nil);
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    if (_data2)
    {
        cell.textLabel.text = _data2.countryName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@",_data2.areaCode];
    }
    else
    {
        cell.textLabel.text = _defaultCountryName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@",_defaultCode];
    }
    
    
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *tempView = [[UIView alloc] init];
    [cell setBackgroundView:tempView];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionsViewController* country2 = [[SectionsViewController alloc] init];
    country2.delegate = self;
    //读取本地countryCode
    if (_areaArray.count == 0) {
        NSMutableArray *dataArray = [YJLocalCountryData localCountryDataArray];
        _areaArray = dataArray;
    }
    [country2 setAreaArray:_areaArray];
    [self presentViewController:country2 animated:YES completion:^{
        
    }];
}


//设置本地区号
-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt = [locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode = [dictCodes objectForKey:tt];
    self.txtAreaCode = [NSString stringWithFormat:@"%@",defaultCode];
    
    NSString* defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:tt];
    _defaultCode = defaultCode;
    _defaultCountryName = defaultCountryName;
}

#pragma mark - SecondViewControllerDelegate的方法
- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
{
    _data2=data;
    NSLog(@"the area data：%@,%@", data.areaCode,data.countryName);
    self.txtAreaCode = [NSString stringWithFormat:@"%@",data.areaCode];
    [_areaTableView reloadData];
}

#pragma mark - buttonAction
-(void)registerBtnAction:(UIButton *)sender{
    ASPhoneRegisterViewController * registervc = [[ASPhoneRegisterViewController alloc] init];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:registervc animated:YES];
}

/**
 *  @author
 *
 *  @brief 用户登录,需要判断账号的类型,如果输入的不是邮箱则需要在输入信息前加上当前区号
 *
 *  @param sender 登录按钮
 */
-(void)loginBtnAction{
    NSString *strUsername = _txtLoginAccount.text;
    NSString *strPassword = _txtPassword.text;
    NSString *telArea = self.txtAreaCode;
    //验证账号密码输入格式
    if (![ASValidate username:strUsername]) {return;}
    if (![ASValidate password:strPassword]) {return;}
    
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"数据加载中..."]];

    //发送登录的post请求
    NSDictionary *parameters = @{@"tel": strUsername,@"password": strPassword,@"tel_area":telArea};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; //AFNetworking框架不支持解析text/html这种格式,需要手动添加.
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //手机登录
    NSString *loginUrl = [NSString stringWithFormat:@"%@",URL_LOGIN_PHONE_URL];
    [manager POST:loginUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self stopMBProgressHUD];
        if (responseObject != nil) {
            
            NSString *registerReturn = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *dataRegReturn = [registerReturn dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dictRegReturn = [NSJSONSerialization JSONObjectWithData:dataRegReturn options:NSJSONReadingMutableLeaves error:&error];
            NSLog(@"%@",dictRegReturn);
            NSString *sRegReturnCode = dictRegReturn[@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            NSString *echo = @"";
            if(iRegReturnCode != 0) {
                if(iRegReturnCode == 1) {
                    echo = [ASLocalizeConfig localizedString:@"账号错误"];;
                }
                else if(iRegReturnCode == 2) {
                    echo = [ASLocalizeConfig localizedString:@"密码错误"];
                }
                else {
                    echo = [ASLocalizeConfig localizedString:@"未定义"];
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"regreturninfotitle", nil) message:echo delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
                [alert show];
            } else {
                echo = [ASLocalizeConfig localizedString:@"登录成功，开启远程控制"];
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"regreturninfotitle", nil) message:echo delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
                alert.tag = LOGIN_SUCCESS;
                [alert show];
            }
        }   
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self stopMBProgressHUD];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"关闭"] otherButtonTitles:nil, nil];
        [alert show];
        
    }];
}

-(void)forgotBtnAction{
 
    
    
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == LOGIN_SUCCESS) {
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
}


-(void)emailLoginPress{
    ASLoginViewController *mailRegVC = [[ASLoginViewController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mailRegVC animated:YES];
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_areaTableView reloadData];
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
