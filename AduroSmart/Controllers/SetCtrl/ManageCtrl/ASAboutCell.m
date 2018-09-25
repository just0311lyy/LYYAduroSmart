//
//  ASAboutCell.m
//  AduroSmart
//
//  Created by MacBook on 16/8/25.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASAboutCell.h"

@implementation ASAboutCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}

-(void)getCellView{
    _cellView = [[UIView alloc] init];
    _cellView.backgroundColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_cellView];
    [_cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASAboutCell getCellHeight]));
    }];

    _nameLabel = [[UILabel alloc] init];
    //    [self.textLabel setFont:[UIFont systemFontOfSize:14]];
    //    _textLabel.textAlignment = NSTextAlignmentLeft;
    [_nameLabel setTextColor:[UIColor whiteColor]];
    [_cellView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_cellView.mas_centerY);
        make.leading.equalTo(_cellView.mas_leading).offset(10);
        make.trailing.equalTo(_cellView.mas_centerX);
        make.height.equalTo(@(25));
    }];
    
    _modelNumberLabel = [[UILabel alloc] init];
    [_modelNumberLabel setTextColor:[UIColor whiteColor]];
    [_modelNumberLabel setFont:[UIFont systemFontOfSize:14]];
    _modelNumberLabel.textAlignment = NSTextAlignmentRight;
    [_cellView addSubview:_modelNumberLabel];
    [_modelNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_top);
        make.leading.equalTo(_cellView.mas_centerX);
        make.trailing.equalTo(_cellView.mas_trailing);
        make.bottom.equalTo(_nameLabel.mas_bottom);
    }];
    
    _IDNumberLabel = [[UILabel alloc] init];
    [_IDNumberLabel setTextColor:[UIColor whiteColor]];
    [_IDNumberLabel setFont:[UIFont systemFontOfSize:12]];
    _IDNumberLabel.textAlignment = NSTextAlignmentRight;
    [_cellView addSubview:_IDNumberLabel];
    [_IDNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_cellView.mas_top);
        make.leading.equalTo(_modelNumberLabel.mas_leading);
        make.trailing.equalTo(_modelNumberLabel.mas_trailing);
        make.height.equalTo(_modelNumberLabel.mas_height);
    }];
 
    _versionLabel = [[UILabel alloc] init];
    [_versionLabel setTextColor:[UIColor whiteColor]];
    [_versionLabel setFont:[UIFont systemFontOfSize:12]];
    _versionLabel.textAlignment = NSTextAlignmentRight;
    [_cellView addSubview:_versionLabel];
    [_versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_cellView.mas_bottom);
        make.leading.equalTo(_modelNumberLabel.mas_leading).offset(-15);
        make.trailing.equalTo(_modelNumberLabel.mas_trailing);
        make.height.equalTo(_modelNumberLabel.mas_height);
    }];
    
}


+(CGFloat)getCellHeight{
    return 75;
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
