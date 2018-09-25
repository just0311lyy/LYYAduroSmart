//
//  ASDeviceCell.m
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.


#import "ASDeviceCell.h"
#import "ASDataBaseOperation.h"
#import "NSString+Wrapper.h"
@interface ASDeviceCell (){
    UILabel *_deviceNameLb;
    UILabel *_deviceTypeLb;
    UILabel *_deviceNetStateLb; //在线状态
    UIButton *_deviceSwitchBtn;
    UIButton *_deviceShowDetailBtn;
    //传感器状态显示
//    UILabel *_sensorStateLabel;
    UIImageView *_sensorStateImgView;
    //代表设备类型的图标
    UIImageView *_deviceTypeImageView;
    UISlider *_alphaSlider;
    UIImageView *_leftPointImgView;
    UIImageView *_rightPointImgView;
    //开关是否开启
    BOOL isOn;
    UIView *_cellView;

    AduroDevice *_aduroDeviceInfo;
    //智能插座设备
    UILabel *_voltageLb;
    UIButton *_VLb;
    UILabel *_currentLb;
    UIButton *_ALb;
    UILabel *_powerLb;
    UIButton *_WLb;
    UILabel *_freqLb;
    UIButton *_HzLb;
    UILabel *_PFLb;
    UIButton *_pLb;
}
-(void)getCellView;
@end
@implementation ASDeviceCell

@synthesize aduroDeviceInfo = _aduroDeviceInfo;
-(AduroDevice *)aduroDeviceInfo{
    return _aduroDeviceInfo;
}

-(void)setAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{
    if (_aduroDeviceInfo != aduroDeviceInfo) {
        _aduroDeviceInfo = nil;
        _aduroDeviceInfo = aduroDeviceInfo;
                
        [_deviceNameLb setText:[NSString stringWithFormat:@"%@",[NSString changeName:_aduroDeviceInfo.deviceName]]];

        if (_aduroDeviceInfo.deviceSwitchState == DeviceSwitchStateOn) {
            isOn = YES;
        }else{
            isOn = NO;
        }
        [self setSwitchButtonImage:isOn switchButton:_deviceSwitchBtn];
        [_deviceSwitchBtn setHidden:YES];
        [_voltageLb setHidden:YES];
        [_VLb setHidden:YES];
        [_currentLb setHidden:YES];
        [_ALb setHidden:YES];
        [_powerLb setHidden:YES];
        [_WLb setHidden:YES];
        [_freqLb setHidden:YES];
        [_HzLb setHidden:YES];
        [_PFLb setHidden:YES];
        [_pLb setHidden:YES];
        CGFloat offset = 0;
        NSString *strDeviceType = @"";
        
        [_deviceTypeImageView setImage:[UIImage imageNamed:@"unonline"]];

        switch (_aduroDeviceInfo.deviceTypeID)
        {
            case 0x0105://可调颜色灯,有调光、开关功能
            case 0x0102://彩灯
            case 0x0210://飞利浦彩灯
            case DeviceTypeIDColorLight:
            {
                [_deviceSwitchBtn setHidden:NO];
                [_deviceTypeImageView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"彩灯"];
                offset = 40;
                break;
            }
            case 0x0110://色温灯
            case 0x0220:
            {
                [_deviceSwitchBtn setHidden:NO];
                [_deviceTypeImageView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"色温灯"];
                offset = 40;
                break;
            }
            case 0x0101://调光灯
            case 0x0100://强制改开关为灯泡
            {
                [_deviceSwitchBtn setHidden:NO];
                [_deviceTypeImageView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"调光灯"];
                offset = 40;
                break;
            }
            case DeviceTypeIDHumanSensor://海曼传感器
            {
                [_deviceSwitchBtn setHidden:YES];
//                [_sensorStateLabel setHidden:NO];
                [_sensorStateImgView setHidden:NO];
                {
                    switch (_aduroDeviceInfo.deviceZoneType) {
                        case DeviceZoneTypeMotionSensor:
                        {
//                            if ([_aduroDeviceInfo.deviceName isEqualToString:@"CIE Device"]) {
//                                [_deviceNameLb setText:@"Motion Sensor"];
//                            }
                            strDeviceType = [ASLocalizeConfig localizedString:@"人体传感器"];
                            [_deviceTypeImageView setImage:[UIImage imageNamed:@"sensor_0014"]];
                            //人体红外 motion sensor
                            if (_aduroDeviceInfo.deviceSensorData == (0x01 + HEXADECIMAL_DATA_OFFSET)) {
//                                [_sensorStateLabel setText:@"Passing"];
                                [_sensorStateImgView setImage:[UIImage imageNamed:@"pir_cross"]];
                            }
                            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clearSensorStateLabel) userInfo:nil repeats:NO];
                        }
                            break;
                        case DeviceZoneTypeContactSwitch:
                        {
//                            if ([_aduroDeviceInfo.deviceName isEqualToString:@"CIE Device"]) {
//                                [_deviceNameLb setText:@"Contact Switch"];
//                            }
                            strDeviceType = [ASLocalizeConfig localizedString:@"门磁传感器"];
                            [_deviceTypeImageView setImage:[UIImage imageNamed:@"sensor_0015"]];
                            if (_aduroDeviceInfo.deviceSensorData == (0x01 + HEXADECIMAL_DATA_OFFSET)) {
//                                [_sensorStateLabel setText:@"Open"];
                                [_sensorStateImgView setImage:[UIImage imageNamed:@"door_open"]];
                            }
                            if (_aduroDeviceInfo.deviceSensorData == HEXADECIMAL_DATA_OFFSET) {
//                                [_sensorStateLabel setText:@"Close"];
                                [_sensorStateImgView setImage:[UIImage imageNamed:@"door_close"]];
                            }
                            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clearSensorStateLabel) userInfo:nil repeats:NO];
                        }
                            break;
                        case DeviceZoneTypeVibrationMovementSensor:
                        {
                            strDeviceType = [ASLocalizeConfig localizedString:@"震动传感器"];
                            [_deviceTypeImageView setImage:[UIImage imageNamed:@"sensor"]];
                            
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
                [_deviceSwitchBtn setHidden:NO];
                strDeviceType = [ASLocalizeConfig localizedString:@"Smart Socket"];
                [_deviceTypeImageView setImage:[UIImage imageNamed:@"smart_plug"]];
                offset = 80;
                [_voltageLb setHidden:NO];
                [_VLb setHidden:NO];
                [_currentLb setHidden:NO];
                [_ALb setHidden:NO];
                [_powerLb setHidden:NO];
                [_WLb setHidden:NO];
                [_freqLb setHidden:NO];
                [_HzLb setHidden:NO];
                [_PFLb setHidden:NO];
                [_pLb setHidden:NO];
                break;
            }
            case 0x0202:
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Curtain"];
                [_deviceTypeImageView setImage:[UIImage imageNamed:@"window_curtain"]];
                break;
            }
            case DeviceTypeIDLightingRemotes:
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Lighting Remotes"];
                [_deviceTypeImageView setImage:[UIImage imageNamed:@"light_remotes"]];
                [_deviceSwitchBtn setHidden:YES];
                break;
            }
            default:
            {
                break;
            }
        }
        //智能插座
        CGFloat rMSVoltage = _aduroDeviceInfo.electmeasVolatage;
        CGFloat rMSCurrent = _aduroDeviceInfo.electmeasCurrent;
        CGFloat activePower = _aduroDeviceInfo.electmeasPower;
        CGFloat aCFrequency = _aduroDeviceInfo.electmeasFrequency;
        CGFloat powerFactor = _aduroDeviceInfo.electmeasPowerFactor;
        [_VLb setTitle:[NSString stringWithFormat:@"%.0lf",rMSVoltage] forState:UIControlStateNormal];
        [_ALb setTitle:[NSString stringWithFormat:@"%.2lf",rMSCurrent] forState:UIControlStateNormal];
        [_WLb setTitle:[NSString stringWithFormat:@"%.2lf",activePower] forState:UIControlStateNormal];
        [_HzLb setTitle:[NSString stringWithFormat:@"%.0lf",aCFrequency] forState:UIControlStateNormal];
        [_pLb setTitle:[NSString stringWithFormat:@"%.2lf",powerFactor] forState:UIControlStateNormal];
//        NSString *strDeviceStaus = [ASLocalizeConfig localizedString:@"离线"];
        
//        switch (_aduroDeviceInfo.deviceNetState)
//        {
//            case DeviceNetStateOffline:
//            {
//                strDeviceStaus = [ASLocalizeConfig localizedString:@"离线"];
//                break;
//            }
//            case DeviceNetStateOnline:
//            case DeviceNetStateRemoteOnline:
//            {
//                strDeviceStaus = [ASLocalizeConfig localizedString:@"在线"];
//                break;
//            }
//            default:
//                break;
//        }
        NSString *strDeviceStaus = [ASLocalizeConfig localizedString:@"Unreachable"];
        if (_aduroDeviceInfo.isCache == YES) {
            strDeviceStaus = [ASLocalizeConfig localizedString:@""];
            [_cellView setBackgroundColor:[UIColor whiteColor]];
        }else{
            [_cellView setBackgroundColor:UIColorFromRGB(0Xd7d7d7)];
            strDeviceStaus = [ASLocalizeConfig localizedString:@"Unreachable"];
        }
        
        if (_aduroDeviceInfo.deviceTypeID == DeviceTypeIDHumanSensor) {
            [_deviceNetStateLb setText:[[NSString alloc] initWithFormat:@"%@-%x %@",strDeviceType,_aduroDeviceInfo.shortAdr,strDeviceStaus]];
        }else{
            [_deviceNetStateLb setText:[[NSString alloc] initWithFormat:@"%@-%x %@",strDeviceType,/*strDeviceStaus,*/_aduroDeviceInfo.shortAdr,strDeviceStaus]];
        }
        [_cellView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@([ASDeviceCell getCellHeight] + offset));
        }];

        if (offset!=0) {
            if (!_alphaSlider) {
                _alphaSlider = [UISlider new];
                UIImage *yellowImg = [UIImage imageNamed:@"slider_yellow"];
                CGFloat top = 7; // 顶端盖高度
                CGFloat bottom = 7 ; // 底端盖高度
                CGFloat left = 20; // 左端盖宽度
                CGFloat right = 20; // 右端盖宽度
                UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
                // 指定为拉伸模式，伸缩后重新赋值
                yellowImg = [yellowImg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
                [_alphaSlider setMinimumTrackImage:yellowImg forState:UIControlStateNormal];
                [_alphaSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_gray"] forState:UIControlStateNormal];
                [_alphaSlider setThumbImage:[UIImage imageNamed:@"slider_btn"] forState:UIControlStateNormal];
                [_alphaSlider setThumbImage:[UIImage imageNamed:@"slider_btn"] forState:UIControlStateHighlighted];
                
                [_cellView addSubview:_alphaSlider];
                [_alphaSlider mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(_cellView.mas_leading).offset(70);
                    make.trailing.equalTo(_cellView.mas_trailing).offset(-70);
                    make.height.equalTo(@(40));
                    make.top.equalTo(_deviceTypeImageView.mas_bottom);
                }];
                [_alphaSlider setMinimumValue:0];
                [_alphaSlider setMaximumValue:1];
//                [_alphaSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
//                [_alphaSlider addTarget:self action:@selector(lampAlphaSliderAction:) forControlEvents:UIControlEventValueChanged];
//                [_alphaSlider addTarget:self action:@selector(lampAlphaSliderDownAction:) forControlEvents:UIControlEventTouchDown];
                [_alphaSlider addTarget:self action:@selector(lampAlphaSliderUpAction:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            //slider左边原点
            _leftPointImgView = [[UIImageView alloc] init];
            [_cellView addSubview:_leftPointImgView];
            _leftPointImgView.image = [UIImage imageNamed:@"slider_left"];
            [_leftPointImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_alphaSlider.mas_centerY);
                make.trailing.equalTo(_alphaSlider.mas_leading).offset(-5);
                make.width.equalTo(@(20));
                make.height.equalTo(_leftPointImgView.mas_width);
            }];
            //slider右边原点
            _rightPointImgView = [[UIImageView alloc] init];
            [_cellView addSubview:_rightPointImgView];
            _rightPointImgView.image = [UIImage imageNamed:@"slider_right"];
            [_rightPointImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_alphaSlider.mas_centerY);
                make.leading.equalTo(_alphaSlider.mas_trailing).offset(5);
                make.width.equalTo(@(20));
                make.height.equalTo(_rightPointImgView.mas_width);
            }];

            CGFloat deviceLevel = _aduroDeviceInfo.deviceLightLevel;
            CGFloat value = deviceLevel*1.0/255.0f;
            [_alphaSlider setValue:value animated:YES];
            
        }else{
            if (_alphaSlider) {
                [_alphaSlider removeFromSuperview];
                [_leftPointImgView removeFromSuperview];
                [_rightPointImgView removeFromSuperview];
                _alphaSlider = nil;
            }
        }
    }
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}

-(void)getCellView{
    _cellView = [[UIView alloc] init];
    [self.contentView addSubview:_cellView];
    _cellView.backgroundColor = UIColorFromRGB(0Xd7d7d7);
    [_cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASDeviceCell getCellHeight]));
    }];
    
    //设备图标
    _deviceTypeImageView = [UIImageView new];
    [_cellView addSubview:_deviceTypeImageView];
    [_deviceTypeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cellView.mas_top).offset(5);
        make.leading.equalTo(_cellView.mas_leading).offset(20); //首部
        make.height.equalTo(@(60));
        make.width.equalTo(_deviceTypeImageView.mas_height);
    }];
    //设备开关按钮
    _deviceSwitchBtn = [[UIButton alloc] init];
    [_deviceSwitchBtn setBackgroundImage:[UIImage imageNamed:@"Button_switch_off"]forState:UIControlStateNormal];
    [_deviceSwitchBtn addTarget:self action:@selector(switchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_cellView addSubview:_deviceSwitchBtn];
    [_deviceSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_deviceTypeImageView.mas_centerY);
        make.trailing.equalTo(_cellView.mas_trailing).offset(-30); //尾部
        make.width.equalTo(@(40));
        make.height.equalTo(_deviceSwitchBtn.mas_width);
    }];
    
//    //传感器LB
//    _sensorStateLabel = [UILabel new];
//    [_sensorStateLabel setBackgroundColor:[UIColor clearColor]];
//    [_cellView addSubview:_sensorStateLabel];
//    [_sensorStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(_cellView.mas_centerY);
//        make.trailing.equalTo(_cellView.mas_trailing).offset(-30);
//        make.width.equalTo(@(66));
//        make.height.equalTo(@(30));
//    }];
//    [_sensorStateLabel setHidden:YES];
    
    _sensorStateImgView = [UIImageView new];
    [_cellView addSubview:_sensorStateImgView];
    [_sensorStateImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_cellView.mas_centerY);
        make.trailing.equalTo(_cellView.mas_trailing).offset(-30);
        make.width.equalTo(@(58/1.6));
        make.height.equalTo(@(56/1.6));
    }];
    [_sensorStateImgView setHidden:YES];

    //设备名称
    _deviceNameLb = [[UILabel alloc]init];
    [_deviceNameLb setFont:[UIFont systemFontOfSize:16]];
    [_cellView addSubview:_deviceNameLb];
    [_deviceNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_deviceTypeImageView.mas_top);
        make.leading.equalTo(_deviceTypeImageView.mas_trailing).offset(10);
        make.trailing.equalTo(_deviceSwitchBtn.mas_leading);
        make.bottom.equalTo(_deviceTypeImageView.mas_centerY);
    }];
    
    _deviceNetStateLb = [[UILabel alloc] init];
    [_deviceNetStateLb setFont:[UIFont systemFontOfSize:14]];
    [_deviceNetStateLb setTextColor:[UIColor lightGrayColor]];
    [_cellView addSubview:_deviceNetStateLb];
    [_deviceNetStateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_deviceTypeImageView.mas_centerY);
        make.leading.equalTo(_deviceTypeImageView.mas_trailing).offset(10);
        make.trailing.equalTo(_deviceSwitchBtn.mas_leading);
        make.bottom.equalTo(_deviceTypeImageView.mas_bottom);
    }];

//    //设备类型
//    _deviceTypeLb = [[UILabel alloc]init];
//    [_deviceTypeLb setFont:[UIFont systemFontOfSize:12]];
//    [_deviceTypeLb setTextColor:[UIColor grayColor]];
//    [_cellView addSubview:_deviceTypeLb];
//    [_deviceTypeLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_deviceNameLb.mas_bottom);
//        make.leading.equalTo(_deviceTypeImageView.mas_trailing).offset(10);
//        make.trailing.equalTo(_deviceSwitchBtn.mas_leading);
//        make.height.equalTo(@(20));
//    }];
    
    //设备详情按钮
    _deviceShowDetailBtn = [[UIButton alloc]init];
    [_deviceShowDetailBtn addTarget:self action:@selector(showDetailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_cellView addSubview:_deviceShowDetailBtn];
    [_deviceShowDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cellView.mas_top);
        make.leading.equalTo(_cellView.mas_leading);
        make.trailing.equalTo(_deviceSwitchBtn.mas_leading);
        make.bottom.equalTo(_cellView.mas_bottom);
    }];
    //cell分割线
    UIView *separatorView = [[UIView alloc]init];
    [separatorView setBackgroundColor:CELL_LIEN_COLOR];
    [_cellView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_cellView.mas_leading).offset(20);
        make.trailing.equalTo(_cellView.mas_trailing);
        make.height.equalTo(@(1));
        make.bottom.equalTo(_cellView.mas_bottom);
    }];
    
    //智能插座布局
    CGFloat lbWidth = (SCREEN_ADURO_WIDTH - 6 * 10)/5;
    //----数据---电压 1
    _voltageLb = [UILabel new];
    [_cellView addSubview:_voltageLb];
    [_voltageLb setText:[ASLocalizeConfig localizedString:@"Voltage-V"]];
    [_voltageLb setTextColor:[UIColor lightGrayColor]];
    [_voltageLb setFont:[UIFont systemFontOfSize:12]];
    _voltageLb.textAlignment = NSTextAlignmentCenter;
    [_voltageLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_cellView.mas_bottom).offset(-25);
        make.leading.equalTo(_cellView.mas_leading).offset(10);
        make.width.equalTo(@(lbWidth));
        make.height.equalTo(@(20));
    }];
    _VLb = [UIButton new];
    [_cellView addSubview:_VLb];
    [_VLb setBackgroundColor:LOGO_COLOR];
    _VLb.layer.cornerRadius = 5.0;
    //                [VLb setTitle:[NSString stringWithFormat:@"%.0lf",_aduroDeviceInfo.electmeasVolatage] forState:UIControlStateNormal];
    [_VLb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_VLb setFont:[UIFont systemFontOfSize:12]];
    [_VLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_cellView.mas_bottom).offset(-5);
        make.leading.equalTo(_voltageLb.mas_leading);
        make.trailing.equalTo(_voltageLb.mas_trailing);
        make.height.equalTo(@(20));
    }];
    //----数据---电流 2
    _currentLb = [UILabel new];
    [_cellView addSubview:_currentLb];
    [_currentLb setText:[ASLocalizeConfig localizedString:@"Current-A"]];
    [_currentLb setTextColor:[UIColor lightGrayColor]];
    [_currentLb setFont:[UIFont systemFontOfSize:12]];
    _currentLb.textAlignment = NSTextAlignmentCenter;
    [_currentLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_voltageLb.mas_top);
        make.leading.equalTo(_voltageLb.mas_trailing).offset(10);
        make.width.equalTo(_voltageLb.mas_width);
        make.height.equalTo(_voltageLb.mas_height);
    }];
    _ALb = [UIButton new];
    [_cellView addSubview:_ALb];
    [_ALb setBackgroundColor:LOGO_COLOR];
    _ALb.layer.cornerRadius = 5.0;
    //                [ALb setTitle:[NSString stringWithFormat:@"%.2lf",_aduroDeviceInfo.electmeasCurrent] forState:UIControlStateNormal];
    [_ALb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_ALb setFont:[UIFont systemFontOfSize:12]];
    [_ALb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_VLb.mas_bottom);
        make.leading.equalTo(_currentLb.mas_leading);
        make.width.equalTo(_VLb.mas_width);
        make.height.equalTo(_VLb.mas_height);
    }];
    //----数据---功率 3
    _powerLb = [UILabel new];
    [_cellView addSubview:_powerLb];
    [_powerLb setText:[ASLocalizeConfig localizedString:@"Power-w"]];
    [_powerLb setTextColor:[UIColor lightGrayColor]];
    [_powerLb setFont:[UIFont systemFontOfSize:12]];
    _powerLb.textAlignment = NSTextAlignmentCenter;
    [_powerLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_currentLb.mas_top);
        make.leading.equalTo(_currentLb.mas_trailing).offset(10);
        make.width.equalTo(_currentLb.mas_width);
        make.height.equalTo(_currentLb.mas_height);
    }];
    _WLb = [UIButton new];
    [_cellView addSubview:_WLb];
    [_WLb setBackgroundColor:LOGO_COLOR];
    _WLb.layer.cornerRadius = 5.0;
    //                [WLb setTitle:[NSString stringWithFormat:@"%.0lf",_aduroDeviceInfo.electmeasPower] forState:UIControlStateNormal];
    [_WLb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_WLb setFont:[UIFont systemFontOfSize:12]];
    [_WLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_ALb.mas_bottom);
        make.leading.equalTo(_powerLb.mas_leading);
        make.width.equalTo(_ALb.mas_width);
        make.height.equalTo(_ALb.mas_height);
    }];
    //----数据---频率 4
    _freqLb = [UILabel new];
    [_cellView addSubview:_freqLb];
    [_freqLb setText:[ASLocalizeConfig localizedString:@"Freq-Hz"]];
    [_freqLb setTextColor:[UIColor lightGrayColor]];
    [_freqLb setFont:[UIFont systemFontOfSize:12]];
    _freqLb.textAlignment = NSTextAlignmentCenter;
    [_freqLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_powerLb.mas_top);
        make.leading.equalTo(_powerLb.mas_trailing).offset(10);
        make.width.equalTo(_powerLb.mas_width);
        make.height.equalTo(_powerLb.mas_height);
    }];
    _HzLb = [UIButton new];
    [_cellView addSubview:_HzLb];
    [_HzLb setBackgroundColor:LOGO_COLOR];
    _HzLb.layer.cornerRadius = 5.0;
    //                [HzLb setTitle:[NSString stringWithFormat:@"%d",_aduroDeviceInfo.electmeasFrequency] forState:UIControlStateNormal];
    [_HzLb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_HzLb setFont:[UIFont systemFontOfSize:12]];
    [_HzLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_WLb.mas_bottom);
        make.leading.equalTo(_freqLb.mas_leading);
        make.width.equalTo(_WLb.mas_width);
        make.height.equalTo(_WLb.mas_height);
    }];
    //----数据---5
    _PFLb = [UILabel new];
    [_cellView addSubview:_PFLb];
    [_PFLb setText:[ASLocalizeConfig localizedString:@"PF"]];
    [_PFLb setTextColor:[UIColor lightGrayColor]];
    [_PFLb setFont:[UIFont systemFontOfSize:12]];
    _PFLb.textAlignment = NSTextAlignmentCenter;
    [_PFLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_freqLb.mas_top);
        make.leading.equalTo(_freqLb.mas_trailing).offset(10);
        make.width.equalTo(_freqLb.mas_width);
        make.height.equalTo(_freqLb.mas_height);
    }];
    _pLb = [UIButton new];
    [_cellView addSubview:_pLb];
    [_pLb setBackgroundColor:LOGO_COLOR];
    _pLb.layer.cornerRadius = 5.0;
    //                [pLb setTitle:[NSString stringWithFormat:@"%.2lf",_aduroDeviceInfo.electmeasPowerFactor] forState:UIControlStateNormal];
    [_pLb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_pLb setFont:[UIFont systemFontOfSize:12]];
    [_pLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_HzLb.mas_bottom);
        make.leading.equalTo(_PFLb.mas_leading);
        make.width.equalTo(_HzLb.mas_width);
        make.height.equalTo(_HzLb.mas_height);
    }];
    
    [_voltageLb setHidden:YES];
    [_VLb setHidden:YES];
    [_currentLb setHidden:YES];
    [_ALb setHidden:YES];
    [_powerLb setHidden:YES];
    [_WLb setHidden:YES];
    [_freqLb setHidden:YES];
    [_HzLb setHidden:YES];
    [_PFLb setHidden:YES];
    [_pLb setHidden:YES];
    
}

#pragma mark - buttonAction
//调节开关状态
-(void)switchButtonAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(deviceSwitch:aduroInfo:)]) {
        isOn = [self.delegate deviceSwitch:(isOn) aduroInfo:self.aduroDeviceInfo];
        [self setSwitchButtonImage:isOn switchButton:sender];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"allGroupListReloadData" object:nil];
    }
}
-(void)setSwitchButtonImage:(BOOL )setOn switchButton:(UIButton *)sender{
    if (setOn) {
        [sender setBackgroundImage:[UIImage imageNamed:@"Button_switch_on"]forState:UIControlStateNormal];
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"Button_switch_off"]forState:UIControlStateNormal];
    }
}
//设备详情页按钮
-(void)showDetailButtonAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(deviceShowDetailWithAduroInfo:)]) {
        [self.delegate deviceShowDetailWithAduroInfo:self.aduroDeviceInfo];
    }
}

-(void)lampAlphaSliderAction:(UISlider *)sender{
//    static float value = 0;
//    float new_value = (float)sender.value;
//    float threshold = 0.05;
//    
//    //如果数据相差大于0.05才发送改变亮度命令·······
//    if ( new_value > value + threshold || new_value < value - threshold ) {
//        value = new_value;
//        if ([self.delegate respondsToSelector:@selector(deviceChangeAlpha:)]) {
//            [self.delegate deviceChangeAlpha:sender.value];
//        }
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//        });
//    }
    [self.aduroDeviceInfo setDeviceLightLevel:sender.value*255.0f];
    DeviceManager *device = [DeviceManager sharedManager];
    [device updateDeviceLevel:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
        DDLogInfo(@"AduroSmartReturnCode = %d",code);
    }];
}

-(void)lampAlphaSliderDownAction:(UISlider *)sender{
    if ([self.delegate respondsToSelector:@selector(deviceChangeAlpha:)]) {
        //        [self.delegate deviceChangeAlpha:sender.value];
    }
    [self.aduroDeviceInfo setDeviceLightLevel:sender.value*255.0f];
    DeviceManager *device = [DeviceManager sharedManager];
    [device updateDeviceLevel:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
        DDLogInfo(@"AduroSmartReturnCode = %d",code);
    }];
}

-(void)lampAlphaSliderUpAction:(UISlider *)sender{
    if ([self.delegate respondsToSelector:@selector(deviceChangeAlpha:)]) {
        //        [self.delegate deviceChangeAlpha:sender.value];
    }
    [self.aduroDeviceInfo setDeviceLightLevel:sender.value*255];
    DeviceManager *device = [DeviceManager sharedManager];
    [device updateDeviceLevel:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
        DDLogInfo(@"AduroSmartReturnCode = %d",code);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"allGroupListReloadData" object:nil];
}

+(CGFloat)getCellHeight{
    return 70.f;
}

-(void)clearSensorStateLabel{
//    [_sensorStateLabel setText:@""];
    [_sensorStateImgView setImage:nil];
    _aduroDeviceInfo.deviceSensorData = 0;
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
