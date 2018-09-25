//
//  ASDeviceSelectTableViewCell.m
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASDeviceSelectTableViewCell.h"

@interface ASDeviceSelectTableViewCell () {
    AduroDevice *_aduroDeviceInfo;
    BOOL _isSelect;
}
-(void)getCellView;
@end


@implementation ASDeviceSelectTableViewCell

@synthesize aduroDeviceInfo = _aduroDeviceInfo;
-(AduroDevice *)aduroDeviceInfo{
    return _aduroDeviceInfo;
}

-(void)setAduroDeviceInfo:(AduroDevice *)aduroDeviceInfo{
    if (_aduroDeviceInfo != aduroDeviceInfo) {
        _aduroDeviceInfo = nil;
        _aduroDeviceInfo = aduroDeviceInfo;

        [_txtLabel setText:aduroDeviceInfo.deviceName];
        _isSelect = NO;
        [self setSelectButtonImage:_isSelect selectButton:_selectBtn];
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
        make.height.equalTo(@([ASDeviceSelectTableViewCell getCellHeight]));
    }];
    
    self.imgView = [[UIImageView alloc] init];
    [cellView addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cellView.mas_top).offset(10);
        make.leading.equalTo(cellView.mas_leading).offset(10);
        make.width.equalTo(self.imgView.mas_height);
        make.bottom.equalTo(cellView.mas_bottom).offset(-10);
    }];
    
    _selectBtn = [[UIButton alloc] init];
    [_selectBtn setImage:[UIImage imageNamed:@"btn_unchoise"] forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(deviceSelectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cellView addSubview:_selectBtn];
    [_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(cellView.mas_trailing).offset(-20);
        make.centerY.equalTo(cellView.mas_centerY);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    self.txtLabel = [[UILabel alloc] init];
    //    [self.textLabel setFont:[UIFont systemFontOfSize:14]];
    //    _textLabel.textAlignment = NSTextAlignmentLeft;
    [cellView addSubview:self.txtLabel];
    [self.txtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_top);
        make.leading.equalTo(self.imgView.mas_trailing);
        make.trailing.equalTo(_selectBtn.mas_leading);
        make.bottom.equalTo(self.imgView.mas_bottom);
    }];
    
    UIView *cellLineView = [[UIView alloc] init];
    cellLineView.backgroundColor = CELL_LIEN_COLOR;
    [cellView addSubview:cellLineView];
    [cellLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(cellView.mas_leading);
        make.trailing.equalTo(cellView.mas_trailing);
        make.height.equalTo(@(1));
        make.bottom.equalTo(cellView.mas_bottom);
    }];
}

#pragma mark - buttonAction
//调节开关状态
-(void)deviceSelectButtonAction:(UIButton *)sender{
    NSLog(@"%d",_isSelect);
    _isSelect = [self.delegate deviceSelect:_isSelect AduroDeviceInfo:_aduroDeviceInfo];
    NSLog(@"%d",_isSelect);
    [self setSelectButtonImage:_isSelect selectButton:sender];
    
}

-(void)setSelectButtonImage:(BOOL )setOn selectButton:(UIButton *)sender{
    if (setOn) {
        [sender setImage:[UIImage imageNamed:@"btn_choise"] forState:UIControlStateNormal];
        
    }else{
        [sender setImage:[UIImage imageNamed:@"btn_unchoise"] forState:UIControlStateNormal];
    }
}



+(CGFloat)getCellHeight{
    return 70;
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
