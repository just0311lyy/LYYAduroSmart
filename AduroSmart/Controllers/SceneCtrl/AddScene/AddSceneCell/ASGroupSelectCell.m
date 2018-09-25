//
//  ASGroupSelectCell.m
//  AduroSmart
//
//  Created by MacBook on 16/8/10.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGroupSelectCell.h"
#import "BFPaperCheckbox.h"
#import "UIColor+BFPaperColors.h"

@interface ASGroupSelectCell ()<BFPaperCheckboxDelegate>{
    UILabel *_groupNameLabel;
    UILabel *_groupDescriptionLabel;
    
    BFPaperCheckbox *_groupCheckbox;
    UIButton *_groupShowDetailButton;
    
    AduroGroup *_aduroGroupInfo;
//    BOOL isGroupOn;
    
//    UIImageView *_checkBoxImageView;
}
-(void)getCellView;
@end

@implementation ASGroupSelectCell

@synthesize aduroGroupInfo = _aduroGroupInfo;

-(void)setGroupCheckboxHidden:(BOOL )isHidden{
    [_groupCheckbox setHidden:isHidden];
    
    [_groupShowDetailButton setHidden:isHidden];
    
}

-(AduroGroup *)aduroGroupInfo{
    return _aduroGroupInfo;
}

-(void)setAduroGroupInfo:(AduroGroup *)aduroGroupInfo{
    if (_aduroGroupInfo != aduroGroupInfo) {
        _aduroGroupInfo = nil;
        _aduroGroupInfo = aduroGroupInfo;
        NSArray *array = [aduroGroupInfo.groupName componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
        NSString *name = [array firstObject];
        //        NSString *typeId = [array lastObject];
        [_groupNameLabel setText:name];
        [_groupDescriptionLabel setText:[NSString stringWithFormat:@"%lx",(long)_aduroGroupInfo.groupSubDeviceIDArray.count]];
        _groupCheckbox.tag = (NSInteger)_aduroGroupInfo.groupID;
        [_groupCheckbox uncheckAnimated:YES];
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
    [_groupCheckbox setIsManual:isManual];
    if (isChecked) {
        [_groupCheckbox checkAnimated:YES];
    }else{
        [_groupCheckbox uncheckAnimated:YES];
    }
    
}

-(void)getCellView{
    UIView *cellView = [[UIView alloc]init];
    [self.contentView addSubview:cellView];
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASGroupSelectCell getCellHeight]));
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

    _groupCheckbox = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(imgView.frame.size.width - 50, 0, 25 * 2, 25 * 2)];
    _groupCheckbox.delegate = self;
    _groupCheckbox.tapCirclePositiveColor = [UIColor paperColorAmber]; // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    _groupCheckbox.tapCircleNegativeColor = [UIColor paperColorRed];   // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    _groupCheckbox.checkmarkColor = LOGO_COLOR;
    [cellView addSubview:_groupCheckbox];
    [_groupCheckbox mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    _groupNameLabel = [[UILabel alloc]init];
    [_groupNameLabel setFont:[UIFont systemFontOfSize:16]];
    [imgView addSubview:_groupNameLabel];
    [_groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_top).offset(20);
        make.leading.equalTo(imgView.mas_leading).offset(30);
        make.height.equalTo(@(20));
        make.trailing.equalTo(_groupCheckbox.mas_leading);
    }];
    
    _groupDescriptionLabel = [[UILabel alloc]init];
    [_groupDescriptionLabel setFont:[UIFont systemFontOfSize:12]];
    [_groupDescriptionLabel setTextColor:[UIColor grayColor]];
    [imgView addSubview:_groupDescriptionLabel];
    [_groupDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_groupNameLabel.mas_bottom);
        make.leading.equalTo(imgView.mas_leading).offset(30);
        make.trailing.equalTo(_groupCheckbox.mas_leading);
        make.height.equalTo(@(20));
    }];
    
    _groupShowDetailButton = [[UIButton alloc]init];
    [_groupShowDetailButton addTarget:self action:@selector(showDetailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [imgView addSubview:_groupShowDetailButton];
    [_groupShowDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_top);
        make.leading.equalTo(imgView.mas_leading);
        make.trailing.equalTo(_groupCheckbox.mas_leading);
        make.bottom.equalTo(imgView.mas_bottom);
    }];
    
//    UIView *separatorView = [[UIView alloc]init];
//    [separatorView setBackgroundColor:CELL_LIEN_COLOR];
//    [cellView addSubview:separatorView];
//    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(cellView.mas_leading).offset(20);
//        make.trailing.equalTo(cellView.mas_trailing);
//        make.height.equalTo(@(1.0f));
//        make.bottom.equalTo(cellView.mas_bottom);
//    }];
    
}

//-(void)setSwitchButtonImage:(BOOL )setOn switchButton:(UIButton *)sender{
//    if (setOn) {
//        [sender setImage:[UIImage imageNamed:@"按钮-开"] forState:UIControlStateNormal];
//    }else{
//        [sender setImage:[UIImage imageNamed:@"按钮-关"] forState:UIControlStateNormal];
//    }
//}

-(void)showDetailButtonAction:(UIButton *)sender{
    if (_groupShowDetailButton.isHidden) {
        return;
    }
}

+(CGFloat)getCellHeight{
    return 70.f;
}

#pragma mark - BFPaperCheckbox Delegate
- (void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox
{
    if (_groupShowDetailButton.isHidden) {
        return;
    }
    [self.delegate selectedAduroGroupInfo:self.aduroGroupInfo];    
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
