//
//  ASDeviceSelectCell.m
//  AduroSmart
//
//  Created by MacBook on 16/8/10.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDeviceSelectCell.h"
#import "NSString+Wrapper.h"
#import "QCheckBox.h"

@interface ASDeviceSelectCell ()<QCheckBoxDelegate>{
    UILabel *_deviceNameLabel;
    UILabel *_deviceDescriptionLabel;
    QCheckBox *_check; //设备选择
    AduroDevice *_aduroDeviceInfo;
    BOOL isOn;
    UIImageView *_deviceTypeImgView;
    UIImageView *_checkBoxImageView;
    
    UISlider *_alphaSlider;
    UISwitch *_onOffSwitch;
}
-(void)getCellView;
@end

@implementation ASDeviceSelectCell

@synthesize aduroDeviceInfo = _aduroDeviceInfo;

-(AduroDevice *)aduroDeviceInfo{
    return _aduroDeviceInfo;
}

-(void)setAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{
    if (_aduroDeviceInfo!=aduroDeviceInfo) {
        _aduroDeviceInfo = nil;
        _aduroDeviceInfo = aduroDeviceInfo;
        [_deviceNameLabel setText:[NSString stringWithFormat:@"%@",[NSString changeName:_aduroDeviceInfo.deviceName]]];
        //开关
        if (_aduroDeviceInfo.deviceSwitchState == DeviceSwitchStateOn) { //开启
            [_onOffSwitch setOn:YES];
        }else{
            [_onOffSwitch setOn:NO];
        }
        //亮度
        CGFloat deviceLevel = _aduroDeviceInfo.deviceLightLevel *1.0/255.0f;
        [_alphaSlider setValue:deviceLevel animated:YES];
        
        if (_aduroDeviceInfo.deviceTypeID == DeviceTypeIDHumanSensor) {
            if (_aduroDeviceInfo.deviceZoneType == DeviceZoneTypeContactSwitch) {
                if ([_aduroDeviceInfo.deviceName isEqualToString:@"CIE Device"]) {
                    _deviceNameLabel.text = @"Contact Switch";
                }
            }else if (_aduroDeviceInfo.deviceZoneType == DeviceZoneTypeMotionSensor){
                if ([_aduroDeviceInfo.deviceName isEqualToString:@"CIE Device"]) {
                    _deviceNameLabel.text = @"Motion Sensor";
                }
            }
        }
        
        NSString *strDeviceType = @"";
        switch (_aduroDeviceInfo.deviceTypeID)
        {
            case 0x0105://可调颜色灯,有调光、开关功能
            case 0x0102://彩灯
            case 0x0210://飞利浦彩灯
            {
                [_deviceTypeImgView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"彩灯"];
                break;
            }
            case 0x0110://色温灯
            case 0x0220:
            {
                [_deviceTypeImgView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"色温灯"];
                break;
            }
            case 0x0101://调光灯
            case 0x0100://强制改开关为灯泡
            {
                [_deviceTypeImgView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"调光灯"];
                break;
            }
            case DeviceTypeIDHumanSensor://海曼传感器
            {
                {
                    switch (_aduroDeviceInfo.deviceZoneType) {
                        case DeviceZoneTypeMotionSensor:
                        {
                            
                            strDeviceType = [ASLocalizeConfig localizedString:@"人体传感器"];
                            [_deviceTypeImgView setImage:[UIImage imageNamed:@"sensor_0014"]];
                            
                        }
                            break;
                        case DeviceZoneTypeContactSwitch:
                        {
                            strDeviceType = [ASLocalizeConfig localizedString:@"门磁传感器"];
                            [_deviceTypeImgView setImage:[UIImage imageNamed:@"sensor_0015"]];
                        }
                            break;
                        case DeviceZoneTypeVibrationMovementSensor:
                        {
                            strDeviceType = [ASLocalizeConfig localizedString:@"震动传感器"];
                            [_deviceTypeImgView setImage:[UIImage imageNamed:@"sensor"]];
                            
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                break;
            }
            case DeviceTypeIDSmartPlug://智能插座
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Smart Socket"];
                [_deviceTypeImgView setImage:[UIImage imageNamed:@"smart_plug"]];
                break;
            }
            case 0x0202:
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Curtain"];
                [_deviceTypeImgView setImage:[UIImage imageNamed:@"window_curtain"]];
                break;
            }
            case DeviceTypeIDLightingRemotes:
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Lighting Remotes"];
                [_deviceTypeImgView setImage:[UIImage imageNamed:@"light_remotes"]];
                break;
            }
            default:
            {
                break;
            }
        }
//        NSString *strDeviceStaus = [ASLocalizeConfig localizedString:@"离线"];
//        
//        switch (_aduroDeviceInfo.deviceNetState)
//        {
//            case 0x0000:
//            {
//                strDeviceStaus = [ASLocalizeConfig localizedString:@"离线"];
//                break;
//            }
//            case 0x0001:
//            case 0x0002:
//            case 0x0003:
//            {
//                strDeviceStaus = [ASLocalizeConfig localizedString:@"在线"];
//                break;
//            }
//            default:
//                break;
//        }
        [_deviceDescriptionLabel setText:[[NSString alloc] initWithFormat:@"%@-%x",strDeviceType,_aduroDeviceInfo.shortAdr]];
        
    }
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}

//设置设备是否被选中
-(void)setCheckboxChecked:(BOOL)isChecked{
    [_check setChecked:isChecked];
}

-(void)getCellView{
    UIView *cellView = [[UIView alloc]init];
    [self.contentView addSubview:cellView];
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASDeviceSelectCell getCellHeight]));
    }];
    
    //背景图
    UIImageView *imgView = [[UIImageView alloc] init];
    UIImage *img = [UIImage imageNamed:@"img_bg"];
    CGFloat top = 10; // 顶端盖高度
    CGFloat bottom = 10 ; // 底端盖高度
    CGFloat left = 15; // 左端盖宽度
    CGFloat right = 15; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    img = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    imgView.image = img;
    [cellView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cellView.mas_top);
        make.leading.equalTo(cellView.mas_leading);
        make.trailing.equalTo(cellView.mas_trailing);
        make.bottom.equalTo(cellView.mas_bottom);
    }];
    
    //房间图标
    _deviceTypeImgView = [UIImageView new];
    [imgView addSubview:_deviceTypeImgView];
    [_deviceTypeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imgView.mas_centerY);
        make.leading.equalTo(imgView.mas_leading).offset(10); //首部
        make.width.equalTo(@(45));
        make.height.equalTo(_deviceTypeImgView.mas_width);
    }];
    
    _check = [[QCheckBox alloc] initWithDelegate:self];
    [cellView addSubview:_check];
    [_check mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cellView.mas_centerY);
        make.trailing.equalTo(cellView.mas_trailing).offset(-10);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
    }];
   
    _deviceNameLabel = [[UILabel alloc]init];
    [_deviceNameLabel setFont:[UIFont systemFontOfSize:16]];
    [cellView addSubview:_deviceNameLabel];
    [_deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_top).offset(14);
        make.leading.equalTo(_deviceTypeImgView.mas_trailing).offset(5);
        make.height.equalTo(@(20));
        make.trailing.equalTo(_check.mas_leading);
    }];
    
    _deviceDescriptionLabel = [[UILabel alloc]init];
    [_deviceDescriptionLabel setFont:[UIFont systemFontOfSize:12]];
    [_deviceDescriptionLabel setTextColor:[UIColor grayColor]];
    [imgView addSubview:_deviceDescriptionLabel];
    [_deviceDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_deviceNameLabel.mas_bottom);
        make.leading.equalTo(_deviceNameLabel.mas_leading);
        make.trailing.equalTo(_check.mas_leading);
        make.height.equalTo(@(20));
    }];
    
    //----------
    _onOffSwitch = [UISwitch new];
    [cellView addSubview:_onOffSwitch];
    [_onOffSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_deviceTypeImgView.mas_centerY).offset(-16);
        make.trailing.equalTo(_check.mas_leading).offset(-5);
    }];
    
    [_onOffSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    _alphaSlider = [UISlider new];
    UIImage *yellowImg = [UIImage imageNamed:@"slider_yellow"];
    CGFloat sliderTop = 7; // 顶端盖高度
    CGFloat sliderBottom = 7 ; // 底端盖高度
    CGFloat sliderLeft = 20; // 左端盖宽度
    CGFloat sliderRight = 20; // 右端盖宽度
    UIEdgeInsets sliderInsets = UIEdgeInsetsMake(sliderTop, sliderLeft, sliderBottom, sliderRight);
    // 指定为拉伸模式，伸缩后重新赋值
    yellowImg = [yellowImg resizableImageWithCapInsets:sliderInsets resizingMode:UIImageResizingModeStretch];
    [_alphaSlider setMinimumTrackImage:yellowImg forState:UIControlStateNormal];
    [_alphaSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_gray"] forState:UIControlStateNormal];
    [_alphaSlider setThumbImage:[UIImage imageNamed:@"slider_btn"] forState:UIControlStateNormal];
    [_alphaSlider setThumbImage:[UIImage imageNamed:@"slider_btn"] forState:UIControlStateHighlighted];
    
    [cellView addSubview:_alphaSlider];
    [_alphaSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_deviceTypeImgView.mas_trailing).offset(20);
        make.trailing.equalTo(_deviceNameLabel.mas_trailing).offset(-20);
        make.height.equalTo(@(40));
        make.bottom.equalTo(cellView.mas_bottom).offset(-5);
    }];
    [_alphaSlider setMinimumValue:0];
    [_alphaSlider setMaximumValue:1];

    [_alphaSlider addTarget:self action:@selector(lampAlphaSliderAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //slider左边原点
    UIImageView *leftPointImgView = [[UIImageView alloc] init];
    [cellView addSubview:leftPointImgView];
    leftPointImgView.image = [UIImage imageNamed:@"slider_left"];
    [leftPointImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_alphaSlider.mas_centerY);
        make.trailing.equalTo(_alphaSlider.mas_leading);
        make.width.equalTo(@(20));
        make.height.equalTo(leftPointImgView.mas_width);
    }];
    //slider右边原点
    UIImageView *rightPointImgView = [[UIImageView alloc] init];
    [cellView addSubview:rightPointImgView];
    rightPointImgView.image = [UIImage imageNamed:@"slider_right"];
    [rightPointImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_alphaSlider.mas_centerY);
        make.leading.equalTo(_alphaSlider.mas_trailing);
        make.width.equalTo(@(20));
        make.height.equalTo(rightPointImgView.mas_width);
    }];

}

+(CGFloat)getCellHeight{
    return 100.f;
}

#pragma mark - QCheckBoxDelegate
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {
    NSLog(@"did tap on CheckBox:%@ checked:%d", checkbox.titleLabel.text, checked);
    
    [self.delegate sceneDeviceSelected:checked WithAduroDeviceInfo:self.aduroDeviceInfo];
}

-(void)switchAction:(UISwitch *)sender{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        _aduroDeviceInfo.deviceSwitchState = DeviceSwitchStateOn; //开启
    }else {
        _aduroDeviceInfo.deviceSwitchState = DeviceSwitchStateOff; //关闭
    }
    DeviceManager *device = [DeviceManager sharedManager];
    [device updateDeviceState:_aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
        NSLog(@"开关返回值 = %d",(int)code);
    }];
  
}

-(void)lampAlphaSliderAction:(UISlider *)sender{
    
//    if ([self.delegate respondsToSelector:@selector(lightDeviceChangeAlpha:)]) {
//        [self.delegate lightDeviceChangeAlpha:sender.value];
//    }
    [self.aduroDeviceInfo setDeviceLightLevel:sender.value*255];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DeviceManager *device = [DeviceManager sharedManager];
        [device updateDeviceLevel:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
            DDLogInfo(@"AduroSmartReturnCode = %d",code);
        }];
    });
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
