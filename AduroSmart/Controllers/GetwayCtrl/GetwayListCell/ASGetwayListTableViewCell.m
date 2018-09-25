//
//  ASGetwayListTableViewCell.m
//  AduroSmart
//
//  Created by MacBook on 16/7/14.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASGetwayListTableViewCell.h"

@implementation ASGetwayListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self getCellView];
    }
    return self;
}

-(void)getCellView{
    UIView *cellView = [[UIView alloc] init];
    cellView.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.contentView addSubview:cellView];
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.equalTo(@([ASGetwayListTableViewCell getCellHeight]));
    }];

    //背景图
    UIImageView *imgView = [[UIImageView alloc] init];
    UIImage *img = [UIImage imageNamed:@"img_bg"];
    CGFloat top = 10; // 顶端盖高度
    CGFloat bottom = 10 ; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    img = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    imgView.image = img;
    [cellView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cellView.mas_top).offset(2);
        make.leading.equalTo(cellView.mas_leading).offset(5);
        make.trailing.equalTo(cellView.mas_trailing).offset(-5);
        make.bottom.equalTo(cellView.mas_bottom).offset(-2);
    }];

    //IP
    UILabel *IPLable = [[UILabel alloc] init];
    [IPLable setFont:[UIFont systemFontOfSize:14]];
    [IPLable setText:@"IP:"];
    IPLable.textAlignment = NSTextAlignmentLeft;
    [imgView addSubview:IPLable];
    [IPLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_top).offset(8);
        make.leading.equalTo(imgView.mas_leading).offset(20); //首部
        make.height.equalTo(@(32));
        make.width.equalTo(@(60));
    }];
    
    self.getwayIpNameLb = [[UILabel alloc] init];
    [self.getwayIpNameLb setFont:[UIFont systemFontOfSize:14]];
    self.getwayIpNameLb.textAlignment = NSTextAlignmentLeft;
    [imgView addSubview:self.getwayIpNameLb];
    [self.getwayIpNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(IPLable.mas_top);
        make.leading.equalTo(IPLable.mas_trailing).offset(2); //首部
        make.trailing.equalTo(imgView.mas_trailing).offset(-10);
        make.height.equalTo(IPLable.mas_height);
    }];

    //id
    UILabel *numberLable = [[UILabel alloc] init];
    [numberLable setFont:[UIFont systemFontOfSize:14]];
    [numberLable setText:[ASLocalizeConfig localizedString:@"编号:"]];
    numberLable.textAlignment = NSTextAlignmentLeft;
    [imgView addSubview:numberLable];
    [numberLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(imgView.mas_bottom).offset(-8);
        make.leading.equalTo(IPLable.mas_leading);
        make.trailing.equalTo(IPLable.mas_trailing);
        make.height.equalTo(IPLable.mas_height);
    }];
    
    self.getwayNumberNameLb = [[UILabel alloc] init];
    [self.getwayNumberNameLb setFont:[UIFont systemFontOfSize:14]];
    self.getwayNumberNameLb.textAlignment = NSTextAlignmentLeft;
    [imgView addSubview:self.getwayNumberNameLb];
    [self.getwayNumberNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(numberLable.mas_trailing).offset(2); //首部
        make.trailing.equalTo(imgView.mas_trailing).offset(-10);
        make.bottom.equalTo(numberLable.mas_bottom);
        make.height.equalTo(numberLable.mas_height);
    }];
}


+(CGFloat)getCellHeight{
    return 80;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
