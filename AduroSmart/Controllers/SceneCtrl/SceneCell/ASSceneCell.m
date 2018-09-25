//
//  ASSceneCell.m
//  AduroSmart
//
//  Created by MacBook on 16/7/26.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSceneCell.h"

@interface ASSceneCell ()<UIAlertViewDelegate>{
    //开关是否开启
    BOOL isSceneOn;
}
-(void)getCellView;
@end
@implementation ASSceneCell

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
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASSceneCell getCellHeight]));
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
        make.leading.equalTo(cellView.mas_leading).offset(5);
        make.trailing.equalTo(cellView.mas_trailing).offset(-5);
        make.bottom.equalTo(cellView.mas_bottom);
    }];
    
//    //设备图标
//    _homeTypeImgView = [UIImageView new];
//    [imgView addSubview:_homeTypeImgView];
//    [_homeTypeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(imgView.mas_centerY);
//        make.leading.equalTo(imgView.mas_leading).offset(20); //首部
//        make.width.equalTo(@(50));
//        make.height.equalTo(_homeTypeImgView.mas_width);
//    }];
//    
//    //设备开关按钮
//    _sceneSwitchBtn = [[UIButton alloc] init];
//    [_sceneSwitchBtn setImage:[UIImage imageNamed:@"Button_switch_on"] forState:UIControlStateNormal];
//    [_sceneSwitchBtn addTarget:self action:@selector(sceneSwitchBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [cellView addSubview:_sceneSwitchBtn];
//    [_sceneSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(cellView.mas_centerY);
//        make.trailing.equalTo(cellView.mas_trailing).offset(-20); //尾部
//        make.width.equalTo(@(42));
//        make.height.equalTo(_sceneSwitchBtn.mas_width);
//    }];
    

    
    //场景名
    _sceneNameLb = [[UILabel alloc]init];
    [_sceneNameLb setFont:[UIFont systemFontOfSize:16]];
    [imgView addSubview:_sceneNameLb];
    [_sceneNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imgView.mas_centerY);
        make.leading.equalTo(imgView.mas_leading).offset(30);
        make.trailing.equalTo(imgView.mas_trailing).offset(-100);
        make.height.equalTo(@(30));
    }];
    
    _netStateLb = [UILabel new];
//    [_netStateLb setText:[ASLocalizeConfig localizedString:@"激活"]];
    [_netStateLb setTextAlignment:NSTextAlignmentRight];
    [_netStateLb setFont:[UIFont systemFontOfSize:12]];
    [_netStateLb setTextColor:[UIColor lightGrayColor]];
    [imgView addSubview:_netStateLb];
    [_netStateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sceneNameLb.mas_centerY);
        make.trailing.equalTo(imgView.mas_trailing).offset(-10);
        make.height.equalTo(_sceneNameLb.mas_height);
        make.leading.equalTo(_sceneNameLb.mas_trailing);
    }];
}

-(void)sceneSwitchBtnAction:(UIButton *)sender{
//    NSLog(@"%d",isSceneOn);
//    isSceneOn = [self.delegate sceneSwitch:(isSceneOn) aduroInfo:self.aduroSceneInfo];
//    NSLog(@"%d",isSceneOn);
//    [self setSwitchButtonImage:isSceneOn switchButton:sender];
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"激活"] message:[ASLocalizeConfig localizedString:@"是否激活该场景"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"确定"] otherButtonTitles:[ASLocalizeConfig localizedString:@"取消"],nil];
    [alter show];
    
    NSLog(@"场景状态激活结果：%@",sender);
}

-(void)setSwitchButtonImage:(BOOL )setOn switchButton:(UIButton *)sender{
    if (setOn) {
        [sender setImage:[UIImage imageNamed:@"Button_switch_on"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[UIImage imageNamed:@"Button_switch_off"] forState:UIControlStateNormal];
    }
}

//-(void)showDetailSceneBtnAction:(UIButton *)sender{
//    [self.delegate sceneShowDetailWithGroupInfo:self.aduroSceneInfo];
//}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        NSLog(@"cell点击的是取消按钮:index=1");
        
    }else if(0 == buttonIndex){
        
        NSLog(@"cell点击的是确定按钮:index=0");
    }
}

+(CGFloat)getCellHeight{
    return 75.f;
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
