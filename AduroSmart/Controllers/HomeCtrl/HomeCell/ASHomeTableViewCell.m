//
//  ASHomeTableViewCell.m
//  AduroSmart
//
//  Created by MacBook on 16/7/23.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASHomeTableViewCell.h"
#import "ASDataBaseOperation.h"
#import "ASGlobalDataObject.h"
@interface ASHomeTableViewCell (){
    AduroGroup *_aduroGroupInfo;
    //开关是否开启
    BOOL isOn;
    UISlider *_alphaSlider;
    UIButton *_homeSwitchBtn;
    UILabel *_groupNetStateLb; //在线状态
}
-(void)getCellView;
@end


@implementation ASHomeTableViewCell

@synthesize aduroGroupInfo = _aduroGroupInfo;
-(AduroGroup *)aduroGroupInfo{
    return _aduroGroupInfo;
}

-(void)setAduroGroupInfo:(AduroGroup *)aduroGroupInfo{
    if (_aduroGroupInfo != aduroGroupInfo) {
        _aduroGroupInfo = nil;
        _aduroGroupInfo = aduroGroupInfo;

        NSArray *array = [aduroGroupInfo.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
        NSString *name = [array firstObject];
        NSString *typeId = [array lastObject];
        [_homeNameLb setText:name];
        //房间开关
        if (_aduroGroupInfo.groupID == MAX_GROUP_ID) {
            for (int j=0; j<[_globalDeviceArray count]; j++) {
                AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
                if (myDevice.deviceSwitchState == DeviceSwitchStateOn) {
                    isOn = YES;
                    goto end;
                }else{
                    isOn = NO;
                }
            }
        }else{
            for (int i=0; i<[_aduroGroupInfo.groupSubDeviceIDArray count]; i++) {
                NSString *deviceID = [[_aduroGroupInfo.groupSubDeviceIDArray objectAtIndex:i] lowercaseString];
                for (int j=0; j<[_globalDeviceArray count]; j++) {
                    AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
                    if ([[myDevice.deviceID lowercaseString] hasSuffix:deviceID]) {
                        if (myDevice.deviceSwitchState == DeviceSwitchStateOn) {
                            isOn = YES;
                            goto end;
                        }else{
                            isOn = NO;
                        }
                    }
                }
            }
        }
        end:{
        NSLog(@"找到打开的灯");
        }
        [self setSwitchButtonImage:isOn switchButton:_homeSwitchBtn];
        //房间亮度
        CGFloat roomLevel = 0;
        CGFloat deviceLevel = 0;
        if (_aduroGroupInfo.groupID == MAX_GROUP_ID) {
            NSMutableArray *lightDeviceArr = [NSMutableArray array];
            for (int i=0; i<[_globalDeviceArray count]; i++) {
                AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:i];
                if (myDevice.deviceTypeID != DeviceTypeIDHumanSensor) {
                    [lightDeviceArr addObject:myDevice];
                    deviceLevel += myDevice.deviceLightLevel*1.0/255.0f;
                }
            }
            roomLevel = deviceLevel/[lightDeviceArr count];
            [_alphaSlider setValue:roomLevel animated:YES];
        }else{
            NSMutableArray *lightGroupDeviceArr = [NSMutableArray array];
            for (int i=0; i<[_aduroGroupInfo.groupSubDeviceIDArray count]; i++) {
                NSString *deviceID = [[_aduroGroupInfo.groupSubDeviceIDArray objectAtIndex:i] lowercaseString];
                for (int j=0; j<[_globalDeviceArray count]; j++) {
                    AduroDevice *myDevice = [_globalDeviceArray objectAtIndex:j];
                    if ([[myDevice.deviceID lowercaseString] hasSuffix:deviceID] && myDevice.deviceTypeID != DeviceTypeIDHumanSensor) {
                        [lightGroupDeviceArr addObject:myDevice];
                        deviceLevel += myDevice.deviceLightLevel*1.0/255.0f;
                    }
                }
            }
            roomLevel = deviceLevel/[lightGroupDeviceArr count];
            [_alphaSlider setValue:roomLevel animated:YES];
        }
        //房间类型
        NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_aduroGroupInfo.groupCoverPath]];
        if (imgData != nil) {
            [_homeTypeImgView setImage:[UIImage imageWithData:imgData]];
        }else{
            if ([typeId isEqualToString:@"01"]) {
                [_homeTypeImgView setImage:[UIImage imageNamed:@"living_room"]];
            }else if ([typeId isEqualToString:@"02"]){
                [_homeTypeImgView setImage:[UIImage imageNamed:@"kitchen"]];
            }else if ([typeId isEqualToString:@"03"]){
                [_homeTypeImgView setImage:[UIImage imageNamed:@"bedroom"]];
            }else if ([typeId isEqualToString:@"04"]){
                [_homeTypeImgView setImage:[UIImage imageNamed:@"bathroom"]];
            }
            else if ([typeId isEqualToString:@"05"]){
                [_homeTypeImgView setImage:[UIImage imageNamed:@"restaurant"]];
            }
            else if ([typeId isEqualToString:@"06"]){
                [_homeTypeImgView setImage:[UIImage imageNamed:@"toilet"]];
            }
            else if ([typeId isEqualToString:@"07"]){
                [_homeTypeImgView setImage:[UIImage imageNamed:@"office"]];
            }
            else if ([typeId isEqualToString:@"08"]){
                [_homeTypeImgView setImage:[UIImage imageNamed:@"hallway"]];
            }
            else{
                [_homeTypeImgView setImage:[UIImage imageNamed:@"all_lights"]];
            }

//            [_homeTypeImgView setImage:[UIImage imageNamed:@"living_room"]];
        }
//        [_groupNetStateLb setText:[ASLocalizeConfig localizedString:@"Unreachable"]];
        if (_aduroGroupInfo.groupType == GROUP_NET_STATE_ONLINE) {
            
            [_groupNetStateLb setText:[ASLocalizeConfig localizedString:@""]];
        }else{
            [_groupNetStateLb setText:[ASLocalizeConfig localizedString:@"Unreachable"]];
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
    
    UIView *cellView = [[UIView alloc] init];
    [self.contentView addSubview:cellView];
    cellView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASHomeTableViewCell getCellHeight]));
    }];
    
    //背景图
    UIImageView *imgView = [[UIImageView alloc] init];
    UIImage *img = [UIImage imageNamed:@"img_bg.png"];
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
        make.leading.equalTo(cellView.mas_leading).offset(5);
        make.trailing.equalTo(cellView.mas_trailing).offset(-5);
        make.bottom.equalTo(cellView.mas_bottom);
    }];

    //房间图标
    _homeTypeImgView = [UIImageView new];
    [imgView addSubview:_homeTypeImgView];
    [_homeTypeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imgView.mas_centerY).offset(-15);
        make.leading.equalTo(imgView.mas_leading).offset(18); //首部
        make.width.equalTo(@(31));
        make.height.equalTo(_homeTypeImgView.mas_width);
    }];
    
    //房间开关按钮
    _homeSwitchBtn = [[UIButton alloc] init];
    [_homeSwitchBtn setBackgroundImage:[UIImage imageNamed:@"Button_switch_off"] forState:UIControlStateNormal];
    [_homeSwitchBtn addTarget:self action:@selector(homeSwitchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cellView addSubview:_homeSwitchBtn];
    [_homeSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_homeTypeImgView.mas_centerY);
        make.trailing.equalTo(cellView.mas_trailing).offset(-30); //尾部
        make.width.equalTo(@(40));
        make.height.equalTo(_homeSwitchBtn.mas_width);
    }];
    
    //房间名
    _homeNameLb = [[UILabel alloc]init];
    [_homeNameLb setFont:[UIFont systemFontOfSize:15]];
    [imgView addSubview:_homeNameLb];
    [_homeNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_top).offset(20);
        make.leading.equalTo(_homeTypeImgView.mas_trailing).offset(10);
        make.height.equalTo(@(30));
        make.trailing.equalTo(_homeSwitchBtn.mas_leading);
    }];
    //房间可控状态
    _groupNetStateLb = [[UILabel alloc] init];
    [_groupNetStateLb setFont:[UIFont systemFontOfSize:12]];
    [_groupNetStateLb setTextColor:UIColorFromRGB(0xffcb79)];
    [imgView addSubview:_groupNetStateLb];
    [_groupNetStateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_homeNameLb.mas_bottom).offset(-10);
        make.leading.equalTo(_homeNameLb.mas_leading);
        make.trailing.equalTo(_homeNameLb.mas_trailing);
        make.height.equalTo(@(20));
    }];
    
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
        make.leading.equalTo(_homeNameLb.mas_leading);
        make.trailing.equalTo(_homeNameLb.mas_trailing).offset(-15);
        make.height.equalTo(@(40));
        make.bottom.equalTo(cellView.mas_bottom).offset(-10);
    }];
    [_alphaSlider setMinimumValue:0];
    [_alphaSlider setMaximumValue:1];
    //                [_alphaSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [_alphaSlider addTarget:self action:@selector(lampAlphaSliderAction:) forControlEvents:UIControlEventValueChanged];
    [_alphaSlider addTarget:self action:@selector(lampAlphaSliderDownAction:) forControlEvents:UIControlEventTouchDown];
    [_alphaSlider addTarget:self action:@selector(lampAlphaSliderUpAction:) forControlEvents:UIControlEventTouchUpInside];
    
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

    
    
//    //房间详情
//    _homeDescriptionLb = [[UILabel alloc]init];
//    [_homeDescriptionLb setFont:[UIFont systemFontOfSize:12]];
//    [_homeDescriptionLb setTextColor:[UIColor grayColor]];
//    [cellView addSubview:_homeDescriptionLb];
//    [_homeDescriptionLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_homeNameLb.mas_bottom);
//        make.leading.equalTo(_homeTypeImgView.mas_trailing);
//        make.trailing.equalTo(_homeSwitchBtn.mas_leading);
//        make.height.equalTo(_homeNameLb.mas_height);
//    }];
    
//    //房间详情按钮
//    _homeShowDetailBtn = [[UIButton alloc]init];
//    [_homeShowDetailBtn addTarget:self action:@selector(showDetailHomeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [cellView addSubview:_homeShowDetailBtn];
//    [_homeShowDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(cellView.mas_top);
//        make.leading.equalTo(cellView.mas_leading);
//        make.trailing.equalTo(cellView.mas_centerX).offset(60);
//        make.bottom.equalTo(cellView.mas_bottom);
//    }];
    
//    //cell分割线
//    UIView *separatorView = [[UIView alloc]init];
//    [separatorView setBackgroundColor:[UIColor colorWithWhite:0.718 alpha:1.000]];
//    [cellView addSubview:separatorView];
//    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(cellView.mas_leading).offset(30);
//        make.trailing.equalTo(cellView.mas_trailing).offset(-30);
//        make.height.equalTo(@(1));
//        make.bottom.equalTo(cellView.mas_bottom);
//    }];
    
}

#pragma mark - buttonAction
//调节开关状态
-(void)homeSwitchBtnAction:(UIButton *)sender{
    NSLog(@"%d",isOn);
    if ([self.delegate respondsToSelector:@selector(homeSwitch:aduroInfo:)]) {
        isOn = [self.delegate homeSwitch:(isOn) aduroInfo:self.aduroGroupInfo];
    }
//    BOOL isHomeOn = NO;
    [self setSwitchButtonImage:isOn switchButton:sender];
    
}

-(void)setSwitchButtonImage:(BOOL )setOn switchButton:(UIButton *)sender{
    if (setOn) {
        [sender setBackgroundImage:[UIImage imageNamed:@"Button_switch_on"] forState:UIControlStateNormal];
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"Button_switch_off"] forState:UIControlStateNormal];
    }
}

-(void)lampAlphaSliderAction:(UISlider *)sender{
//    if (_aduroGroupInfo.groupID == MAX_GROUP_ID) {
//        [[DeviceManager sharedManager]updateAllDeviceLevel:(float)sender.value*255.0f completionHandler:^(AduroSmartReturnCode code) {
//            
//        }];
//    }else{
//        //        static float value = 0;
//        //        float new_value = (float)sender.value;
//        //        float threshold = 0.05;
//        //
//        //        //如果数据相差大于0.05才发送改变亮度命令·······
//        //        if ( new_value > value + threshold || new_value < value - threshold ) {
//        //            value = new_value;
//        
//        //        if ([self.delegate respondsToSelector:@selector(homeDeviceChangeAlpha:)]) {
//        //            [self.delegate homeDeviceChangeAlpha:sender.value];
//        //        }
//        GroupManager *groupManager = [GroupManager sharedManager];
//        [groupManager ctrlGroup:self.aduroGroupInfo alphaValue:(float)sender.value*255.0f completionHandler:^(AduroSmartReturnCode code) {
//            
//        }];
//        //        }
//    }
}

-(void)lampAlphaSliderDownAction:(UISlider *)sender{
//    if ([self.delegate respondsToSelector:@selector(deviceChangeAlpha:)]) {
//        //        [self.delegate deviceChangeAlpha:sender.value];
//    }
//    if (_aduroGroupInfo.groupID == MAX_GROUP_ID) {
//        [[DeviceManager sharedManager]updateAllDeviceLevel:(float)sender.value*255.0f completionHandler:^(AduroSmartReturnCode code) {
//            
//        }];
//    }else{
//        GroupManager *groupManager = [GroupManager sharedManager];
//        [groupManager ctrlGroup:self.aduroGroupInfo alphaValue:((float)sender.value)*255.0f completionHandler:^(AduroSmartReturnCode code) {
//            
//        }];
//    }
}

-(void)lampAlphaSliderUpAction:(UISlider *)sender{
    //    if ([self.delegate respondsToSelector:@selector(deviceChangeAlpha:)]) {
    //        //        [self.delegate deviceChangeAlpha:sender.value];
    //    }
    if (_aduroGroupInfo.groupID == MAX_GROUP_ID) {
        [[DeviceManager sharedManager]updateAllDeviceLevel:(float)sender.value*255.0f completionHandler:^(AduroSmartReturnCode code) {
            
        }];
    }else{
        GroupManager *groupManager = [GroupManager sharedManager];
        [groupManager ctrlGroup:self.aduroGroupInfo alphaValue:((float)sender.value)*255.0f completionHandler:^(AduroSmartReturnCode code) {
            
        }];
    }
}

+(CGFloat)getCellHeight{
    return 100.f;
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
