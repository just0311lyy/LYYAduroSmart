//
//  ASSensorStateCell.m
//  AduroSmart
//
//  Created by MacBook on 16/8/1.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASSensorStateCell.h"

@implementation ASSensorStateCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}

-(void)getCellView{
    _cellView = [[UIView alloc] init];
//    _cellView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.contentView addSubview:_cellView];
    [_cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASSensorStateCell getCellHeight]));
    }];
    
    _sensorImgView = [[UIImageView alloc] init];
    [_cellView addSubview:_sensorImgView];
    [_sensorImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cellView.mas_top).offset(5);
        make.leading.equalTo(_cellView.mas_leading).offset(60);
        make.bottom.equalTo(_cellView.mas_bottom).offset(-5);
        make.width.equalTo(_sensorImgView.mas_height);
    }];
   
    _sensorNameLl = [[UILabel alloc] init];
    //    [self.textLabel setFont:[UIFont systemFontOfSize:14]];
    //    _textLabel.textAlignment = NSTextAlignmentLeft;
    [_cellView addSubview:_sensorNameLl];
    [_sensorNameLl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_sensorImgView.mas_top);
        make.leading.equalTo(_sensorImgView.mas_trailing).offset(5);
        make.trailing.equalTo(_cellView.mas_trailing);
        make.bottom.equalTo(_sensorImgView.mas_bottom);
    }];
    
    UIView *cellLineView = [[UIView alloc] init];
    cellLineView.backgroundColor = CELL_LIEN_COLOR;
    [_cellView addSubview:cellLineView];
    [cellLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_cellView.mas_leading).offset(20);
        make.trailing.equalTo(_cellView.mas_trailing);
        make.height.equalTo(@(1));
        make.bottom.equalTo(_cellView.mas_bottom);
    }];
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
