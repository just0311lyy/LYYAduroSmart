//
//  ASDeviceDetailViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/19.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDeviceDetailViewController.h"
#import "ASGlobalDataObject.h"
#import "NSString+Wrapper.h"

#define NOTI_FEIBIT_CHANGE_PICKER_OF_COLOR @"NOTI_FEIBIT_CHANGE_PICKER_OF_COLOR"
#define NOTI_FEIBIT_CHANGE_DEVICE_LEVEL @"NOTI_FEIBIT_CHANGE_DEVICE_LEVEL"

#define TOP_COLOR_VIEW_HEIGHT 130

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define cptRED 0
#define cptGREEN 1
#define cptBLUE 2

@interface ASDeviceDetailViewController (){
    UIColor *_selectColor;
    BOOL _sendXY_A;
    BOOL _sendXY_B;
    BOOL _sendXY_C;
    BOOL _sendHSV;
}
@end

@implementation ASDeviceDetailViewController



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *navImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_ADURO_WIDTH, 64)];
    [self.view addSubview:navImgView];
    [navImgView setImage:[UIImage imageNamed:@"nav_bg"]];
    
    self.title = [NSString stringWithFormat:@"%@",[NSString changeName:_aduroDeviceInfo.deviceName]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self loadColorView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePickerColorWithNoti:) name:NOTI_FEIBIT_CHANGE_PICKER_OF_COLOR object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDeviceLevelWithNoti:) name:NOTI_FEIBIT_CHANGE_DEVICE_LEVEL object:nil];
    _sendHSV = YES;
    
    _manager = [DeviceManager sharedManager];
}

- (void)loadColorView
{
    //导航栏左按钮
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backBtnPress) forControlEvents:UIControlEventTouchUpInside];
    leftBarBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
//    //导航栏右按钮
//    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBarBtn setImage:[UIImage imageNamed:@"save_nav"] forState:UIControlStateNormal];
//    [rightBarBtn addTarget:self action:@selector(saveBtnPress) forControlEvents:UIControlEventTouchUpInside];
//    rightBarBtn.frame = CGRectMake(0, 0, 30, 30);
//    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
//    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    //--按钮栏
    _topColorBtnView = [UIView new];
    _topColorBtnView.backgroundColor = LOGO_COLOR;
    [self.view addSubview:_topColorBtnView];
    [_topColorBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(TOP_COLOR_VIEW_HEIGHT));
    }];
    //中间按钮
    _whiteBtn = [UIButton new];
    [_topColorBtnView addSubview:_whiteBtn];
    [_whiteBtn setImage:[UIImage imageNamed:@"temperature_btn"] forState:UIControlStateNormal];
    [_whiteBtn addTarget:self action:@selector(whiteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_whiteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topColorBtnView.mas_top).offset(10);
        make.leading.equalTo(_topColorBtnView.mas_centerX).offset(30);
        make.width.equalTo(@(75));
        make.height.equalTo(_whiteBtn.mas_width);
    }];
    UILabel *whiteLb = [UILabel new];
    [_topColorBtnView addSubview:whiteLb];
    [whiteLb setTextAlignment:NSTextAlignmentCenter];
    [whiteLb setFont:[UIFont systemFontOfSize:14]];
    [whiteLb setText:[ASLocalizeConfig localizedString:@"色温"]];
    [whiteLb setTextColor:[UIColor blackColor]];
    [whiteLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_whiteBtn.mas_bottom).offset(5);
        make.leading.equalTo(_whiteBtn.mas_leading).offset(-8);
        make.trailing.equalTo(_whiteBtn.mas_trailing).offset(8);
        make.height.equalTo(@(25));
    }];
    //左边按钮
    _colorBtn = [UIButton new];
    [_topColorBtnView addSubview:_colorBtn];
    [_colorBtn setImage:[UIImage imageNamed:@"color_selected_btn"] forState:UIControlStateNormal];
    [_colorBtn addTarget:self action:@selector(colorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_colorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_topColorBtnView.mas_centerX).offset(-30);
        make.centerY.equalTo(_whiteBtn.mas_centerY);
        make.width.equalTo(_whiteBtn.mas_width);
        make.height.equalTo(_colorBtn.mas_width);
    }];
    UILabel *colorLb = [UILabel new];
    [_topColorBtnView addSubview:colorLb];
    [colorLb setTextAlignment:NSTextAlignmentCenter];
    [colorLb setFont:[UIFont systemFontOfSize:14]];
    [colorLb setText:[ASLocalizeConfig localizedString:@"色彩"]];
    [colorLb setTextColor:[UIColor blackColor]];
    [colorLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(whiteLb.mas_top);
        make.leading.equalTo(_colorBtn.mas_leading);
        make.trailing.equalTo(_colorBtn.mas_trailing);
        make.height.equalTo(@(25));
    }];

    //右边按钮
//    _defaultBtn = [UIButton new];
//    [_topColorBtnView addSubview:_defaultBtn];
//    [_defaultBtn setImage:[UIImage imageNamed:@"custom_btn"] forState:UIControlStateNormal];
//    [_defaultBtn addTarget:self action:@selector(defaultButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_defaultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(_whiteBtn.mas_trailing).offset(30);
//        make.centerY.equalTo(_whiteBtn.mas_centerY);
//        make.width.equalTo(_whiteBtn.mas_width);
//        make.height.equalTo(_defaultBtn.mas_width);
//    }];
//    UILabel *defaultLb = [UILabel new];
//    [_topColorBtnView addSubview:defaultLb];
//    [defaultLb setTextAlignment:NSTextAlignmentCenter];
//    [defaultLb setFont:[UIFont systemFontOfSize:14]];
//    [defaultLb setText:[ASLocalizeConfig localizedString:@"默认"]];
//    [defaultLb setTextColor:[UIColor blackColor]];
//    [defaultLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(whiteLb.mas_top);
//        make.leading.equalTo(_defaultBtn.mas_leading);
//        make.trailing.equalTo(_defaultBtn.mas_trailing);
//        make.height.equalTo(@(25));
//    }];

//    //亮度调节按钮
//    _alphaSlider = [[UISlider alloc]init];
//    [_topColorBtnView addSubview:_alphaSlider];
//    [_alphaSlider setMinimumValue:0];
//    [_alphaSlider setMaximumValue:1];
//    [_alphaSlider setValue:1 animated:NO];
//    [_alphaSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
//    [_alphaSlider addTarget:self action:@selector(lampAlphaSliderAction:) forControlEvents:UIControlEventValueChanged];
//    [_alphaSlider mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(_topColorBtnView.mas_leading).offset(60);
//        make.trailing.equalTo(_topColorBtnView.mas_trailing).offset(-60);
//        make.height.equalTo(@(20));
//        make.bottom.equalTo(_topColorBtnView.mas_bottom).offset(-5);
//    }];
    
    // ----- 色温视图
    _colorTemperatureView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_COLOR_VIEW_HEIGHT, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - TOP_COLOR_VIEW_HEIGHT - 64)];
    [self.view addSubview:_colorTemperatureView];
    //色温调节
    _colorTemperaturePicker = [[InfColorBarPicker alloc] initWithFrame:CGRectMake(0, 0, _colorTemperatureView.frame.size.width, _colorTemperatureView.frame.size.height)];
    [_colorTemperaturePicker setHiddenIndicator:YES];
    [_colorTemperatureView addSubview:_colorTemperaturePicker];
    [_colorTemperaturePicker setDelegate:self];
    [_colorTemperatureView setHidden:YES];
    
    // ----- 色彩视图
    _colorView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_COLOR_VIEW_HEIGHT, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - TOP_COLOR_VIEW_HEIGHT - 64)];
    [self.view addSubview:_colorView];

    //色彩调节
    _colorPicker = [[InfColorSquarePicker alloc] init];
//    [self changePickerColorWithDeviceInfo:self.aduroDeviceInfo];
    [_colorPicker setDelegate:self];
    [_colorPicker setBackgroundColor:[UIColor blackColor]];
    [_colorPicker setSenceImage:[UIImage imageNamed:@"RGB_pattern"]];
    [_colorView addSubview:_colorPicker];
    [_colorPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_colorView.mas_top);
        make.leading.equalTo(_colorView.mas_leading);
        make.trailing.equalTo(_colorView.mas_trailing);
        make.bottom.equalTo(_colorView.mas_bottom);
    }];
    
    // ----- 默认视图
    _defaultView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_COLOR_VIEW_HEIGHT, SCREEN_ADURO_WIDTH, SCREEN_ADURO_HEIGHT - TOP_COLOR_VIEW_HEIGHT - 64)];
    [self.view addSubview:_defaultView];
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = _defaultView.bounds;
//    gradient.startPoint = CGPointMake(0, 1);
//    gradient.endPoint = CGPointMake(0, 0);
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[LOGO_COLOR CGColor], nil];
//    [_defaultView.layer insertSublayer:gradient atIndex:0];
    [_defaultView setHidden:YES];
    //默认色彩调节
    _defaultPicker = [[InfColorSquarePicker alloc] init];
//    [self changePickerColorWithDeviceInfo:self.aduroDeviceInfo];
    [_defaultPicker setDelegate:self];
    [_defaultPicker setBackgroundColor:[UIColor clearColor]];
    [_defaultPicker setNewSenceImage:[UIImage imageNamed:@"wheel"]];
    [_defaultView addSubview:_defaultPicker];
    [_defaultPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_defaultView.mas_top);
        make.leading.equalTo(_defaultView.mas_leading);
        make.trailing.equalTo(_defaultView.mas_trailing);
        make.bottom.equalTo(_defaultView.mas_bottom);
    }];

    //若为色温灯
    if (self.aduroDeviceInfo.deviceTypeID == DeviceTypeIDColorTemperatureLamp || self.aduroDeviceInfo.deviceTypeID == DeviceTypeIDColorTemperatureLampJZGD) {
        [_colorView setHidden:YES];  //色彩视图隐藏
        [_colorTemperatureView setHidden:NO];  //色温视图显示
        _colorBtn.userInteractionEnabled=NO; //色彩按钮不可点击
    }

}

-(void)changePickerColorWithNoti:(NSNotification *)noti{
        if (!_colorPicker.isCustomeImage) {
            NSDictionary *dict = [noti userInfo];
            AduroDevice *info = [dict objectForKey:@"FeibitDeviceInfo"];
            _aduroDeviceInfo = info;
            [self changePickerColorWithDeviceInfo:info];
        }
}

-(void)changePickerColorWithDeviceInfo:(AduroDevice *)info{
    if (!info) {
        return;
    }
    
    if (self.aduroDeviceInfo.deviceID != info.deviceID) {
        return;
    }
    CGFloat r=0.0f, g=0.0f, b=0.0f, h=0.0f, s=0.0f, v=0.0f, alpha=0.0f;
    
    h = (CGFloat)(info.deviceLightHue>>8);
    h = (h*1.0)/255.0f;
    s = (CGFloat)(info.deviceLightSat&0xff);
    s = (s*1.0f)/255.0f;
    v = (CGFloat)info.deviceLightLevel;
    alpha = v;
    v = (v*1.0f)/255.0f;
    
    if (r==0&&g==0&&b==0) {
        r=1;
        g=1;
        b=1;
    }
    //    isCallback = YES;
    
    _colorPicker.value = CGPointMake(h, 1-s);
}


#pragma mark - KZColorBarChangeDelegate
-(void)barColorChange:(UIColor *)color{
    [_colorTemperaturePicker setHiddenIndicator:NO];
    [_colorPicker setHiddenIndicator:YES];
    DDLogDebug(@"barColorChange = %@",color);
//    [_alphaSlider setMinimumTrackTintColor:color];
    [_topColorBtnView setBackgroundColor:color];
    _selectColor = color;
}
/**
 *  @author xingman.yi, 16-06-16 09:06:44
 *
 *  @brief 色温调节视图回调
 *
 *  @param hsv
 */
-(void)barHSVChange:(HSVType )hsv{
    //色温调节
    if (self.aduroDeviceInfo.deviceTypeID == 0x0110 || self.aduroDeviceInfo.deviceTypeID == 0x0220) {
        return;
    }
    [_colorTemperaturePicker setHiddenIndicator:NO];
    [_colorPicker setHiddenIndicator:YES];
    [self setDeviceHSV:hsv];
    
}

// adurosmartSDK 设置设备色温
-(void)barColorTemperature:(CGFloat)colorTemperature{
    if (self.aduroDeviceInfo.deviceTypeID == 0x0110 || self.aduroDeviceInfo.deviceTypeID == 0x0220) { //彩灯 或者 色温灯
        DDLogDebug(@"colorTemperature = %lf",colorTemperature);
        [_colorTemperaturePicker setHiddenIndicator:NO];
        [_colorPicker setHiddenIndicator:YES];
        NSInteger startColorTemp = 153;
        NSInteger colorTempRange = 500-startColorTemp;
        //colorTemperature * colorTempRange 越大 色温越冷（偏蓝色）
        UInt16 temper = 500 - colorTemperature * colorTempRange;
        [self.aduroDeviceInfo setDeviceLightColorTemperature:temper];
        
        [_manager updateDeviceColorTemperature:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"调节色温返回 = %d",(int)code);
        }];

    }
    
//    if (self.aduroDeviceInfo.deviceID ==[NSString stringWithFormat:@"71770"]) {
//        NSInteger startColorTemp = 153;
//        NSInteger colorTempRange = 500-startColorTemp;
//        UInt16 temper = colorTemperature * colorTempRange + startColorTemp;
//        
//        [self.aduroDeviceInfo setDeviceLightColorTemperature:temper];
//        
//        [_manager updateDeviceColorTemperature:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
//            NSLog(@"调节色温返回 = %d",(int)code);
//        }];
//    }
}

#pragma mark - KZColorPickerColorChangeDelegate
-(void)pickerHSVChange:(HSVType)hsv{
    [_colorTemperaturePicker setHiddenIndicator:YES];
    [_colorPicker setHiddenIndicator:NO];
    
    if (_sendHSV) {
        [self setDeviceHSV:hsv];
    }
}

-(void)pickerColorChange:(UIColor *)color{
    NSLog(@"color = %@",color);
//    [_alphaSlider setMinimumTrackTintColor:color];
    [_topColorBtnView setBackgroundColor:color];
    _selectColor = color;
    [self setColorToDevice:color];
}

#pragma mark 设置设备的颜色

-(void)setDeviceHSV:(HSVType)hsv{
    if ((self.aduroDeviceInfo.deviceTypeID != DeviceTypeIDColorTemperatureLamp)&&(self.aduroDeviceInfo.deviceTypeID != DeviceTypeIDColorTemperatureLampJZGD)) {
        [self.aduroDeviceInfo setDeviceLightHue:(hsv.h * 255.0f)];
        [self.aduroDeviceInfo setDeviceLightSat:(hsv.s * 255.0f)];
        DeviceManager *device = [DeviceManager sharedManager];
        //        _sendDataCount ++ ;
        //        [_labelTopTitle setText:[NSString stringWithFormat:@"sned %d",(int)_sendDataCount]];
        [device updateDeviceHueSat:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
            NSLog(@"updateDeviceHueSatBack = %d",code);
        }];
    }
}

-(void)setColorToDevice:(UIColor *)color{
    CGPoint xyPoint;
    //飞利浦的算法
    NSString *model;
    if (_sendXY_A) {
        model = @"LCT001";
    }else if (_sendXY_B) {
        model = @"LLC001";
    }else if (_sendXY_C) {
        model = @"";
    }else{
        return;
    }
    
    xyPoint = [ASDeviceDetailViewController calculateXY:color forModel:model];
    NSLog(@"x = %lf,y = %lf,color = %@",xyPoint.x,xyPoint.y,color);
    [h setText:[NSString stringWithFormat:@"x=%0.2lf",xyPoint.x]];
    [s setText:[NSString stringWithFormat:@"y=%0.2lf",xyPoint.y]];
    UInt16 x = (UInt16)(xyPoint.x*65536.0f);
    UInt16 y = (UInt16)(xyPoint.y*65536.0f);
    
    
    if (self.aduroDeviceInfo) {
        [self.aduroDeviceInfo setDeviceLightX:x];
        [self.aduroDeviceInfo setDeviceLightY:y];
        DeviceManager *device = [DeviceManager sharedManager];
        [device updateDeviceColorToXY:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"调节Device xy = %d",(int)code);
        }];
    }
    if (self.currentAduroGroup) {
        GroupManager *group = [GroupManager sharedManager];
        [group ctrlGroup:self.currentAduroGroup xValue:x yValue:y completionHandler:^(AduroSmartReturnCode code) {
            DLog(@"调节Group xy = %d",(int)code);
        }];
    }
    
}

+ (CGPoint)calculateXY:(UIColor *)color forModel:(NSString*)model {
    CGColorRef cgColor = [color CGColor];
    
    const CGFloat *components = CGColorGetComponents(cgColor);
    long numberOfComponents = CGColorGetNumberOfComponents(cgColor);
    
    // Default to white
    CGFloat red = 1.0f;
    CGFloat green = 1.0f;
    CGFloat blue = 1.0f;
    
    if (numberOfComponents == 4) {
        // Full color
        red = components[0];
        green = components[1];
        blue = components[2];
    }
    else if (numberOfComponents == 2) {
        // Greyscale color
        red = green = blue = components[0];
    }
    
    // Apply gamma correction
    float r = (red   > 0.04045f) ? pow((red   + 0.055f) / (1.0f + 0.055f), 2.4f) : (red   / 12.92f);
    float g = (green > 0.04045f) ? pow((green + 0.055f) / (1.0f + 0.055f), 2.4f) : (green / 12.92f);
    float b = (blue  > 0.04045f) ? pow((blue  + 0.055f) / (1.0f + 0.055f), 2.4f) : (blue  / 12.92f);
    
    // Wide gamut conversion D65
    float X = r * 0.664511f + g * 0.154324f + b * 0.162028f;
    float Y = r * 0.283881f + g * 0.668433f + b * 0.047685f;
    float Z = r * 0.000088f + g * 0.072310f + b * 0.986039f;
    
    float cx = X / (X + Y + Z);
    float cy = Y / (X + Y + Z);
    
    if (isnan(cx)) {
        cx = 0.0f;
    }
    
    if (isnan(cy)) {
        cy = 0.0f;
    }
    
    //Check if the given XY value is within the colourreach of our lamps.
    
    CGPoint xyPoint =  CGPointMake(cx,cy);
    NSArray *colorPoints = [self colorPointsForModel:model];
    BOOL inReachOfLamps = [self checkPointInLampsReach:xyPoint withColorPoints:colorPoints];
    
    if (!inReachOfLamps) {
        //It seems the colour is out of reach
        //let's find the closest colour we can produce with our lamp and send this XY value out.
        
        //Find the closest point on each line in the triangle.
        CGPoint pAB =[self getClosestPointToPoints:[self getPointFromValue:[colorPoints objectAtIndex:cptRED]] point2:[self getPointFromValue:[colorPoints objectAtIndex:cptGREEN]] point3:xyPoint];
        CGPoint pAC = [self getClosestPointToPoints:[self getPointFromValue:[colorPoints objectAtIndex:cptBLUE]] point2:[self getPointFromValue:[colorPoints objectAtIndex:cptRED]] point3:xyPoint];
        CGPoint pBC = [self getClosestPointToPoints:[self getPointFromValue:[colorPoints objectAtIndex:cptGREEN]] point2:[self getPointFromValue:[colorPoints objectAtIndex:cptBLUE]] point3:xyPoint];
        
        //Get the distances per point and see which point is closer to our Point.
        float dAB = [self getDistanceBetweenTwoPoints:xyPoint point2:pAB];
        float dAC = [self getDistanceBetweenTwoPoints:xyPoint point2:pAC];
        float dBC = [self getDistanceBetweenTwoPoints:xyPoint point2:pBC];
        
        float lowest = dAB;
        CGPoint closestPoint = pAB;
        
        if (dAC < lowest) {
            lowest = dAC;
            closestPoint = pAC;
        }
        if (dBC < lowest) {
            lowest = dBC;
            closestPoint = pBC;
        }
        
        //Change the xy value to a value which is within the reach of the lamp.
        cx = closestPoint.x;
        cy = closestPoint.y;
    }
    
    return CGPointMake(cx, cy);
}

/**
 * Method to see if the given XY value is within the reach of the lamps.
 *
 * @param p the point containing the X,Y value
 * @return true if within reach, false otherwise.
 */
+ (BOOL)checkPointInLampsReach:(CGPoint)p withColorPoints:(NSArray*)colorPoints {
    CGPoint red =   [self getPointFromValue:[colorPoints objectAtIndex:cptRED]];
    CGPoint green = [self getPointFromValue:[colorPoints objectAtIndex:cptGREEN]];
    CGPoint blue =  [self getPointFromValue:[colorPoints objectAtIndex:cptBLUE]];
    
    CGPoint v1 = CGPointMake(green.x - red.x, green.y - red.y);
    CGPoint v2 = CGPointMake(blue.x - red.x, blue.y - red.y);
    
    CGPoint q = CGPointMake(p.x - red.x, p.y - red.y);
    
    float s = [self crossProduct:q point2:v2] / [self crossProduct:v1 point2:v2];
    float t = [self crossProduct:v1 point2:q] / [self crossProduct:v1 point2:v2];
    
    if ( (s >= 0.0f) && (t >= 0.0f) && (s + t <= 1.0f)) {
        return true;
    }
    else {
        return false;
    }
}

+ (NSArray *)colorPointsForModel:(NSString*)model {
    NSMutableArray *colorPoints = [NSMutableArray array];
    
    NSArray *hueBulbs = [NSArray arrayWithObjects:@"LCT001" /* Hue A19 */,
                         @"LCT002" /* Hue BR30 */,
                         @"LCT003" /* Hue GU10 */, nil];
    NSArray *livingColors = [NSArray arrayWithObjects:  @"LLC001" /* Monet, Renoir, Mondriaan (gen II) */,
                             @"LLC005" /* Bloom (gen II) */,
                             @"LLC006" /* Iris (gen III) */,
                             @"LLC007" /* Bloom, Aura (gen III) */,
                             @"LLC011" /* Hue Bloom */,
                             @"LLC012" /* Hue Bloom */,
                             @"LLC013" /* Storylight */,
                             @"LST001" /* Light Strips */, nil];
    if ([hueBulbs containsObject:model]) {
        // Hue bulbs color gamut triangle
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(0.674F, 0.322F)]];     // Red
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(0.408F, 0.517F)]];     // Green
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(0.168F, 0.041F)]];     // Blue
        
    }
    else if ([livingColors containsObject:model]) {
        // LivingColors color gamut triangle
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(0.703F, 0.296F)]];     // Red
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(0.214F, 0.709F)]];     // Green
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(0.139F, 0.081F)]];     // Blue
    }
    else {
        // Default construct triangle wich contains all values
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(1.0F, 0.0F)]];         // Red
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(0.0F, 1.0F)]];         // Green
        [colorPoints addObject:[self getValueFromPoint:CGPointMake(0.0F, 0.0F)]];         // Blue
    }
    return colorPoints;
}

/**
 * Find the closest point on a line.
 * This point will be within reach of the lamp.
 *
 * @param A the point where the line starts
 * @param B the point where the line ends
 * @param P the point which is close to a line.
 * @return the point which is on the line.
 */
+ (CGPoint)getClosestPointToPoints:(CGPoint)A point2:(CGPoint)B point3:(CGPoint)P {
    CGPoint AP = CGPointMake(P.x - A.x, P.y - A.y);
    CGPoint AB = CGPointMake(B.x - A.x, B.y - A.y);
    float ab2 = AB.x * AB.x + AB.y * AB.y;
    float ap_ab = AP.x * AB.x + AP.y * AB.y;
    
    float t = ap_ab / ab2;
    
    if (t < 0.0f) {
        t = 0.0f;
    }
    else if (t > 1.0f) {
        t = 1.0f;
    }
    
    CGPoint newPoint = CGPointMake(A.x + AB.x * t, A.y + AB.y * t);
    return newPoint;
}

+(CGPoint)getPointFromValue:(NSValue *)value{
    return [value CGPointValue];
}

/**
 * Find the distance between two points.
 *
 * @param one
 * @param two
 * @return the distance between point one and two
 */
+ (float)getDistanceBetweenTwoPoints:(CGPoint)one point2:(CGPoint)two {
    float dx = one.x - two.x; // horizontal difference
    float dy = one.y - two.y; // vertical difference
    float dist = sqrt(dx * dx + dy * dy);
    
    return dist;
}

/**
 * Calculates crossProduct of two 2D vectors / points.
 *
 * @param p1 first point used as vector
 * @param p2 second point used as vector
 * @return crossProduct of vectors
 */
+ (float)crossProduct:(CGPoint)p1 point2:(CGPoint)p2 {
    return (p1.x * p2.y - p1.y * p2.x);
}

+(NSValue *)getValueFromPoint:(CGPoint)point{
    return [NSValue valueWithCGPoint:point];
}

//slider控制亮度
-(void)lampAlphaSliderAction:(UISlider *)sender{
    DDLogDebug(@"UISlider.value = %lf",sender.value);
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        [[JNI_iOS_SDK defaultJNI_iOS_SDK] setDeviceLevelByDeviceUID:self.currentDeviceInfo.uId value:sender.value*255.0f];
    //    });
    
    [self.aduroDeviceInfo setDeviceLightLevel:sender.value*255];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_manager updateDeviceLevel:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
            DDLogInfo(@"AduroSmartReturnCode = %lu",code);
        }];
    });
}






//-(void)changeDeviceLevelWithNoti:(NSNotification *)noti{
//    NSDictionary *dict = [noti userInfo];
//    AduroDevice *info = [dict objectForKey:@"FeibitDeviceInfo"];
//    self.aduroDeviceInfo.deviceLightLevel = info.deviceLightLevel;
//    CGFloat deviceLevel = info.deviceLightLevel;
//    CGFloat value = deviceLevel*1.0/255.0f;
////    [_alphaSlider setValue:value animated:YES];
//}


-(void)deleteCurrentDevice{
    if (self.aduroDeviceInfo) {
        //删除分组中包含的设备
        for (NSInteger i=0; i<[_globalGroupArray count]; i++) {
            AduroGroup *oneGroup = [_globalGroupArray objectAtIndex:i];
//            for (NSInteger j=0; j<[oneGroup.deviceArray count]; j++) {
//                DeviceInfo *deviceOfGroup = [oneGroup.deviceArray objectAtIndex:j];
//                if (deviceOfGroup.uId == self.currentDeviceInfo.uId) {
//                    [oneGroup.deviceArray removeObjectAtIndex:j];
//                }
//            }
        }
        //删除场景中包含的设备
        for (NSInteger i=0; i<[_globalSceneArray count]; i++) {
            AduroScene *oneSceneData = [_globalSceneArray objectAtIndex:i];
//            for (NSInteger j=0; j<[oneSenceData.senceDatas count]; j++) {
//                SenceData *deviceOfSence = [oneSenceData.senceDatas objectAtIndex:j];
//                if (deviceOfSence.uID == self.currentDeviceInfo.uId) {
//                    [oneSenceData.senceDatas removeObjectAtIndex:j];
//                }
//            }
        }
        //设备列表
        for (NSInteger i=0; i<[_globalDeviceArray count]; i++) {
            AduroDevice *device = [_globalDeviceArray objectAtIndex:i];
            if (device.deviceID == self.aduroDeviceInfo.deviceID) {
                [_globalDeviceArray removeObjectAtIndex:i];
            }
        }
        //从当前网关删除指定设备
        [_manager deleteDevice:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
            NSLog(@"deleteDeviceReturnCode = %d",(int)code);
        }];
    }
}


-(void)backBtnPress{
    if ([self.delegate respondsToSelector:@selector(selectViewController:didSelectColor:)]) {
        [self.delegate selectViewController:self didSelectColor:_selectColor];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)colorButtonAction:(UIButton *)sender{
    [_colorBtn setImage:[UIImage imageNamed:@"color_selected_btn"] forState:UIControlStateNormal];
    [_whiteBtn setImage:[UIImage imageNamed:@"temperature_btn"] forState:UIControlStateNormal];
    [_defaultBtn setImage:[UIImage imageNamed:@"custom_btn"] forState:UIControlStateNormal];
    [_colorView setHidden:NO];
    [_colorTemperatureView setHidden:YES];
    [_defaultView setHidden:YES];
}

-(void)whiteButtonAction:(UIButton *)sender{
    [_colorBtn setImage:[UIImage imageNamed:@"color_btn"] forState:UIControlStateNormal];
    [_whiteBtn setImage:[UIImage imageNamed:@"temperature_selected_btn"] forState:UIControlStateNormal];
    [_defaultBtn setImage:[UIImage imageNamed:@"custom_btn"] forState:UIControlStateNormal];
    [_colorView setHidden:YES];
    [_colorTemperatureView setHidden:NO];
    [_defaultView setHidden:YES];
}

-(void)defaultButtonAction:(UIButton *)sender{
    [_colorBtn setImage:[UIImage imageNamed:@"color_btn"] forState:UIControlStateNormal];
    [_whiteBtn setImage:[UIImage imageNamed:@"temperature_btn"] forState:UIControlStateNormal];
    [_defaultBtn setImage:[UIImage imageNamed:@"custom_selected_btn"] forState:UIControlStateNormal];
    [_colorView setHidden:YES];
    [_colorTemperatureView setHidden:YES];
    [_defaultView setHidden:NO];
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
