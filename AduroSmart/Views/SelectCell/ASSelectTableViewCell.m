//
//  ASSelectTableViewCell.m
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSelectTableViewCell.h"
#import "NSString+Wrapper.h"
@interface ASSelectTableViewCell () {
   
    //是否添加该设备
    BOOL isSelect;

}
-(void)getCellView;
@end

@implementation ASSelectTableViewCell

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
        make.height.equalTo(@([ASSelectTableViewCell getCellHeight]));
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
    [_selectBtn setImage:[UIImage imageNamed:@"check_select_btn"] forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cellView addSubview:_selectBtn];
    [_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(cellView.mas_trailing).offset(-10);
        make.centerY.equalTo(cellView.mas_centerY);
        make.width.equalTo(@(35));
        make.height.equalTo(@(35));
    }];
    
    self.txtLabel = [[UILabel alloc] init];
    [cellView addSubview:self.txtLabel];
    [self.txtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_top);
        make.leading.equalTo(self.imageView.mas_trailing);
        make.trailing.equalTo(_selectBtn.mas_leading);
        make.bottom.equalTo(self.imageView.mas_centerY);
    }];
    
    self.txtDetialLabel = [[UILabel alloc] init];
    //    [self.textLabel setFont:[UIFont systemFontOfSize:14]];
    //    _textLabel.textAlignment = NSTextAlignmentLeft;
    [cellView addSubview:self.txtDetialLabel];
    [self.txtDetialLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_centerY);
        make.leading.equalTo(self.imageView.mas_trailing);
        make.trailing.equalTo(_selectBtn.mas_leading);
        make.bottom.equalTo(self.imageView.mas_bottom);
    }];

    UIView *cellLineView = [[UIView alloc] init];
    cellLineView.backgroundColor = [UIColor lightGrayColor];
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
-(void)selectButtonAction:(UIButton *)sender{

    [self setSelectButtonImage:isSelect selectButton:sender];
    
}

-(void)setSelectButtonImage:(BOOL )setOn selectButton:(UIButton *)sender{
    if (setOn) {
        isSelect = NO;
        [sender setImage:[UIImage imageNamed:@"check_select_btn"] forState:UIControlStateNormal];
    }else{
        isSelect = YES;
        [sender setImage:[UIImage imageNamed:@"check_unselect_btn"] forState:UIControlStateNormal];
    }
}



+(CGFloat)getCellHeight{
    return 60;
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
