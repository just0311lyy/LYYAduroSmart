//
//  SelectedCell.m
//  AduroSmart
//
//  Created by MacBook on 16/8/3.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "SelectedCell.h"
#import "NSString+Wrapper.h"
#import "QCheckBox.h"

@interface SelectedCell ()<QCheckBoxDelegate>{
    UILabel *_deviceNameLabel;
    UILabel *_deviceDescriptionLabel;
    UIImageView *_deviceImgView;

    QCheckBox *_check; //设备选择
//    UIButton *_deviceShowDetailButton;
    
    AduroDevice *_aduroDeviceInfo;
    BOOL isSelect;
}
-(void)getCellView;
@end

@implementation SelectedCell

@synthesize aduroDeviceInfo = _aduroDeviceInfo;

-(AduroDevice *)aduroDeviceInfo{
    return _aduroDeviceInfo;
}

-(void)setAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{
    if (_aduroDeviceInfo != aduroDeviceInfo) {
        _aduroDeviceInfo = nil;
        _aduroDeviceInfo = aduroDeviceInfo;
        //        [_deviceNameLabel setText:[NSString stringWithFormat:@"%@-%x",[MyTool changeName:_feibitDeviceInfo.deviceName],_feibitDeviceInfo.uId]];
        [_deviceNameLabel setText:[NSString stringWithFormat:@"%@",[NSString changeName:_aduroDeviceInfo.deviceName]]];

        NSString *strDeviceType = @"";
        [_deviceImgView setImage:[UIImage imageNamed:@"unonline"]];
        
        switch (_aduroDeviceInfo.deviceTypeID)
        {
            case 0x0105://可调颜色灯,有调光、开关功能
            case 0x0102://彩灯
            case 0x0210://飞利浦彩灯
            case DeviceTypeIDColorLight:
            {

                [_deviceImgView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"彩灯"];
                break;
            }
            case 0x0110://色温灯
            case 0x0220:
            {
                [_deviceImgView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"色温灯"];
                break;
            }
            case 0x0101://调光灯
            case 0x0100://强制改开关为灯泡
            {
                [_deviceImgView setImage:[UIImage imageNamed:@"light"]];
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
                            [_deviceImgView setImage:[UIImage imageNamed:@"sensor_0014"]];

                        }
                            break;
                        case DeviceZoneTypeContactSwitch:
                        {
                            strDeviceType = [ASLocalizeConfig localizedString:@"门磁传感器"];
                            [_deviceImgView setImage:[UIImage imageNamed:@"sensor_0015"]];
                        }
                            break;
                        case DeviceZoneTypeVibrationMovementSensor:
                        {
                            strDeviceType = [ASLocalizeConfig localizedString:@"震动传感器"];
                            [_deviceImgView setImage:[UIImage imageNamed:@"sensor"]];
                            
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
                strDeviceType = [ASLocalizeConfig localizedString:@"Smart plug"];
                [_deviceImgView setImage:[UIImage imageNamed:@"smart_plug"]];
                break;
            }
            case 0x0202:
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Curtain"];
                [_deviceImgView setImage:[UIImage imageNamed:@"window_curtain"]];
                break;
            }
            case DeviceTypeIDLightingRemotes:
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Lighting Remotes"];
                [_deviceImgView setImage:[UIImage imageNamed:@"light_remotes"]];
                break;
            }
            default:
            {
                break;
            }
        }
        
        NSString *strDeviceStaus = [ASLocalizeConfig localizedString:@"离线"];
        
        switch (_aduroDeviceInfo.deviceNetState)
        {
            case DeviceNetStateOffline:
            {
                strDeviceStaus = [ASLocalizeConfig localizedString:@"离线"];
                break;
            }
            case DeviceNetStateOnline:
            case DeviceNetStateRemoteOnline:
            {
                strDeviceStaus = [ASLocalizeConfig localizedString:@"在线"];
                break;
            }
            default:
                break;
        }
        if (_aduroDeviceInfo.deviceTypeID == DeviceTypeIDHumanSensor) {
            [_deviceDescriptionLabel setText:[[NSString alloc] initWithFormat:@"%@-%x",strDeviceType,_aduroDeviceInfo.shortAdr]];
        }else{
            [_deviceDescriptionLabel setText:[[NSString alloc] initWithFormat:@"%@-%x",strDeviceType,/*strDeviceStaus,*/_aduroDeviceInfo.shortAdr]];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
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
        make.height.equalTo(@([SelectedCell getCellHeight]));
    }];

    _check = [[QCheckBox alloc] initWithDelegate:self];
    [cellView addSubview:_check];
    [_check mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cellView.mas_centerY);
        make.trailing.equalTo(cellView.mas_trailing).offset(-10);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
    }];
    
    _deviceImgView = [[UIImageView alloc] init];
    [cellView addSubview:_deviceImgView];
    [_deviceImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cellView.mas_top).offset(10);
        make.leading.equalTo(cellView.mas_leading).offset(10);
        make.width.equalTo(_deviceImgView.mas_height);
        make.bottom.equalTo(cellView.mas_bottom).offset(-10);
    }];
    
    _deviceNameLabel = [[UILabel alloc]init];
    [_deviceNameLabel setFont:[UIFont systemFontOfSize:16]];
    [cellView addSubview:_deviceNameLabel];
    [_deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cellView.mas_top).offset(20);
        make.leading.equalTo(_deviceImgView.mas_trailing).offset(5);
        make.height.equalTo(@(20));
        make.trailing.equalTo(_check.mas_leading);
    }];
    
    _deviceDescriptionLabel = [[UILabel alloc]init];
    [_deviceDescriptionLabel setFont:[UIFont systemFontOfSize:12]];
    [_deviceDescriptionLabel setTextColor:[UIColor grayColor]];
    [cellView addSubview:_deviceDescriptionLabel];
    [_deviceDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_deviceNameLabel.mas_bottom);
        make.leading.equalTo(_deviceImgView.mas_trailing).offset(5);
        make.trailing.equalTo(_check.mas_leading);
        make.height.equalTo(@(20));
    }];

    UIView *separatorView = [[UIView alloc]init];
    [separatorView setBackgroundColor:CELL_LIEN_COLOR];
    [cellView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_deviceImgView.mas_leading);
        make.trailing.equalTo(cellView.mas_trailing);
        make.height.equalTo(@(1.0f));
        make.bottom.equalTo(cellView.mas_bottom);
    }];
    
}

+(CGFloat)getCellHeight{
    return 70.f;
}

#pragma mark - QCheckBoxDelegate

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {
    NSLog(@"did tap on CheckBox:%@ checked:%d", checkbox.titleLabel.text, checked);
    
    [self.delegate deviceSelected:checked WithAduroDeviceInfo:self.aduroDeviceInfo];
}

@end
