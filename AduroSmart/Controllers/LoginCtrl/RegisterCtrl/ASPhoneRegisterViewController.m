//
//  ASPhoneRegisterViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/21.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASPhoneRegisterViewController.h"
#import "YJLocalCountryData.h"
#import "SectionsViewController.h"
#import "ASMailRegisterViewController.h"
#import "ASValidate.h"

#import <AFNetworking.h>
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/Extend/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/Extend/SMSSDK+DeprecatedMethods.h>
#import <SMS_SDK/Extend/SMSSDKUserInfo.h>//信息
#import <SMS_SDK/Extend/SMSSDK+AddressBookMethods.h>//好有
#import <SMS_SDK/Extend/SMSSDK+ExtexdMethods.h>
#import <MOBFoundation/MOBFoundation.h>

@interface ASPhoneRegisterViewController ()<UIAlertViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,SecondViewControllerDelegate>{
    
    UIView *_backgroundView;
    UITableView *_areaTableView;
    UITextField *_txtPhoneNumber;
    UITextField *_txtVerification;
    UITextField *_txtpassword;
    
    SMSSDKCountryAndAreaCode* _data2; //国家名称和编码的类
    NSString* _defaultCode;  //当前国家代码
    NSString* _defaultCountryName; //当前国家名
    
    NSMutableArray* _areaArray;
}

@property (nonatomic,strong) NSString *txtAreaCode;

@end

@implementation ASPhoneRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ASLocalizeConfig localizedString:@"注册"];
    [self initWithPhoneRegisterView];
}

-(void)initWithPhoneRegisterView{
    
    _backgroundView = [UIView new];
    [self.view addSubview:_backgroundView];
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_top).offset(310);
    }];
    
    UILabel *areaLabel = [UILabel new];
    [_backgroundView addSubview:areaLabel];
    [areaLabel setNumberOfLines:3];
    [areaLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [areaLabel setText:[ASLocalizeConfig localizedString:@"国家和地区"]];
    [areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backgroundView.mas_top).offset(10);
        make.leading.equalTo(_backgroundView.mas_leading).offset(20);
        make.trailing.equalTo(_backgroundView.mas_trailing).offset(-10);
        make.height.equalTo(@(44));
    }];
    
    [self selectAreaView];
    
    UIView *areaLineView = [UIView new];
    [_backgroundView addSubview:areaLineView];
    areaLineView.backgroundColor = [UIColor lightGrayColor];
    [areaLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(areaLabel.mas_bottom).offset(46);
        make.leading.equalTo(areaLabel.mas_leading);
        make.trailing.equalTo(areaLabel.mas_trailing);
        make.height.equalTo(@(1));
        
    }];
    
    //---------
    UILabel *telLabel = [UILabel new];
    [_backgroundView addSubview:telLabel];
    [telLabel setNumberOfLines:3];
    [telLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [telLabel setText:@"Tel:"];
    [telLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(areaLineView.mas_bottom).offset(5);
        make.leading.equalTo(areaLineView.mas_leading);
        make.width.equalTo(@(34));
        make.height.equalTo(@(44));
    }];
    
    UIButton *getCodeBtn = [UIButton new];
    [_backgroundView addSubview:getCodeBtn];
    [getCodeBtn setTitle:[ASLocalizeConfig localizedString:@"验证码"] forState:UIControlStateNormal];
    [getCodeBtn.layer setCornerRadius:5.0];
    [getCodeBtn setBackgroundColor:LOGO_COLOR];
    [getCodeBtn setTintColor:[UIColor whiteColor]];
    [getCodeBtn addTarget:self action:@selector(getVerCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    [getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(areaLineView.mas_bottom).offset(13);
        make.trailing.equalTo(_backgroundView.mas_trailing).offset(-10);
        make.width.equalTo(@(80));
        make.height.equalTo(@(28));
    }];
    
    _txtPhoneNumber = [UITextField new];
    [_txtPhoneNumber setPlaceholder:[ASLocalizeConfig localizedString:@"请输入手机号码"]];
    //    _txtPhone.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;//垂直居下
    //    [_txtPhone setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [_txtPhoneNumber setDelegate:self];
    [_backgroundView addSubview:_txtPhoneNumber];
    [_txtPhoneNumber setBorderStyle:UITextBorderStyleNone];
    [_txtPhoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(telLabel.mas_top);
        make.leading.equalTo(telLabel.mas_trailing);
        make.trailing.equalTo(getCodeBtn.mas_leading);
        make.height.equalTo(@(44));
    }];
    
    UIView *telLineView = [UIView new];
    [_backgroundView addSubview:telLineView];
    telLineView.backgroundColor = [UIColor lightGrayColor];
    [telLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(telLabel.mas_bottom).offset(2);
        make.leading.equalTo(areaLineView.mas_leading);
        make.trailing.equalTo(areaLineView.mas_trailing);
        make.height.equalTo(@(1));
    }];
    
    //----验证码
    UILabel *verificationLb = [UILabel new];
    [_backgroundView addSubview:verificationLb];
    [verificationLb setNumberOfLines:3];
    [verificationLb setLineBreakMode:NSLineBreakByWordWrapping];
    [verificationLb setText:[ASLocalizeConfig localizedString:@"验证码:"]];
    [verificationLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(telLineView.mas_bottom).offset(5);
        make.leading.equalTo(telLabel.mas_leading);
        make.width.equalTo(@(100));
        make.height.equalTo(telLabel.mas_height);
    }];
    
    
    _txtVerification = [UITextField new];
    [_txtVerification setPlaceholder:[ASLocalizeConfig localizedString:@"请输入验证码"]];
    [_txtVerification setDelegate:self];
    [_backgroundView addSubview:_txtVerification];
    [_txtVerification setBorderStyle:UITextBorderStyleNone];
    [_txtVerification mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(telLineView.mas_bottom).offset(5);
        make.leading.equalTo(verificationLb.mas_trailing);
        make.trailing.equalTo(telLineView.mas_trailing);
        make.height.equalTo(@(44));
    }];
    
    UIView *codeLineView = [UIView new];
    [_backgroundView addSubview:codeLineView];
    codeLineView.backgroundColor = [UIColor lightGrayColor];
    [codeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(verificationLb.mas_bottom).offset(2);
        make.leading.equalTo(telLineView.mas_leading);
        make.trailing.equalTo(telLineView.mas_trailing);
        make.height.equalTo(@(1));
    }];
    
    //----password
    
    UILabel *passwordLb = [UILabel new];
    [_backgroundView addSubview:passwordLb];
    [passwordLb setNumberOfLines:3];
    [passwordLb setLineBreakMode:NSLineBreakByWordWrapping];
    [passwordLb setText:[ASLocalizeConfig localizedString:@"密码:"]];
    [passwordLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(codeLineView.mas_bottom).offset(5);
        make.leading.equalTo(codeLineView.mas_leading);
        make.width.equalTo(@(90));
        make.height.equalTo(verificationLb.mas_height);
    }];
    
    _txtpassword = [UITextField new];
    [_txtpassword setPlaceholder:[ASLocalizeConfig localizedString:@"请输入密码"]];
    [_txtpassword setDelegate:self];
    [_backgroundView addSubview:_txtpassword];
    [_txtpassword setBorderStyle:UITextBorderStyleNone];
    [_txtpassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(codeLineView.mas_bottom).offset(5);
        make.leading.equalTo(passwordLb.mas_trailing);
        make.trailing.equalTo(codeLineView.mas_trailing);
        make.height.equalTo(passwordLb.mas_height);
    }];
    
    UIView *passwordLineView = [UIView new];
    [_backgroundView addSubview:passwordLineView];
    passwordLineView.backgroundColor = [UIColor lightGrayColor];
    [passwordLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordLb.mas_bottom).offset(2);
        make.leading.equalTo(passwordLb.mas_leading);
        make.trailing.equalTo(_txtpassword.mas_trailing);
        make.height.equalTo(@(1));
    }];
    
    UIButton *createBtn = [UIButton new];
    [_backgroundView addSubview:createBtn];
    [createBtn setTitle:[ASLocalizeConfig localizedString:@"创建账号"] forState:UIControlStateNormal];
    [createBtn.layer setCornerRadius:22.0];
    [createBtn setBackgroundColor:LOGO_COLOR];
    [createBtn setTintColor:[UIColor whiteColor]];
    [createBtn addTarget:self action:@selector(createAccountBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_backgroundView.mas_bottom);
        make.leading.equalTo(_backgroundView.mas_leading).offset(20);
        make.trailing.equalTo(_backgroundView.mas_trailing).offset(-20);
        make.height.equalTo(@(40));
    }];
    
    UIButton *mailRegBtn = [UIButton new];
    [self.view addSubview:mailRegBtn];
    [mailRegBtn setTitle:[ASLocalizeConfig localizedString:@"进入"] forState:UIControlStateNormal];
    [mailRegBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [mailRegBtn.layer setCornerRadius:5.0];
//    [mailRegBtn setBackgroundColor:ASSIST_COLOR];
//    [mailRegBtn setTintColor:[UIColor whiteColor]];
    [mailRegBtn addTarget:self action:@selector(mailboxLoginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [mailRegBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backgroundView.mas_bottom).offset(2);
        make.trailing.equalTo(_backgroundView.mas_trailing).offset(-20);
        make.width.equalTo(@(80));
        make.height.equalTo(@(40));
    }];
    
    
}

-(void)selectAreaView{
    //选择区域码的表格
    _areaTableView = [[UITableView alloc]init];
    [_backgroundView addSubview:_areaTableView];
    [_areaTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backgroundView.mas_top).offset(54);
        make.leading.equalTo(_backgroundView.mas_leading).offset(6);
        make.trailing.equalTo(_backgroundView.mas_trailing);
        make.height.equalTo(@(44));
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

#pragma mark - SecondViewControllerDelegate的方法
- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
{
    _data2=data;
    NSLog(@"the area data：%@,%@", data.areaCode,data.countryName);
    self.txtAreaCode = [NSString stringWithFormat:@"%@",data.areaCode];
    [_areaTableView reloadData];
}

#pragma mark - buttonAction
//获取手机验证码
-(void)getVerCodeAction:(UIButton *)sender{
    NSString *zone = [_txtAreaCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *phoneNumber = _txtPhoneNumber.text;
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"数据加载中..."]];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *phoneUrl = [NSString stringWithFormat:@"%@",URL_VERIFICATION_PHONE_URL];
    NSDictionary *parameters = @{@"tel":phoneNumber,@"tel_area":zone};
    [manager POST:phoneUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (responseObject != nil) {
            [self stopMBProgressHUD];
            NSString *registerReturn = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *dataRegReturn = [registerReturn dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dictRegReturn = [NSJSONSerialization JSONObjectWithData:dataRegReturn options:NSJSONReadingMutableLeaves error:&error];
            NSLog(@"%@",dictRegReturn);
            NSString *sRegReturnCode = [dictRegReturn objectForKey:@"code"];
            NSInteger iRegReturnCode = [sRegReturnCode intValue];
            NSString *echo = @"";
            if(iRegReturnCode != 0) {
                if(iRegReturnCode == 1) {
                    echo = [ASLocalizeConfig localizedString:@"注册失败"];;
                }
                else if(iRegReturnCode == 2) {
                    echo = [ASLocalizeConfig localizedString:@"邮箱格式错误"];
                }
                else if(iRegReturnCode == 3) {
                    echo = [ASLocalizeConfig localizedString:@"手机格式错误"];
                }
                else if(iRegReturnCode == 4) {
                    echo = [ASLocalizeConfig localizedString:@"用户名格式错误"];
                }
                else {
                    echo = [ASLocalizeConfig localizedString:@"未定义"];
                }
            } else {
                echo = [ASLocalizeConfig localizedString:@"验证成功，可以注册"];
                //发送手机验证码
                [self sendCodeToPhoneWithPhoneNumber:phoneNumber andZone:zone];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
    }];
}
//发送验证码到手机
-(void)sendCodeToPhoneWithPhoneNumber:(NSString *)phoneNumber andZone:(NSString *)zone{
//customIdentifier 为自定义短信标识。需从官网申请
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phoneNumber zone:zone customIdentifier:nil result:^(NSError *error) {
        [self stopMBProgressHUD];
        if (!error) {
            //无错误，则此时手机收到短信验证码
        }else{ //有错误
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:  NSLocalizedString(@"codesenderrtitle", nil) message:[NSString stringWithFormat:@"状态码：%zi ,错误描述：%@",error.code,error.domain] delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil,nil];
            [alert show];
        }
    }];

}
//创建账号
-(void)createAccountBtnAction:(UIButton *)sender{
    if (![ASValidate telephone:_txtPhoneNumber.text]) {
        return;
    }
    [SMSSDK enableAppContactFriends:NO];
    [self startMBProgressHUDWithText:[ASLocalizeConfig localizedString:@"数据加载中..."]];
    NSString *pwd = _txtpassword.text;
    NSString *phoneNumber = _txtPhoneNumber.text;
    NSString *verifictionCode = _txtVerification.text;
    NSString *zone = [_txtAreaCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
//    1.先进行验证码比对
    [SMSSDK commitVerificationCode:verifictionCode phoneNumber:phoneNumber zone:zone result:^(NSError *error) {
        if (error) {
            [self stopMBProgressHUD];
            NSLog(@"验证失败");
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"verifycodeerrormsg", nil)];
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycodeerrortitle", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
            [alert show];
            
        }else{ //验证成功
            NSDictionary *parameters = @{@"account":phoneNumber,@"tel":phoneNumber,@"tel_area":zone,@"password":pwd};
            [self registerToAduroSmart:parameters];
        }    
    }];
//    NSDictionary *parameters = @{@"tel":phoneNumber,@"tel_area":zone,@"password":pwd};
//    [self registerToAduroSmart:parameters];
}

-(void)registerToAduroSmart:(NSDictionary *)parameters{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *phoneUrl = [NSString stringWithFormat:@"%@",URL_REGISTER_PHONE_URL];
    [manager POST:phoneUrl parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) { // _Nonnull 表示可以为空
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
                    echo = [ASLocalizeConfig localizedString:@"注册失败"];;
                }
                else if(iRegReturnCode == 2) {
                    echo = [ASLocalizeConfig localizedString:@"邮箱格式错误"];
                }
                else if(iRegReturnCode == 3) {
                    echo = [ASLocalizeConfig localizedString:@"手机格式错误"];
                }
                else if(iRegReturnCode == 4) {
                    echo = [ASLocalizeConfig localizedString:@"用户名格式错误"];
                }
                else {
                    echo = [ASLocalizeConfig localizedString:@"未定义"];
                }
            } else {
                echo = [ASLocalizeConfig localizedString:@"注册成功,请登录"];
            }
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"regreturninfotitle", nil) message:echo delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
            [alert show];
            //返回登录页面
//            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        [self stopMBProgressHUD];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"loginreturninfotitle"] message:[ASLocalizeConfig localizedString:@"网络出错了,请检查网络后重试!"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"sure"] otherButtonTitles:nil, nil];
        [alert show];
    }];
    
}

//切换邮箱登录
-(void)mailboxLoginBtnAction:(UIButton *)sender{
    ASMailRegisterViewController *mailRegVC = [[ASMailRegisterViewController alloc] init];
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
