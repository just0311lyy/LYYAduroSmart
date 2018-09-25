//
//  ASListCell.m
//  AduroSmart
//
//  Created by MacBook on 16/7/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASListCell.h"


@implementation ASListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}

-(void)getCellView{
    _cellView = [[UIView alloc] init];
    _cellView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.contentView addSubview:_cellView];
    [_cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASListCell getCellHeight]));
    }];
    
    self.imgView = [[UIImageView alloc] init];
    [_cellView addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_cellView.mas_centerY);
        make.leading.equalTo(_cellView.mas_leading).offset(20);
        make.height.equalTo(@(45));
        make.width.equalTo(self.imgView.mas_height);
    }];
    
    UIImageView *arrowView = [[UIImageView alloc] init];
    arrowView.image = [UIImage imageNamed:@"arrow"];
    [_cellView addSubview:arrowView];
    [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_cellView.mas_trailing).offset(-20);
        make.centerY.equalTo(_cellView.mas_centerY);
        make.width.equalTo(@(16));
        make.height.equalTo(@(16));
    }];
    
    _txtLabel = [[UILabel alloc] init];
    //    [self.textLabel setFont:[UIFont systemFontOfSize:14]];
    //    _textLabel.textAlignment = NSTextAlignmentLeft;
    [_cellView addSubview:_txtLabel];
    [_txtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgView.mas_top);
        make.leading.equalTo(_imgView.mas_trailing).offset(10);
        make.trailing.equalTo(arrowView.mas_leading);
        make.bottom.equalTo(_imgView.mas_bottom);
    }];
    
    UIView *cellLineView = [[UIView alloc] init];
    cellLineView.backgroundColor = CELL_LIEN_COLOR;
    [_cellView addSubview:cellLineView];
    [cellLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.imgView.mas_leading).offset(5);
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
