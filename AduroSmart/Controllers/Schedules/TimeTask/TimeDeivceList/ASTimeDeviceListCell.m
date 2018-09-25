//
//  ASTimeDeviceListCell.m
//  AduroSmart
//
//  Created by MacBook on 16/8/28.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASTimeDeviceListCell.h"
#import "BFPaperCheckbox.h"
#import "UIColor+BFPaperColors.h"
#import "NSString+Wrapper.h"
@interface ASTimeDeviceListCell ()<BFPaperCheckboxDelegate>{
    //代表设备类型的图标
    UIImageView *_deviceImageView;
    UILabel *_deviceNameLabel;
    UILabel *_deviceDescriptionLabel;
    UISlider *_alphaSlider;
    BFPaperCheckbox *_deviceCheckbox;
    UIButton *_deviceShowDetailButton;
    UISwitch *_onOffSwitch;
    
    AduroDevice *_aduroDeviceInfo;
}
-(void)getCellView;
@end

@implementation ASTimeDeviceListCell

@synthesize aduroDeviceInfo = _aduroDeviceInfo;

-(void)setDeviceCheckboxHidden:(BOOL )isHidden{
    [_deviceCheckbox setHidden:isHidden];
    
    [_deviceShowDetailButton setHidden:isHidden];
    
}

-(AduroDevice *)aduroDeviceInfo{
    return _aduroDeviceInfo;
}

-(void)setAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{
    if (_aduroDeviceInfo != aduroDeviceInfo) {
        _aduroDeviceInfo = nil;
        _aduroDeviceInfo = aduroDeviceInfo;

        [_deviceNameLabel setText:[NSString stringWithFormat:@"%@",[NSString changeName:_aduroDeviceInfo.deviceName]]];
        
        NSString *strDeviceType = @"";
        [_deviceImageView setImage:[UIImage imageNamed:@"unonline"]];
        switch (_aduroDeviceInfo.deviceTypeID)
        {
            case 0x0105://可调颜色灯,有调光、开关功能
            case 0x0102://彩灯
            case 0x0210://飞利浦彩灯
            case DeviceTypeIDColorLight:
            {
                [_deviceImageView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"彩灯"];
                break;
            }
            case 0x0110://色温灯
            case 0x0220:
            {
                [_deviceImageView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"色温灯"];
                break;
            }
            case 0x0101://调光灯
            case 0x0100://强制改开关为灯泡
            {
                [_deviceImageView setImage:[UIImage imageNamed:@"light"]];
                strDeviceType = [ASLocalizeConfig localizedString:@"调光灯"];
                break;
            }
            case DeviceTypeIDSmartPlug://智能插座
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Smart plug"];
                [_deviceImageView setImage:[UIImage imageNamed:@"smart_plug"]];
                break;
            }
            case 0x0202:
            {
                strDeviceType = [ASLocalizeConfig localizedString:@"Curtain"];
                [_deviceImageView setImage:[UIImage imageNamed:@"window_curtain"]];
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

        [_deviceDescriptionLabel setText:[[NSString alloc] initWithFormat:@"Type=%@,Net=%@,Level=%x,Hue=%x,Sat=%x,SwitchState=%x",strDeviceType,strDeviceStaus,aduroDeviceInfo.deviceLightLevel,aduroDeviceInfo.deviceLightHue,aduroDeviceInfo.deviceLightSat,aduroDeviceInfo.deviceSwitchState]];

        _deviceCheckbox.tag = (NSInteger)_aduroDeviceInfo.deviceID;
        [_deviceCheckbox uncheckAnimated:YES];
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}

-(void)setCheckboxChecked:(BOOL)isChecked manual:(BOOL )isManual{
    [_deviceCheckbox setIsManual:isManual];
    if (isChecked) {
        [_deviceCheckbox checkAnimated:YES];
    }else{
        [_deviceCheckbox uncheckAnimated:YES];
    }
    
}

-(void)getCellView{
    UIView *cellView = [[UIView alloc]init];
    [self.contentView addSubview:cellView];
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASTimeDeviceListCell getCellHeight]));
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
    
    _deviceCheckbox = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(imgView.frame.size.width - 50, 0, 25 * 2, 25 * 2)];
    _deviceCheckbox.delegate = self;
    _deviceCheckbox.tapCirclePositiveColor = [UIColor paperColorAmber]; // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    _deviceCheckbox.tapCircleNegativeColor = [UIColor paperColorRed];   // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    _deviceCheckbox.checkmarkColor = LOGO_COLOR;
    [cellView addSubview:_deviceCheckbox];
    [_deviceCheckbox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imgView.mas_centerY);
        make.trailing.equalTo(imgView.mas_trailing).offset(-10);
        make.width.equalTo(@(50));
        make.height.equalTo(@(50));
    }];
    
    //    _checkBoxImageView = [UIImageView new];
    //    [_checkBoxImageView setImage:[UIImage imageNamed:@"ischeck"]];
    //    [cellView addSubview:_checkBoxImageView];
    //    [_checkBoxImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(cellView.mas_top);
    //        make.trailing.equalTo(cellView.mas_trailing).offset(-30);
    //        make.width.equalTo(@(33));
    //        make.height.equalTo(@(33));
    //    }];
    //    [_checkBoxImageView setHidden:YES];
    
    _deviceImageView = [UIImageView new];
    [imgView addSubview:_deviceImageView];
    [_deviceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imgView.mas_centerY).offset(-15);
        make.leading.equalTo(imgView.mas_leading).offset(25); //首部
        make.width.equalTo(@(55));
        make.height.equalTo(_deviceImageView.mas_width);
    }];

    _deviceNameLabel = [[UILabel alloc]init];
    [_deviceNameLabel setFont:[UIFont systemFontOfSize:16]];
    [imgView addSubview:_deviceNameLabel];
    [_deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_deviceImageView.mas_centerY);
        make.leading.equalTo(_deviceImageView.mas_trailing).offset(10);
        make.height.equalTo(@(20));
        make.trailing.equalTo(_deviceCheckbox.mas_leading);
    }];
    
    _onOffSwitch = [UISwitch new];
    [cellView addSubview:_onOffSwitch];
    [_onOffSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_deviceImageView.mas_centerY);
        make.trailing.equalTo(_deviceCheckbox.mas_leading).offset(-5);
    }];

    [_onOffSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
//    _deviceDescriptionLabel = [[UILabel alloc]init];
//    [_deviceDescriptionLabel setFont:[UIFont systemFontOfSize:12]];
//    [_deviceDescriptionLabel setTextColor:[UIColor grayColor]];
//    [imgView addSubview:_deviceDescriptionLabel];
//    [_deviceDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_deviceNameLabel.mas_bottom);
//        make.leading.equalTo(imgView.mas_leading).offset(30);
//        make.trailing.equalTo(_deviceCheckbox.mas_leading);
//        make.height.equalTo(@(20));
//    }];
    
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
        make.leading.equalTo(_deviceImageView.mas_trailing);
        make.trailing.equalTo(_deviceNameLabel.mas_trailing).offset(-20);
        make.height.equalTo(@(40));
        make.bottom.equalTo(cellView.mas_bottom).offset(-5);
    }];
    [_alphaSlider setMinimumValue:0];
    [_alphaSlider setMaximumValue:1];
    //                [_alphaSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [_alphaSlider addTarget:self action:@selector(lampAlphaSliderAction:) forControlEvents:UIControlEventValueChanged];
//    [_alphaSlider addTarget:self action:@selector(lampAlphaSliderDownAction:) forControlEvents:UIControlEventTouchDown];
//    [_alphaSlider addTarget:self action:@selector(lampAlphaSliderUpAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //slider左边原点
    UIImageView *leftPointImgView = [[UIImageView alloc] init];
    [cellView addSubview:leftPointImgView];
    leftPointImgView.image = [UIImage imageNamed:@"slider_left"];
    [leftPointImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_alphaSlider.mas_centerY);
        make.trailing.equalTo(_alphaSlider.mas_leading).offset(-5);
        make.width.equalTo(@(20));
        make.height.equalTo(leftPointImgView.mas_width);
    }];
    //slider右边原点
    UIImageView *rightPointImgView = [[UIImageView alloc] init];
    [cellView addSubview:rightPointImgView];
    rightPointImgView.image = [UIImage imageNamed:@"slider_right"];
    [rightPointImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_alphaSlider.mas_centerY);
        make.leading.equalTo(_alphaSlider.mas_trailing).offset(5);
        make.width.equalTo(@(20));
        make.height.equalTo(rightPointImgView.mas_width);
    }];

//    _deviceShowDetailButton = [[UIButton alloc]init];
//    [_deviceShowDetailButton addTarget:self action:@selector(showLightDetailButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    [cellView addSubview:_deviceShowDetailButton];
//    [_deviceShowDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(cellView.mas_top);
//        make.leading.equalTo(cellView.mas_leading);
//        make.trailing.equalTo(_deviceCheckbox.mas_leading);
//        make.bottom.equalTo(cellView.mas_bottom);
//    }];
    
}

//-(void)showLightDetailButtonAction{
//    
//    [self.delegate lightDeviceShowDetailWithAduroInfo:self.aduroDeviceInfo];
//
//}

-(void)lampAlphaSliderAction:(UISlider *)sender{
    
    if ([self.delegate respondsToSelector:@selector(lightDeviceChangeAlpha:)]) {
        [self.delegate lightDeviceChangeAlpha:sender.value];
    }
    [self.aduroDeviceInfo setDeviceLightLevel:sender.value*255];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DeviceManager *device = [DeviceManager sharedManager];
        [device updateDeviceLevel:self.aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {
            DDLogInfo(@"AduroSmartReturnCode = %d",code);
        }];
    });
}

+(CGFloat)getCellHeight{
    return 100.f;
}

-(void)switchAction:(UISwitch *)sender{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        _aduroDeviceInfo.deviceSwitchState = DeviceSwitchStateOn; //开启
    }else {
        _aduroDeviceInfo.deviceSwitchState = DeviceSwitchStateOff; //关闭
    }
    if ([self.delegate respondsToSelector:@selector(lightDeviceSwitchChange:)]) {
        [self.delegate lightDeviceSwitchChange:isButtonOn];
    }
//    DeviceManager *device = [DeviceManager sharedManager];
//    [device updateDeviceState:_aduroDeviceInfo completionHandler:^(AduroSmartReturnCode code) {    
//    }];

}


#pragma mark - BFPaperCheckbox Delegate
- (void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox
{
    if (_deviceShowDetailButton.isHidden) {
        return;
    }
    [self.delegate selectedTimeAduroDeviceInfo:self.aduroDeviceInfo];
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
